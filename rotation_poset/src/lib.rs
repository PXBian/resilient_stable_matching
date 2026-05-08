pub mod ranking_position;
pub mod profile;
pub mod rotation_set;
pub mod rotation_digraph;
pub mod matching;
pub mod rotations;
pub mod algorithms;
pub mod stable_pairs_graph;

pub use ranking_position::{RankingListMatrix, PositionMapMatrix};
pub use profile::Profile;
pub use rotation_digraph::RotationDigraph;
pub use rotation_set::RotationSet;
pub use stable_pairs_graph::StablePairsGraph;

#[unsafe(no_mangle)]
pub extern "C" fn get_rotation_digraph(men: RankingListMatrix, women: PositionMapMatrix, complete_data: u8) -> RotationDigraph {
    let profile = Profile::new(men, women);
    let rp = RotationSet::from(&profile, complete_data != 0);
    RotationDigraph::from_rotation_set(&rp, &profile, complete_data != 0)
}

#[unsafe(no_mangle)]
pub extern "C" fn free_rotation_digraph(arr: RotationDigraph) {
    if !arr.dependencies_list.is_null() {
        unsafe {
            // Reconstruct the Vec safely
            let _ = Vec::from_raw_parts(arr.dependencies_list, arr.n_dependencies, arr.n_dependencies);
            // when it goes out of scope, the Vec is dropped
        }
    }

    if !arr.starting_indexes.is_null() {
        unsafe {
            // Reconstruct the Vec safely
            let _ = Vec::from_raw_parts(arr.starting_indexes, arr.n_rotations, arr.n_rotations);
            // when it goes out of scope, the Vec is dropped
        }
    }

    if !arr.pairs_list.is_null() {
        unsafe {
            // Reconstruct the Vec safely
            let _ = Vec::from_raw_parts(arr.pairs_list, arr.n_pairs, arr.n_pairs);
            // when it goes out of scope, the Vec is dropped
        }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn get_stable_pairs_graph(rd: RotationDigraph) -> StablePairsGraph {
    StablePairsGraph::from_rotation_digraph(&rd)
}

#[unsafe(no_mangle)]
pub extern "C" fn free_stable_pairs_graph(arr: StablePairsGraph) {
    if !arr.arcs_list.is_null() {
        unsafe {
            // Reconstruct the Vec safely
            let _ = Vec::from_raw_parts(arr.arcs_list, arr.n_arcs, arr.n_arcs);
            // when it goes out of scope, the Vec is dropped
        }
    }
}
