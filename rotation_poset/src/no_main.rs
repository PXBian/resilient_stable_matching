// [lib]
// crate-type = ["cdylib"]


use rotation_poset::preference_profile::PreferenceProfile;
use rotation_poset::rotation_poset::RotationPoset;
use rotation_poset::c_rotation_poset::CRotationPoset;

fn main() {
    // Create a random preference profile with seed 0
    //let n = 4;
    //let profile = PreferenceProfile::random(n, Some(0));

    //let _ = profile.save_to_file("small_instance.txt");

    let profile = PreferenceProfile::load_from_file("instance.txt").unwrap();
    
    // Build the rotation poset
    let rp_f = RotationPoset::from(&profile, false);
    
    println!("Rotation poset: {:?}", rp_f);
    

    

    let _ = CRotationPoset::from_rotation_poset(&rp_f);

    println!("All done!");
    //println!("Rotation poset details: {:?}", rp);
}