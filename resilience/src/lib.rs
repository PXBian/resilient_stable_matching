pub mod ranking_position;
pub mod profile;
pub mod rotation_set;
pub mod rotation_digraph;
pub mod matching;
pub mod rotations;
pub mod algorithms;
pub mod girl_path_graph;
pub mod linking_pair_network;

pub use algorithms::max_disjoint_matchings::max_disjoint_matchings;
pub use ranking_position::{RankingListMatrix, PositionMapMatrix};
pub use profile::Profile;
pub use rotation_digraph::RotationDigraph;
pub use rotation_set::RotationSet;
pub use girl_path_graph::GirlPathGraph;
pub use linking_pair_network::LinkingPairNetwork;

#[unsafe(no_mangle)]
pub extern "C" fn get_rotation_digraph(men: RankingListMatrix, women: PositionMapMatrix, find_dependencies: u8, find_pairs: u8) -> RotationDigraph {
    let profile = Profile::new(men, women);
    let rp = RotationSet::from(&profile, find_dependencies != 0, find_pairs != 0);
    RotationDigraph::from_rotation_set(&rp, &profile, find_dependencies != 0, find_pairs != 0)
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
pub extern "C" fn get_girl_path_graph(digraph: RotationDigraph, women: PositionMapMatrix) -> GirlPathGraph {
    GirlPathGraph::from_rotation_digraph(&digraph, &women)
}

#[unsafe(no_mangle)]
pub extern "C" fn free_girl_path_graph(arr: GirlPathGraph) {
    if !arr.arcs_list.is_null() {
        unsafe {
            // Reconstruct the Vec safely
            let _ = Vec::from_raw_parts(arr.arcs_list, arr.n_arcs, arr.n_arcs);
            // when it goes out of scope, the Vec is dropped
        }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn get_linking_pair_network(digraph: RotationDigraph, n: usize) -> LinkingPairNetwork {
    LinkingPairNetwork::from_rotation_digraph(&digraph, n)
}

#[unsafe(no_mangle)]
pub extern "C" fn free_linking_pair_network(arr: LinkingPairNetwork) {
    if !arr.arcs_list.is_null() {
        unsafe {
            // Reconstruct the Vec safely
            let _ = Vec::from_raw_parts(arr.arcs_list, arr.n_arcs, arr.n_arcs);
            // when it goes out of scope, the Vec is dropped
        }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn resilience_via_packing(men: RankingListMatrix, women: PositionMapMatrix) -> usize {
    let profile = Profile::new(men, women);
    max_disjoint_matchings(&profile)
}