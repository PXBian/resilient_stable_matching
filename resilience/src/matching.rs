use crate::profile::Profile;
use crate::rotations::Rotation;
use crate::algorithms::gale_shapley::gale_shapley_male_optimal;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Matching {
    pub men_to_women: Vec<Option<u32>>, // for each man the rank of his partner (None if single)
    pub women_to_men: Vec<Option<u32>>, // for each woman the id of her partner (None if single)
    pub n: usize,
}

impl Matching {
    /// Creates an empty matching of size n:
    /// - men_to_women[m] = None
    /// - women_to_men[w] = None
    pub fn new(n: usize) -> Self {
        Self {
            men_to_women: vec![None; n],
            women_to_men: vec![None; n],
            n,
        }
    }

    /// Returns the male-optimal stable matching.
    pub fn male_optimal(profile: &Profile) -> Self {
        gale_shapley_male_optimal(profile)
    }

    /// DOESN'T NOTIFY THEIR PREVIOUS PARTNERS (if any)! Ghosting!
    pub fn set_pair(&mut self, m: u32, r_w: u32, profile: &Profile) {
        let w = profile.men_ranking[m as usize][r_w as usize];
        self.men_to_women[m as usize] = Some(r_w);
        self.women_to_men[w as usize] = Some(m);
    }

    pub fn man_gets_single(&mut self, m: u32) {
        self.men_to_women[m as usize] = None;
    }

    /// Returns true if `woman` prefers `man` with respect to her current partner
    /// or if it is not paired.
    pub fn woman_prefers(
        &self,
        woman: u32,
        man: u32,
        profile: &Profile,
    ) -> bool {
        match self.women_to_men[woman as usize] {
            None => return true,
            Some(current_man) => {
                profile.woman_prefers(woman, man, current_man)
            }
        }
    }
    
    /// Applies a rotation to the matching
    /// inserts all (m,w) in `introduced`.
    /// The resulting matching is assumed to still be perfect.
    pub fn apply_rotation(&mut self, rot: &Rotation, profile: &Profile) {
        // Insert all pairs in "introduced"
        for &(m, r_w) in &rot.introduced {
            let w = profile.men_ranking[m as usize][r_w as usize];
            self.men_to_women[m as usize] = Some(r_w);
            self.women_to_men[w as usize] = Some(m);
        }
    }
}
