pub mod preference;
pub mod preference_profile;
pub mod matching;
pub mod rotations;
pub mod rotation_poset;
pub mod algorithms;
pub mod c_rotation_poset;
pub mod rotation_poset_extended;
pub mod c_rotation_poset_extended;
pub use preference::Preferences;
pub use preference_profile::{PreferenceProfile, CPreferenceProfile};
pub use c_rotation_poset::{CRotationPoset, CDependency};
pub use matching::Matching;
pub use rotations::Rotation;
pub use rotation_poset::RotationPoset;
pub use algorithms::gale_shapley::{gale_shapley_male_optimal, gale_shapley_female_optimal};
pub use algorithms::matching_comparison::all_men_prefer;
pub use algorithms::rotation_poset_generation::build_rotation_poset;
pub use c_rotation_poset_extended::{CRotationPosetExtended, CDependencyExtended, CPair};
pub use rotation_poset_extended::RotationPosetExtended;
pub use algorithms::rotation_poset_generation_extended::build_rotation_poset_extended;

#[unsafe(no_mangle)]
pub extern "C" fn get_rotation_poset(c_profile: &preference_profile::CPreferenceProfile) -> CRotationPoset {
    let profile = PreferenceProfile::from_c_profile(c_profile);
    let rp = RotationPoset::from(&profile, false);
    CRotationPoset::from_rotation_poset(&rp)
}

#[unsafe(no_mangle)]
pub extern "C" fn free_c_rotation_poset(arr: CRotationPoset) {
    if !arr.data.is_null() {
        return; // nothing to free
    }

    unsafe {
        // Reconstruct the Vec safely
        let _ = Vec::from_raw_parts(arr.data, arr.len, arr.len);
        // when it goes out of scope, the Vec is dropped
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn get_rotation_poset_extended(c_profile: &preference_profile::CPreferenceProfile) -> CRotationPosetExtended {
    let profile = PreferenceProfile::from_c_profile(c_profile);
    let rp = RotationPosetExtended::from(&profile);
    CRotationPosetExtended::from_rotation_poset(&rp, &profile)
}

#[unsafe(no_mangle)]
pub extern "C" fn free_c_rotation_poset_extended(arr: CRotationPosetExtended) {
    if !arr.data.is_null() {
        return; // nothing to free
    }

    unsafe {
        // Reconstruct the Vec safely
        let _ = Vec::from_raw_parts(arr.data, arr.len, arr.len);
        // when it goes out of scope, the Vec is dropped
    }
}
