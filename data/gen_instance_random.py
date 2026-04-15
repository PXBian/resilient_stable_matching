#!/usr/bin/env python3
"""
Generate cyclic-block random instances for stable matching.

Core idea:
Partition both sides into K blocks and impose a cyclic block order.

- X agents in block i rank Y blocks as: i, i+1, i+2, ..., i-1   (mod K)
- Y agents in block j rank X blocks as: j+1, j+2, ..., j        (mod K)

Inside each block, agents rank the other side using a shared block-local
"quality" signal plus agent-specific noise. Crucially, the block order itself
is kept fixed, so the macro cyclic structure remains intact.

Use --noise in [0, 1] to control only the within-block heterogeneity:
- noise=0   → all agents agree on the same internal order inside each block
- noise>0   → agents increasingly disagree within each block
- noise=1   → strong within-block individuality, while block order still stays cyclic

This is much safer than perturbing the block order itself: it adds diversity
without immediately collapsing flow=1 min-cost to 1.

Examples:
  python3 gen_instance_random.py -n 120 --blocks 3 --seed 42 --out hc3.txt
  python3 gen_instance_random.py -n 120 --blocks 4 --seed 42 --out hc4.txt --check-min-cost
  python3 gen_instance_random.py -n 1000 --blocks 10 --seed 7 --noise 0.2 --out hc_mixed.txt --shuffle-labels
"""

import argparse
import math
import random
import re
import subprocess
from typing import List, Tuple


def partition_indices(n: int, blocks: int) -> List[List[int]]:
    """
    Split [0, n) into `blocks` consecutive groups whose sizes differ by at most 1.
    """
    base = n // blocks
    rem = n % blocks
    groups: List[List[int]] = []
    start = 0
    for b in range(blocks):
        size = base + (1 if b < rem else 0)
        end = start + size
        groups.append(list(range(start, end)))
        start = end
    return groups


def gumbel(rng: random.Random) -> float:
    u = max(rng.random(), 1e-300)
    return -math.log(-math.log(u))


def rank_block_with_noise(
    candidates: List[int],
    shared_quality: List[float],
    noise: float,
    rng: random.Random,
) -> List[int]:
    """
    Rank candidates inside a single block.

    The block itself stays in its fixed cyclic position; only the internal
    ordering is perturbed. Every candidate has a shared block-local quality,
    and each observing agent adds independent Gumbel noise scaled by `noise`.
    """
    if noise == 0.0:
        return sorted(candidates, key=lambda idx: (-shared_quality[idx], idx))

    scored = [
        ((1.0 - noise) * shared_quality[idx] + noise * gumbel(rng), idx)
        for idx in candidates
    ]
    scored.sort(reverse=True)
    return [idx for _, idx in scored]


def build_cyclic_block_instance(
    n: int,
    blocks: int,
    seed: int,
    shuffle_labels: bool,
    noise: float = 0.0,
) -> Tuple[List[List[int]], List[List[int]]]:
    rng = random.Random(seed)

    x_blocks = partition_indices(n, blocks)
    y_blocks = partition_indices(n, blocks)

    # Shared latent quality within each opposite-side block.
    # These preserve a common "shape" inside each block while allowing
    # per-agent deviations controlled by `noise`.
    y_quality = [rng.random() for _ in range(n)]
    x_quality = [rng.random() for _ in range(n)]

    x_prefs: List[List[int]] = []
    for block_id, agents in enumerate(x_blocks):
        for _ in agents:
            cyclic_order = [(block_id + step) % blocks for step in range(blocks)]
            pref: List[int] = []
            for target_block in cyclic_order:
                pref.extend(
                    rank_block_with_noise(
                        y_blocks[target_block],
                        y_quality,
                        noise,
                        rng,
                    )
                )
            x_prefs.append(pref)

    y_prefs: List[List[int]] = []
    for block_id, agents in enumerate(y_blocks):
        for _ in agents:
            cyclic_order = [(block_id + 1 + step) % blocks for step in range(blocks)]
            pref: List[int] = []
            for target_block in cyclic_order:
                pref.extend(
                    rank_block_with_noise(
                        x_blocks[target_block],
                        x_quality,
                        noise,
                        rng,
                    )
                )
            y_prefs.append(pref)

    if shuffle_labels:
        x_perm = list(range(n))
        y_perm = list(range(n))
        rng.shuffle(x_perm)
        rng.shuffle(y_perm)

        inv_x = [0] * n
        inv_y = [0] * n
        for old, new in enumerate(x_perm):
            inv_x[old] = new
        for old, new in enumerate(y_perm):
            inv_y[old] = new

        shuffled_x = [[] for _ in range(n)]
        shuffled_y = [[] for _ in range(n)]

        for old_x in range(n):
            new_x = inv_x[old_x]
            shuffled_x[new_x] = [inv_y[old_y] for old_y in x_prefs[old_x]]
        for old_y in range(n):
            new_y = inv_y[old_y]
            shuffled_y[new_y] = [inv_x[old_x] for old_x in y_prefs[old_y]]

        x_prefs, y_prefs = shuffled_x, shuffled_y

    return x_prefs, y_prefs


def verify_instance(x_prefs: List[List[int]], y_prefs: List[List[int]], n: int) -> bool:
    target = list(range(n))
    for i, row in enumerate(x_prefs):
        if sorted(row) != target:
            print(f"ERROR: invalid X preference row {i}")
            return False
    for j, row in enumerate(y_prefs):
        if sorted(row) != target:
            print(f"ERROR: invalid Y preference row {j}")
            return False
    return True


def write_instance(path: str, x_prefs: List[List[int]], y_prefs: List[List[int]]) -> None:
    with open(path, "w") as f:
        for row in x_prefs:
            f.write(" ".join(map(str, row)) + "\n")
        for row in y_prefs:
            f.write(" ".join(map(str, row)) + "\n")


def evaluate_min_cost(path: str, n: int, solver: str, flow: int) -> int:
    proc = subprocess.run(
        [solver, path, str(n), str(flow)],
        capture_output=True,
        text=True,
        check=False,
    )
    if proc.returncode != 0:
        raise RuntimeError(
            f"Solver failed with code {proc.returncode}.\nstdout:\n{proc.stdout}\nstderr:\n{proc.stderr}"
        )
    match = re.search(r"total_cost\s*=\s*(-?\d+)", proc.stdout)
    if match is None:
        raise RuntimeError(
            f"Could not parse total_cost from solver output.\nstdout:\n{proc.stdout}\nstderr:\n{proc.stderr}"
        )
    return int(match.group(1))


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate cyclic-block stable-matching instances with controllable min-cost structure"
    )
    parser.add_argument("-n", type=int, required=True, help="Number of agents on each side")
    parser.add_argument("--blocks", type=int, default=3,
                        help="Number of cyclic blocks. When noise=0, min-cost is typically close to this value. (default: 3)")
    parser.add_argument("--seed", type=int, default=0, help="Random seed")
    parser.add_argument("--out", required=True, help="Output path")
    parser.add_argument("--shuffle-labels", action="store_true",
                        help="Randomly relabel X and Y indices after construction so the block structure is less obvious")
    parser.add_argument("--check-min-cost", action="store_true",
                        help="Run the local solver after generation and print the resulting min-cost")
    parser.add_argument("--solver", default="./network_simplex",
                        help="Solver used by --check-min-cost. (default: ./network_simplex)")
    parser.add_argument("--flow", type=int, default=1,
                        help="Flow amount used by --check-min-cost. (default: 1)")
    parser.add_argument("--noise", type=float, default=0.0,
                        help="Within-block heterogeneity level in [0,1]. "
                             "0 means agents agree on each block's internal order; "
                             "1 means strong per-agent variation inside blocks, while "
                             "the block order itself remains cyclic. (default: 0.0)")
    args = parser.parse_args()

    if not (0.0 <= args.noise <= 1.0):
        parser.error("--noise must be in [0.0, 1.0]")
    if args.n < 2:
        parser.error("-n must be at least 2")
    if args.blocks < 3:
        parser.error("--blocks must be at least 3 if you want 3+ cost structure")
    if args.blocks > args.n:
        parser.error("--blocks cannot exceed n")
    if args.flow <= 0:
        parser.error("--flow must be positive")

    x_prefs, y_prefs = build_cyclic_block_instance(
        n=args.n,
        blocks=args.blocks,
        seed=args.seed,
        shuffle_labels=args.shuffle_labels,
        noise=args.noise,
    )

    print(f"Generating cyclic-block instance: n={args.n}, blocks={args.blocks}, seed={args.seed}, noise={args.noise}")
    print("Verifying preference lists...", end=" ")
    ok = verify_instance(x_prefs, y_prefs, args.n)
    print("OK" if ok else "FAILED")
    if not ok:
        raise SystemExit(1)

    write_instance(args.out, x_prefs, y_prefs)
    print(f"Wrote: {args.out} ({2 * args.n} lines)")

    if args.check_min_cost:
        min_cost = evaluate_min_cost(args.out, args.n, args.solver, args.flow)
        print(f"Solver check: flow={args.flow}, total_cost={min_cost}")


if __name__ == "__main__":
    main()
