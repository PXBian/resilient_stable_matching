use crate::ranking_position::{RankingListMatrix, PositionMapMatrix};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Profile {
    pub men_ranking: RankingListMatrix,
    pub women_position: PositionMapMatrix,
    pub n: usize,
}

impl Profile {
    pub fn new(men_ranking: RankingListMatrix, women_position: PositionMapMatrix) -> Self {
        let n = men_ranking.n;
        assert_eq!(n, women_position.n);
        Self { men_ranking, women_position, n }
    }

    pub fn woman_prefers(&self, woman: u32, man1: u32, man2: u32) -> bool {
        self.women_position.prefers(woman, man1, man2)
    }
}
