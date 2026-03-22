pub mod ranking_position;
pub mod profile;
pub mod rotation_set;
pub mod rotation_digraph;
pub mod matching;
pub mod rotations;
pub mod algorithms;

pub use ranking_position::{RankingListMatrix, PositionMapMatrix};
pub use profile::Profile;
pub use rotation_digraph::{RotationDigraph, Dependency};
pub use rotation_set::RotationSet;

#[unsafe(no_mangle)]
pub extern "C" fn get_rotation_digraph(men: RankingListMatrix, women: PositionMapMatrix) -> RotationDigraph {
    let profile = Profile::new(men, women);
    let rp = RotationSet::from(&profile, false);
    RotationDigraph::from_rotation_set(&rp, &profile)
}

#[unsafe(no_mangle)]
pub extern "C" fn free_rotation_digraph(arr: RotationDigraph) {
    if !arr.data.is_null() {
        return; // nothing to free
    }

    unsafe {
        // Reconstruct the Vec safely
        let _ = Vec::from_raw_parts(arr.data, arr.len, arr.len);
        // when it goes out of scope, the Vec is dropped
    }
}