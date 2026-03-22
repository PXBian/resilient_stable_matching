use std::collections::HashSet;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Rotation {
    pub removed: HashSet<(u32, u32)>, // a man and the rank of his partner
    pub introduced: HashSet<(u32, u32)>, // a man and the rank of his partner
}

impl Rotation {
    pub fn new() -> Self {
        Self {
            removed: HashSet::new(),
            introduced: HashSet::new(),
        }
    }

    pub fn add_removed(&mut self, man: u32, woman_rank: u32) {
        self.removed.insert((man, woman_rank));
    }

    pub fn add_introduced(&mut self, man: u32, woman_rank: u32) {
        self.introduced.insert((man, woman_rank));
    }
}
