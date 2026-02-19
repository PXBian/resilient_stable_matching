#!/usr/bin/env python3
"""
ADM instance generator with data augmentation support for large n (25000+)

This script extends gen_instance_ADM.py to support large n values by:
1. Generating synthetic priority and accepted_ratio values based on existing data distribution
2. Using vectorized computation and memory-efficient processing
3. Multi-dimensional signals via latent factor model (increases rotation count)
4. Optional individual noise per agent-partner pair to increase preference diversity

Optimized for n up to 25000+ with:
- Vectorized data generation
- Batch processing for preference generation
- Memory-efficient operations
- Latent factor model: each agent has unique multi-dimensional feature vector
- Optional pair-wise individual noise (similar to BIKE, increases rotation count when enabled)

Usage
-----
python3 gen_instance_ADM_augmented.py \
  --csv raw/ADM_Norway_raw.csv \
  -n 25000 \
  --seed 42 \
  --temp-x 0.9 \
  --temp-y 0.9 \
  --individual-noise 0.0 \
  --out-txt ADM_25000_instance.txt

To increase rotation count:
- Increase --temp-x and --temp-y (0.9-1.5): Higher temperature = more diversity
- Add --individual-noise (0.2-0.5): Pair-wise noise increases rotation (similar to BIKE)
- Latent factors are enabled by default (auto-scaled with n) - no need to tune
- Use --latent-dim 0 to disable if needed (not recommended)
"""

import argparse
import csv
import json
import math
import random
from typing import List, Dict, Tuple, Optional
import numpy as np

# Import functions from original script
from gen_instance_ADM import (
    open_csv_reader, normalize_header, find_cols,
    zscore, gumbel, pl_permutation, verify_complete_no_ties
)

# ---------------- Data Augmentation ----------------

def generate_synthetic_scores(
    existing_pri_scores: List[float],
    existing_acc_scores: List[float],
    target_count: int,
    seed: int,
) -> Tuple[List[float], List[float]]:
    """
    Generate synthetic priority and accepted_ratio scores based on existing distribution.
    
    Uses bootstrap resampling with added noise to maintain diversity and prevent
    score concentration that would reduce rotation count.
    """
    random.seed(seed)
    np.random.seed(seed)
    
    # Analyze existing distributions
    pri_array = np.array(existing_pri_scores)
    acc_array = np.array([x for x in existing_acc_scores if math.isfinite(x)])
    
    # Calculate statistics for noise scaling
    pri_mean = np.mean(pri_array)
    pri_std = np.std(pri_array) if len(pri_array) > 1 else 1.0
    
    if len(acc_array) > 0:
        acc_mean = np.mean(acc_array)
        acc_std = np.std(acc_array) if len(acc_array) > 1 else 1.0
    else:
        acc_mean = 0.5
        acc_std = 0.2
    
    # Generate synthetic scores
    n_needed = target_count - len(existing_pri_scores)
    if n_needed > 0:
        # Use bootstrap resampling instead of pure normal distribution
        # This maintains diversity and prevents score concentration
        synthetic_pri = []
        synthetic_acc = []
        
        for i in range(n_needed):
            # Bootstrap: sample from existing data with replacement
            idx = np.random.randint(0, len(existing_pri_scores))
            base_pri = existing_pri_scores[idx]
            base_acc = existing_acc_scores[idx] if idx < len(existing_acc_scores) else acc_mean
            
            # Add small random noise to increase diversity (key for rotation count)
            # Noise scale: 10-20% of std to maintain distribution while adding variety
            pri_noise = np.random.normal(0, pri_std * 0.15)
            acc_noise = np.random.normal(0, acc_std * 0.15) if math.isfinite(base_acc) else 0.0
            
            synthetic_pri.append(base_pri + pri_noise)
            
            # Handle acc_ratio: add noise but keep in reasonable range
            if math.isfinite(base_acc):
                synthetic_acc.append(np.clip(base_acc + acc_noise, -1.0, 2.0))
            else:
                synthetic_acc.append(base_acc)  # Keep -inf as is
        
        # Combine with existing
        all_pri_scores = list(existing_pri_scores) + synthetic_pri
        all_acc_scores = list(existing_acc_scores) + synthetic_acc
        
        return all_pri_scores, all_acc_scores
    
    return existing_pri_scores, existing_acc_scores

# ---------------- Enhanced Data Loading ----------------

def load_rows_augmented(
    path: str, 
    n: int, 
    sample_rows: bool, 
    delim: Optional[str],
    augment: bool = True,
    seed: int = 0
) -> Tuple[List[float], List[float]]:
    """
    Load rows with augmentation support.
    Returns two aligned score lists of length n:
      - pri_scores: for ranking Y as seen by X (invert so lower Priority => higher score)
      - acc_scores: for ranking X as seen by Y (Accepted Offer / Admission Offer)
    """
    reader, fh = open_csv_reader(path, delim)
    try:
        header = next(reader)
    except StopIteration:
        fh.close()
        raise ValueError("Empty file.")

    header_norm = normalize_header(header)

    # Accept common header variants
    idx = find_cols(
        header_norm,
        {
            "priority": ["priority"],
            "accepted_offer": ["accepted offer", "accepted_offer"],
            "admission_offer": ["admission offer", "admission_offer"],
        },
    )
    ip = idx["priority"]
    iao = idx["accepted_offer"]
    iadm = idx["admission_offer"]

    rows: List[Tuple[float, float]] = []
    for row in reader:
        # Skip bad rows
        if max(ip, iao, iadm) >= len(row):
            continue
        try:
            pr_raw = row[ip]
            acc_raw = row[iao]
            adm_raw = row[iadm]
            # Handle thousand separators or spaces if present
            pr = float(str(pr_raw).replace(",", "").strip())
            acc = float(str(acc_raw).replace(",", "").strip())
            adm = float(str(adm_raw).replace(",", "").strip())
        except Exception:
            continue

        # NaN check
        if not (pr == pr and acc == acc and adm == adm):
            continue

        # Convert to scores:
        # Priority: smaller is better -> score = -priority (larger score = better)
        pri_score = -pr

        # Accepted ratio: handle zero/neg admissions robustly
        acc_ratio = (acc / adm) if adm > 0 else float("-inf")

        rows.append((pri_score, acc_ratio))

    fh.close()

    if len(rows) < n:
        if augment:
            print(f"Augmenting data: have {len(rows)} valid rows, need {n}")
            # Use all available rows, then generate synthetic
            pri_scores = [a for (a, _) in rows]
            acc_scores = [b for (_, b) in rows]
            
            # Generate synthetic scores
            pri_scores, acc_scores = generate_synthetic_scores(
                pri_scores, acc_scores, n, seed
            )
            print(f"  Generated {n - len(rows)} synthetic rows")
            return pri_scores, acc_scores
        else:
            raise ValueError(f"Only {len(rows)} valid rows; requested n={n}.")

    if sample_rows and len(rows) > n:
        rows = random.sample(rows, n)
    else:
        rows = rows[:n]

    pri_scores = [a for (a, _) in rows]
    acc_scores = [b for (_, b) in rows]
    return pri_scores, acc_scores

# ---------------- Latent Factor Model (Multi-dimensional signals) ----------------

def generate_latent_factors(
    n: int,
    latent_dim: int,
    seed: int
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Generate latent factor vectors for X and Y agents.
    Each agent gets a unique multi-dimensional feature vector.
    This increases signal dimensionality from 1D to latent_dim dimensions.
    
    Similar to how RAP uses topics and FOOD uses locations - but for ADM,
    we generate synthetic factors since the raw data only has 1D signals.
    """
    np.random.seed(seed)
    
    # Generate factor vectors: each agent has a unique vector in latent_dim space
    # Use normal distribution with unit variance for diversity
    x_factors = np.random.normal(0, 1.0, size=(n, latent_dim)).astype(np.float32)
    y_factors = np.random.normal(0, 1.0, size=(n, latent_dim)).astype(np.float32)
    
    # Normalize to unit length for stable dot products
    x_norms = np.linalg.norm(x_factors, axis=1, keepdims=True)
    x_norms = np.where(x_norms > 0, x_norms, 1.0)
    x_factors = x_factors / x_norms
    
    y_norms = np.linalg.norm(y_factors, axis=1, keepdims=True)
    y_norms = np.where(y_norms > 0, y_norms, 1.0)
    y_factors = y_factors / y_norms
    
    return x_factors, y_factors

def auto_scale_latent_dim(n: int, user_specified: int) -> int:
    """
    Auto-scale latent dimension based on n, similar to gen_rotation_max.py.
    This ensures good diversity for large n without requiring user to tune.
    
    If user_specified == 0: disable latent factors
    If user_specified == 8 (default): auto-scale based on n
    If user_specified > 0 and != 8: use user's value
    """
    if user_specified == 0:
        return 0  # User explicitly disabled
    
    if user_specified != 8:
        return user_specified  # User explicitly set a custom value
    
    # Auto-scale: sqrt(n) / 100, clamped to reasonable range
    # For n=50000: sqrt(50000)/100 ≈ 7, so 8 is good
    # For n=100000: sqrt(100000)/100 ≈ 10
    auto_dim = max(4, min(16, int(np.sqrt(n) / 100)))
    return auto_dim

# ---------------- Optimized Preference Building ----------------

def build_preferences_individual_optimized(
    pri_scores: List[float], 
    acc_scores: List[float], 
    temp_x: float, 
    temp_y: float,
    individual_noise_scale: float = 0.0,
    latent_dim: int = 0,
    latent_weight: float = 1.0,
    seed: int = 0
) -> Tuple[List[str], List[str], Dict[str, List[str]], Dict[str, List[str]]]:
    """
    Optimized version with batch processing for large n.
    
    Enhanced with multi-dimensional signals:
    1. Latent factor model: each agent has a unique feature vector
    2. Pair-wise matching scores based on factor similarity
    3. Individual noise for additional diversity
    
    This increases signal dimensionality from 1D (priority/accepted_ratio) to 
    (1 + latent_dim) dimensions, similar to FOOD/RAP/BIKE.
    """
    random.seed(seed)
    np.random.seed(seed)
    
    n = len(pri_scores)
    x_ids = [f"x{i+1}" for i in range(n)]
    y_ids = [f"y{i+1}" for i in range(n)]
    
    # Generate latent factors if enabled (increases dimensionality)
    x_factors = None
    y_factors = None
    if latent_dim > 0:
        print(f"  Generating {latent_dim}-dimensional latent factors for {n} agents...")
        x_factors, y_factors = generate_latent_factors(n, latent_dim, seed)
        print(f"  Using latent weight: {latent_weight}")

    # X side: for each intuition, sample a permutation of students
    print(f"Building X preferences (intuition → students) for {n} agents...")
    if individual_noise_scale > 0:
        print(f"  Using individual noise scale: {individual_noise_scale}")
    x_prefs: Dict[str, List[str]] = {}
    batch_size = 1000
    
    for batch_start in range(0, n, batch_size):
        batch_end = min(batch_start + batch_size, n)
        if n > 1000:
            print(f"  Processing agents {batch_start+1}-{batch_end} of {n}...")
        for i in range(batch_start, batch_end):
            x = x_ids[i]
            
            # Start with base scores (raw pri_scores) - 1D signal
            scores = np.array(pri_scores, dtype=np.float64)
            
            # Add latent factor matching scores (multi-dimensional signal)
            # X agent i prefers Y agent j based on factor similarity
            if x_factors is not None and y_factors is not None:
                # Compute dot product similarity: x_factors[i] · y_factors[j]
                factor_similarity = np.dot(x_factors[i], y_factors.T)  # shape: (n,)
                scores += latent_weight * factor_similarity.astype(np.float64)
            
            # Add pair-wise individual noise (KEY for rotation count)
            # Each x-y pair has unique noise based on their IDs
            # This is done BEFORE zscore to preserve individual differences
            if individual_noise_scale > 0:
                for j in range(n):
                    # Use hash of (x_id, y_id) for consistent but unique noise
                    pair_hash = hash((x, y_ids[j])) % (2**31)
                    pair_rng = random.Random(pair_hash)
                    scores[j] += pair_rng.gauss(0, individual_noise_scale)
            
            # Now normalize the individualized scores
            scores_norm = zscore(scores.tolist())
            
            # Generate permutation with individualized scores
            order = pl_permutation(scores_norm, temp_x)
            x_prefs[x] = [y_ids[j] for j in order]

    # Y side: for each student, sample a permutation of intuitions
    print(f"Building Y preferences (students → intuition) for {n} agents...")
    y_prefs: Dict[str, List[str]] = {}
    
    for batch_start in range(0, n, batch_size):
        batch_end = min(batch_start + batch_size, n)
        if n > 1000:
            print(f"  Processing agents {batch_start+1}-{batch_end} of {n}...")
        for j in range(batch_start, batch_end):
            y = y_ids[j]
            
            # Start with base scores (raw acc_scores) - 1D signal
            scores = np.array(acc_scores, dtype=np.float64)
            
            # Add latent factor matching scores (multi-dimensional signal)
            # Y agent j prefers X agent i based on factor similarity
            if x_factors is not None and y_factors is not None:
                # Compute dot product similarity: y_factors[j] · x_factors[i]
                factor_similarity = np.dot(y_factors[j], x_factors.T)  # shape: (n,)
                scores += latent_weight * factor_similarity.astype(np.float64)
            
            # Add pair-wise individual noise (KEY for rotation count)
            # Each y-x pair has unique noise based on their IDs
            # This is done BEFORE zscore to preserve individual differences
            if individual_noise_scale > 0:
                for i in range(n):
                    # Use hash of (y_id, x_id) for consistent but unique noise
                    pair_hash = hash((y, x_ids[i])) % (2**31)
                    pair_rng = random.Random(pair_hash)
                    scores[i] += pair_rng.gauss(0, individual_noise_scale)
            
            # Now normalize the individualized scores
            scores_norm = zscore(scores.tolist())
            
            # Generate permutation with individualized scores
            order = pl_permutation(scores_norm, temp_y)
            y_prefs[y] = [x_ids[i] for i in order]

    return x_ids, y_ids, x_prefs, y_prefs

# ---------- CLI ----------

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--csv", required=True, help="Path to ADM_Norway_raw.csv (CSV/TSV; delimiter auto-detected).")
    ap.add_argument("-n", type=int, required=True, help="Number of agents per side.")
    ap.add_argument("--seed", type=int, default=0, help="RNG seed for reproducibility.")
    ap.add_argument("--sample-rows", action="store_true", help="Sample which rows to use (vs take first n).")
    ap.add_argument("--temp-x", type=float, default=0.9, help="Temperature for X (higher = more rotation, default: 0.9).")
    ap.add_argument("--temp-y", type=float, default=0.9, help="Temperature for Y (higher = more rotation, default: 0.9).")
    ap.add_argument("--individual-noise", type=float, default=0.0,
                    help="Scale of individual noise for preference diversity (higher = more rotation, default: 0.0 = disabled)")
    ap.add_argument("--latent-dim", type=int, default=8,
                    help="Dimension of latent factors for multi-dimensional signals (0 = disabled, default: 8, auto-scaled with n)")
    ap.add_argument("--latent-weight", type=float, default=1.0,
                    help="Weight of latent factor matching scores (default: 1.0, usually no need to change)")
    ap.add_argument("--delim", default=None,
                    help="Override delimiter (e.g. ',' or '\\t'). If omitted, we auto-detect.")
    ap.add_argument("--out-txt", required=True, help="Output text file (required)")
    ap.add_argument("--augment", type=lambda x: x.lower() in ['true', '1', 'yes'], default=True,
                    help="Enable data augmentation for large n (default: True)")
    args = ap.parse_args()

    random.seed(args.seed)

    pri_scores, acc_scores = load_rows_augmented(
        args.csv, args.n, sample_rows=args.sample_rows, 
        delim=args.delim, augment=args.augment, seed=args.seed
    )
    
    # Auto-scale latent dimension (default behavior, like RAP/FOOD - no tuning needed)
    # This makes it work like RAP/FOOD - no need to tune parameters
    effective_latent_dim = auto_scale_latent_dim(args.n, args.latent_dim)
    if effective_latent_dim > 0:
        if args.latent_dim == 8:  # Using default, show auto-scaling
            print(f"Using {effective_latent_dim}-dimensional latent factors (auto-scaled for n={args.n})")
        else:
            print(f"Using {effective_latent_dim}-dimensional latent factors")
    else:
        print("Latent factors disabled (using 1D signals only)")
    
    x_ids, y_ids, x_prefs_ids, y_prefs_ids = build_preferences_individual_optimized(
        pri_scores, acc_scores, args.temp_x, args.temp_y,
        individual_noise_scale=args.individual_noise,
        latent_dim=effective_latent_dim,
        latent_weight=args.latent_weight,
        seed=args.seed
    )
    
    check = verify_complete_no_ties(x_prefs_ids, y_prefs_ids, x_ids, y_ids)
    
    if not all(check.values()):
        print("Warning: Verification failed!")
        for k, v in check.items():
            if not v:
                print(f"  {k}: {v}")

    # Build index mappings (always use 0-based indices)
    x_to_idx = {x: i for i, x in enumerate(x_ids)}
    y_to_idx = {y: j for j, y in enumerate(y_ids)}

    # Convert prefs to indices (0-based)
    X_prefs = [[y_to_idx[y] for y in x_prefs_ids[x]] for x in x_ids]
    Y_prefs = [[x_to_idx[x] for x in y_prefs_ids[y]] for y in y_ids]

    # Output: simple format - first n lines are X side, next n lines are Y side
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












