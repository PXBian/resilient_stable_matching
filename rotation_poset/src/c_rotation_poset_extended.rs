use crate::preference_profile::PreferenceProfile;
use crate::rotation_poset_extended::RotationPosetExtended;

#[repr(C)]
#[derive(Debug)]
pub struct CPair {
    pub man: usize,
    pub woman: usize,
}

#[repr(C)]
#[derive(Debug)]
pub struct CDependencyExtended {
    pub from: usize, 
    pub to: usize,       
    pub generator: CPair, // pair causing the dependency
    pub gen_is_stable: u8, // 1 if stable, 0 otherwise
}

#[repr(C)]
pub struct CRotationPosetExtended {
    pub data: *mut CDependencyExtended, // pointer
    pub len: usize,       // length
    pub n_rotations: usize, // number of rotations
}

impl CRotationPosetExtended {
    pub fn from_rotation_poset(rp: &RotationPosetExtended, profile: &PreferenceProfile) -> Self {
        let n = rp.n;
        
        let mut vec: Vec<CDependencyExtended> = Vec::new();

        for i in 0..n {
            let mut last_stable_pos = vec.len();
            let mut j = 0;
            while rp.stable_grid[i][j] != Some(true) {
                j += 1;
            }
            while j < n {
                if let Some(rot_idx) = rp.rotation_index[i][j] { 
                    let gen_is_stable = if rp.stable_grid[i][j] == Some(true) { 1 } else { 0 };
                    
                    if gen_is_stable == 1 {
                        for idx in last_stable_pos..vec.len() {
                            vec[idx].to = rot_idx;
                        }
                        last_stable_pos = vec.len();
                    }
                    let next = CDependencyExtended {
                        from: rot_idx,
                        to: rot_idx,
                        generator: CPair { man: i, woman: profile.men[i][j] },
                        gen_is_stable,
                    };
                    
                    vec.push(next);
                    j += 1;
                } else {
                    break;
                }
            
            }

            for idx in last_stable_pos..vec.len() {
                vec[idx].to = rp.rotations.len() - 1; 
            }
        }

        let data_ptr = vec.as_mut_ptr();
        let len = vec.len();
        let n_rotations = rp.rotations.len();

        std::mem::forget(vec); // avoids the deallocation of vec

        CRotationPosetExtended { data: data_ptr, len, n_rotations }
    }
}

