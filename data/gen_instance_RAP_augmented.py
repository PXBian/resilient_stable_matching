#!/usr/bin/env python3
"""
RAP instance generator with data augmentation support for large n (10000+)

This script extends gen_instance_RAP.py to support large n values by:
1. Generating synthetic papers based on existing paper topic distribution
2. Generating synthetic reviewers based on existing reviewer topic distribution
3. Generating synthetic COI pairs based on existing COI patterns

Output format:
- For n=5000, outputs 10000 lines (5000 + 5000)
- First n lines: X side (papers) preference lists
- Next n lines: Y side (reviewers) preference lists
- Each line contains n integers (0-based indices) separated by spaces
- No headers or extra information

Usage
-----
python3 gen_instance_RAP_augmented.py \
  --author-dir raw/RAP_author \
  --paper-dir raw/RAP_pub \
  --coi-file raw/RAP_COI_pairs.csv \
  -n 5000 \
  --seed 42 \
  --strategy top \
  --temp-x 0.35 \
  --temp-y 0.35 \
  --out-txt RAP_5000_instance.txt \
  --augment true
"""

import argparse
import os
import re
import random
import math
import csv
from collections import defaultdict
from typing import Dict, List, Tuple, Set
import numpy as np

# Import functions from original script by reading and executing
# We'll copy the necessary functions directly to avoid import issues
def topic_from_filename(fn: str) -> str:
    """Extract topic label: graph-T16_sub0.net -> 'T16'; graph-16.net -> 'T16'."""
    m = re.search(r"[T\-](\d+)", fn)
    return f"T{m.group(1)}" if m else os.path.splitext(fn)[0]

def sniff_delim(path: str) -> str:
    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        sample = f.read(4096)
    try:
        dialect = csv.Sniffer().sniff(sample, delimiters=",\t;|")
        return dialect.delimiter
    except Exception:
        return ","

def parse_author_net_folder(author_dir: str) -> Dict[str, Set[str]]:
    """Read ALL *.net files in author_dir. Return: author_topics_by_name (LOWERCASED names) -> set(topic_labels)"""
    author_topics: Dict[str, Set[str]] = defaultdict(set)
    files = [f for f in os.listdir(author_dir) if f.lower().endswith(".net")]
    if not files:
        raise ValueError(f"No .net files found in author_dir={author_dir}")
    for fn in files:
        topic = topic_from_filename(fn)
        path = os.path.join(author_dir, fn)
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            in_vertices = False
            for line in f:
                s = line.strip()
                if not s:
                    continue
                low = s.lower()
                if low.startswith("*vertices"):
                    in_vertices = True
                    continue
                if low.startswith("*edges") or low.startswith("*arcs") or low.startswith("*triangles"):
                    in_vertices = False
                    continue
                if in_vertices:
                    m_id = re.match(r"^(\d+)\s+", s)
                    if not m_id:
                        continue
                    m_name = re.search(r'"([^"]+)"', s)
                    if not m_name:
                        continue
                    name = m_name.group(1).strip().lower()
                    if name:
                        author_topics[name].add(topic)
    return author_topics

def parse_paper_net_folder(paper_dir: str) -> Dict[str, Dict[str, str]]:
    """Read ALL *.net files in paper_dir. Return: papers: dict[paper_id('Txx:vid')] -> {'title': str, 'topic': str}"""
    papers: Dict[str, Dict[str, str]] = {}
    files = [f for f in os.listdir(paper_dir) if f.lower().endswith(".net")]
    if not files:
        raise ValueError(f"No .net files found in paper_dir={paper_dir}")
    for fn in files:
        topic = topic_from_filename(fn)
        path = os.path.join(paper_dir, fn)
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            in_vertices = False
            for line in f:
                s = line.strip()
                if not s:
                    continue
                low = s.lower()
                if low.startswith("*vertices"):
                    in_vertices = True
                    continue
                if low.startswith("*edges") or low.startswith("*arcs"):
                    in_vertices = False
                    continue
                if in_vertices:
                    m_id = re.match(r"^(\d+)\s+", s)
                    if not m_id:
                        continue
                    vid = m_id.group(1)
                    m_title = re.search(r'"([^"]+)"', s)
                    title = m_title.group(1).strip() if m_title else ""
                    pid = f"{topic}_{vid}"
                    papers[pid] = {"title": title, "topic": topic}
    return papers

def reviewer_modal_topic(topics: Set[str]) -> str:
    """Pick deterministic single topic label for a reviewer (if many, smallest lex)."""
    if not topics:
        return "unknown"
    return sorted(topics)[0]

def assign_reviewer_ids(author_topics_by_name: Dict[str, Set[str]]) -> Tuple[Dict[str, str], Dict[str, str], Dict[str, Set[str]], Dict[str, str]]:
    """Given LOWERCASED names, assign stable reviewer IDs A000001, A000002, ..."""
    names = sorted(author_topics_by_name.keys())
    width = max(6, len(str(len(names))))
    name_to_id: Dict[str, str] = {}
    id_to_name: Dict[str, str] = {}
    author_topics_by_id: Dict[str, Set[str]] = {}
    normname_to_id: Dict[str, str] = {}
    for i, name in enumerate(names, start=1):
        rid = f"A{str(i).zfill(width)}"
        name_to_id[name] = rid
        id_to_name[rid] = name
        author_topics_by_id[rid] = set(author_topics_by_name[name])
        normname_to_id[name] = rid
    return name_to_id, id_to_name, author_topics_by_id, normname_to_id

def load_coi_for_subset(
    coi_path: str,
    paper_ids_set: Set[str],
    reviewer_ids_set: Set[str],
    normname_to_id: Dict[str, str],
) -> Dict[str, Set[str]]:
    """Stream the COI file once and keep only pairs for selected papers+reviewers."""
    if not coi_path:
        return {}
    if not os.path.exists(coi_path):
        raise FileNotFoundError(f"COI file not found: {coi_path}")
    delim = sniff_delim(coi_path)
    coi: Dict[str, Set[str]] = defaultdict(set)
    with open(coi_path, "r", encoding="utf-8", errors="ignore") as f:
        r = csv.reader(f, delimiter=delim)
        try:
            header = next(r)
        except StopIteration:
            return {}
        cols = [h.strip().lower() for h in header]
        try:
            c_pid = cols.index("paper_id")
        except ValueError:
            raise ValueError("COI file header must include 'paper_id'")
        c_rid = cols.index("reviewer_id") if "reviewer_id" in cols else None
        c_rnm = cols.index("reviewer_name") if "reviewer_name" in cols else None
        if c_rid is None and c_rnm is None:
            raise ValueError("COI file needs 'reviewer_id' or 'reviewer_name' column")
        for row in r:
            if len(row) <= c_pid:
                continue
            pid = row[c_pid].strip()
            if pid not in paper_ids_set:
                continue
            rid = None
            if c_rid is not None and len(row) > c_rid:
                cand = row[c_rid].strip()
                if cand in reviewer_ids_set:
                    rid = cand
            if rid is None and c_rnm is not None and len(row) > c_rnm:
                nm = row[c_rnm].strip().lower()
                rid = normname_to_id.get(nm)
                if rid and rid not in reviewer_ids_set:
                    rid = None
            if rid:
                coi[pid].add(rid)
    return coi

def gumbel():
    u = random.random()
    u = max(u, 1e-12)
    return -math.log(-math.log(u))

def gumbel_sort(ids: List[str], base_scores: Dict[str, float], temperature: float) -> List[str]:
    if temperature <= 0:
        raise ValueError("temperature must be > 0")
    noisy = []
    invT = 1.0 / temperature
    for x in ids:
        s = base_scores.get(x, 0.0)
        noisy.append((-(s * invT + gumbel()), x))
    noisy.sort()
    return [x for _, x in noisy]


def gumbel_sort_partition(high_ids: List[str], low_ids: List[str], temperature: float) -> List[str]:
    """
    Sort a binary-score candidate set without materializing a full base-score dict.
    `high_ids` get base score 1.0, `low_ids` get base score 0.0.
    """
    if temperature <= 0:
        raise ValueError("temperature must be > 0")
    noisy = []
    invT = 1.0 / temperature
    for x in high_ids:
        noisy.append((-(1.0 * invT + gumbel()), x))
    for x in low_ids:
        noisy.append((-(0.0 + gumbel()), x))
    noisy.sort()
    return [x for _, x in noisy]

def verify_complete_no_ties(X_prefs, Y_prefs, paper_ids, reviewers):
    def is_complete(pref_dict, universe):
        S = set(universe)
        return all(len(lst) == len(universe) and set(lst) == S for lst in pref_dict.values())
    def has_ties(pref_dict):
        return any(len(lst) != len(set(lst)) for lst in pref_dict.values())
    return {
        "complete_x_over_y": is_complete(X_prefs, reviewers),
        "complete_y_over_x": is_complete(Y_prefs, paper_ids),
        "no_ties_x_over_y": not has_ties(X_prefs),
        "no_ties_y_over_x": not has_ties(Y_prefs),
    }

# ---------------- Data Augmentation ----------------

def generate_synthetic_papers(
    existing_papers: Dict[str, Dict[str, str]],
    target_count: int,
    seed: int,
) -> Dict[str, Dict[str, str]]:
    """
    Generate synthetic papers by sampling from existing paper topic distribution.
    """
    random.seed(seed)
    np.random.seed(seed)
    
    # Analyze topic distribution
    topic_distribution = defaultdict(int)
    for pid, info in existing_papers.items():
        topic_distribution[info["topic"]] += 1
    
    # Calculate topic probabilities
    total_papers = len(existing_papers)
    topic_probs = {topic: count / total_papers for topic, count in topic_distribution.items()}
    topics = list(topic_probs.keys())
    probs = [topic_probs[t] for t in topics]
    
    # Generate synthetic papers
    synthetic = {}
    existing_list = list(existing_papers.items())
    
    for i in range(len(existing_papers), target_count):
        # Sample topic based on distribution
        topic = np.random.choice(topics, p=probs)
        
        # Sample a base paper from the same topic for title pattern
        base_papers = [(pid, info) for pid, info in existing_list if info["topic"] == topic]
        if base_papers:
            base_pid, base_info = random.choice(base_papers)
            # Generate synthetic title
            title = f"Synthetic Paper {i+1} (Topic {topic})"
        else:
            title = f"Synthetic Paper {i+1} (Topic {topic})"
        
        # Generate paper ID
        pid = f"{topic}_SYN{i}"
        synthetic[pid] = {"title": title, "topic": topic}
    
    return synthetic

def generate_synthetic_reviewers(
    existing_reviewers: List[str],
    author_topics_by_id: Dict[str, Set[str]],
    target_count: int,
    seed: int,
) -> Tuple[List[str], Dict[str, Set[str]]]:
    """
    Generate synthetic reviewers by sampling from existing reviewer topic distribution.
    Returns: (new_reviewer_ids, new_author_topics_by_id)
    """
    random.seed(seed + 1)  # Different seed
    np.random.seed(seed + 1)
    
    # Analyze topic distribution
    topic_counts = defaultdict(int)
    reviewer_topic_sets = []
    for rid in existing_reviewers:
        topics = author_topics_by_id[rid]
        reviewer_topic_sets.append(topics)
        for topic in topics:
            topic_counts[topic] += 1
    
    # Calculate topic probabilities
    total_topics = sum(topic_counts.values())
    if total_topics == 0:
        # Fallback: assign random topics
        all_topics = set()
        for topics in reviewer_topic_sets:
            all_topics.update(topics)
        if not all_topics:
            all_topics = {"T16", "T24", "T75"}  # Default topics
    
    # Generate synthetic reviewers
    synthetic_reviewers = []
    new_author_topics_by_id = {}
    
    # Determine ID width
    width = max(6, len(str(target_count)))
    
    for i in range(len(existing_reviewers), target_count):
        rid = f"A{str(i+1).zfill(width)}"
        synthetic_reviewers.append(rid)
        
        # Sample topics based on existing distribution
        # Sample 1-3 topics per reviewer (based on existing pattern)
        num_topics = np.random.choice([1, 2, 3], p=[0.5, 0.3, 0.2])
        
        # Sample topics weighted by frequency
        if topic_counts:
            topics_list = list(topic_counts.keys())
            weights = [topic_counts[t] for t in topics_list]
            total_weight = sum(weights)
            if total_weight > 0:
                probs = [w / total_weight for w in weights]
                selected_topics = set(np.random.choice(topics_list, size=min(num_topics, len(topics_list)), 
                                                       replace=False, p=probs))
            else:
                # Fallback: sample from existing reviewers
                base_reviewer = random.choice(existing_reviewers)
                selected_topics = set(author_topics_by_id[base_reviewer])
        else:
            # Fallback: use topics from a random existing reviewer
            base_reviewer = random.choice(existing_reviewers)
            selected_topics = set(author_topics_by_id[base_reviewer])
        
        new_author_topics_by_id[rid] = selected_topics
    
    return synthetic_reviewers, new_author_topics_by_id

def generate_synthetic_coi(
    paper_ids: List[str],
    reviewers: List[str],
    papers: Dict[str, Dict[str, str]],
    author_topics_by_id: Dict[str, Set[str]],
    existing_coi: Dict[str, Set[str]],
    seed: int,
) -> Dict[str, Set[str]]:
    """
    Generate synthetic COI pairs based on:
    1. Existing COI patterns (topic overlap, frequency)
    2. Random sampling with topic-based bias
    """
    random.seed(seed + 2)
    np.random.seed(seed + 2)
    
    # Analyze existing COI patterns
    coi_count = sum(len(s) for s in existing_coi.values())
    total_pairs = len(paper_ids) * len(reviewers)
    coi_rate = coi_count / total_pairs if total_pairs > 0 else 0.01  # Default 1% if no existing COI
    
    # If no existing COI, use a small default rate
    if coi_rate == 0:
        coi_rate = 0.01  # 1% default
    
    # Calculate topic-based COI probability
    # Papers and reviewers with same topic are more likely to have COI
    topic_coi_rate = coi_rate * 2.0  # Same topic: 2x base rate
    
    synthetic_coi = defaultdict(set)
    
    # Copy existing COI
    for pid, reviewer_set in existing_coi.items():
        if pid in paper_ids:
            synthetic_coi[pid].update(r for r in reviewer_set if r in reviewers)
    
    # Generate additional COI for synthetic papers/reviewers
    for pid in paper_ids:
        if pid not in synthetic_coi:
            synthetic_coi[pid] = set()
        
        ptopic = papers[pid]["topic"]
        
        for rid in reviewers:
            if rid in synthetic_coi[pid]:
                continue  # Already has COI
            
            # Check if same topic
            reviewer_topics = author_topics_by_id.get(rid, set())
            same_topic = ptopic in reviewer_topics
            
            # Determine COI probability
            prob = topic_coi_rate if same_topic else coi_rate
            
            # Sample COI
            if random.random() < prob:
                synthetic_coi[pid].add(rid)
    
    return dict(synthetic_coi)

# ---------------- Enhanced Selection ----------------

def select_sets_augmented(
    papers: Dict[str, Dict[str, str]],
    author_topics_by_id: Dict[str, Set[str]],
    n: int,
    strategy: str,
    seed: int,
    augment: bool = True,
) -> Tuple[List[str], List[str], Dict[str, Dict[str, str]], Dict[str, Set[str]]]:
    """
    Select entities, augmenting if needed to reach target n.
    Returns: (paper_ids, reviewers, augmented_papers, augmented_author_topics_by_id)
    """
    rng = random.Random(seed)
    
    paper_ids = list(papers.keys())
    reviewers = list(author_topics_by_id.keys())
    
    # Augment if needed
    if augment:
        if len(paper_ids) < n:
            print(f"Augmenting papers: have {len(paper_ids)}, need {n}")
            synthetic_papers = generate_synthetic_papers(papers, n, seed)
            papers.update(synthetic_papers)
            paper_ids = list(papers.keys())
            print(f"  Generated {len(synthetic_papers)} synthetic papers")
        
        if len(reviewers) < n:
            print(f"Augmenting reviewers: have {len(reviewers)}, need {n}")
            synthetic_reviewers, synthetic_topics = generate_synthetic_reviewers(
                reviewers, author_topics_by_id, n, seed
            )
            reviewers.extend(synthetic_reviewers)
            author_topics_by_id.update(synthetic_topics)
            print(f"  Generated {len(synthetic_reviewers)} synthetic reviewers")
    
    if len(paper_ids) < n:
        raise ValueError(f"Not enough papers: {len(paper_ids)} < n={n}")
    if len(reviewers) < n:
        raise ValueError(f"Not enough reviewers: {len(reviewers)} < n={n}")
    
    # Select n papers and n reviewers
    if strategy == "random":
        paper_ids = rng.sample(paper_ids, n)
        reviewers = rng.sample(reviewers, n)
    elif strategy == "top":
        paper_ids = sorted(paper_ids)[:n]
        reviewers = sorted(reviewers, key=lambda r: (-len(author_topics_by_id.get(r, set())), r))[:n]
    else:
        raise ValueError("strategy must be one of {'top','random'}")
    
    return paper_ids, reviewers, papers, author_topics_by_id

# ---------------- Optimized Preferences Building ----------------

def build_preferences_optimized(
    paper_ids: List[str],
    reviewers: List[str],
    papers: Dict[str, Dict[str, str]],
    author_topics_by_id: Dict[str, Set[str]],
    coi_pairs: Dict[str, Set[str]],
    temp_x: float,
    temp_y: float,
):
    """
    Optimized version with batch processing for large n.
    """
    reviewer_topic = {r: reviewer_modal_topic(author_topics_by_id[r]) for r in reviewers}
    paper_topic = {pid: papers[pid]["topic"] for pid in paper_ids}
    paper_topics = sorted({paper_topic[pid] for pid in paper_ids})
    reviewer_topics = sorted({reviewer_topic[r] for r in reviewers})

    reviewers_by_topic: Dict[str, List[str]] = {topic: [] for topic in paper_topics}
    for r in reviewers:
        rtopic = reviewer_topic[r]
        if rtopic in reviewers_by_topic:
            reviewers_by_topic[rtopic].append(r)
    reviewers_other_topic = {
        topic: [r for r in reviewers if reviewer_topic[r] != topic] for topic in paper_topics
    }

    papers_by_topic: Dict[str, List[str]] = {topic: [] for topic in reviewer_topics}
    for pid in paper_ids:
        ptopic = paper_topic[pid]
        if ptopic in papers_by_topic:
            papers_by_topic[ptopic].append(pid)
    papers_other_topic = {
        topic: [pid for pid in paper_ids if paper_topic[pid] != topic] for topic in reviewer_topics
    }

    reviewer_coi_pairs: Dict[str, Set[str]] = defaultdict(set)
    for pid, reviewer_set in coi_pairs.items():
        for rid in reviewer_set:
            reviewer_coi_pairs[rid].add(pid)
    
    # X: papers rank reviewers
    print(f"Building X preferences (papers → reviewers) for {len(paper_ids)} papers...")
    X_prefs: Dict[str, List[str]] = {}
    batch_size = 1000
    
    for batch_start in range(0, len(paper_ids), batch_size):
        batch_end = min(batch_start + batch_size, len(paper_ids))
        if len(paper_ids) > 1000:
            print(f"  Processing papers {batch_start+1}-{batch_end} of {len(paper_ids)}...")
        
        for i in range(batch_start, batch_end):
            pid = paper_ids[i]
            ptopic = paper_topic[pid]
            coi_set = coi_pairs.get(pid, set())

            topic_reviewers = reviewers_by_topic.get(ptopic, [])
            other_reviewers = reviewers_other_topic.get(ptopic, reviewers)

            no_coi_match = [r for r in topic_reviewers if r not in coi_set]
            no_coi_other = [r for r in other_reviewers if r not in coi_set]
            coi_match = [r for r in topic_reviewers if r in coi_set]
            coi_other = [r for r in other_reviewers if r in coi_set]

            ord_no_coi = gumbel_sort_partition(no_coi_match, no_coi_other, temp_x)
            ord_coi = gumbel_sort_partition(coi_match, coi_other, temp_x)
            
            X_prefs[pid] = ord_no_coi + ord_coi
    
    # Y: reviewers rank papers
    print(f"Building Y preferences (reviewers → papers) for {len(reviewers)} reviewers...")
    Y_prefs: Dict[str, List[str]] = {}
    
    for batch_start in range(0, len(reviewers), batch_size):
        batch_end = min(batch_start + batch_size, len(reviewers))
        if len(reviewers) > 1000:
            print(f"  Processing reviewers {batch_start+1}-{batch_end} of {len(reviewers)}...")
        
        for i in range(batch_start, batch_end):
            r = reviewers[i]
            rtopic = reviewer_topic[r]

            reviewer_coi = reviewer_coi_pairs.get(r, set())
            topic_papers = papers_by_topic.get(rtopic, [])
            other_papers = papers_other_topic.get(rtopic, paper_ids)

            no_coi_match = [pid for pid in topic_papers if pid not in reviewer_coi]
            no_coi_other = [pid for pid in other_papers if pid not in reviewer_coi]
            coi_match = [pid for pid in topic_papers if pid in reviewer_coi]
            coi_other = [pid for pid in other_papers if pid in reviewer_coi]

            ord_no_coi = gumbel_sort_partition(no_coi_match, no_coi_other, temp_y)
            ord_coi = gumbel_sort_partition(coi_match, coi_other, temp_y)
            
            Y_prefs[r] = ord_no_coi + ord_coi
    
    return X_prefs, Y_prefs, reviewer_topic

# =============== CLI ===============

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--author-dir", required=True)
    ap.add_argument("--paper-dir", required=True)
    ap.add_argument("-n", type=int, required=True)
    ap.add_argument("--strategy", choices=["top","random"], default="top")
    ap.add_argument("--seed", type=int, default=0)
    ap.add_argument("--coi-file", default=None, help="CSV/TSV with columns paper_id + (reviewer_name [lowercase] OR reviewer_id)")
    ap.add_argument("--temp-x", type=float, default=0.35, help="Temperature for papers ranking reviewers")
    ap.add_argument("--temp-y", type=float, default=0.35, help="Temperature for reviewers ranking papers")
    ap.add_argument("--out-txt", required=True, help="Output text file (required)")
    ap.add_argument("--augment", type=lambda x: x.lower() in ['true', '1', 'yes'], default=True,
                    help="Enable data augmentation for large n (default: True)")
    args = ap.parse_args()

    random.seed(args.seed)

    # Parse & assign IDs
    print("Loading data...")
    author_topics_by_name = parse_author_net_folder(args.author_dir)
    name_to_id, id_to_name, author_topics_by_id, normname_to_id = assign_reviewer_ids(author_topics_by_name)
    papers = parse_paper_net_folder(args.paper_dir)
    
    print(f"Loaded {len(papers)} papers, {len(author_topics_by_id)} reviewers")

    # Select n/n with augmentation
    paper_ids, reviewers, papers, author_topics_by_id = select_sets_augmented(
        papers, author_topics_by_id, args.n, args.strategy, args.seed, augment=args.augment
    )

    # Load COI for this subset
    coi_pairs = {}
    if args.coi_file:
        print("Loading COI pairs...")
        coi_pairs = load_coi_for_subset(
            args.coi_file,
            paper_ids_set=set(paper_ids),
            reviewer_ids_set=set(reviewers),
            normname_to_id=normname_to_id,
        )
        print(f"Loaded {sum(len(s) for s in coi_pairs.values())} existing COI pairs")
    
    # Generate synthetic COI if augmenting
    if args.augment:
        print("Generating synthetic COI pairs...")
        coi_pairs = generate_synthetic_coi(
            paper_ids, reviewers, papers, author_topics_by_id, coi_pairs, args.seed
        )
        print(f"Total COI pairs: {sum(len(s) for s in coi_pairs.values())}")

    # Build randomized, COI-aware preferences (over IDs)
    X_prefs_ids, Y_prefs_ids, reviewer_topic = build_preferences_optimized(
        paper_ids, reviewers, papers, author_topics_by_id, coi_pairs,
        temp_x=args.temp_x, temp_y=args.temp_y
    )

    # Verify over IDs
    check = verify_complete_no_ties(X_prefs_ids, Y_prefs_ids, paper_ids, reviewers)
    if not all(check.values()):
        print("Warning: Verification failed!")
        for k, v in check.items():
            if not v:
                print(f"  {k}: {v}")

    # Build index mappings (always use indices, starting from 0)
    paper_to_idx = {pid: i for i, pid in enumerate(paper_ids)}
    reviewer_to_idx = {rid: j for j, rid in enumerate(reviewers)}

    # Convert prefs to indices (0-based)
    X_prefs = [[reviewer_to_idx[r] for r in X_prefs_ids[pid]] for pid in paper_ids]
    Y_prefs = [[paper_to_idx[pid] for pid in Y_prefs_ids[r]] for r in reviewers]

    # Output: simple format - first n lines are X side, next n lines are Y side
    if args.out_txt:
        with open(args.out_txt, "w") as f:
            # X side: n lines, each with n integers (0-based indices)
            for pref_list in X_prefs:
                f.write(" ".join(str(x) for x in pref_list) + "\n")
            # Y side: n lines, each with n integers (0-based indices)
            for pref_list in Y_prefs:
                f.write(" ".join(str(x) for x in pref_list) + "\n")
        print(f"Wrote TXT: {args.out_txt} ({len(X_prefs)} + {len(Y_prefs)} = {len(X_prefs) + len(Y_prefs)} lines)")

if __name__ == "__main__":
    main()
