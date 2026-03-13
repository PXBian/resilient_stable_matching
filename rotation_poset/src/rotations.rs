use std::collections::HashSet;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Rotation {
    pub removed: HashSet<(usize, usize)>,
    pub introduced: HashSet<(usize, usize)>,
}

impl Rotation {
    pub fn new() -> Self {
        Self {
            removed: HashSet::new(),
            introduced: HashSet::new(),
        }
    }

    pub fn add_removed(&mut self, man: usize, woman: usize) {
        self.removed.insert((man, woman));
    }

    pub fn add_introduced(&mut self, man: usize, woman: usize) {
        self.introduced.insert((man, woman));
    }
}
