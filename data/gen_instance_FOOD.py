#!/usr/bin/env python3
"""
FOOD instance with Plackett–Luce (Gumbel-top-k) using the SAME core functions
(zscore, gumbel, pl_permutation) as in gen_instance_TAXI.py.

Sides
-----
- X = places (restaurants): rank users by *proximity* via PL over negative distance.
- Y = users: rank places by *their own ratings* via PL (unrated → baseline).

- Useful headers, comma-delimited:
    FOOD_rating_final.csv : userID,placeID,rating
    FOOD_userprofile.csv  : userID,latitude,longitude
    FOOD_geoplaces2.csv   : placeID,latitude,longitude
- Deterministic with --seed (uses Python's global `random`).

Usage
-----
python3 gen_instance_FOOD.py \
  --ratings raw/FOOD_rating_final.csv \
  --users   raw/FOOD_userprofile.csv \
  --places  raw/FOOD_geoplaces2.csv \
  -n 90 \
  --seed 42 \
  --temp-x 0.1 \
  --temp-y 0.1 \
  --unrated-baseline 0.0 \
  --strategy top \
  --out-txt FOOD_90_instance.txt \
  --output-format indices \
  --out-map-csv FOOD_idx_map.csv
"""

import argparse, csv, json, math, random
from collections import defaultdict
from typing import Dict, List, Tuple

# ---------------- Gumbel-top-k trick ----------------

def zscore(xs: List[float]) -> List[float]:
    import math
    finite = [x for x in xs if math.isfinite(x)]
    if not finite:
        return [0.0]*len(xs)
    mu = sum(finite)/len(finite)
    var = sum((x-mu)**2 for x in finite)/len(finite)
    sd = math.sqrt(var) if var > 0 else 1.0
    def nz(x):
        if not math.isfinite(x):
            return -10.0 if x < 0 else 10.0
        return (x - mu)/sd
    return [nz(x) for x in xs]

def gumbel() -> float:
    import math, random
    u = random.random()
    return -math.log(-math.log(max(u, 1e-12)))

def pl_permutation(scores: List[float], temperature: float) -> List[int]:
    if temperature <= 0:
        raise ValueError("temperature must be > 0")
    noisy = [(i, scores[i]/temperature + gumbel()) for i in range(len(scores))]
    noisy.sort(key=lambda t: (-t[1], t[0]))
    return [i for (i, _) in noisy]

# ---------------- FOOD-specific helpers ----------------

def haversine_km(lat1, lon1, lat2, lon2):
    R = 6371.0088
    p1, p2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dl   = math.radians(lon2 - lon1)
    a = math.sin(dphi/2)**2 + math.cos(p1)*math.cos(p2)*math.sin(dl/2)**2
    return 2 * R * math.asin(math.sqrt(a))

def parse_float(x):
    try:
        return float(x)
    except Exception:
        return None

# ---------------- Load CSVs with exact headers ----------------

def load_user_coords(path: str) -> Dict[str, Tuple[float, float]]:
    out = {}
    with open(path, newline="") as f:
        r = csv.DictReader(f)
        needed = {"userID","latitude","longitude"}
        if set(r.fieldnames or []) < needed:
            raise ValueError(f"{path} must have headers {needed}, got {r.fieldnames}")
        for row in r:
            uid = str(row["userID"]).strip()
            lat = parse_float(row["latitude"]) 
            lon = parse_float(row["longitude"]) 
            if uid and lat is not None and lon is not None:
                out[uid] = (lat, lon)
    if not out:
        raise ValueError("No valid user coords found.")
    return out

def load_place_coords(path: str) -> Dict[str, Tuple[float, float]]:
    out = {}
    with open(path, newline="") as f:
        r = csv.DictReader(f)
        needed = {"placeID","latitude","longitude"}
        if set(r.fieldnames or []) < needed:
            raise ValueError(f"{path} must have headers {needed}, got {r.fieldnames}")
        for row in r:
            pid = str(row["placeID"]).strip()
            lat = parse_float(row["latitude"]) 
            lon = parse_float(row["longitude"]) 
            if pid and lat is not None and lon is not None:
                out[pid] = (lat, lon)
    if not out:
        raise ValueError("No valid place coords found.")
    return out

def load_ratings(path: str) -> List[Tuple[str,str,float]]:
    rows = []
    with open(path, newline="") as f:
        r = csv.DictReader(f)
        needed = {"userID","placeID","rating"}
        if set(r.fieldnames or []) < needed:
            raise ValueError(f"{path} must have headers {needed}, got {r.fieldnames}")
        for row in r:
            uid = str(row["userID"]).strip()
            pid = str(row["placeID"]).strip()
            rt  = parse_float(row["rating"]) 
            if uid and pid and rt is not None:
                rows.append((uid,pid,rt))
    if not rows:
        raise ValueError("No ratings loaded.")
    return rows

# ---------------- Selection ----------------

def select_entities(
    ratings: List[Tuple[str,str,float]],
    user_coords: Dict[str,Tuple[float,float]],
    place_coords: Dict[str,Tuple[float,float]],
    n: int,
    seed: int,
    strategy: str = "top",
):
    filtered = [(u,p,r) for (u,p,r) in ratings if u in user_coords and p in place_coords]
    if not filtered:
        raise ValueError("No ratings where both user & place have coordinates.")

    by_user_count = defaultdict(int)
    by_place_count = defaultdict(int)
    by_user_ratings = defaultdict(dict)
    for u,p,r in filtered:
        by_user_count[u] += 1
        by_place_count[p] += 1
        by_user_ratings[u][p] = r

    users_all  = list(by_user_count.keys())
    places_all = list(by_place_count.keys())
    if len(users_all) < n or len(places_all) < n:
        raise ValueError(f"Need n={n}, but have users={len(users_all)}, places={len(places_all)}")

    random.seed(seed)
    if strategy == "random":
        users  = random.sample(users_all,  n)
        places = random.sample(places_all, n)
    else:  # "top"
        users  = sorted(users_all,  key=lambda u: (-by_user_count[u], u))[:n]
        places = sorted(places_all, key=lambda p: (-by_place_count[p], p))[:n]

    ratings_map = {u: {p: r for p, r in by_user_ratings[u].items() if p in places} for u in users}
    return users, places, ratings_map

# ---------------- Build preferences with PL (per-agent) ----------------

def build_prefs_pl(
    users: List[str],
    places: List[str],
    ratings_map: Dict[str,Dict[str,float]],
    user_coords: Dict[str,Tuple[float,float]],
    place_coords: Dict[str,Tuple[float,float]],
    temp_x: float,
    temp_y: float,
    unrated_baseline: float,
):
    # X = places → users (per place): utilities = -distance(user, place)
    X_prefs: Dict[str, List[str]] = {}
    for p in places:
        plat, plon = place_coords[p]
        scores = []
        for u in users:
            ulat, ulon = user_coords[u]
            d = haversine_km(ulat, ulon, plat, plon)
            scores.append(-d)
        order = pl_permutation(zscore(scores), temp_x)
        X_prefs[p] = [users[i] for i in order]

    # Y = users → places (per user): utilities = rating or baseline for unrated
    Y_prefs: Dict[str, List[str]] = {}
    for u in users:
        scores = []
        ur = ratings_map.get(u, {})
        for p in places:
            scores.append(ur.get(p, unrated_baseline))
        order = pl_permutation(zscore(scores), temp_y)
        Y_prefs[u] = [places[i] for i in order]

    return X_prefs, Y_prefs

# ---------------- Verification ----------------

def verify_complete_no_ties(
    X_prefs: Dict[str, List[str]],
    Y_prefs: Dict[str, List[str]],
    users: List[str],
    places: List[str],
) -> Dict[str, bool]:
    def is_complete(pref_dict, universe):
        S = set(universe)
        return all(len(lst) == len(universe) and set(lst) == S for lst in pref_dict.values())
    def has_ties(pref_dict):
        return any(len(lst) != len(set(lst)) for lst in pref_dict.values())
    return {
        "complete_X_over_Y": is_complete(X_prefs, users),
        "complete_Y_over_X": is_complete(Y_prefs, places),
        "no_ties_X_over_Y":  not has_ties(X_prefs),
        "no_ties_Y_over_X":  not has_ties(Y_prefs),
    }

# ---------------- CLI ----------------


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ratings", required=True)
    ap.add_argument("--users",   required=True)
    ap.add_argument("--places",  required=True)
    ap.add_argument("-n", type=int, required=True)
    ap.add_argument("--seed", type=int, default=0)
    ap.add_argument("--strategy", choices=["top","random"], default="top")
    ap.add_argument("--temp-x", type=float, default=0.01, help="temperature for X=places→users (distance)")
    ap.add_argument("--temp-y", type=float, default=0.01, help="temperature for Y=users→places (rating)")
    ap.add_argument("--unrated-baseline", type=float, default=0.0)
    # NEW:
    ap.add_argument("--output-format", choices=["ids","indices"], default="ids",
                    help="ids: keep placeID/userID labels (default); indices: output 1..n indices")
    ap.add_argument("--out-json", default=None)
    ap.add_argument("--out-txt",  default=None)
    ap.add_argument("--out-map-csv", default=None, help="Optional CSV mapping indices↔IDs for both sides.")
    args = ap.parse_args()

    random.seed(args.seed)

    user_coords  = load_user_coords(args.users)
    place_coords = load_place_coords(args.places)
    ratings      = load_ratings(args.ratings)

    users, places, ratings_map = select_entities(
        ratings, user_coords, place_coords, n=args.n, seed=args.seed, strategy=args.strategy
    )

    X_prefs_ids, Y_prefs_ids = build_prefs_pl(
        users, places, ratings_map, user_coords, place_coords,
        temp_x=args.__dict__["temp_x"], temp_y=args.__dict__["temp_y"],
        unrated_baseline=args.__dict__["unrated_baseline"],
    )

    check = verify_complete_no_ties(X_prefs_ids, Y_prefs_ids, users, places)
    print("Verification:")
    for k, v in check.items():
        print(f"  {k}: {v}")

    # -------- Output-format handling (IDs vs indices) --------
    use_indices = (args.output_format == "indices")
    if use_indices:
        # Build mappings: places = 1..n, users = 1..n (in the selected order)
        place_to_idx = {p: i+1 for i, p in enumerate(places)}
        user_to_idx  = {u: j+1 for j, u in enumerate(users)}
        idx_to_place = {i+1: p for i, p in enumerate(places)}
        idx_to_user  = {j+1: u for j, u in enumerate(users)}

        # Convert preference lists
        X_prefs = {place_to_idx[p]: [user_to_idx[u] for u in X_prefs_ids[p]] for p in places}
        Y_prefs = {user_to_idx[u]:  [place_to_idx[p] for p in Y_prefs_ids[u]] for u in users}
    else:
        X_prefs = X_prefs_ids
        Y_prefs = Y_prefs_ids
        place_to_idx = user_to_idx = idx_to_place = idx_to_user = None

    # -------- Preview --------
    def preview_ids(title, d, keys, k=3, m=10):
        print(f"\n{title} (showing {k}; top {m}):")
        for a in keys[:k]:
            print(f"  {a}: {' '.join(d[a][:m])}")

    def preview_indices(title, d, keys, k=3, m=10):
        print(f"\n{title} (indices) (showing {k}; top {m}):")
        for a in keys[:k]:
            print(f"  {a}: {' '.join(str(t) for t in d[a][:m])}")

    if use_indices:
        preview_indices("X (places) → users [PL / distance]", X_prefs, sorted(X_prefs.keys()))
        preview_indices("Y (users) → places [PL / rating]",  Y_prefs, sorted(Y_prefs.keys()))
    else:
        preview_ids("X (places) → users [PL / distance]", X_prefs, places)
        preview_ids("Y (users) → places [PL / rating]",  Y_prefs, users)

    # -------- JSON --------
    if args.out_json:
        payload = {
            "output_format": args.output_format,
            "X_side_label": "place_index" if use_indices else "placeID",
            "Y_side_label": "user_index"  if use_indices else "userID",
            "places": list(range(1, len(places)+1)) if use_indices else places,
            "users":  list(range(1, len(users)+1))  if use_indices else users,
            "X_prefs": X_prefs,
            "Y_prefs": Y_prefs,
            "temp_x": args.temp_x,
            "temp_y": args.temp_y,
            "unrated_baseline": args.unrated_baseline,
            "seed": args.seed,
        }
        if use_indices:
            payload.update({
                "place_index_to_id": idx_to_place,
                "user_index_to_id":  idx_to_user,
                "place_id_to_index": place_to_idx,
                "user_id_to_index":  user_to_idx,
            })
        with open(args.out_json, "w") as f:
            json.dump(payload, f, indent=2)
        print(f"\nWrote JSON: {args.out_json}")

    # -------- TXT --------
    if args.out_txt:
        with open(args.out_txt, "w") as f:
            if use_indices:
                f.write("X side (places indices) preferences over Y (users indices):\n")
                for i in sorted(X_prefs.keys()):
                    f.write(f"{i}: {' '.join(str(t) for t in X_prefs[i])}\n")
                f.write("\nY side (users indices) preferences over X (places indices):\n")
                for j in sorted(Y_prefs.keys()):
                    f.write(f"{j}: {' '.join(str(t) for t in Y_prefs[j])}\n")
            else:
                f.write("X side (places) preferences over Y (users):\n")
                for p in places:
                    f.write(f"{p}: {' '.join(X_prefs[p])}\n")
                f.write("\nY side (users) preferences over X (places):\n")
                for u in users:
                    f.write(f"{u}: {' '.join(Y_prefs[u])}\n")
        print(f"Wrote TXT: {args.out_txt}")

    # -------- Mapping CSV (optional) --------
    if args.out_map_csv:
        with open(args.out_map_csv, "w", newline="", encoding="utf-8") as f:
            w = csv.writer(f)
            if use_indices:
                w.writerow(["side","index","id"])
                for i, p in enumerate(places, start=1):
                    w.writerow(["X_place", i, p])
                for j, u in enumerate(users, start=1):
                    w.writerow(["Y_user", j, u])
            else:
                w.writerow(["side","id"])
                for p in places:
                    w.writerow(["X_place", p])
                for u in users:
                    w.writerow(["Y_user", u])
        print(f"Wrote mapping CSV: {args.out_map_csv}")

if __name__ == "__main__":
    main()
