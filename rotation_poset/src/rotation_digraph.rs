use crate::rotation_set::RotationSet;
use crate::profile::Profile;
use std::collections::HashMap;

#[repr(C)]
#[derive(Debug)]
pub struct Dependency {
    pub from: u32, 
    pub to: u32,
    pub capacity: u32, // capacity of the edge
}

#[repr(C)]
pub struct RotationDigraph {
    pub data: *mut Dependency, // pointer
    pub len: usize,       // length
    pub n_rotations: usize, // number of rotations
}

impl RotationDigraph {
    pub fn from_rotation_set(rp: &RotationSet, profile: &Profile) -> Self {

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

                rot_to = if stable {rot_from} else {rot_to};
            }
        }

        let mut vec: Vec<Dependency> = map.into_iter().map(|((from, to), capacity)| Dependency { from, to, capacity }).collect();
        
        let data_ptr = vec.as_mut_ptr();
        let len = vec.len();
        let n_rotations = rp.n_rotations;

        std::mem::forget(vec); // avoids the deallocation of vec

        RotationDigraph { data: data_ptr, len, n_rotations }
    }
}

