use crate::rotation_set::RotationSet;
use crate::profile::Profile;
use std::collections::HashMap;

#[repr(C)]
#[derive(Debug, Clone, Copy)]
pub struct StablePair {
    pub man: u32, 
    pub woman: u32,
    pub rem_rotation: u32, // rotation that removes this pair
}

#[repr(C)]
#[derive(Debug, Clone, Copy)]
pub struct Dependency {
    pub from: u32, 
    pub to: u32,
    pub capacity: u32, // capacity of the edge
}

#[repr(C)]
pub struct RotationDigraph {
    pub starting_indexes: *mut u32, // for each rotation, the index of its first stable pair in the list
    pub n_rotations: usize, // number of rotations
    pub pairs_list: *mut StablePair, // list
    pub n_pairs: usize, // number of pairs
    pub dependencies_list: *mut Dependency, // pointer
    pub n_dependencies: usize, // length
}

impl RotationDigraph {
    pub fn from_rotation_set(rp: &RotationSet, profile: &Profile, complete_data: bool) -> Self {

        let mut starting_indexes: Vec<u32>;
        let mut current_indexes;
        let n_rotations = rp.n_rotations;
        let mut pairs_list;
        let mut n_pairs = 0;
        
        if complete_data {
            starting_indexes = rp.rotations_sizes.iter().scan(0, |acc, &size| {
                let current = *acc;
                *acc += size;
                Some(current)
            }).collect();
            current_indexes = starting_indexes.clone();
            n_pairs = rp.rotations_sizes.iter().sum::<u32>() as usize;
            pairs_list = vec![StablePair {man: 0, woman: 0, rem_rotation: 0}; n_pairs];
        } else {
            starting_indexes = Vec::new();
            current_indexes = Vec::new();
            pairs_list = Vec::new();
        }

        let mut map: HashMap<(u32, u32), u32> = HashMap::new();

        for (i, man_index) in rp.men_rotation_index.iter().enumerate(){

            let start = rp.male_optimal_matching.men_to_women[i].unwrap() as usize;
            let end = rp.female_optimal_matching.men_to_women[i].unwrap() as usize + 1;
            
            let mut rot_to = (rp.n_rotations - 1) as u32; // rotation index of the rotation that touched (i, end)

            for j in profile.men_ranking[i][start..end].iter().rev().map(|&j| j as u32).filter(|&j| man_index.contains_key(&j)) {
                let stable = man_index[&j] > 0;
                let rot_from = if stable {man_index[&j] - 1} else {-man_index[&j] - 1} as u32; // rotation index of the rotation that touched (i, j)
                
                if !map.contains_key(&(rot_from, rot_to)) {
                    map.insert((rot_from, rot_to), 0);
                } 
                
                *map.get_mut(&(rot_from, rot_to)).unwrap() += if stable {1} else {0};

                if stable && complete_data {
                    let index = current_indexes[rot_from as usize] as usize;
                    pairs_list[index] = StablePair {man: i as u32, woman: j, rem_rotation: rot_to};
                    current_indexes[rot_from as usize] += 1;
                }

                rot_to = if stable {rot_from} else {rot_to};


            }
        }

        let mut vec: Vec<Dependency> = map.into_iter().map(|((from, to), capacity)| Dependency { from, to, capacity }).collect();
        
        let starting_indexes_ptr = if complete_data {
            let ptr = starting_indexes.as_mut_ptr();
            std::mem::forget(starting_indexes); // avoids the deallocation of starting_indexes
            ptr
        } else {
            std::ptr::null_mut()
        };
        let pairs_list_ptr = if complete_data {
            let ptr = pairs_list.as_mut_ptr();
            std::mem::forget(pairs_list); // avoids the deallocation of pairs_list
            ptr
        } else {
            std::ptr::null_mut()
        };
        let dependencies_list_ptr = vec.as_mut_ptr();
        let n_dependencies = vec.len();

        std::mem::forget(vec); // avoids the deallocation of vec

        RotationDigraph { starting_indexes: starting_indexes_ptr, n_rotations, pairs_list: pairs_list_ptr, n_pairs, dependencies_list: dependencies_list_ptr, n_dependencies }
    }
}

