use crate::preference_profile::PreferenceProfile;
use crate::rotations::Rotation;
use crate::algorithms::gale_shapley::{gale_shapley_male_optimal,gale_shapley_female_optimal};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Matching {
    pub men_to_women: Vec<Option<usize>>,
    pub women_to_men: Vec<Option<usize>>,
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
    pub fn male_optimal(profile: &PreferenceProfile) -> Self {
        gale_shapley_male_optimal(profile)
    }

    /// Returns the female-optimal stable matching.
    pub fn female_optimal(profile: &PreferenceProfile) -> Self {
        gale_shapley_female_optimal(profile)
    }

    /// DOESN'T NOTIFY THEIR PREVIOUS PARTNERS (if any)! Ghosting!
    pub fn set_pair(&mut self, m: usize, w: usize) {
        self.men_to_women[m] = Some(w);
        self.women_to_men[w] = Some(m);
    }

    pub fn man_gets_single(&mut self, m: usize) {
        self.men_to_women[m] = None;
    }

    pub fn woman_gets_single(&mut self, w: usize) {
        self.women_to_men[w] = None;
    }

    pub fn is_perfect(&self) -> bool {
        self.men_to_women.iter().all(|x| x.is_some())
            && self.women_to_men.iter().all(|x| x.is_some())
    }

    pub fn clear(&mut self) {
        for x in &mut self.men_to_women {
            *x = None;
        }
        for x in &mut self.women_to_men {
            *x = None;
        }
    }

    /// Returns true if `man` prefers `woman` with respect to his current partner
    /// or if it is not paired.
    pub fn man_prefers(
        &self,
        man: usize,
        woman: usize,
        profile: &PreferenceProfile,
    ) -> bool {
        match self.men_to_women[man] {
            None => return true, // not paired -> accepts
            Some(current) => {
                let pref = &profile.men[man];
                pref.position[woman] < pref.position[current]
            }
        }
    }

    /// Same as above
    pub fn woman_prefers(
        &self,
        woman: usize,
        man: usize,
        profile: &PreferenceProfile,
    ) -> bool {
        match self.women_to_men[woman] {
            None => return true,
            Some(current) => {
                let pref = &profile.women[woman];
                pref.position[man] < pref.position[current]
            }
        }
    }
    
    /// Applies a rotation to the matching
    /// inserts all (m,w) in `introduced`.
    /// The resulting matching is assumed to still be perfect.
    pub fn apply_rotation(&mut self, rot: &Rotation) {
        // Insert all pairs in "introduced"
        for &(m, w) in &rot.introduced {
            self.men_to_women[m] = Some(w);
            self.women_to_men[w] = Some(m);
        }
    }

    /// Checks that men_to_women and women_to_men are consistent.
    pub fn validate(&self) -> Result<(), String> {
        let n = self.men_to_women.len();

        if self.women_to_men.len() != n {
            return Err("men_to_women and women_to_men have different sizes".to_string());
        }

        // Checks indices are valid
        for (man, mw) in self.men_to_women.iter().enumerate() {
            if let Some(w) = mw {
                if *w >= n {
                    return Err(format!("man {} is matched with invalid woman {}", man, w));
                }
            }
        }

        for (woman, wm) in self.women_to_men.iter().enumerate() {
            if let Some(m) = wm {
                if *m >= n {
                    return Err(format!("woman {} is matched with invalid man {}", woman, m));
                }
            }
        }

        // Checks consistency
        for man in 0..n {
            if let Some(woman) = self.men_to_women[man] {
                match self.women_to_men[woman] {
                    Some(m2) if m2 == man => {} // OK
                    _ => {
                        return Err(format!(
                            "inconsistency: man {} -> woman {}, but reverse not matching",
                            man, woman
                        ));
                    }
                }
            }
        }

        for woman in 0..n {
            if let Some(man) = self.women_to_men[woman] {
                match self.men_to_women[man] {
                    Some(w2) if w2 == woman => {} // OK
                    _ => {
                        return Err(format!(
                            "inconsistency: woman {} -> man {}, but reverse not matching",
                            woman, man
                        ));
                    }
                }
            }
        }

        Ok(())
    }
    
    
    pub fn is_stable(&self, profile: &PreferenceProfile) -> bool {
        let n = self.men_to_women.len();

        for m in 0..n {
            for &w in profile.men[m].ranking.iter() {
                
                if let Some(curr_w) = self.men_to_women[m] {
                    if w == curr_w {
                        break; 
                    }
                }

                // If m prefers w 
                if self.man_prefers(m, w, profile) {
                    // And w prefers m
                    if self.woman_prefers(w, m, profile) {
                        return false; // blocking pair!
                    }
                }
            }
        }

        true
    }
}


#[cfg(test)]
mod tests {
    use super::*;
    use crate::preference::Preferences;
    use crate::preference_profile::PreferenceProfile;

    // Simple test
    #[test]
    fn test_man_prefers() {
        let n = 3;

        let men = vec![
            Preferences::new(vec![0, 1, 2]),
            Preferences::new(vec![1, 2, 0]),
            Preferences::new(vec![2, 0, 1]),
        ];
        let women = men.clone(); 
        let profile = PreferenceProfile::new(men, women);

        let mut m = Matching::new(n);

        m.men_to_women[0] = Some(2); 
        assert!(m.man_prefers(0, 0, &profile));

        assert!(m.man_prefers(0, 1, &profile));

        assert!(!m.man_prefers(0, 2, &profile));
    }
}
