use crate::rotation_digraph::RotationDigraph;
use crate::ranking_position::PositionMapMatrix;
use std::collections::HashSet;

#[repr(C)]
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct Arc {
    pub from: u32, 
    pub to: u32,
    pub cost: u32, // 0 or 1, backward/parallel or forward arc
    pub capacity: u32, // n or 1, backward/parallel or forward arc (the source-sink arc may have capacity bigger than 1)
}

#[repr(C)]
pub struct GirlPathGraph {
    pub n_vertices: usize, // number of pairs - number of girls + 2 (source and sink)
    pub arcs_list: *mut Arc, // pointer
    pub n_arcs: usize, // length
}

impl GirlPathGraph {
    pub fn from_rotation_digraph(digraph: &RotationDigraph, women: &PositionMapMatrix) -> Self {
        let n = women.n;
        
        let mut arcs_set = HashSet::new();
        let mut st_arcs = 0;

        // Forward and backward arcs
        for i in 0..digraph.n_pairs {
            let pair = unsafe { *digraph.pairs_list.add(i) };
            let mut to_pair = digraph.n_pairs as u32;
            if pair.rem_rotation != digraph.n_rotations as u32 - 1 { 
                to_pair = unsafe { *digraph.starting_indexes.add(pair.rem_rotation as usize) };
                while (unsafe { *digraph.pairs_list.add(to_pair as usize) }).woman != pair.woman {
                        to_pair += 1;
                    }
            }
            let from_pair = if i < n {0} else {i as u32 - n as u32 + 1};
            to_pair = if to_pair < n as u32 {0} else {to_pair - n as u32 + 1};
            if from_pair == 0 && to_pair == digraph.n_pairs as u32 - n as u32 + 1 {
                st_arcs += 1;
            } else {
                arcs_set.insert(Arc { from: from_pair, to: to_pair, cost: 1, capacity: 1 });
                arcs_set.insert(Arc { from: to_pair, to: from_pair, cost: 0, capacity: n as u32 }); 
            }
            
        }

        // Find the minimum matching for each rotation

        let mut min_matching: Vec<Vec<u32>> = vec![vec![n as u32; n]; digraph.n_rotations];
        let mut pair_position: Vec<Vec<u32>> = vec![vec![digraph.n_pairs as u32; n]; digraph.n_rotations];
        
        let mut current_rotation = 0;
        for i in 0..digraph.n_pairs {
            if i == unsafe { *digraph.starting_indexes.add(current_rotation + 1) } as usize {
                current_rotation += 1;
            }
            let pair = unsafe { *digraph.pairs_list.add(i) };
            min_matching[current_rotation][pair.woman as usize] = pair.man;
            pair_position[current_rotation][pair.woman as usize] = i as u32;
        }

        let mut dep_buckets: Vec<Vec<u32>> = vec![Vec::new(); digraph.n_rotations];
        for i in 0..digraph.n_dependencies {
            let dep = unsafe { *digraph.dependencies_list.add(i) };
            dep_buckets[dep.from as usize].push(dep.to);
        }

        for from in 0..digraph.n_rotations {
            for &to in &dep_buckets[from] {
                for j in 0..n {
                    let first_man = min_matching[from as usize][j];
                    let second_man = min_matching[to as usize][j];
                    if second_man == n as u32 || women.prefers(j as u32, first_man, second_man) {
                        min_matching[to as usize][j] = first_man;
                        pair_position[to as usize][j] = pair_position[from as usize][j];
                    }
                }
            }
        }

        // Parallel arcs
        let mut current_rotation = 0;
        for i in n..digraph.n_pairs {
            if i == unsafe { *digraph.starting_indexes.add(current_rotation + 1) } as usize {
                current_rotation += 1;
            }

            for j in 0..n {
                let from_pair = if i < n {0} else {i as u32 - n as u32 + 1};
                let to_pair = if (pair_position[current_rotation][j] as usize) < n {0} else {pair_position[current_rotation][j] - n as u32 + 1};
                if from_pair != to_pair {
                    arcs_set.insert(Arc { from: from_pair, to: to_pair, cost: 0, capacity: n as u32 });
                }
            }
        }
        
        let mut arcs_list: Vec<Arc> = arcs_set.into_iter().collect();
        
        if st_arcs > 0 {
            arcs_list.push(Arc { from: 0, to: digraph.n_pairs as u32 - n as u32 + 1, cost: 1, capacity: st_arcs as u32 });
            arcs_list.push(Arc { from: digraph.n_pairs as u32 - n as u32 + 1, to: 0, cost: 1, capacity: n as u32 });
        }
        
        let arcs_list_ptr = arcs_list.as_mut_ptr();
        let arcs_list_len = arcs_list.len();

        std::mem::forget(arcs_list); // avoids the deallocation

        GirlPathGraph {
            n_vertices: digraph.n_pairs - n + 2,
            arcs_list: arcs_list_ptr,
            n_arcs: arcs_list_len,
        }
    }
}