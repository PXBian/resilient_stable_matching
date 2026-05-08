use crate::rotation_digraph::RotationDigraph;
use std::collections::HashSet;

#[repr(C)]
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct Arc {
    pub from: u32, 
    pub to: u32,
    pub cost: u8, // 0 or 1, backward or forward arc
}

#[repr(C)]
pub struct StablePairsGraph {
    pub n_vertices: usize, // number of pairs
    pub arcs_list: *mut Arc, // pointer
    pub n_arcs: usize, // length
}

impl StablePairsGraph {
    pub fn from_rotation_digraph(digraph: &RotationDigraph) -> Self {
        let n = unsafe { *digraph.starting_indexes.add(1) } as usize;
        let mut rotations_inneighbors: Vec<Vec<u32>> = vec![Vec::new(); digraph.n_rotations];
        
        for i in 0..digraph.n_dependencies {
            let dep = unsafe { *digraph.dependencies_list.add(i) };
            rotations_inneighbors[dep.to as usize].push(dep.from);
        }

        let mut ancestors: Vec<Vec<u32>> = vec![Vec::new(); digraph.n_rotations];
        for i in 0..digraph.n_rotations {
            let mut new_ancestors = HashSet::new();
            new_ancestors.insert(i as u32);
            for &neighbor in &rotations_inneighbors[i] {
                new_ancestors.insert(neighbor);
                new_ancestors.extend(ancestors[neighbor as usize].iter());
            }
            ancestors[i] = new_ancestors.into_iter().collect();
        }

        let mut arcs_set = HashSet::new();
        let mut st_arcs = 0;
        // Forward arcs
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
            arcs_set.insert(Arc { from: from_pair, to: to_pair, cost: 1 });
            if from_pair == 0 && to_pair == digraph.n_pairs as u32 - n as u32 + 1 {
                st_arcs += 1;
            }
        }

        // Backward arcs
        let mut current_rotation = 0;
        for i in 0..digraph.n_pairs {
            if i == unsafe { *digraph.starting_indexes.add(current_rotation + 1) } as usize {
                current_rotation += 1;
            }
            for &ancestor in &ancestors[current_rotation] {
                for k in (unsafe { *digraph.starting_indexes.add(ancestor as usize) } as usize)..(unsafe { *digraph.starting_indexes.add(ancestor as usize + 1) } as usize) {
                    let from_pair = if i < n {0} else {i as u32 - n as u32 + 1};
                    let to_pair = if k < n as usize {0} else {k as u32 - n as u32 + 1};
                    if from_pair != to_pair {
                        arcs_set.insert(Arc { from: from_pair, to: to_pair, cost: 0 });
                    }
                }
            }            
        }

        let mut arcs_list: Vec<Arc> = arcs_set.into_iter().collect();
        for _ in 1..st_arcs {
            arcs_list.push(Arc { from: 0, to: digraph.n_pairs as u32 - n as u32 + 1, cost: 1 });
        }
        
        let arcs_list_ptr = arcs_list.as_mut_ptr();
        let arcs_list_len = arcs_list.len();

        std::mem::forget(arcs_list); // avoids the deallocation

        StablePairsGraph {
            n_vertices: digraph.n_pairs - n + 2,
            arcs_list: arcs_list_ptr,
            n_arcs: arcs_list_len,
        }
    }
}