#!/usr/bin/env python3
"""
Two-sided matching from AMiner-style .net topic folders, with AFFINITY + COI.
All author names are LOWERCASED everywhere (parsing, internal state, outputs).

Inputs:
  --author-dir : folder of author coauthor .net files (topics; e.g., graph-T16_sub0.net)
                 We read ONLY *Vertices lines to collect AUTHOR NAMES (lowercased) and their topics.
  --paper-dir  : folder of paper citation .net files (topics; e.g., graph-16.net)
                 We read ONLY *Vertices lines to collect PAPERS (ID->title, topic). Paper IDs are "Txx:<vid>".

Optional:
  --coi-file   : CSV/TSV of positive COI pairs with header including:
                   paper_id, reviewer_name   (reviewer_name MUST be lowercased)
                 or: paper_id, reviewer_id   (reviewer_id = our synthetic A000001-style IDs)

Outputs:
  - JSON: metadata + preference lists (IDs only); reviewer_id_to_name is LOWERCASE per request
  - TXT: preference lists
Ranking for both sides: (coi_flag, -affinity, id)  -> no-COI first, same-topic next, then ID.

Output formats:
  --output-format ids      (default) -> preferences over IDs (paper_id 'Txx:vid', reviewer_id 'A000001')
  --output-format indices  -> preferences over indices 1..n, with mapping exported in JSON and optional CSV

Optional CSV mapping (--out-map-csv) has rows for both papers and reviewers.

Ranking constraints:
  - no-COI block always before COI block
  - randomness only inside each block via Gumbel-top-k using affinity as base score

Example:
python3 gen_instance_RAP.py \
      --author-dir raw/RAP_author \
      --paper-dir  raw/RAP_pub \
      --coi-file   raw/RAP_COI_pairs.csv \
      -n 300 \
      --strategy top \
      --seed 42 \
      --output-format indices \
      --out-txt RAP_300_instance.txt \
      --out-map-csv RAP_idx_map.csv \
      --temp-x 0.01 \
      --temp-y 0.01
"""

import argparse
import os
import re
import random
import math
import csv
from collections import defaultdict
from typing import Dict, List, Tuple, Set

# =============== Helpers ===============

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

# =============== Parse author .net folder (LOWERCASE NAMES) ===============

def parse_author_net_folder(author_dir: str) -> Dict[str, Set[str]]:
    """
    Read ALL *.net files in author_dir.
    Return: author_topics_by_name (LOWERCASED names) -> set(topic_labels)
    """
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
                    # vertex: id "Author Name" num_papers
                    m_id = re.match(r"^(\d+)\s+", s)
                    if not m_id:
                        continue
                    m_name = re.search(r'"([^"]+)"', s)
                    if not m_name:
                        continue
                    name = m_name.group(1).strip().lower()  # LOWERCASE HERE
                    if name:
                        author_topics[name].add(topic)
    return author_topics

# =============== Parse paper .net folder ===============

def parse_paper_net_folder(paper_dir: str) -> Dict[str, Dict[str, str]]:
    """
    Read ALL *.net files in paper_dir (citation networks).
    Return: papers: dict[paper_id('Txx:vid')] -> {'title': str (as-is), 'topic': str}
    """
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
                    # vertex: id "title" cited_count
                    m_id = re.match(r"^(\d+)\s+", s)
                    if not m_id:
                        continue
                    vid = m_id.group(1)
                    m_title = re.search(r'"([^"]+)"', s)
                    title = m_title.group(1).strip() if m_title else ""
                    pid = f"{topic}_{vid}"  # composite paper ID (unique across files)
                    papers[pid] = {"title": title, "topic": topic}
    return papers

# =============== Reviewer ID assignment (LOWERCASE NAMES) ===============

def reviewer_modal_topic(topics: Set[str]) -> str:
    """Pick deterministic single topic label for a reviewer (if many, smallest lex)."""
    if not topics:
        return "unknown"
    return sorted(topics)[0]

def assign_reviewer_ids(author_topics_by_name: Dict[str, Set[str]]) -> Tuple[Dict[str, str], Dict[str, str], Dict[str, Set[str]], Dict[str, str]]:
    """
    Given LOWERCASED names, assign stable reviewer IDs A000001, A000002, ...
    Returns:
      name_to_id (lowername->rid),
      id_to_name (rid->lowername),
      author_topics_by_id (rid->set(topics)),
      normname_to_id (same as name_to_id for convenience)
    """
    names = sorted(author_topics_by_name.keys())  # already lowercase
    width = max(6, len(str(len(names))))
    name_to_id: Dict[str, str] = {}
    id_to_name: Dict[str, str] = {}
    author_topics_by_id: Dict[str, Set[str]] = {}
    normname_to_id: Dict[str, str] = {}

    for i, name in enumerate(names, start=1):
        rid = f"A{str(i).zfill(width)}"
        name_to_id[name] = rid
        id_to_name[rid] = name                      # LOWERCASE stored
        author_topics_by_id[rid] = set(author_topics_by_name[name])
        normname_to_id[name] = rid                  # LOWERCASE key
    return name_to_id, id_to_name, author_topics_by_id, normname_to_id

# =============== Selection ===============

def select_sets(
    papers: Dict[str, Dict[str, str]],
    author_topics_by_id: Dict[str, Set[str]],
    n: int,
    strategy: str,
    seed: int
) -> Tuple[List[str], List[str]]:
    """
    Choose n papers and n reviewers.
    strategy: 'top' or 'random'
      - papers 'top': sort by paper_id asc (deterministic)
      - reviewers 'top': sort by #topics desc, then reviewer_id asc
    """
    rng = random.Random(seed)

    paper_ids = list(papers.keys())
    reviewers = list(author_topics_by_id.keys())

    if len(paper_ids) < n:
        raise ValueError(f"Not enough papers: {len(paper_ids)} < n={n}")
    if len(reviewers) < n:
        raise ValueError(f"Not enough reviewers: {len(reviewers)} < n={n}")

    if strategy == "random":
        paper_ids = rng.sample(paper_ids, n)
        reviewers = rng.sample(reviewers, n)
    elif strategy == "top":
        paper_ids = sorted(paper_ids)[:n]
        reviewers = sorted(reviewers, key=lambda r: (-len(author_topics_by_id[r]), r))[:n]
    else:
        raise ValueError("strategy must be one of {'top','random'}")

    return paper_ids, reviewers

# =============== COI loader (stream/filter huge file) ===============

def load_coi_for_subset(
    coi_path: str,
    paper_ids_set: Set[str],
    reviewer_ids_set: Set[str],
    normname_to_id: Dict[str, str],
) -> Dict[str, Set[str]]:
    """
    Stream the COI file once and keep only pairs for selected papers+reviewers.
    Header options:
      - paper_id, reviewer_name   (reviewer_name MUST be LOWERCASED)
      - paper_id, reviewer_id
    Return: dict[paper_id] -> set(reviewer_id)
    """
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
        # columns
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
                # Keep only if the reviewer ID is one of the selected reviewers
                if cand in reviewer_ids_set:
                    rid = cand
            if rid is None and c_rnm is not None and len(row) > c_rnm:
                nm = row[c_rnm].strip().lower()  # COI file already lowercase per user; ensure anyway
                rid = normname_to_id.get(nm)
                if rid and rid not in reviewer_ids_set:
                    rid = None
            if rid:
                coi[pid].add(rid)

    return coi

# ---------------- Gumbel-top-k utilities ----------------

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
        noisy.append((-(s * invT + gumbel()), x))  # negative for ascending sort -> descending by score
    noisy.sort()
    return [x for _, x in noisy]

# ---------------- Preferences (COI-aware, randomized within blocks) ----------------

def build_preferences(
    paper_ids: List[str],
    reviewers: List[str],
    papers: Dict[str, Dict[str, str]],
    author_topics_by_id: Dict[str, Set[str]],
    coi_pairs: Dict[str, Set[str]],   # pid -> set(rid)
    temp_x: float,
    temp_y: float,
):
    """
    For each paper:
      - Partition reviewers into no-COI and COI blocks.
      - Within each block, base_score = 1 if same-topic else 0.
      - Apply Gumbel-top-k with temperature temp_x to get a random, tie-free order.
      - Concatenate: no-COI block first, then COI block.
    Symmetric for each reviewer ranking papers (temp_y).
    """
    reviewer_topic = {r: reviewer_modal_topic(author_topics_by_id[r]) for r in reviewers}

    # X: papers rank reviewers
    X_prefs: Dict[str, List[str]] = {}
    for pid in paper_ids:
        ptopic = papers[pid]["topic"]
        coi_set = coi_pairs.get(pid, set())

        no_coi = [r for r in reviewers if r not in coi_set]
        coi = [r for r in reviewers if r in coi_set]

        # base score by affinity (same topic -> 1, else 0)
        base_no_coi = {r: 1.0 if reviewer_topic[r] == ptopic else 0.0 for r in no_coi}
        base_coi    = {r: 1.0 if reviewer_topic[r] == ptopic else 0.0 for r in coi}

        # randomized sort (higher base score tends to be earlier)
        ord_no_coi = gumbel_sort(no_coi, base_no_coi, temp_x)
        ord_coi    = gumbel_sort(coi,    base_coi,    temp_x)

        X_prefs[pid] = ord_no_coi + ord_coi

    # Y: reviewers rank papers
    Y_prefs: Dict[str, List[str]] = {}
    for r in reviewers:
        rtopic = reviewer_topic[r]
        # partition papers by COI with this reviewer
        no_coi = [pid for pid in paper_ids if r not in coi_pairs.get(pid, set())]
        coi    = [pid for pid in paper_ids if r in  coi_pairs.get(pid, set())]

        base_no_coi = {pid: 1.0 if papers[pid]["topic"] == rtopic else 0.0 for pid in no_coi}
        base_coi    = {pid: 1.0 if papers[pid]["topic"] == rtopic else 0.0 for pid in coi}

        ord_no_coi = gumbel_sort(no_coi, base_no_coi, temp_y)
        ord_coi    = gumbel_sort(coi,    base_coi,    temp_y)

        Y_prefs[r] = ord_no_coi + ord_coi

    return X_prefs, Y_prefs, reviewer_topic

# ---------------- Verification ----------------

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

# =============== CLI ===============

def main():
    import json
    ap = argparse.ArgumentParser()
    ap.add_argument("--author-dir", required=True)
    ap.add_argument("--paper-dir", required=True)
    ap.add_argument("-n", type=int, required=True)
    ap.add_argument("--strategy", choices=["top","random"], default="top")
    ap.add_argument("--seed", type=int, default=0)
    ap.add_argument("--coi-file", default=None, help="CSV/TSV with columns paper_id + (reviewer_name [lowercase] OR reviewer_id)")
    ap.add_argument("--temp-x", type=float, default=0.35, help="Temperature for papers ranking reviewers")
    ap.add_argument("--temp-y", type=float, default=0.35, help="Temperature for reviewers ranking papers")
    ap.add_argument("--output-format", choices=["ids","indices"], default="ids",
                    help="ids: preferences use IDs (default). indices: preferences use 1..n indices.")
    ap.add_argument("--out-json", default=None)
    ap.add_argument("--out-txt", default=None)
    ap.add_argument("--out-map-csv", default=None, help="Optional CSV mapping indices↔IDs↔names/titles.")
    args = ap.parse_args()

    random.seed(args.seed)

    # Parse & assign IDs
    author_topics_by_name = parse_author_net_folder(args.author_dir)  # names are lowercase
    name_to_id, id_to_name, author_topics_by_id, normname_to_id = assign_reviewer_ids(author_topics_by_name)
    papers = parse_paper_net_folder(args.paper_dir)

    # Select n/n
    paper_ids, reviewers = select_sets(papers, author_topics_by_id, args.n, args.strategy, args.seed)

    # Load COI for this subset
    coi_pairs = {}
    if args.coi_file:
        coi_pairs = load_coi_for_subset(
            args.coi_file,
            paper_ids_set=set(paper_ids),
            reviewer_ids_set=set(reviewers),
            normname_to_id=normname_to_id,
        )

    # Build randomized, COI-aware preferences (over IDs)
    X_prefs_ids, Y_prefs_ids, reviewer_topic = build_preferences(
        paper_ids, reviewers, papers, author_topics_by_id, coi_pairs,
        temp_x=args.temp_x, temp_y=args.temp_y
    )

    # Verify over IDs
    check = verify_complete_no_ties(X_prefs_ids, Y_prefs_ids, paper_ids, reviewers)
    print("Verification:")
    for k, v in check.items():
        print(f"  {k}: {v}")

    # Build index mappings if requested
    use_indices = (args.output_format == "indices")
    if use_indices:
        paper_to_idx = {pid: i+1 for i, pid in enumerate(paper_ids)}       # 1..n
        reviewer_to_idx = {rid: j+1 for j, rid in enumerate(reviewers)}    # 1..n
        idx_to_paper = {i+1: pid for i, pid in enumerate(paper_ids)}
        idx_to_reviewer = {j+1: rid for j, rid in enumerate(reviewers)}

        # Convert prefs to indices
        X_prefs = {paper_to_idx[pid]: [reviewer_to_idx[r] for r in X_prefs_ids[pid]] for pid in paper_ids}
        Y_prefs = {reviewer_to_idx[r]: [paper_to_idx[pid] for pid in Y_prefs_ids[r]] for r in reviewers}
    else:
        X_prefs = X_prefs_ids
        Y_prefs = Y_prefs_ids
        paper_to_idx = reviewer_to_idx = idx_to_paper = idx_to_reviewer = None

    # Preview
    def preview_ids(title, mapping, keys, show=3, topk=10):
        print(f"\n{title} (showing {show}; top {topk} choices):")
        for k in keys[:show]:
            print(f"  {k}: {' '.join(mapping[k][:topk])}")

    def preview_indices(title, mapping, keys, show=3, topk=10):
        print(f"\n{title} (indices) (showing {show}; top {topk} choices):")
        for k in keys[:show]:
            vals = ' '.join(str(x) for x in mapping[k][:topk])
            print(f"  {k}: {vals}")

    if use_indices:
        preview_indices("X (papers) → Y (reviewers)", X_prefs, sorted(X_prefs.keys()))
        preview_indices("Y (reviewers) → X (papers)", Y_prefs, sorted(Y_prefs.keys()))
    else:
        preview_ids("X (papers) → Y (reviewers, IDs)", X_prefs, paper_ids)
        preview_ids("Y (reviewers, IDs) → X (papers)", Y_prefs, reviewers)

    # Outputs
    if args.out_json:
        payload = {
            "output_format": args.output_format,
            "X_side_label": "paper_index" if use_indices else "paper_id",
            "Y_side_label": "reviewer_index" if use_indices else "reviewer_id",
            "papers": {pid: papers[pid] for pid in paper_ids},                     # title + topic
            "reviewers": reviewers if not use_indices else list(range(1, len(reviewers)+1)),
            "reviewer_id_to_name": {rid: id_to_name[rid] for rid in reviewers},    # lowercase names
            "reviewer_id_to_topic": {rid: reviewer_topic[rid] for rid in reviewers},
            "X_prefs": X_prefs,
            "Y_prefs": Y_prefs,
        }
        if use_indices:
            payload.update({
                "paper_index_to_id": {i: idx_to_paper[i] for i in idx_to_paper},
                "reviewer_index_to_id": {j: idx_to_reviewer[j] for j in idx_to_reviewer},
                "paper_id_to_index": paper_to_idx,
                "reviewer_id_to_index": reviewer_to_idx,
            })
        with open(args.out_json, "w") as f:
            import json
            json.dump(payload, f, indent=2)
        print(f"\nWrote JSON: {args.out_json}")

    if args.out_txt:
        with open(args.out_txt, "w") as f:
            if use_indices:
                f.write("X side (papers indices) preferences over Y (reviewers indices):\n")
                for i in sorted(X_prefs.keys()):
                    f.write(f"{i}: {' '.join(str(x) for x in X_prefs[i])}\n")
                f.write("\nY side (reviewers indices) preferences over X (papers indices):\n")
                for j in sorted(Y_prefs.keys()):
                    f.write(f"{j}: {' '.join(str(x) for x in Y_prefs[j])}\n")
            else:
                f.write("X side (papers IDs) preferences over Y (reviewers IDs):\n")
                for pid in paper_ids:
                    f.write(f"{pid}: {' '.join(X_prefs[pid])}\n")
                f.write("\nY side (reviewers IDs) preferences over X (papers IDs):\n")
                for rid in reviewers:
                    f.write(f"{rid}: {' '.join(Y_prefs[rid])}\n")
        print(f"Wrote TXT: {args.out_txt}")

    if args.out_map_csv:
        with open(args.out_map_csv, "w", newline="", encoding="utf-8") as f:
            w = csv.writer(f)
            # header
            if use_indices:
                w.writerow(["side","index","id","name_or_title","topic"])
                # reviewers
                for j, rid in enumerate(reviewers, start=1):
                    w.writerow(["reviewer", j, rid, id_to_name[rid], reviewer_topic[rid]])
                # papers
                for i, pid in enumerate(paper_ids, start=1):
                    w.writerow(["paper", i, pid, papers[pid]["title"], papers[pid]["topic"]])
            else:
                w.writerow(["side","id","name_or_title","topic"])
                for rid in reviewers:
                    w.writerow(["reviewer", rid, id_to_name[rid], reviewer_topic[rid]])
                for pid in paper_ids:
                    w.writerow(["paper", pid, papers[pid]["title"], papers[pid]["topic"]])
        print(f"Wrote mapping CSV: {args.out_map_csv}")

if __name__ == "__main__":
    main()