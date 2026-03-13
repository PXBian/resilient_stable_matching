use crate::preference_profile::PreferenceProfile;
use crate::rotations::Rotation;
use crate::algorithms::rotation_poset_generation::build_rotation_poset;

/// Poset of rotations.
/// 
/// `rotations`: list of all rotations discovered
/// `rotation_index`: grid[m][rank] = idx means that rotation |idx|-1 touched (m, rank), and is stable if idx > 0, unstable if idx < 0. 0 means untouched.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RotationPoset {
    pub rotations: Vec<Rotation>,
    pub n_rotations: usize,
    pub rotation_index: Vec<Vec<isize>>,
    pub n: usize,
}

impl RotationPoset {
    /// Creates an empty poset with uninitialized grids.
    pub fn new(n: usize) -> Self {
        Self {
            rotations: Vec::new(),
            n_rotations: 0,
            rotation_index: vec![vec![0; n]; n],
            n,
        }
    }

    pub fn from(profile: &PreferenceProfile, save_rotations: bool) -> Self {
        build_rotation_poset(profile, save_rotations)
    }
}

