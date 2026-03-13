use crate::rotation_poset::RotationPoset;
use std::collections::HashMap;

/*
#[repr(C)]
#[derive(Debug)]
pub struct CPair {
    pub man: usize,
    pub woman: usize,
}
*/

#[repr(C)]
#[derive(Debug)]
pub struct CDependency {
    pub from: usize, 
    pub to: usize,
    pub capacity: usize, // capacity of the edge
}

#[repr(C)]
pub struct CRotationPoset {
    pub data: *mut CDependency, // pointer
    pub len: usize,       // length
    pub n_rotations: usize, // number of rotations
}

impl CRotationPoset {
    pub fn from_rotation_poset(rp: &RotationPoset) -> Self {
        let n = rp.n;
        
        let mut map: HashMap<(usize, usize), usize> = HashMap::new();

        for i in 0..n {
            let mut j = 0;
            while rp.rotation_index[i][j] <= 0 {
                j += 1;
            }
            while j < n {
                let mut j_next = j + 1;
                while j_next < n && rp.rotation_index[i][j_next] <= 0 {
                    j_next += 1;
                }

                let rot_to = if j_next < n {(rp.rotation_index[i][j_next] - 1) as usize} else {rp.n_rotations - 1}; // rotation index of the rotation that touched (i, j_next)

                let rot_from = (rp.rotation_index[i][j] - 1) as usize; // rotation index of the rotation that touched (i, j)

                if !map.contains_key(&(rot_from, rot_to)) {
                    map.insert((rot_from, rot_to), 1);
                } else {
                    *map.get_mut(&(rot_from, rot_to)).unwrap() += 1;
                }

                if j_next < n {

                    for idx in (j+1)..j_next {
                        if rp.rotation_index[i][idx] < 0 {
                            let rot_from = (-rp.rotation_index[i][idx] - 1) as usize; // rotation index of the rotation that touched (i, idx)
                            if !map.contains_key(&(rot_from, rot_to)) {
                                map.insert((rot_from, rot_to), 0);
                            }
                        }
                    }
                }

                j = j_next;

            }
        }

        let mut vec: Vec<CDependency> = map.into_iter().map(|((from, to), capacity)| CDependency { from, to, capacity }).collect();
        
        let data_ptr = vec.as_mut_ptr();
        let len = vec.len();
        let n_rotations = rp.n_rotations;

        std::mem::forget(vec); // avoids the deallocation of vec

        CRotationPoset { data: data_ptr, len, n_rotations }
    }
}

