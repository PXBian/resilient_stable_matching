#!/usr/bin/env python3
"""
Generate individualized stable-marriage preferences from ADM_Norway_raw.csv (or similar).

X side ("intuition"): prefers Y by smaller Priority (lower = better).
Y side ("student"):  prefers X by higher accepted_ratio = Accepted Offer / Admission Offer.

- Auto-detects CSV/TSV delimiter (or override with --delim).
- Each agent has their own list (via Gumbel/Plackett–Luce sampling).
- Complete and tie-free by construction.
- Deterministic & reproducible with --seed.

Output formats:
  --output-format ids      (default) -> preferences over IDs (paper_id 'Txx:vid', reviewer_id 'A000001')
  --output-format indices  -> preferences over indices 1..n, with mapping exported in JSON and optional CSV

Optional CSV mapping (--out-map-csv) has rows for both papers and reviewers.

Usage example:
  python3 gen_instance_ADM.py \
    --csv raw/ADM_Norway_raw.csv \
    -n 200 \
    --seed 42 \
    --temp-x 0.1 \
    --temp-y 0.1 \
    --out-txt  ADM_200_instance.txt \
    --output-format indices \
    --out-map-csv ADM_idx_map.csv
"""

import argparse
import csv
import json
import math
import random
from typing import List, Dict, Tuple, Optional

# ---------- CSV helpers ----------

def open_csv_reader(path: str, delim: Optional[str] = None):
    """
    Open a CSV/TSV with auto-detected delimiter (unless delim is provided).
    Returns (reader, file_handle).
    """
    f = open(path, newline="")
    if delim is not None:
        reader = csv.reader(f, delimiter=delim)
        return reader, f

    # Try to detect among common delimiters
    head = f.read(4096)
    f.seek(0)
    try:
        dialect = csv.Sniffer().sniff(head, delimiters=",;\t|")
        reader = csv.reader(f, dialect)
    except csv.Error:
        # Fallback: assume comma
        reader = csv.reader(f, delimiter=",")
    return reader, f

def normalize_header(header: List[str]) -> List[str]:
    # Lowercase & strip spaces; also collapse multiple spaces
    return [" ".join(h.strip().lower().split()) for h in header]

def find_cols(header: List[str], variants: Dict[str, List[str]]) -> Dict[str, int]:
    """
    Map logical names -> column indices using a list of acceptable header variants.
    Header is assumed already normalized.
    """
    index = {h: i for i, h in enumerate(header)}
    out: Dict[str, int] = {}
    for logical, opts in variants.items():
        hit = None
        for name in opts:
            key = " ".join(name.strip().lower().split())
            if key in index:
                hit = index[key]
                break
        if hit is None:
            raise ValueError(
                f"Missing a column for '{logical}'. Found headers: {list(index.keys())}"
            )
        out[logical] = hit
    return out

# ---------- Core data loading ----------

def load_rows(path: str, n: int, sample_rows: bool, delim: Optional[str]) -> Tuple[List[float], List[float]]:
    """
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
        raise ValueError(f"Only {len(rows)} valid rows; requested n={n}.")

    if sample_rows and len(rows) > n:
        rows = random.sample(rows, n)
    else:
        rows = rows[:n]

    pri_scores = [a for (a, _) in rows]
    acc_scores = [b for (_, b) in rows]
    return pri_scores, acc_scores

# ---------- Preference generation (Gumbel / Plackett–Luce) ----------

def zscore(xs: List[float]) -> List[float]:
    finite = [x for x in xs if math.isfinite(x)]
    if not finite:
        return [0.0] * len(xs)
    mu = sum(finite) / len(finite)
    var = sum((x - mu) ** 2 for x in finite) / len(finite)
    sd = math.sqrt(var) if var > 0 else 1.0

    def norm(x: float) -> float:
        if not math.isfinite(x):
            return -10.0 if x < 0 else 10.0
        return (x - mu) / sd

    return [norm(x) for x in xs]

def gumbel() -> float:
    u = max(random.random(), 1e-12)
    return -math.log(-math.log(u))

def pl_permutation(scores: List[float], temperature: float) -> List[int]:
    """
    Plackett–Luce via the Gumbel trick: sample a permutation biased by scores.
    Higher scores more likely earlier in the order.
    """
    if temperature <= 0:
        raise ValueError("temperature must be > 0")
    noisy = [(i, scores[i] / temperature + gumbel()) for i in range(len(scores))]
    # Strict ordering: break exact ties deterministically by index
    noisy.sort(key=lambda t: (-t[1], t[0]))
    return [i for (i, _) in noisy]

def build_preferences_individual(
    pri_scores: List[float], acc_scores: List[float], temp_x: float, temp_y: float
):
    """
    - For each X_i (intuition): sample a permutation of Y by pri_scores (smaller Priority -> higher score).
    - For each Y_j (student):   sample a permutation of X by acc_scores (higher accepted ratio -> higher score).
    """
    n = len(pri_scores)
    x_ids = [f"x{i+1}" for i in range(n)]
    y_ids = [f"y{i+1}" for i in range(n)]

    ps = zscore(pri_scores)
    rs = zscore(acc_scores)

    x_prefs: Dict[str, List[str]] = {}
    for x in x_ids:
        order = pl_permutation(ps, temp_x)
        x_prefs[x] = [y_ids[j] for j in order]

    y_prefs: Dict[str, List[str]] = {}
    for y in y_ids:
        order = pl_permutation(rs, temp_y)
        y_prefs[y] = [x_ids[i] for i in order]

    return x_ids, y_ids, x_prefs, y_prefs

# ---------- Verification ----------

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

# ---------- CLI ----------


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--csv", required=True, help="Path to ADM_Norway_raw.csv (CSV/TSV; delimiter auto-detected).")
    ap.add_argument("-n", type=int, required=True, help="Number of agents per side.")
    ap.add_argument("--seed", type=int, default=0, help="RNG seed for reproducibility.")
    ap.add_argument("--sample-rows", action="store_true", help="Sample which rows to use (vs take first n).")
    ap.add_argument("--temp-x", type=float, default=0.01, help="Temperature for X (lower = closer to metric).")
    ap.add_argument("--temp-y", type=float, default=0.01, help="Temperature for Y (lower = closer to metric).")
    ap.add_argument("--delim", default=None,
                    help="Override delimiter (e.g. ',' or '\\t'). If omitted, we auto-detect.")
    ap.add_argument("--output-format", choices=["ids","indices"], default="ids",
                    help="ids: keep x1/y1 labels (default); indices: output 1..n indices for both sides")
    ap.add_argument("--out-json", default=None, help="Write preferences to JSON.")
    ap.add_argument("--out-txt", default=None, help="Write human-readable TXT.")
    ap.add_argument("--out-map-csv", default=None, help="Optional CSV mapping indices↔IDs for both sides.")
    args = ap.parse_args()

    random.seed(args.seed)

    pri_scores, acc_scores = load_rows(args.csv, args.n, sample_rows=args.sample_rows, delim=args.delim)
    x_ids, y_ids, x_prefs_ids, y_prefs_ids = build_preferences_individual(pri_scores, acc_scores, args.temp_x, args.temp_y)
    check = verify_complete_no_ties(x_prefs_ids, y_prefs_ids, x_ids, y_ids)

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

    # Small preview
    def preview_ids(title, d, keys, k=3, m=10):
        print(f"\n{title} (showing {k} agents; top {m} choices each):")
        for a in keys[:k]:
            print(f"  {a}: {' '.join(d[a][:m])}")

    def preview_indices(title, d, keys, k=3, m=10):
        print(f"\n{title} (indices) (showing {k} agents; top {m} choices each):")
        for a in keys[:k]:
            print(f"  {a}: {' '.join(str(t) for t in d[a][:m])}")

    if use_indices:
        preview_indices("X (intuition) → Y (students)", x_prefs, sorted(x_prefs.keys()))
        preview_indices("Y (students) → X (intuition)", y_prefs, sorted(y_prefs.keys()))
    else:
        preview_ids("X (intuition) → Y (students)", x_prefs, x_ids)
        preview_ids("Y (students) → X (intuition)", y_prefs, y_ids)

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
        print(f"\nWrote JSON: {args.out_json}")

    # TXT output
    if args.out_txt:
        with open(args.out_txt, "w") as f:
            if use_indices:
                f.write("X side (intuition indices) preferences over Y (student indices):\n")
                for xi in sorted(x_prefs.keys()):
                    f.write(f"{xi}: {' '.join(str(t) for t in x_prefs[xi])}\n")
                f.write("\nY side (student indices) preferences over X (intuition indices):\n")
                for yi in sorted(y_prefs.keys()):
                    f.write(f"{yi}: {' '.join(str(t) for t in y_prefs[yi])}\n")
            else:
                f.write("X side (intuition) preferences over Y (students):\n")
                for x in x_ids:
                    f.write(f"{x}: {' '.join(x_prefs[x])}\n")
                f.write("\nY side (students) preferences over X (intuition):\n")
                for y in y_ids:
                    f.write(f"{y}: {' '.join(y_prefs[y])}\n")
        print(f"Wrote TXT: {args.out_txt}")

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
