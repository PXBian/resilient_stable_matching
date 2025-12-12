use std::ops::{Deref, DerefMut};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Preferences {
    pub ranking: Vec<usize>,
    pub position: Vec<usize>,
}


impl Deref for Preferences {
    type Target = Vec<usize>;
    fn deref(&self) -> &Self::Target { &self.ranking }
}

impl DerefMut for Preferences {
    fn deref_mut(&mut self) -> &mut Self::Target { &mut self.ranking }
}


impl Preferences {
    pub fn new(ranking: Vec<usize>) -> Self {
        let n = ranking.len();
        let mut position = vec![0; n];
        for (i, &p) in ranking.iter().enumerate() {
            if p >= n {
                panic!("index out of bounds: the len is {} but the index is {}", n, p);
            }
            position[p] = i;
        }
        Self { ranking, position }
    }

    pub fn prefers(&self, a: usize, b: usize) -> bool {
        self.position[a] < self.position[b]
    }

    /// Returns Ok(()) if 'ranking' and 'position' are consistent and valid permutations.
    pub fn validate(&self) -> Result<(), String> {
        let n = self.ranking.len();

        if self.position.len() != n {
            return Err("position has wrong length".into());
        }

        // Check permutation
        let mut seen = vec![false; n];
        for (i, &p) in self.ranking.iter().enumerate() {
            if p >= n {
                return Err(format!("ranking[{i}] = {p} out of bounds"));
            }
            if seen[p] {
                return Err(format!("duplicate entry: {p}"));
            }
            seen[p] = true;

            // Check inverse consistency
            if self.position[p] != i {
                return Err(format!(
                    "position mismatch: position[{}] = {}, expected {}",
                    p, self.position[p], i
                ));
            }
        }

        Ok(())
    }

}
