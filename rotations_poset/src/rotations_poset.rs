use crate::preference_profile::PreferenceProfile;
use crate::rotations::Rotation;
use crate::algorithms::rotation_poset_generation::build_rotation_poset;

/// Poset of rotations.
/// 
/// `rotations`: list of all rotations discovered
/// `stable_grid`: grid[m][rank] = Some(bool) meaning stable or unstable
/// `rotation_index`: grid[m][rank] = Some(idx) telling which rotation touched (m, rank)
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RotationPoset {
    pub rotations: Vec<Rotation>,
    pub stable_grid: Vec<Vec<Option<bool>>>,
    pub rotation_index: Vec<Vec<Option<usize>>>,
    pub n: usize,
}

impl RotationPoset {
    /// Creates an empty poset with uninitialized grids.
    pub fn new(n: usize) -> Self {
        Self {
            rotations: Vec::new(),
            stable_grid: vec![vec![None; n]; n],
            rotation_index: vec![vec![None; n]; n],
            n,
        }
    }

    pub fn from(profile: &PreferenceProfile) -> Self {
        build_rotation_poset(profile)
    }
}

