#!/usr/bin/env python3
"""
FOOD instance generator with data augmentation support for large n (10000+)

This script extends gen_instance_FOOD.py to support large n values by:
1. Generating synthetic places and users based on existing data distribution
2. Generating synthetic ratings based on distance and rating patterns
3. Using vectorized computation and memory-efficient processing

Optimized for n up to 20000+ with:
- Vectorized haversine distance calculation
- Batch processing for preference generation
- Memory-efficient rating matrix operations

Usage
-----
python3 gen_instance_FOOD_augmented.py \
  --ratings raw/FOOD_rating_final.csv \
  --users   raw/FOOD_userprofile.csv \
  --places  raw/FOOD_geoplaces2.csv \
  -n 20000 \
  --seed 42 \
  --temp-x 0.1 \
  --temp-y 0.1 \
  --unrated-baseline 0.0 \
  --strategy top \
  --out-txt FOOD_20000_instance.txt \
  --output-format indices \
  --out-map-csv FOOD_idx_map.csv \
  --augment true
"""

import argparse, csv, math, random
from collections import defaultdict
from typing import Dict, List, Tuple
import numpy as np

# Import functions from original script
from gen_instance_FOOD import (
    zscore, gumbel, pl_permutation, haversine_km, parse_float,
    load_user_coords, load_place_coords, load_ratings,
    verify_complete_no_ties
)

# Optimized version of build_prefs_pl for large n
def build_prefs_pl_optimized(
    users: List[str],
    places: List[str],
    ratings_map: Dict[str,Dict[str,float]],
    user_coords: Dict[str,Tuple[float,float]],
    place_coords: Dict[str,Tuple[float,float]],
    temp_x: float,
    temp_y: float,
    unrated_baseline: float,
):
    """
    Optimized version using vectorized computation for large n.
    """
    # Prepare coordinate arrays
    user_lats = np.array([user_coords[u][0] for u in users])
    user_lons = np.array([user_coords[u][1] for u in users])
    place_lats = np.array([place_coords[p][0] for p in places])
    place_lons = np.array([place_coords[p][1] for p in places])
    
    # X = places → users: utilities = -distance(user, place)
    print(f"  Building X preferences (vectorized) for {len(places)} places...")
    dist_matrix = haversine_vectorized(user_lats, user_lons, place_lats, place_lons)
    # Transpose so rows are places, columns are users
    dist_matrix_X = dist_matrix.T  # shape: (n_places, n_users)
    scores_X = -dist_matrix_X
    
    X_prefs: Dict[str, List[str]] = {}
    batch_size = 1000
    for batch_start in range(0, len(places), batch_size):
        batch_end = min(batch_start + batch_size, len(places))
        if len(places) > 1000:
            print(f"    Processing places {batch_start+1}-{batch_end} of {len(places)}...")
        for i in range(batch_start, batch_end):
            p = places[i]
            scores = scores_X[i].tolist()
            order = pl_permutation(zscore(scores), temp_x)
            X_prefs[p] = [users[j] for j in order]
    
    # Free memory
    del dist_matrix, dist_matrix_X, scores_X
    
    # Y = users → places: utilities = rating or baseline
    print(f"  Building Y preferences (vectorized) for {len(users)} users...")
    scores_Y = np.full((len(users), len(places)), unrated_baseline)
    place_to_idx = {p: j for j, p in enumerate(places)}
    for i, u in enumerate(users):
        ur = ratings_map.get(u, {})
        for p, r in ur.items():
            if p in place_to_idx:
                scores_Y[i, place_to_idx[p]] = r
    
    Y_prefs: Dict[str, List[str]] = {}
    batch_size = 1000
    for batch_start in range(0, len(users), batch_size):
        batch_end = min(batch_start + batch_size, len(users))
        if len(users) > 1000:
            print(f"    Processing users {batch_start+1}-{batch_end} of {len(users)}...")
        for i in range(batch_start, batch_end):
            u = users[i]
            scores = scores_Y[i].tolist()
            order = pl_permutation(zscore(scores), temp_y)
            Y_prefs[u] = [places[j] for j in order]
    
    # Free memory
    del scores_Y
    
    return X_prefs, Y_prefs

# ---------------- Data Augmentation ----------------

def generate_synthetic_places(
    existing_places: List[str],
    place_coords: Dict[str, Tuple[float, float]],
    target_count: int,
    seed: int,
) -> Dict[str, Tuple[float, float]]:
    """
    Generate synthetic places by sampling from existing place distribution
    with small random perturbations. Optimized for large target_count.
    """
    random.seed(seed)
    np.random.seed(seed)
    
    # Get bounding box of existing places
    lats = [place_coords[p][0] for p in existing_places]
    lons = [place_coords[p][1] for p in existing_places]
    
    lat_min, lat_max = min(lats), max(lats)
    lon_min, lon_max = min(lons), max(lons)
    
    # Calculate spread (use 1.5x the range to allow some expansion)
    lat_range = lat_max - lat_min
    lon_range = lon_max - lon_min
    lat_spread = lat_range * 0.3  # 30% spread around existing area
    lon_spread = lon_range * 0.3
    
    synthetic = {}
    existing_list = list(existing_places)
    existing_coords = np.array([[place_coords[p][0], place_coords[p][1]] for p in existing_places])
    
    # Vectorized generation for large counts
    n_needed = target_count - len(existing_places)
    if n_needed > 0:
        # Sample base indices
        base_indices = np.random.randint(0, len(existing_places), size=n_needed)
        base_coords = existing_coords[base_indices]
        
        # Generate noise vectorized
        noise = np.random.normal(0, 0.045, size=(n_needed, 2))
        new_coords = base_coords + noise
        
        # Clamp to bounds
        new_coords[:, 0] = np.clip(new_coords[:, 0], lat_min - lat_spread, lat_max + lat_spread)
        new_coords[:, 1] = np.clip(new_coords[:, 1], lon_min - lon_spread, lon_max + lon_spread)
        
        # Convert to dictionary
        for idx, (new_lat, new_lon) in enumerate(new_coords):
            synthetic[f"SYN_PLACE_{len(existing_places) + idx}"] = (float(new_lat), float(new_lon))
    
    return synthetic

def generate_synthetic_users(
    existing_users: List[str],
    user_coords: Dict[str, Tuple[float, float]],
    target_count: int,
    seed: int,
) -> Dict[str, Tuple[float, float]]:
    """
    Generate synthetic users by sampling from existing user distribution
    with small random perturbations. Optimized for large target_count.
    """
    random.seed(seed + 1)  # Different seed for users
    np.random.seed(seed + 1)
    
    # Get bounding box of existing users
    lats = [user_coords[u][0] for u in existing_users]
    lons = [user_coords[u][1] for u in existing_users]
    
    lat_min, lat_max = min(lats), max(lats)
    lon_min, lon_max = min(lons), max(lons)
    
    # Calculate spread
    lat_range = lat_max - lat_min
    lon_range = lon_max - lon_min
    lat_spread = lat_range * 0.3
    lon_spread = lon_range * 0.3
    
    synthetic = {}
    existing_coords = np.array([[user_coords[u][0], user_coords[u][1]] for u in existing_users])
    
    # Vectorized generation for large counts
    n_needed = target_count - len(existing_users)
    if n_needed > 0:
        # Sample base indices
        base_indices = np.random.randint(0, len(existing_users), size=n_needed)
        base_coords = existing_coords[base_indices]
        
        # Generate noise vectorized
        noise = np.random.normal(0, 0.045, size=(n_needed, 2))
        new_coords = base_coords + noise
        
        # Clamp to bounds
        new_coords[:, 0] = np.clip(new_coords[:, 0], lat_min - lat_spread, lat_max + lat_spread)
        new_coords[:, 1] = np.clip(new_coords[:, 1], lon_min - lon_spread, lon_max + lon_spread)
        
        # Convert to dictionary
        for idx, (new_lat, new_lon) in enumerate(new_coords):
            synthetic[f"SYN_USER_{len(existing_users) + idx}"] = (float(new_lat), float(new_lon))
    
    return synthetic

def haversine_vectorized(user_lats, user_lons, place_lats, place_lons):
    """
    Vectorized haversine distance calculation.
    Returns matrix of distances: shape (n_users, n_places)
    """
    R = 6371.0088
    user_lats_rad = np.radians(user_lats)
    user_lons_rad = np.radians(user_lons)
    place_lats_rad = np.radians(place_lats)
    place_lons_rad = np.radians(place_lons)
    
    # Broadcasting: (n_users, 1) - (1, n_places) = (n_users, n_places)
    dlat = place_lats_rad[np.newaxis, :] - user_lats_rad[:, np.newaxis]
    dlon = place_lons_rad[np.newaxis, :] - user_lons_rad[:, np.newaxis]
    
    a = (np.sin(dlat/2)**2 + 
         np.cos(user_lats_rad[:, np.newaxis]) * np.cos(place_lats_rad[np.newaxis, :]) * 
         np.sin(dlon/2)**2)
    distances = 2 * R * np.arcsin(np.sqrt(a))
    return distances

def generate_synthetic_ratings(
    users: List[str],
    places: List[str],
    existing_ratings: Dict[str, Dict[str, float]],
    user_coords: Dict[str, Tuple[float, float]],
    place_coords: Dict[str, Tuple[float, float]],
    seed: int,
) -> Dict[str, Dict[str, float]]:
    """
    Generate synthetic ratings based on:
    1. Distance (closer places get higher ratings on average)
    2. Existing rating patterns
    Uses vectorized computation for efficiency.
    """
    random.seed(seed + 2)
    np.random.seed(seed + 2)
    
    # Analyze existing rating patterns
    all_ratings = []
    for u_ratings in existing_ratings.values():
        all_ratings.extend(u_ratings.values())
    
    if all_ratings:
        mean_rating = np.mean(all_ratings)
        std_rating = np.std(all_ratings) if len(all_ratings) > 1 else 1.0
    else:
        mean_rating = 2.5
        std_rating = 1.0
    
    # Prepare coordinate arrays for vectorized computation
    user_lats = np.array([user_coords[u][0] for u in users])
    user_lons = np.array([user_coords[u][1] for u in users])
    place_lats = np.array([place_coords[p][0] for p in places])
    place_lons = np.array([place_coords[p][1] for p in places])
    
    # Vectorized distance calculation
    print(f"  Computing distances (vectorized) for {len(users)} users x {len(places)} places...")
    dist_matrix = haversine_vectorized(user_lats, user_lons, place_lats, place_lons)
    max_dist = np.max(dist_matrix)
    print(f"  Max distance: {max_dist:.2f} km")
    
    # Pre-compute user means
    user_means = np.zeros(len(users))
    for i, u in enumerate(users):
        if u in existing_ratings and existing_ratings[u]:
            user_means[i] = np.mean(list(existing_ratings[u].values()))
        else:
            user_means[i] = mean_rating + np.random.normal(0, 0.3)
    
    # Build existing ratings matrix
    existing_matrix = np.full((len(users), len(places)), np.nan)
    place_to_idx = {p: i for i, p in enumerate(places)}
    for i, u in enumerate(users):
        if u in existing_ratings:
            for p, r in existing_ratings[u].items():
                if p in place_to_idx:
                    existing_matrix[i, place_to_idx[p]] = r
    
    # Generate ratings matrix (vectorized)
    print("  Generating ratings (vectorized)...")
    # Distance effect: closer = higher rating
    dist_effect = 0.5 * (1 - dist_matrix / max_dist) if max_dist > 0 else np.zeros_like(dist_matrix)
    
    # Base ratings with user bias and distance effect
    base_ratings = user_means[:, np.newaxis] + dist_effect
    
    # Add noise
    noise = np.random.normal(0, std_rating * 0.5, size=dist_matrix.shape)
    ratings_matrix = base_ratings + noise
    
    # Clamp to reasonable range
    ratings_matrix = np.clip(ratings_matrix, 0.5, 5.0)
    
    # Overwrite with existing ratings where available
    mask_existing = ~np.isnan(existing_matrix)
    ratings_matrix[mask_existing] = existing_matrix[mask_existing]
    
    # Convert to dictionary format (memory efficient for large n)
    print("  Converting ratings matrix to dictionary...")
    ratings_map = {}
    batch_size = 1000
    for batch_start in range(0, len(users), batch_size):
        batch_end = min(batch_start + batch_size, len(users))
        if len(users) > 1000:
            print(f"    Converting users {batch_start+1}-{batch_end} of {len(users)}...")
        for i in range(batch_start, batch_end):
            u = users[i]
            ratings_map[u] = {places[j]: float(ratings_matrix[i, j]) 
                             for j in range(len(places))}
    
    # Free memory
    del dist_matrix, existing_matrix, ratings_matrix, dist_effect, base_ratings, noise
    
    return ratings_map

# ---------------- Enhanced Selection ----------------

def select_entities_augmented(
    ratings: List[Tuple[str,str,float]],
    user_coords: Dict[str,Tuple[float,float]],
    place_coords: Dict[str,Tuple[float,float]],
    n: int,
    seed: int,
    strategy: str = "top",
    augment: bool = True,
):
    """
    Select entities, augmenting if needed to reach target n.
    """
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
    
    # Augment if needed
    if augment and (len(users_all) < n or len(places_all) < n):
        print(f"Augmenting data: have {len(users_all)} users, {len(places_all)} places, need {n}")
        
        # Generate synthetic places
        if len(places_all) < n:
            synthetic_places = generate_synthetic_places(
                places_all, place_coords, n, seed
            )
            place_coords.update(synthetic_places)
            places_all.extend(synthetic_places.keys())
            print(f"  Generated {len(synthetic_places)} synthetic places")
        
        # Generate synthetic users
        if len(users_all) < n:
            synthetic_users = generate_synthetic_users(
                users_all, user_coords, n, seed
            )
            user_coords.update(synthetic_users)
            users_all.extend(synthetic_users.keys())
            print(f"  Generated {len(synthetic_users)} synthetic users")
    
    if len(users_all) < n or len(places_all) < n:
        raise ValueError(f"Need n={n}, but have users={len(users_all)}, places={len(places_all)}")

    random.seed(seed)
    if strategy == "random":
        users  = random.sample(users_all,  n)
        places = random.sample(places_all, n)
    else:  # "top"
        # For synthetic entities, assign count based on existing pattern
        for u in users_all:
            if u not in by_user_count:
                by_user_count[u] = random.randint(1, 10)  # Random count for synthetic
        for p in places_all:
            if p not in by_place_count:
                by_place_count[p] = random.randint(1, 10)
        
        users  = sorted(users_all,  key=lambda u: (-by_user_count.get(u, 0), u))[:n]
        places = sorted(places_all, key=lambda p: (-by_place_count.get(p, 0), p))[:n]

    # Generate synthetic ratings for all user-place pairs
    ratings_map = generate_synthetic_ratings(
        users, places, by_user_ratings, user_coords, place_coords, seed
    )
    
    return users, places, ratings_map

# ---------------- Main CLI ----------------

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
    ap.add_argument("--out-txt", required=True, help="Output text file (required)")
    ap.add_argument("--augment", type=lambda x: x.lower() in ['true', '1', 'yes'], default=True,
                    help="Enable data augmentation for large n (default: True)")
    args = ap.parse_args()

    random.seed(args.seed)

    user_coords  = load_user_coords(args.users)
    place_coords = load_place_coords(args.places)
    ratings      = load_ratings(args.ratings)

    users, places, ratings_map = select_entities_augmented(
        ratings, user_coords, place_coords, n=args.n, seed=args.seed, 
        strategy=args.strategy, augment=args.augment
    )

    # Use optimized version for large n
    print("Building preferences...")
    X_prefs_ids, Y_prefs_ids = build_prefs_pl_optimized(
        users, places, ratings_map, user_coords, place_coords,
        temp_x=args.__dict__["temp_x"], temp_y=args.__dict__["temp_y"],
        unrated_baseline=args.__dict__["unrated_baseline"],
    )

    check = verify_complete_no_ties(X_prefs_ids, Y_prefs_ids, users, places)
    if not all(check.values()):
        print("Warning: Verification failed!")
        for k, v in check.items():
            if not v:
                print(f"  {k}: {v}")

    # Build index mappings (always use 0-based indices)
    place_to_idx = {p: i for i, p in enumerate(places)}
    user_to_idx = {u: j for j, u in enumerate(users)}

    # Convert prefs to indices (0-based)
    X_prefs = [[user_to_idx[u] for u in X_prefs_ids[p]] for p in places]
    Y_prefs = [[place_to_idx[p] for p in Y_prefs_ids[u]] for u in users]

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

