#!/usr/bin/env python3
"""
Generate individualized stable-marriage preference lists from a CSV.

- X (taxis) prefer Y (passengers) according to total_amount (higher better).
- Y (passengers) prefer X (taxis) according to tip_ratio = tip_amount / total_amount (higher better).
- Each agent gets their own list by sampling from a Plackett–Luce-like model using the Gumbel trick.
- Deterministic with --seed. Always complete and tie-free.

Output formats:
  --output-format ids (default) -> preferences over IDs (taxi_id 'x100', passenger_id 'y50')
  --output-format indices       -> preferences over indices 1..n, with mapping exported in TAXI_idx_map.csv

Optional CSV mapping (--out-map-csv) has rows for both papers and reviewers.

Usage:
python3 gen_instance_TAXI.py \
    --csv raw/TAXI_raw.csv \
    -n 100 \
    --sample-rows \
    --seed 42 \
    --temp-x 0.1 \  # Adjust the randomness level of the preference list. 
    --temp-y 0.1 \  # Lower values -> more deterministic rankings, higher values -> more diverse and random rankings
    --out-txt TAXI_100_instance.txt \
    --output-format indices \
    --out-map-csv TAXI_idx_map.csv
"""

import argparse, csv, json, math, random
from typing import List, Dict, Tuple
import sys

def load_rows(path: str, n: int, sample: bool) -> Tuple[List[float], List[float]]:
    # Read the total_amount and calculate the tip_ratio to be the order of each side's preference lists
    rows = []
    with open(path, newline="") as f:
        r = csv.reader(f)
        header = next(r)
        cols = {name.strip().lower(): idx for idx, name in enumerate(header)}
        for required in ("total_amount", "tip_amount"):
            if required not in cols:
                raise ValueError(f"Missing required column '{required}'. Found: {list(cols.keys())}")
        it, ia = cols["total_amount"], cols["tip_amount"]
        for row in r:
            try:
                total = float(row[it]); tip = float(row[ia])
            except Exception:
                continue
            if not (total == total and tip == tip):  # NaNs
                continue
            tip_ratio = (tip / total) if total > 0 else float("-inf")
            rows.append((total, tip_ratio))

    if len(rows) < n:
        raise ValueError(f"Only {len(rows)} valid rows; requested n={n}")

    if sample and len(rows) > n:
        rows = random.sample(rows, n)
    else:
        rows = rows[:n]

    totals = [t for (t, _) in rows]
    ratios = [tr for (_, tr) in rows]
    return totals, ratios

def zscore(xs: List[float]) -> List[float]:
    # Normalize the lists of scores to have mean=0 and standard deviation=1 (Z-scores)
    # to keep numeric scales comparable; 
    # handle +/-inf with +/-10 so they stay extreme but finite
    finite = [x for x in xs if math.isfinite(x)]
    if not finite:
        return [0.0]*len(xs)
    mu = sum(finite)/len(finite)
    var = sum((x-mu)**2 for x in finite)/len(finite)
    sd = math.sqrt(var) if var > 0 else 1.0
    def nz(x):
        if not math.isfinite(x):  # -inf goes very low
            return -10.0 if x < 0 else 10.0
        return (x - mu)/sd
    return [nz(x) for x in xs]  # The output is the exp value

def gumbel() -> float:
    # Sample a random number from a standard Gumbel distribution (0,1).
    # This is because the Gumbel–Max trick lets us turn a list of scores into a random ranking 
    # where higher scores are more likely to appear earlier 
    u = random.random()
    return -math.log(-math.log(max(u, 1e-12)))  ## The Gumbel distribution 

def pl_permutation(scores: List[float], temperature: float) -> List[int]:
    """
    Gumbel-top-k / Plackett–Luce style:
    return a permutation of indices, higher score more likely to be early.
    """
    if temperature <= 0:
        raise ValueError("temperature must be > 0")
    noisy = [(i, scores[i]/temperature + gumbel()) for i in range(len(scores))]
    # Sort by descending noisy score; break exact ties by index
    noisy.sort(key=lambda t: (-t[1], t[0]))
    return [i for (i, _) in noisy]

def build_preferences_individual(
    totals: List[float], ratios: List[float], temp_x: float, temp_y: float
):
    """
    Each X_i draws its own permutation of Y based on totals;
    Each Y_j draws its own permutation of X based on tip_ratios.
    """
    n = len(totals)
    x_ids = [f"x{i+1}" for i in range(n)]
    y_ids = [f"y{i+1}" for i in range(n)]

    # Normalize scores to keep temperatures meaningful
    t_scores = zscore(totals)
    r_scores = zscore(ratios)

    # X side: for each taxi, sample a Y permutation using totals
    x_prefs: Dict[str, List[str]] = {}
    for i, x in enumerate(x_ids):
        order = pl_permutation(t_scores, temp_x)
        x_prefs[x] = [y_ids[j] for j in order]

    # Y side: for each passenger, sample an X permutation using tip ratios
    y_prefs: Dict[str, List[str]] = {}
    for j, y in enumerate(y_ids):
        order = pl_permutation(r_scores, temp_y)
        y_prefs[y] = [x_ids[i] for i in order]

    return x_ids, y_ids, x_prefs, y_prefs

def verify_complete_no_ties(
    x_prefs: Dict[str, List[str]],
    y_prefs: Dict[str, List[str]],
    x_ids: List[str],
    y_ids: List[str],
) -> Dict[str, bool]:
    def is_complete(pref_dict, other_side):
        exp = set(other_side)
        return all(len(lst) == len(other_side) and set(lst) == exp for lst in pref_dict.values())

    def has_ties(pref_dict):
        for lst in pref_dict.values():
            if len(lst) != len(set(lst)):
                return True
        return False

    return {
        "complete_x_over_y": is_complete(x_prefs, y_ids),
        "complete_y_over_x": is_complete(y_prefs, x_ids),
        "no_ties_x_over_y": not has_ties(x_prefs),
        "no_ties_y_over_x": not has_ties(y_prefs),
    }

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--csv", required=True)
    p.add_argument("-n", type=int, required=True, help="agents per side")
    p.add_argument("--sample-rows", action="store_true", help="sample which rows to use (vs first n)")
    p.add_argument("--seed", type=int, default=0, help="RNG seed for reproducibility")
    p.add_argument("--temp-x", type=float, default=0.25, help="temperature for X's preferences (lower = closer to metric)")
    p.add_argument("--temp-y", type=float, default=0.25, help="temperature for Y's preferences (lower = closer to metric)")
    p.add_argument("--output-format", choices=["ids","indices"], default="ids",
                   help="ids: keep x1/y1 labels (default); indices: output 1..n indices for both sides")
    p.add_argument("--out-json", default=None)
    p.add_argument("--out-txt", default=None)
    p.add_argument("--out-map-csv", default=None, help="Optional CSV mapping indices↔IDs for both sides")
    args = p.parse_args()

    random.seed(args.seed)

    totals, ratios = load_rows(args.csv, args.n, sample=args.sample_rows)
    x_ids, y_ids, x_prefs_ids, y_prefs_ids = build_preferences_individual(totals, ratios, args.temp_x, args.temp_y)
    check = verify_complete_no_ties(x_prefs_ids, y_prefs_ids, x_ids, y_ids)

    # Show verification first
    print("Verification:")
    for k, v in check.items():
        print(f"  {k}: {v}")

    # Build index mappings if requested
    use_indices = (args.output_format == "indices")
    if use_indices:
        x_to_idx = {x: i+1 for i, x in enumerate(x_ids)}
        y_to_idx = {y: j+1 for j, y in enumerate(y_ids)}
        idx_to_x = {i+1: x for i, x in enumerate(x_ids)}
        idx_to_y = {j+1: y for j, y in enumerate(y_ids)}

        # Convert prefs to indices
        x_prefs = {x_to_idx[x]: [y_to_idx[y] for y in x_prefs_ids[x]] for x in x_ids}
        y_prefs = {y_to_idx[y]: [x_to_idx[x] for x in y_prefs_ids[y]] for y in y_ids}
    else:
        x_prefs = x_prefs_ids
        y_prefs = y_prefs_ids
        x_to_idx = y_to_idx = idx_to_x = idx_to_y = None

    # Quick peek
    def preview_ids(title, d, keys, k=5, m=20):
        print(f"\n{title} (showing {k} lists; top {m} choices):")
        for a in keys[:k]:
            print(f"  {a}: {' '.join(d[a][:m])}")

    def preview_indices(title, d, keys, k=5, m=20):
        print(f"\n{title} (indices) (showing {k} lists; top {m} choices):")
        for a in keys[:k]:
            top = ' '.join(str(t) for t in d[a][:m])
            print(f"  {a}: {top}")

    if use_indices:
        preview_indices("X→Y preferences", x_prefs, sorted(x_prefs.keys()))
        preview_indices("Y→X preferences", y_prefs, sorted(y_prefs.keys()))
    else:
        preview_ids("X→Y preferences", x_prefs, x_ids)
        preview_ids("Y→X preferences", y_prefs, y_ids)

    # JSON output
    if args.out_json:
        payload = {
            "output_format": args.output_format,
            "X_side_label": "x_index" if use_indices else "x_id",
            "Y_side_label": "y_index" if use_indices else "y_id",
            "X_prefs": x_prefs,
            "Y_prefs": y_prefs,
        }
        if use_indices:
            payload.update({
                "x_index_to_id": idx_to_x,
                "y_index_to_id": idx_to_y,
                "x_id_to_index": x_to_idx,
                "y_id_to_index": y_to_idx,
            })
        with open(args.out_json, "w") as f:
            json.dump(payload, f, indent=2)
        print(f"\nWrote JSON instance to: {args.out_json}")

    # TXT output
    if args.out_txt:
        with open(args.out_txt, "w") as f:
            if use_indices:
                f.write("X side (taxis indices) preferences over Y (passengers indices):\n")
                for xi in sorted(x_prefs.keys()):
                    f.write(f"{xi}: {' '.join(str(t) for t in x_prefs[xi])}\n")
                f.write("\nY side (passengers indices) preferences over X (taxis indices):\n")
                for yi in sorted(y_prefs.keys()):
                    f.write(f"{yi}: {' '.join(str(t) for t in y_prefs[yi])}\n")
            else:
                f.write("X side (taxis) preferences over Y (passengers):\n")
                for x in x_ids:
                    f.write(f"{x}: {' '.join(x_prefs[x])}\n")
                f.write("\nY side (passengers) preferences over X (taxis):\n")
                for y in y_ids:
                    f.write(f"{y}: {' '.join(y_prefs[y])}\n")
        print(f"Wrote text instance to: {args.out_txt}")

    # Mapping CSV (optional)
    if args.out_map_csv:
        with open(args.out_map_csv, "w", newline="", encoding="utf-8") as f:
            w = csv.writer(f)
            if use_indices:
                w.writerow(["side","index","id"])
                for i, x in enumerate(x_ids, start=1):
                    w.writerow(["X", i, x])
                for j, y in enumerate(y_ids, start=1):
                    w.writerow(["Y", j, y])
            else:
                w.writerow(["side","id"])
                for x in x_ids:
                    w.writerow(["X", x])
                for y in y_ids:
                    w.writerow(["Y", y])
        print(f"Wrote mapping CSV: {args.out_map_csv}")

if __name__ == "__main__":
    main()
