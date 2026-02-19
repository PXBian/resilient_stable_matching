#!/usr/bin/env python3
"""
Generate bipartite matching instance for taxi matching: Drivers ↔ Orders

Design:
- X side: Drivers (based on dropoff location, historical revenue)
- Y side: Orders (based on pickup location, order amount)

Preference design for maximizing rotations and arcs:
- X (drivers) prefer Y (orders) by:
  * Revenue (order amount) - primary factor
  * Distance (from driver's current location to pickup) - secondary factor
  * Individual preferences and pair-wise noise for diversity
  
- Y (orders) prefer X (drivers) by:
  * Distance (from driver to pickup) - primary factor (passengers want quick pickup)
  * Driver quality (estimated from historical fare) - secondary factor
  * Individual preferences and pair-wise noise for diversity

The asymmetric preferences (drivers prioritize revenue, orders prioritize proximity)
combined with individual noise create many rotations while maintaining realistic scenarios.

Sampling: Plackett-Luce model using Gumbel trick (reference: gen_instance_BIKE_augmented.py)

Output format:
- First n lines: X side (drivers) preference lists, each with n integers (0-based indices)
- Next n lines: Y side (orders) preference lists, each with n integers (0-based indices)

Usage:
python3 gen_instance_TAXI_new.py \
    --csv raw/TAXI_raw.csv \
    -n 500 \
    --seed 42 \
    --temp-x 0.9 \
    --temp-y 0.9 \
    --out-txt TAXI_new_500_instance.txt
"""

import argparse
import csv
import math
import random
from typing import List, Dict, Tuple, Optional
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path

try:
    import geopandas as gpd
    import numpy as np
    HAS_GEO = True
except ImportError:
    HAS_GEO = False
    np = None

# ==================== Data Structures ====================

@dataclass
class Driver:
    """Driver/vehicle entity"""
    driver_id: str
    location: int  # DOLocationID (current location after last dropoff)
    fare_avg: float  # Average fare from historical data
    trip_count: int  # Number of trips (for quality estimation)

@dataclass
class Order:
    """Order/passenger request entity"""
    order_id: str
    pickup_loc: int  # PULocationID
    total_amount: float  # Total order amount
    trip_distance: float  # Trip distance
    hour: int  # Pickup hour (0-23)

# ==================== Data Augmentation ====================

def generate_synthetic_drivers(
    existing_drivers: List[Driver],
    target_count: int,
    seed: int,
) -> List[Driver]:
    """
    Generate synthetic drivers by sampling from existing driver distribution.

    - Maintain realistic application: many taxis can share the same zone (location).
    - Use trip_count as a proxy for how "busy" a driver/location is and sample accordingly.
    - Add small noise to fare_avg to create heterogeneity.
    """
    if not existing_drivers:
        return []

    random.seed(seed)
    if np is not None:
        np.random.seed(seed)

    # Probabilities proportional to trip_count (busier drivers/locations more likely)
    trip_counts = [max(1, d.trip_count) for d in existing_drivers]
    total_trips = sum(trip_counts)
    probs = [tc / total_trips for tc in trip_counts]

    n_existing = len(existing_drivers)
    n_needed = max(0, target_count - n_existing)
    synthetic: List[Driver] = []

    if n_needed == 0:
        return synthetic

    # Use numpy for fast sampling when available
    if np is not None:
        indices = np.random.choice(len(existing_drivers), size=n_needed, p=probs)
        for idx, base_idx in enumerate(indices):
            base = existing_drivers[base_idx]
            # Small multiplicative noise on fare_avg
            if base.fare_avg > 0:
                noise_factor = float(np.random.normal(1.0, 0.1))
                fare_avg = max(0.0, base.fare_avg * noise_factor)
            else:
                fare_avg = 0.0
            trip_multiplier = max(0.5, float(np.random.normal(1.0, 0.3)))
            trip_count = max(1, int(base.trip_count * trip_multiplier))
            synthetic.append(Driver(
                driver_id=f"SYN_DRIVER_{n_existing + idx}",
                location=base.location,
                fare_avg=fare_avg,
                trip_count=trip_count,
            ))
    else:
        # Fallback: pure Python sampling
        for i in range(n_needed):
            base = random.choices(existing_drivers, weights=trip_counts, k=1)[0]
            noise_factor = random.gauss(1.0, 0.1) if base.fare_avg > 0 else 1.0
            fare_avg = max(0.0, base.fare_avg * noise_factor)
            trip_multiplier = max(0.5, random.gauss(1.0, 0.3))
            trip_count = max(1, int(base.trip_count * trip_multiplier))
            synthetic.append(Driver(
                driver_id=f"SYN_DRIVER_{n_existing + i}",
                location=base.location,
                fare_avg=fare_avg,
                trip_count=trip_count,
            ))

    return synthetic

# ==================== Data Loading ====================

def load_taxi_data(
    csv_path: str,
    n: int,
    sample: bool,
    augment: bool,
    seed: int,
) -> Tuple[List[Driver], List[Order]]:
    """
    Load drivers and orders from TAXI_raw.csv
    
    Drivers: based on dropoff locations (DOLocationID)
    Orders: based on pickup locations (PULocationID)
    """
    drivers = []
    orders = []
    driver_stats = defaultdict(lambda: {'fare_sum': 0.0, 'trip_count': 0})
    
    with open(csv_path, newline="", encoding="utf-8") as f:
        reader = csv.reader(f)
        header = next(reader)
        cols = {name.strip().lower(): idx for idx, name in enumerate(header)}
        
        # Required columns
        required = ["total_amount", "fare_amount", "pulocationid", "dolocationid", 
                   "trip_distance", "tpep_pickup_datetime"]
        missing = [r for r in required if r not in cols]
        if missing:
            raise ValueError(f"Missing required columns: {missing}. Found: {list(cols.keys())[:20]}...")
        
        it = cols["total_amount"]
        ifa = cols["fare_amount"]
        ipu = cols["pulocationid"]
        ido = cols["dolocationid"]
        idist = cols["trip_distance"]
        ipick = cols["tpep_pickup_datetime"]
        
        # Optional columns
        itip = cols.get("tip_amount")
        
        for row in reader:
            try:
                total = float(row[it])
                fare = float(row[ifa])
                dist = float(row[idist])
            except (ValueError, IndexError):
                continue
            
            if not (math.isfinite(total) and math.isfinite(fare) and 
                    math.isfinite(dist) and dist >= 0):
                continue
            
            # Parse locations
            try:
                pu_loc = int(float(row[ipu])) if ipu < len(row) and row[ipu].strip() else None
                do_loc = int(float(row[ido])) if ido < len(row) and row[ido].strip() else None
            except (ValueError, IndexError):
                pu_loc = do_loc = None
            
            if pu_loc is None or do_loc is None:
                continue
            
            # Parse time (extract hour)
            hour = 0
            if ipick < len(row):
                try:
                    time_str = row[ipick]
                    if ' ' in time_str:
                        hour = int(time_str.split()[1].split(':')[0])
                except (ValueError, IndexError):
                    pass
            
            # Track driver statistics (by dropoff location as proxy for driver)
            driver_key = do_loc
            driver_stats[driver_key]['fare_sum'] += fare
            driver_stats[driver_key]['trip_count'] += 1
            
            # Create order
            orders.append(Order(
                order_id=f"order_{len(orders)}",
                pickup_loc=pu_loc,
                total_amount=total,
                trip_distance=dist,
                hour=hour
            ))
    
    # Create drivers from statistics
    for loc, stats in driver_stats.items():
        fare_avg = stats['fare_sum'] / stats['trip_count'] if stats['trip_count'] > 0 else 0.0
        drivers.append(Driver(
            driver_id=f"driver_{loc}",
            location=loc,
            fare_avg=fare_avg,
            trip_count=stats['trip_count']
        ))
    
    # Augment drivers if needed (orders are already plentiful)
    if len(drivers) < n:
        if augment:
            print(f"Augmenting drivers: have {len(drivers)}, need {n}")
            synthetic_drivers = generate_synthetic_drivers(drivers, n, seed)
            drivers.extend(synthetic_drivers)
            print(f"  Generated {len(synthetic_drivers)} synthetic drivers")
        else:
            raise ValueError(f"Only {len(drivers)} drivers, {len(orders)} orders; need {n} each (use --augment to enable driver augmentation)")

    if len(orders) < n:
        raise ValueError(f"Only {len(orders)} orders; need {n}")
    
    # Sample or take first n
    if sample:
        drivers = random.sample(drivers, n)
        orders = random.sample(orders, n)
    else:
        # Sort drivers by trip_count (most active first) and take first n
        drivers.sort(key=lambda d: -d.trip_count)
        drivers = drivers[:n]
        orders = orders[:n]
    
    return drivers, orders

# ==================== Distance Calculation ====================

def load_zone_centroids(zones_dir: Optional[str] = None) -> Dict[int, Tuple[float, float]]:
    """
    Load zone centroids from taxi_zones shapefile.
    Returns dict: LocationID -> (lat_rad, lon_rad)
    """
    if not HAS_GEO:
        return {}
    
    if zones_dir is None:
        zones_dir = "taxi_zones"
    
    zones_path = Path(zones_dir)
    shp_path = zones_path / "taxi_zones.shp"
    
    if not shp_path.exists():
        candidates = list(zones_path.rglob("*.shp"))
        if candidates:
            shp_path = candidates[0]
        else:
            return {}
    
    try:
        gdf = gpd.read_file(shp_path)
        
        if "LocationID" not in gdf.columns:
            return {}
        
        try:
            if gdf.crs is None:
                gdf = gdf.set_crs(epsg=2263, allow_override=True)
            
            if not str(gdf.crs).startswith('EPSG:2263'):
                gdf_proj = gdf.to_crs(epsg=2263)
            else:
                gdf_proj = gdf
            
            cent_proj = gdf_proj.geometry.centroid
            gdf_wgs = gdf_proj.to_crs(epsg=4326)
            lat = gdf_wgs.geometry.centroid.y.to_numpy()
            lon = gdf_wgs.geometry.centroid.x.to_numpy()
        except Exception as e:
            try:
                if gdf.crs is None:
                    gdf = gdf.set_crs(epsg=4326, allow_override=True)
                gdf_wgs = gdf.to_crs(epsg=4326)
                rep_point = gdf_wgs.geometry.representative_point()
                lat = rep_point.y.to_numpy()
                lon = rep_point.x.to_numpy()
            except:
                raise e
        
        loc = gdf["LocationID"].astype(int).to_numpy()
        
        out = {int(loc[i]): (math.radians(float(lat[i])), math.radians(float(lon[i]))) 
               for i in range(len(loc))}
        return out
    except Exception as e:
        print(f"Warning: Could not load zone centroids: {e}")
        return {}

def haversine_km(lat1_rad: float, lon1_rad: float, lat2_rad: float, lon2_rad: float) -> float:
    """Compute Haversine distance between two points in km. Inputs are in radians."""
    R = 6371.0088  # Earth radius in km
    dlat = lat2_rad - lat1_rad
    dlon = lon2_rad - lon1_rad
    a = math.sin(dlat/2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlon/2)**2
    c = 2 * math.asin(math.sqrt(a))
    return R * c

def compute_location_distance(
    loc1: int, 
    loc2: int, 
    zone_centroids: Optional[Dict[int, Tuple[float, float]]] = None
) -> float:
    """Compute distance between two location IDs using real geographic coordinates."""
    if loc1 is None or loc2 is None:
        return 50.0  # Default large distance
    
    if zone_centroids and loc1 in zone_centroids and loc2 in zone_centroids:
        lat1, lon1 = zone_centroids[loc1]
        lat2, lon2 = zone_centroids[loc2]
        return haversine_km(lat1, lon1, lat2, lon2)
    
    # Fallback: approximate distance based on zone ID difference
    diff = abs(loc1 - loc2)
    return math.sqrt(diff) * 2.0  # Approximate km

# ==================== Preference Score Calculation ====================

def compute_driver_preference_scores(
    driver: Driver,
    orders: List[Order],
    zone_centroids: Optional[Dict[int, Tuple[float, float]]],
    alpha: float = 1.0,  # Weight for revenue
    beta: float = 0.5,   # Weight for distance
    individual_noise_scale: float = 0.4
) -> List[float]:
    """
    Compute preference scores for a driver over all orders.
    Score_driver→order = α·Revenue(order) - β·Distance(driver_loc, pickup_loc) + IndividualNoise
    
    Drivers prioritize revenue but also consider distance (moderate preference).
    Individual noise increases diversity and rotation count.
    """
    scores = []
    
    # Normalize order amounts
    all_amounts = [o.total_amount for o in orders]
    max_amount = max(all_amounts) if all_amounts else 1.0
    min_amount = min(all_amounts) if all_amounts else 0.0
    amount_range = max_amount - min_amount if max_amount > min_amount else 1.0
    
    # Generate driver-specific random seed for consistent individual noise
    driver_hash = hash(driver.driver_id) % (2**31)
    
    for order in orders:
        # Revenue component (primary factor)
        norm_amount = (order.total_amount - min_amount) / amount_range if amount_range > 0 else 0.0
        revenue_score = alpha * norm_amount
        
        # Distance component (secondary factor)
        pickup_dist_km = compute_location_distance(driver.location, order.pickup_loc, zone_centroids)
        # Normalize distance (assume max ~50km in city)
        norm_dist = min(pickup_dist_km / 50.0, 1.0)
        distance_cost = beta * norm_dist
        
        # Base score
        base_score = revenue_score - distance_cost
        
        # Pair-wise individual noise (KEY for rotation count)
        # Each driver-order pair has unique noise, creating fully pair-specific score matrix
        pair_hash = hash((driver.driver_id, order.order_id)) % (2**31)
        pair_rng = random.Random(pair_hash)
        pair_noise = pair_rng.gauss(0, individual_noise_scale)
        
        score = base_score + pair_noise
        scores.append(score)
    
    return scores

def compute_order_preference_scores(
    order: Order,
    drivers: List[Driver],
    zone_centroids: Optional[Dict[int, Tuple[float, float]]],
    a: float = 1.0,      # Weight for distance (primary for orders)
    b: float = 0.3,     # Weight for driver quality
    individual_noise_scale: float = 0.4
) -> List[float]:
    """
    Compute preference scores for an order over all drivers.
    Score_order→driver = -a·Distance(driver_loc, pickup_loc) + b·DriverQuality + IndividualNoise
    
    Orders prioritize proximity (want quick pickup) but also consider driver quality.
    Individual noise increases diversity and rotation count.
    """
    scores = []
    
    # Normalize driver quality (based on fare_avg as proxy)
    all_fares = [d.fare_avg for d in drivers]
    max_fare = max(all_fares) if all_fares else 1.0
    min_fare = min(all_fares) if all_fares else 0.0
    fare_range = max_fare - min_fare if max_fare > min_fare else 1.0
    
    # Generate order-specific random seed for consistent individual noise
    order_hash = hash(order.order_id) % (2**31)
    
    for driver in drivers:
        # Distance component (primary factor - orders want nearby drivers)
        pickup_dist_km = compute_location_distance(driver.location, order.pickup_loc, zone_centroids)
        # Normalize distance (assume max ~50km in city)
        norm_dist = min(pickup_dist_km / 50.0, 1.0)
        distance_cost = a * norm_dist  # Negative preference for distance
        
        # Driver quality component (secondary factor)
        norm_quality = (driver.fare_avg - min_fare) / fare_range if fare_range > 0 else 0.0
        quality_score = b * norm_quality
        
        # Base score (negative distance means prefer closer)
        base_score = -distance_cost + quality_score
        
        # Pair-wise individual noise (KEY for rotation count)
        # Each order-driver pair has unique noise, creating fully pair-specific score matrix
        pair_hash = hash((order.order_id, driver.driver_id)) % (2**31)
        pair_rng = random.Random(pair_hash)
        pair_noise = pair_rng.gauss(0, individual_noise_scale)
        
        score = base_score + pair_noise
        scores.append(score)
    
    return scores

# ==================== Preference List Generation ====================

def zscore(xs: List[float]) -> List[float]:
    """Normalize scores to z-scores"""
    finite = [x for x in xs if math.isfinite(x)]
    if not finite:
        return [0.0] * len(xs)
    mu = sum(finite) / len(finite)
    var = sum((x - mu) ** 2 for x in finite) / len(finite)
    sd = math.sqrt(var) if var > 0 else 1.0
    
    def nz(x):
        if not math.isfinite(x):
            return -10.0 if x < 0 else 10.0
        return (x - mu) / sd
    
    return [nz(x) for x in xs]

def gumbel() -> float:
    """Sample from standard Gumbel distribution"""
    u = random.random()
    return -math.log(-math.log(max(u, 1e-12)))

def pl_permutation(scores: List[float], temperature: float) -> List[int]:
    """Generate permutation using Plackett-Luce model with Gumbel trick"""
    if temperature <= 0:
        raise ValueError("temperature must be > 0")
    noisy = [(i, scores[i] / temperature + gumbel()) for i in range(len(scores))]
    noisy.sort(key=lambda t: (-t[1], t[0]))
    return [i for (i, _) in noisy]

def build_preferences(
    drivers: List[Driver],
    orders: List[Order],
    zone_centroids: Optional[Dict[int, Tuple[float, float]]],
    temp_x: float,
    temp_y: float,
    alpha: float = 1.0,
    beta: float = 0.5,
    a: float = 1.0,
    b: float = 0.3,
    individual_noise_scale: float = 0.4
) -> Tuple[List[List[int]], List[List[int]]]:
    """
    Build preference lists for both sides.
    Uses Plackett-Luce sampling with Gumbel trick for diversity.
    """
    n = len(drivers)
    
    # X side: drivers rank orders
    print(f"  Building X preferences (drivers → orders) for {n} drivers...")
    X_prefs = []
    batch_size = 1000
    for batch_start in range(0, n, batch_size):
        batch_end = min(batch_start + batch_size, n)
        if n > 1000:
            print(f"    Processing drivers {batch_start+1}-{batch_end} of {n}...")
        for i in range(batch_start, batch_end):
            driver = drivers[i]
            scores = compute_driver_preference_scores(
                driver, orders, zone_centroids, alpha, beta, individual_noise_scale
            )
            norm_scores = zscore(scores)
            order = pl_permutation(norm_scores, temp_x)
            X_prefs.append(order)
    
    # Y side: orders rank drivers
    print(f"  Building Y preferences (orders → drivers) for {n} orders...")
    Y_prefs = []
    for batch_start in range(0, n, batch_size):
        batch_end = min(batch_start + batch_size, n)
        if n > 1000:
            print(f"    Processing orders {batch_start+1}-{batch_end} of {n}...")
        for i in range(batch_start, batch_end):
            order = orders[i]
            scores = compute_order_preference_scores(
                order, drivers, zone_centroids, a, b, individual_noise_scale
            )
            norm_scores = zscore(scores)
            order = pl_permutation(norm_scores, temp_y)
            Y_prefs.append(order)
    
    return X_prefs, Y_prefs

# ==================== Verification ====================

def verify_complete_no_ties(
    x_prefs: List[List[int]],
    y_prefs: List[List[int]],
    n: int,
) -> Dict[str, bool]:
    """Verify completeness and no ties"""
    def is_complete(pref_lists, other_size):
        return all(len(lst) == other_size and set(lst) == set(range(other_size)) 
                   for lst in pref_lists)
    
    def has_ties(pref_lists):
        return any(len(lst) != len(set(lst)) for lst in pref_lists)
    
    return {
        "complete_x_over_y": is_complete(x_prefs, n),
        "complete_y_over_x": is_complete(y_prefs, n),
        "no_ties_x_over_y": not has_ties(x_prefs),
        "no_ties_y_over_x": not has_ties(y_prefs),
    }

# ==================== Main ====================

def main():
    parser = argparse.ArgumentParser(
        description="Generate taxi matching instance (Drivers ↔ Orders)"
    )
    parser.add_argument("--csv", required=True, help="Path to TAXI_raw.csv")
    parser.add_argument("-n", type=int, required=True, help="Number of drivers and orders")
    parser.add_argument("--seed", type=int, default=0, help="RNG seed")
    parser.add_argument("--sample", action="store_true", 
                       help="Sample drivers/orders randomly (vs first n)")
    parser.add_argument("--temp-x", type=float, default=0.9, 
                       help="Temperature for drivers' preferences (higher = more rotation)")
    parser.add_argument("--temp-y", type=float, default=0.9, 
                       help="Temperature for orders' preferences (higher = more rotation)")
    parser.add_argument("--out-txt", required=True, help="Output text file")
    
    # Preference weight parameters
    parser.add_argument("--alpha", type=float, default=1.0, 
                       help="Weight for revenue in driver preferences")
    parser.add_argument("--beta", type=float, default=0.5, 
                       help="Weight for distance in driver preferences")
    parser.add_argument("--a", type=float, default=1.0, 
                       help="Weight for distance in order preferences")
    parser.add_argument("--b", type=float, default=0.3, 
                       help="Weight for driver quality in order preferences")
    parser.add_argument("--individual-noise", type=float, default=0.4, 
                       help="Scale of individual noise for preference diversity (higher = more rotation)")
    parser.add_argument("--augment", type=lambda x: x.lower() in ['true', '1', 'yes'], default=True,
                       help="Enable driver augmentation for large n (default: True)")
    
    args = parser.parse_args()
    
    random.seed(args.seed)
    
    print("Loading taxi data...")
    drivers, orders = load_taxi_data(args.csv, args.n, args.sample, args.augment, args.seed)
    print(f"Loaded {len(drivers)} drivers and {len(orders)} orders")
    
    # Load zone centroids for real geographic distance
    print("Loading zone centroids for real geographic distance...")
    zone_centroids = load_zone_centroids()
    if zone_centroids:
        print(f"Loaded {len(zone_centroids)} zone centroids")
    else:
        print("Warning: Could not load zone centroids, using approximate distance calculation")
    
    # Build preferences
    print("Building preferences...")
    X_prefs, Y_prefs = build_preferences(
        drivers, orders, zone_centroids,
        args.temp_x, args.temp_y,
        args.alpha, args.beta, args.a, args.b,
        args.individual_noise
    )
    
    # Verify
    check = verify_complete_no_ties(X_prefs, Y_prefs, args.n)
    if not all(check.values()):
        print("Warning: Verification failed!")
        for k, v in check.items():
            if not v:
                print(f"  {k}: {v}")
    
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

