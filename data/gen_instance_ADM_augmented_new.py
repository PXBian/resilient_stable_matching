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
import hashlib
import json
import math
import multiprocessing as mp
import random
from typing import List, Dict, Tuple, Optional
import numpy as np

# Import functions from original script
from gen_instance_ADM import (
    open_csv_reader, normalize_header, find_cols,
    zscore, verify_complete_no_ties
)


_ADM_POOL_CTX = None


def _stable_seed(*parts: object) -> int:
    payload = "||".join(str(p) for p in parts).encode("utf-8")
    return int.from_bytes(hashlib.blake2b(payload, digest_size=8).digest(), "big")


def gumbel(rng: Optional[random.Random] = None) -> float:
    if rng is None:
        u = random.random()
    else:
        u = rng.random()
    return -math.log(-math.log(max(u, 1e-12)))


def pl_permutation(scores: List[float], temperature: float, rng: Optional[random.Random] = None) -> List[int]:
    if temperature <= 0:
        raise ValueError("temperature must be > 0")
    noisy = [(i, scores[i] / temperature + gumbel(rng)) for i in range(len(scores))]
    noisy.sort(key=lambda t: (-t[1], t[0]))
    return [i for (i, _) in noisy]


def _init_adm_pool(ctx):
    global _ADM_POOL_CTX
    _ADM_POOL_CTX = ctx

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
        # Vectorized bootstrap resampling with noise
        indices = np.random.randint(0, len(existing_pri_scores), size=n_needed)
        base_pri_arr = np.array(existing_pri_scores)[indices]
        base_acc_arr = np.array(existing_acc_scores)[indices]

        pri_noise = np.random.normal(0, pri_std * 0.15, size=n_needed)
        synthetic_pri = (base_pri_arr + pri_noise).tolist()

        # For acc: only add noise where finite; keep -inf as is
        acc_finite_mask = np.isfinite(base_acc_arr)
        acc_noise = np.where(acc_finite_mask,
                             np.random.normal(0, acc_std * 0.15, size=n_needed),
                             0.0)
        synthetic_acc_arr = np.where(acc_finite_mask,
                                     np.clip(base_acc_arr + acc_noise, -1.0, 2.0),
                                     base_acc_arr)
        synthetic_acc = synthetic_acc_arr.tolist()

        return list(existing_pri_scores) + synthetic_pri, list(existing_acc_scores) + synthetic_acc

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

def _x_pref_task(i: int) -> Tuple[str, List[str]]:
    ctx = _ADM_POOL_CTX
    x_ids = ctx["x_ids"]
    y_ids = ctx["y_ids"]
    scores = np.array(ctx["pri_scores"], dtype=np.float64)

    if ctx["x_factors"] is not None and ctx["y_factors"] is not None:
        factor_similarity = np.dot(ctx["x_factors"][i], ctx["y_factors"].T)
        scores += ctx["latent_weight"] * factor_similarity.astype(np.float64)

    if ctx["individual_noise_scale"] > 0:
        for j in range(ctx["n"]):
            pair_hash = _stable_seed("pair_noise_x_y", x_ids[i], y_ids[j])
            pair_rng = random.Random(pair_hash)
            scores[j] += pair_rng.gauss(0, ctx["individual_noise_scale"])

    scores_norm = zscore(scores.tolist())
    row_rng = random.Random(_stable_seed("pl_row_x", ctx["seed"], i))
    order = pl_permutation(scores_norm, ctx["temp_x"], rng=row_rng)
    return x_ids[i], [y_ids[j] for j in order]


def _y_pref_task(j: int) -> Tuple[str, List[str]]:
    ctx = _ADM_POOL_CTX
    x_ids = ctx["x_ids"]
    y_ids = ctx["y_ids"]
    scores = np.array(ctx["acc_scores"], dtype=np.float64)

    if ctx["x_factors"] is not None and ctx["y_factors"] is not None:
        factor_similarity = np.dot(ctx["y_factors"][j], ctx["x_factors"].T)
        scores += ctx["latent_weight"] * factor_similarity.astype(np.float64)

    if ctx["individual_noise_scale"] > 0:
        for i in range(ctx["n"]):
            pair_hash = _stable_seed("pair_noise_y_x", y_ids[j], x_ids[i])
            pair_rng = random.Random(pair_hash)
            scores[i] += pair_rng.gauss(0, ctx["individual_noise_scale"])

    scores_norm = zscore(scores.tolist())
    row_rng = random.Random(_stable_seed("pl_row_y", ctx["seed"], j))
    order = pl_permutation(scores_norm, ctx["temp_y"], rng=row_rng)
    return y_ids[j], [x_ids[i] for i in order]


def build_preferences_individual_optimized(
    pri_scores: List[float],
    acc_scores: List[float],
    temp_x: float,
    temp_y: float,
    individual_noise_scale: float = 0.0,
    latent_dim: int = 0,
    latent_weight: float = 1.0,
    seed: int = 0,
    workers: int = 1,
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

    x_factors = None
    y_factors = None
    if latent_dim > 0:
        print(f"  Generating {latent_dim}-dimensional latent factors for {n} agents...")
        x_factors, y_factors = generate_latent_factors(n, latent_dim, seed)
        print(f"  Using latent weight: {latent_weight}")

    print(f"Building X preferences (intuition → students) for {n} agents...")
    if individual_noise_scale > 0:
        print(f"  Using individual noise scale: {individual_noise_scale}")

    effective_workers = max(1, workers)
    pool_ctx = {
        "pri_scores": pri_scores,
        "acc_scores": acc_scores,
        "x_ids": x_ids,
        "y_ids": y_ids,
        "x_factors": x_factors,
        "y_factors": y_factors,
        "latent_weight": latent_weight,
        "individual_noise_scale": individual_noise_scale,
        "temp_x": temp_x,
        "temp_y": temp_y,
        "seed": seed,
        "n": n,
    }

    x_prefs: Dict[str, List[str]] = {}
    if effective_workers == 1:
        _init_adm_pool(pool_ctx)
        for i in range(n):
            key, pref = _x_pref_task(i)
            x_prefs[key] = pref
    else:
        print(f"  Parallel workers: {effective_workers}")
        try:
            with mp.Pool(processes=effective_workers, initializer=_init_adm_pool, initargs=(pool_ctx,)) as pool:
                for key, pref in pool.imap(_x_pref_task, range(n), chunksize=1):
                    x_prefs[key] = pref
        except (PermissionError, OSError) as exc:
            print(f"  Warning: parallel execution unavailable ({exc}); falling back to single worker.")
            _init_adm_pool(pool_ctx)
            for i in range(n):
                key, pref = _x_pref_task(i)
                x_prefs[key] = pref

    print(f"Building Y preferences (students → intuition) for {n} agents...")
    y_prefs: Dict[str, List[str]] = {}
    if effective_workers == 1:
        _init_adm_pool(pool_ctx)
        for j in range(n):
            key, pref = _y_pref_task(j)
            y_prefs[key] = pref
    else:
        try:
            with mp.Pool(processes=effective_workers, initializer=_init_adm_pool, initargs=(pool_ctx,)) as pool:
                for key, pref in pool.imap(_y_pref_task, range(n), chunksize=1):
                    y_prefs[key] = pref
        except (PermissionError, OSError) as exc:
            print(f"  Warning: parallel execution unavailable ({exc}); falling back to single worker.")
            _init_adm_pool(pool_ctx)
            for j in range(n):
                key, pref = _y_pref_task(j)
                y_prefs[key] = pref

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
    ap.add_argument("--workers", type=int, default=1,
                    help="Number of parallel workers for preference building (default: 1; >1 is experimental)")
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
        seed=args.seed,
        workers=args.workers,
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







