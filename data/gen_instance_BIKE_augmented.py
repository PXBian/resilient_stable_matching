#!/usr/bin/env python3
"""
Generate bipartite matching instance for bike rebalancing: Bikes ↔ Stations

Simplified version:
- X side: Bikes (bike_id)
- Y side: Stations (station_id, top n by demand)
- Preferences based on demand, distance, and type fit

Output format:
- For n=5000, outputs 10000 lines (5000 + 5000)
- First n lines: X side (bikes) preference lists
- Next n lines: Y side (stations) preference lists
- Each line contains n integers (0-based indices) separated by spaces
- No headers or extra information

Usage:
python3 gen_instance_BIKE.py \
    --csv raw/metro-trips-2025-q4.csv \
    -n 500 \
    --seed 42 \
    --temp-x 0.9 \
    --temp-y 0.9 \
    --out-txt BIKE_500_instance.txt
"""

import argparse
import csv
import math
import random
from datetime import datetime
from typing import List, Dict, Tuple, Optional
from collections import defaultdict
from dataclasses import dataclass
import numpy as np

# ==================== Data Structures ====================

@dataclass
class Trip:
    trip_id: str
    start_time: str
    end_time: str
    start_station: str
    start_lat: float
    start_lon: float
    end_station: str
    end_lat: float
    end_lon: float
    bike_id: str
    bike_type: str

@dataclass
class BikeState:
    bike_id: str
    bike_type: str
    last_end_station: Optional[str]
    last_end_lat: Optional[float]
    last_end_lon: Optional[float]
    last_end_time: Optional[str]

# ==================== Time Window Parsing ====================

def time_in_window(time_str: str, start_hour: int, end_hour: int) -> bool:
    """Check if a time string falls within the window (06:00-10:00)"""
    try:
        dt = datetime.strptime(time_str, "%m/%d/%Y %H:%M")
        hour = dt.hour
        return start_hour <= hour < end_hour
    except:
        return False

# ==================== Distance Calculation ====================

def haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculate great circle distance between two points in kilometers"""
    if not (math.isfinite(lat1) and math.isfinite(lon1) and 
            math.isfinite(lat2) and math.isfinite(lon2)):
        return float('inf')
    
    R = 6371  # Earth radius in km
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (math.sin(dlat/2)**2 + 
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * 
         math.sin(dlon/2)**2)
    c = 2 * math.asin(math.sqrt(a))
    return R * c

# ==================== Data Loading ====================

def load_trips(csv_path: str) -> List[Trip]:
    """Load and parse all trips from CSV"""
    trips = []
    with open(csv_path, newline="", encoding="utf-8") as f:
        reader = csv.reader(f)
        header = next(reader)
        cols = {name.strip().lower(): idx for idx, name in enumerate(header)}
        
        required = ["start_station", "end_station", "bike_id", "bike_type", 
                   "start_time", "start_lat", "start_lon", "end_lat", "end_lon"]
        missing = [r for r in required if r not in cols]
        if missing:
            raise ValueError(f"Missing columns: {missing}. Found: {list(cols.keys())}")
        
        for row in reader:
            try:
                start_station = row[cols["start_station"]].strip()
                end_station = row[cols["end_station"]].strip()
                bike_id = row[cols["bike_id"]].strip()
                bike_type = row[cols["bike_type"]].strip()
                start_time = row[cols["start_time"]].strip()
                
                if not all([start_station, end_station, bike_id, bike_type, start_time]):
                    continue
                
                try:
                    start_lat = float(row[cols["start_lat"]])
                    start_lon = float(row[cols["start_lon"]])
                    end_lat = float(row[cols["end_lat"]]) if row[cols["end_lat"]].strip() else None
                    end_lon = float(row[cols["end_lon"]]) if row[cols["end_lon"]].strip() else None
                except (ValueError, IndexError):
                    continue
                
                try:
                    end_time = row[cols.get("end_time", 0)].strip()
                except (IndexError, KeyError):
                    end_time = ""
                
                trips.append(Trip(
                    trip_id=row[cols.get("trip_id", 0)],
                    start_time=start_time,
                    end_time=end_time,
                    start_station=start_station,
                    start_lat=start_lat,
                    start_lon=start_lon,
                    end_station=end_station,
                    end_lat=end_lat,
                    end_lon=end_lon,
                    bike_id=bike_id,
                    bike_type=bike_type
                ))
            except Exception:
                continue
    
    return trips

def compute_bike_states(trips: List[Trip]) -> Dict[str, BikeState]:
    """Compute the last known state for each bike"""
    bike_states = {}
    bike_trips = defaultdict(list)
    
    # Group trips by bike
    for trip in trips:
        bike_trips[trip.bike_id].append(trip)
    
    for bike_id, bike_trip_list in bike_trips.items():
        # Sort by start_time
        bike_trip_list.sort(key=lambda t: t.start_time)
        
        # Get last trip
        last_trip = bike_trip_list[-1]
        
        bike_states[bike_id] = BikeState(
            bike_id=bike_id,
            bike_type=last_trip.bike_type,
            last_end_station=last_trip.end_station if last_trip.end_lat else None,
            last_end_lat=last_trip.end_lat,
            last_end_lon=last_trip.end_lon,
            last_end_time=last_trip.end_time
        )
    
    return bike_states

def compute_station_demand(trips: List[Trip], start_hour: int = 6, end_hour: int = 10) -> Dict[str, int]:
    """
    Compute demand for each station in the time window (06:00-10:00).
    Returns: {station: demand_count}
    """
    demand = defaultdict(int)
    
    for trip in trips:
        if time_in_window(trip.start_time, start_hour, end_hour):
            demand[trip.start_station] += 1
    
    return dict(demand)

def generate_synthetic_bikes(
    existing_bikes: List[BikeState],
    target_count: int,
    seed: int,
) -> List[BikeState]:
    """
    Generate synthetic bikes by sampling from existing bike distribution.
    """
    random.seed(seed)
    np.random.seed(seed)
    
    # Analyze bike type distribution
    bike_types = [b.bike_type for b in existing_bikes]
    type_counts = defaultdict(int)
    for bt in bike_types:
        type_counts[bt] += 1
    
    # Analyze last_end_station distribution
    station_distribution = defaultdict(int)
    station_coords_map = {}
    for bike in existing_bikes:
        if bike.last_end_station:
            station_distribution[bike.last_end_station] += 1
            if bike.last_end_lat and bike.last_end_lon:
                station_coords_map[bike.last_end_station] = (bike.last_end_lat, bike.last_end_lon)
    
    # Calculate probabilities
    total_bikes = len(existing_bikes)
    type_probs = {bt: count / total_bikes for bt, count in type_counts.items()}
    total_stations = sum(station_distribution.values())
    station_probs = {s: count / total_stations for s, count in station_distribution.items()} if total_stations > 0 else {}
    
    # Generate synthetic bikes
    synthetic = []
    n_needed = target_count - len(existing_bikes)
    
    if n_needed > 0:
        types = list(type_probs.keys())
        type_probs_list = [type_probs[t] for t in types]
        stations = list(station_probs.keys()) if station_probs else []
        station_probs_list = [station_probs[s] for s in stations] if stations else []
        
        for i in range(n_needed):
            # Sample bike type
            bike_type = np.random.choice(types, p=type_probs_list) if len(types) > 0 else "standard"
            
            # Sample last_end_station
            if stations and station_probs_list:
                last_end_station = np.random.choice(stations, p=station_probs_list)
                coords = station_coords_map.get(last_end_station)
                last_end_lat = coords[0] if coords else None
                last_end_lon = coords[1] if coords else None
            else:
                # Fallback: use a random existing bike's location
                base_bike = random.choice(existing_bikes)
                last_end_station = base_bike.last_end_station
                last_end_lat = base_bike.last_end_lat
                last_end_lon = base_bike.last_end_lon
            
            bike_id = f"SYN_BIKE_{len(existing_bikes) + i}"
            synthetic.append(BikeState(
                bike_id=bike_id,
                bike_type=bike_type,
                last_end_station=last_end_station,
                last_end_lat=last_end_lat,
                last_end_lon=last_end_lon,
                last_end_time=None
            ))
    
    return synthetic

def generate_synthetic_stations(
    existing_stations: List[str],
    station_coords: Dict[str, Tuple[float, float]],
    station_demand: Dict[str, int],
    target_count: int,
    seed: int,
) -> Tuple[List[str], Dict[str, Tuple[float, float]], Dict[str, int]]:
    """
    Generate synthetic stations by sampling from existing station distribution
    with small random perturbations. Returns: (new_stations, new_coords, new_demand)
    """
    random.seed(seed + 1000)  # Different seed
    np.random.seed(seed + 1000)
    
    if not existing_stations:
        raise ValueError("No existing stations to base synthesis on")
    
    # Get bounding box
    lats = [station_coords[s][0] for s in existing_stations if s in station_coords]
    lons = [station_coords[s][1] for s in existing_stations if s in station_coords]
    
    if not lats or not lons:
        raise ValueError("No valid station coordinates")
    
    lat_min, lat_max = min(lats), max(lats)
    lon_min, lon_max = min(lons), max(lons)
    
    # Calculate spread
    lat_range = lat_max - lat_min
    lon_range = lon_max - lon_min
    lat_spread = lat_range * 0.3
    lon_spread = lon_range * 0.3
    
    # Analyze demand distribution
    demands = [station_demand.get(s, 0) for s in existing_stations]
    avg_demand = sum(demands) / len(demands) if demands else 1.0
    min_demand = min(demands) if demands else 1
    max_demand = max(demands) if demands else 1
    
    synthetic_stations = []
    synthetic_coords = {}
    synthetic_demand = {}
    
    n_needed = target_count - len(existing_stations)
    
    if n_needed > 0:
        existing_coords_array = np.array([[station_coords[s][0], station_coords[s][1]] 
                                         for s in existing_stations if s in station_coords])
        
        if len(existing_coords_array) > 0:
            # Vectorized generation
            base_indices = np.random.randint(0, len(existing_coords_array), size=n_needed)
            base_coords = existing_coords_array[base_indices]
            
            # Generate noise
            noise = np.random.normal(0, 0.045, size=(n_needed, 2))
            new_coords = base_coords + noise
            
            # Clamp to bounds
            new_coords[:, 0] = np.clip(new_coords[:, 0], lat_min - lat_spread, lat_max + lat_spread)
            new_coords[:, 1] = np.clip(new_coords[:, 1], lon_min - lon_spread, lon_max + lon_spread)
            
            # Generate synthetic stations
            for idx, (new_lat, new_lon) in enumerate(new_coords):
                station_id = f"SYN_STATION_{len(existing_stations) + idx}"
                synthetic_stations.append(station_id)
                synthetic_coords[station_id] = (float(new_lat), float(new_lon))
                # Generate demand based on distribution
                synthetic_demand[station_id] = max(1, int(np.random.normal(avg_demand, avg_demand * 0.5)))
    
    return synthetic_stations, synthetic_coords, synthetic_demand

def select_top_stations(
    demand: Dict[str, int],
    station_coords: Dict[str, Tuple[float, float]],
    n: int
) -> List[str]:
    """Select top n stations by demand"""
    # Filter stations that have coordinates
    valid_stations = [(s, d) for s, d in demand.items() if s in station_coords]
    
    # Sort by demand (descending)
    valid_stations.sort(key=lambda x: -x[1])
    
    # Select top n
    selected = [s for s, _ in valid_stations[:n]]
    
    if len(selected) < n:
        raise ValueError(f"Only {len(selected)} stations with valid coordinates; requested n={n}")
    
    return selected

# ==================== Preference Score Calculation ====================

def compute_bike_preference_scores(
    bike: BikeState,
    stations: List[str],
    station_demand: Dict[str, int],
    station_coords: Dict[str, Tuple[float, float]],
    alpha: float = 1.0,
    beta: float = 0.5,
    individual_noise_scale: float = 0.3
) -> List[float]:
    """
    Compute preference scores for a bike over all stations.
    Score_b→s = α·Demand(s) - β·Distance(last_station(b), s) + IndividualNoise(b,s)
    
    Added individual noise to increase preference diversity and rotation count.
    """
    scores = []
    
    # Normalize demand values
    all_demands = list(station_demand.values())
    max_demand = max(all_demands) if all_demands else 1.0
    
    # Generate bike-specific random seed from bike_id for consistent individual noise
    bike_hash = hash(bike.bike_id) % (2**31)
    rng = random.Random(bike_hash)
    
    for station in stations:
        # Demand component
        demand = station_demand.get(station, 0)
        norm_demand = demand / max_demand if max_demand > 0 else 0.0
        
        # Distance component
        if bike.last_end_lat and bike.last_end_lon and station in station_coords:
            dist = haversine_distance(
                bike.last_end_lat, bike.last_end_lon,
                station_coords[station][0], station_coords[station][1]
            )
            # Normalize distance (assume max ~50km in city)
            norm_dist = min(dist / 50.0, 1.0)
        else:
            norm_dist = 1.0  # Penalty for unknown location
        
        # Base score
        base_score = alpha * norm_demand - beta * norm_dist
        
        # Add individual noise for this bike-station pair (increases diversity)
        # Use hash of bike_id + station_id for consistent but unique noise
        pair_hash = hash((bike.bike_id, station)) % (2**31)
        pair_rng = random.Random(pair_hash)
        individual_noise = pair_rng.gauss(0, individual_noise_scale)
        
        score = base_score + individual_noise
        scores.append(score)
    
    return scores

def compute_station_preference_scores(
    station: str,
    bikes: List[BikeState],
    station_demand: Dict[str, int],
    station_type_demand: Dict[str, Dict[str, int]],  # {station: {bike_type: count}}
    station_coords: Dict[str, Tuple[float, float]],
    a: float = 1.0,
    b: float = 0.5,
    individual_noise_scale: float = 0.3
) -> List[float]:
    """
    Compute preference scores for a station over all bikes.
    Score_s→b = a·TypeFit(s,b) - b·Distance(last_station(b), s) + IndividualNoise(s,b)
    
    Added individual noise to increase preference diversity and rotation count.
    """
    scores = []
    
    # Get station's type demand
    station_type_counts = station_type_demand.get(station, {})
    total_demand = station_demand.get(station, 0)
    
    # Normalize distance (for all bikes)
    max_dist = 50.0  # Assume max distance
    
    # Generate station-specific random seed for consistent individual noise
    station_hash = hash(station) % (2**31)
    
    for bike in bikes:
        # Type fit component
        if total_demand > 0:
            bike_type_demand = station_type_counts.get(bike.bike_type, 0)
            type_fit = bike_type_demand / total_demand
        else:
            type_fit = 0.5  # Neutral if no data
        
        # Distance component
        if bike.last_end_lat and bike.last_end_lon and station in station_coords:
            dist = haversine_distance(
                bike.last_end_lat, bike.last_end_lon,
                station_coords[station][0], station_coords[station][1]
            )
            norm_dist = min(dist / max_dist, 1.0)
        else:
            norm_dist = 1.0
        
        # Base score
        base_score = a * type_fit - b * norm_dist
        
        # Add individual noise for this station-bike pair (increases diversity)
        # Use hash of station + bike_id for consistent but unique noise
        pair_hash = hash((station, bike.bike_id)) % (2**31)
        pair_rng = random.Random(pair_hash)
        individual_noise = pair_rng.gauss(0, individual_noise_scale)
        
        score = base_score + individual_noise
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
    bikes: List[BikeState],
    stations: List[str],
    station_demand: Dict[str, int],
    station_type_demand: Dict[str, Dict[str, int]],
    station_coords: Dict[str, Tuple[float, float]],
    temp_x: float,
    temp_y: float,
    alpha: float = 1.0,
    beta: float = 0.5,
    a: float = 1.0,
    b: float = 0.5,
    individual_noise_scale: float = 0.3
) -> Tuple[List[List[int]], List[List[int]]]:
    """
    Build preference lists for both sides (optimized for large n).
    Added individual noise to increase rotation count.
    """
    
    # X side: bikes rank stations
    print(f"  Building X preferences (bikes → stations) for {len(bikes)} bikes...")
    X_prefs = []
    batch_size = 1000
    for batch_start in range(0, len(bikes), batch_size):
        batch_end = min(batch_start + batch_size, len(bikes))
        if len(bikes) > 1000:
            print(f"    Processing bikes {batch_start+1}-{batch_end} of {len(bikes)}...")
        for i in range(batch_start, batch_end):
            bike = bikes[i]
            scores = compute_bike_preference_scores(
                bike, stations, station_demand, station_coords, alpha, beta, individual_noise_scale
            )
            norm_scores = zscore(scores)
            order = pl_permutation(norm_scores, temp_x)
            X_prefs.append(order)
    
    # Y side: stations rank bikes
    print(f"  Building Y preferences (stations → bikes) for {len(stations)} stations...")
    Y_prefs = []
    for batch_start in range(0, len(stations), batch_size):
        batch_end = min(batch_start + batch_size, len(stations))
        if len(stations) > 1000:
            print(f"    Processing stations {batch_start+1}-{batch_end} of {len(stations)}...")
        for i in range(batch_start, batch_end):
            station = stations[i]
            scores = compute_station_preference_scores(
                station, bikes, station_demand, station_type_demand, station_coords, a, b, individual_noise_scale
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
        description="Generate bike rebalancing matching instance"
    )
    parser.add_argument("--csv", required=True, help="Path to metro-trips CSV")
    parser.add_argument("-n", type=int, required=True, help="Number of bikes and stations")
    parser.add_argument("--seed", type=int, default=0, help="RNG seed")
    parser.add_argument("--temp-x", type=float, default=1.2, help="Temperature for bikes' preferences (higher = more rotation)")
    parser.add_argument("--temp-y", type=float, default=1.2, help="Temperature for stations' preferences (higher = more rotation)")
    parser.add_argument("--sample-bikes", action="store_true", 
                       help="Sample bikes randomly (vs first n)")
    parser.add_argument("--augment", type=lambda x: x.lower() in ['true', '1', 'yes'], default=True,
                       help="Enable data augmentation for large n (default: True)")
    parser.add_argument("--out-txt", required=True, help="Output text file (required)")
    
    # Preference weight parameters
    parser.add_argument("--alpha", type=float, default=1.0, help="Weight for demand in bike preferences")
    parser.add_argument("--beta", type=float, default=0.5, help="Weight for distance in bike preferences")
    parser.add_argument("--a", type=float, default=1.0, help="Weight for type fit in station preferences")
    parser.add_argument("--b", type=float, default=0.5, help="Weight for distance in station preferences")
    parser.add_argument("--individual-noise", type=float, default=0.4, 
                       help="Scale of individual noise for preference diversity (higher = more rotation)")
    
    args = parser.parse_args()
    
    random.seed(args.seed)
    
    print("Loading trips...")
    trips = load_trips(args.csv)
    print(f"Loaded {len(trips)} trips")
    
    # Compute station coordinates (from start_station)
    station_coords = {}
    for trip in trips:
        if trip.start_station and trip.start_station not in station_coords:
            if math.isfinite(trip.start_lat) and math.isfinite(trip.start_lon):
                station_coords[trip.start_station] = (trip.start_lat, trip.start_lon)
    
    # Compute demand (06:00-10:00)
    print("Computing station demand (06:00-10:00)...")
    station_demand = compute_station_demand(trips, 6, 10)
    print(f"Found {len(station_demand)} stations with demand")
    
    # Compute type-specific demand
    station_type_demand = defaultdict(lambda: defaultdict(int))
    for trip in trips:
        if time_in_window(trip.start_time, 6, 10):
            station_type_demand[trip.start_station][trip.bike_type] += 1
    station_type_demand = dict(station_type_demand)
    
    # Compute bike states
    print("Computing bike states...")
    bike_states = compute_bike_states(trips)
    print(f"Found {len(bike_states)} unique bikes")
    
    # Select bikes (with augmentation if needed)
    all_bikes = list(bike_states.values())
    if len(all_bikes) < args.n:
        if args.augment:
            print(f"Augmenting bikes: have {len(all_bikes)}, need {args.n}")
            synthetic_bikes = generate_synthetic_bikes(all_bikes, args.n, args.seed)
            all_bikes.extend(synthetic_bikes)
            print(f"  Generated {len(synthetic_bikes)} synthetic bikes")
        else:
            raise ValueError(f"Only {len(all_bikes)} bikes available; requested n={args.n} (use --augment to enable data augmentation)")
    
    if len(all_bikes) < args.n:
        raise ValueError(f"Not enough bikes: {len(all_bikes)} < n={args.n}")
    
    if args.sample_bikes:
        bikes = random.sample(all_bikes, args.n)
    else:
        bikes = all_bikes[:args.n]
    print(f"Selected {len(bikes)} bikes")
    
    # Select top n stations (with augmentation if needed)
    valid_stations = [(s, d) for s, d in station_demand.items() if s in station_coords]
    valid_stations.sort(key=lambda x: -x[1])
    existing_stations = [s for s, _ in valid_stations]
    
    if len(existing_stations) < args.n:
        if args.augment:
            print(f"Augmenting stations: have {len(existing_stations)}, need {args.n}")
            synthetic_stations, synthetic_coords, synthetic_demand = generate_synthetic_stations(
                existing_stations, station_coords, station_demand, args.n, args.seed
            )
            existing_stations.extend(synthetic_stations)
            station_coords.update(synthetic_coords)
            station_demand.update(synthetic_demand)
            # Update type demand for synthetic stations (use average distribution)
            for syn_station in synthetic_stations:
                # Use average type distribution from existing stations
                type_totals = defaultdict(int)
                for s in existing_stations[:len(existing_stations) - len(synthetic_stations)]:
                    for bt, count in station_type_demand.get(s, {}).items():
                        type_totals[bt] += count
                total = sum(type_totals.values())
                if total > 0:
                    station_type_demand[syn_station] = {
                        bt: max(1, int(count * synthetic_demand[syn_station] / total))
                        for bt, count in type_totals.items()
                    }
                else:
                    station_type_demand[syn_station] = {"standard": synthetic_demand[syn_station] // 2,
                                                       "electric": synthetic_demand[syn_station] // 2}
            print(f"  Generated {len(synthetic_stations)} synthetic stations")
        else:
            raise ValueError(f"Only {len(existing_stations)} stations available; requested n={args.n} (use --augment to enable data augmentation)")
    
    # Select top n stations
    print(f"Selecting top {args.n} stations by demand...")
    selected_stations = select_top_stations(station_demand, station_coords, args.n)
    print(f"Selected {len(selected_stations)} stations")
    
    # Build preferences
    print("Building preferences...")
    X_prefs, Y_prefs = build_preferences(
        bikes, selected_stations, station_demand, station_type_demand, station_coords,
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
