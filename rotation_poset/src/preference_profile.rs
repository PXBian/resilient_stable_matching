use crate::preference::Preferences;
use std::fs::File;
use std::io::{Write, BufWriter, BufRead, BufReader};
// use rand::thread_rng;
// use rand::{Rng, SeedableRng};
use rand::{SeedableRng};
use rand::rngs::StdRng;
use rand::seq::SliceRandom;

#[repr(C)]
pub struct CPreferenceProfile {
    pub men: *mut usize, // pointer
    pub women: *mut usize, // pointer
    pub len: usize,       // length
}   


#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PreferenceProfile {
    pub men: Vec<Preferences>,
    pub women: Vec<Preferences>,
    pub n: usize,
}

impl PreferenceProfile {
    pub fn new(men: Vec<Preferences>, women: Vec<Preferences>) -> Self {
        let n = men.len();
        assert_eq!(n, women.len());
        Self { men, women, n }
    }

    pub fn save_to_file(&self, path: &str) -> std::io::Result<()> {
        let mut w = BufWriter::new(File::create(path)?);

        writeln!(w, "MEN:")?;
        for pref in &self.men {
            for (j, p) in pref.iter().enumerate() {
                if j > 0 { write!(w, " ")?; }
                write!(w, "{p}")?;
            }
            writeln!(w)?;
        }

        writeln!(w, "WOMEN:")?;
        for pref in &self.women {
            for (j, p) in pref.iter().enumerate() {
                if j > 0 { write!(w, " ")?; }
                write!(w, "{p}")?;
            }
            writeln!(w)?;
        }

        Ok(())
    }

    #[unsafe(no_mangle)]
    pub fn from_c_profile(c_profile: &CPreferenceProfile) -> Self {

        let n = c_profile.len;

        let slice_m = unsafe { std::slice::from_raw_parts(c_profile.men, n*n) };
        let slice_w = unsafe { std::slice::from_raw_parts(c_profile.women, n*n) };
        
        let men = slice_m.chunks(n).map(|row| Preferences::new(row.to_vec())).collect();
        let women = slice_w.chunks(n).map(|row| Preferences::new(row.to_vec())).collect();

        PreferenceProfile::new(men, women)
        
    }

    pub fn load_from_file(path: &str) -> Result<Self, String> {
        let file = File::open(path)
            .map_err(|e| format!("Cannot open file: {e}"))?;
        let reader = BufReader::new(file);

        let mut men = Vec::new();
        let mut women = Vec::new();
        let mut section = None; // "MEN" oppure "WOMEN"

        for line in reader.lines() {
            let line = line.map_err(|e| format!("IO error: {e}"))?;
            let line = line.trim();
            if line.is_empty() { continue; }

            if line == "MEN:" {
                section = Some("MEN");
                continue;
            }
            if line == "WOMEN:" {
                section = Some("WOMEN");
                continue;
            }

            let nums: Vec<usize> = line
                .split_whitespace()
                .map(|x| x.parse::<usize>()
                     .map_err(|_| format!("Invalid number: {x}")))
                .collect::<Result<_,_>>()?;

            let pref = Preferences::new(nums);

            match section {
                Some("MEN") => men.push(pref),
                Some("WOMEN") => women.push(pref),
                _ => return Err("Data outside MEN/WOMEN sections".into()),
            }
        }

        let profile = PreferenceProfile::new(men, women);
        profile.validate()?;

        Ok(profile)
    }

    /// Generates a random profile.
    /// - `n`: number of men/women
    /// - `seed`: if `Some(s)`, it uses a deterministic generator; if `None`, random seed.
    pub fn random(n: usize, seed: Option<u64>) -> Self {
        let mut rng: StdRng = match seed {
            Some(s) => StdRng::seed_from_u64(s),
            None => StdRng::from_entropy(),
        };

        let mut men = Vec::with_capacity(n);
        let mut women = Vec::with_capacity(n);

        for _ in 0..n {
            let mut r: Vec<usize> = (0..n).collect();
            r.shuffle(&mut rng);
            men.push(Preferences::new(r));
        }

        for _ in 0..n {
            let mut r: Vec<usize> = (0..n).collect();
            r.shuffle(&mut rng);
            women.push(Preferences::new(r));
        }

        Self::new(men, women)
    }


    pub fn validate(&self) -> Result<(), String> {
        let n = self.men.len();

        if self.women.len() != n {
            return Err("men and women length mismatch".into());
        }

        for (i, p) in self.men.iter().enumerate() {
            p.validate()
                .map_err(|e| format!("men[{i}] invalid: {e}"))?;
        }

        for (i, p) in self.women.iter().enumerate() {
            p.validate()
                .map_err(|e| format!("women[{i}] invalid: {e}"))?;
        }

        Ok(())
    }
}

impl PreferenceProfile {
    #[cfg(test)]
    pub fn men_mut(&mut self) -> &mut Vec<Preferences> {
        &mut self.men
    }

    #[cfg(test)]
    pub fn women_mut(&mut self) -> &mut Vec<Preferences> {
        &mut self.women
    }
}


#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_random_with_seed() {
        let p1 = PreferenceProfile::random(5, Some(123));
        let p2 = PreferenceProfile::random(5, Some(123));
        let p3 = PreferenceProfile::random(5, Some(999));

        assert_eq!(p1.men, p2.men);
        assert_eq!(p1.women, p2.women);

        assert_ne!(p1.men, p3.men);
        assert_ne!(p1.women, p3.women);
    }

    #[test]
    fn test_save_and_load() {
        let tmpfile = "test_instance.txt";

        let original = PreferenceProfile::random(4, Some(42));
        original.save_to_file(tmpfile).unwrap();

        let loaded = PreferenceProfile::load_from_file(tmpfile).unwrap();

        assert_eq!(original.men, loaded.men);
        assert_eq!(original.women, loaded.women);

        // cleanup (optional)
        std::fs::remove_file(tmpfile).unwrap();
    }

    #[test]
    fn test_validation_ok() {
        let p = PreferenceProfile::random(6, Some(10));
        assert!(p.validate().is_ok());
    }

    #[test]
    fn test_validation_fails_on_inconsistent_data() {
        // Creates a valid profile
        let mut p = PreferenceProfile::random(3, Some(999));

        // Corrupts it
        p.men_mut()[0].position[0] = 99;

        assert!(p.validate().is_err());
    }

}