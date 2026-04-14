#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Rotation {
    pub introduced: Vec<(u32, u32)>, // a man and the rank of his partner
}

impl Rotation {
    pub fn new() -> Self {
        Self {
            introduced: Vec::new(),
        }
    }

    pub fn add_introduced(&mut self, man: u32, woman_rank: u32) {
        self.introduced.push((man, woman_rank));
    }
}
