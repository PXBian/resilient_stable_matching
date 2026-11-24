use crate::profile::Profile;
use crate::matching::Matching;
use crate::algorithms::rotation_set_generation::build_rotation_set;
use std::collections::{HashMap};

/// Set of rotations.
#[repr(C)]
#[derive(Debug, Clone, Copy)]
pub struct StablePair {
    pub man: u32, 
    pub woman: u32,
    pub rem_rotation: u32, // rotation that removes this pair
}

pub struct RotationSet {
    pub male_optimal_matching: Matching,
    pub female_optimal_matching: Matching,
    pub rotations_sizes: Vec<u32>,
    pub n_rotations: usize,
    pub men_rotation_index: Vec<HashMap<u32, i32>>,
    pub women_rotation_index: Vec<HashMap<u32, u32>>,
    pub pairs_list: Vec<StablePair>,
    pub n: usize,
}

impl RotationSet {
    /// Creates an empty set
    pub fn new(profile: &Profile) -> Self {
        let n = profile.n;
        Self {
            male_optimal_matching: Matching::new(n),
            female_optimal_matching: Matching::new(n),
            rotations_sizes: Vec::new(),
            n_rotations: 0,
            men_rotation_index: vec![HashMap::new(); n],
            women_rotation_index: vec![HashMap::new(); n],
            pairs_list: Vec::new(),
            n,
        }
    }

    pub fn from(profile: &Profile, find_dependencies: bool, find_pairs: bool) -> Self {
        build_rotation_set(profile, find_dependencies, find_pairs)
    }

    pub fn compute_grid(&mut self, profile: &Profile) {
        
        let n = self.n;

        for (i, women_index) in self.women_rotation_index.iter().enumerate() {

            let first_man = self.female_optimal_matching.women_to_men[i].unwrap();
            let last_man = self.male_optimal_matching.women_to_men[i].unwrap();

            let start = profile.women_position[i][first_man as usize] as usize;
            let end = profile.women_position[i][last_man as usize] as usize + 1;

            let mut i_ranking = vec![0; end - start];

            for man in (0..n).filter(|&man| profile.women_position[i][man] >= start as u32 && profile.women_position[i][man] < end as u32){
                i_ranking[profile.women_position[i][man as usize] as usize - start as usize] = man as u32;
            }

            let mut current_rotation_index = women_index[&first_man];

            for man in i_ranking {
                if women_index.contains_key(&man) {
                    current_rotation_index = women_index[&man];
                    self.men_rotation_index[man as usize].insert(i as u32, (current_rotation_index + 1) as i32);
                } else {
                    self.men_rotation_index[man as usize].insert(i as u32, -((current_rotation_index + 1) as i32));
                }
            }
        }
    }
}

