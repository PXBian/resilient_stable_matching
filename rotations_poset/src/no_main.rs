use resiliency::preference_profile::PreferenceProfile;
use resiliency::rotations_poset::RotationPoset;
use resiliency::c_rotation_poset::CRotationPoset;

fn main() {
    // Create a random preference profile with seed 0
    let n = 4;
    let profile = PreferenceProfile::random(n, Some(3));

    profile.save_to_file("small_instance.txt");

    //let profile = PreferenceProfile::load_from_file("failure.txt").unwrap();
    
    // Build the rotation poset
    let rp = RotationPoset::from(&profile);

    println!("Rotation poset: {:?}", rp);

    let _ = CRotationPoset::from_rotation_poset(&rp, &profile);

    println!("All done!");
    //println!("Rotation poset details: {:?}", rp);
}