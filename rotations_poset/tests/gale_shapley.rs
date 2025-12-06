use resiliency::preference_profile::PreferenceProfile;
use resiliency::matching::Matching;
use resiliency::algorithms::matching_comparison::all_men_prefer;

/// Test Gale–Shapley (male-optimal)
#[test]
fn test_gale_shapley_random_multiple() {
    // Test Gale–Shapley on different dimensions and seeds
    let sizes = [2, 3, 4, 5, 8, 10];

    for &n in &sizes {
        for seed in 0..10 {
            let profile = PreferenceProfile::random(n, Some(seed));

            let male_matching = Matching::male_optimal(&profile);

            assert!(
                male_matching.is_perfect(),
                "Matching is not perfect! (n = {n}, seed = {seed})"
            );

            assert!(
                male_matching.is_stable(&profile),
                "Matching is not stable! (n = {n}, seed = {seed})"
            );

            
            assert!(male_matching.validate().is_ok());

            let female_matching = Matching::female_optimal(&profile);

            assert!(
                female_matching.is_perfect(),
                "Matching is not perfect! (n = {n}, seed = {seed})"
            );

            assert!(
                female_matching.is_stable(&profile),
                "Matching is not stable! (n = {n}, seed = {seed})"
            );

            assert!(female_matching.validate().is_ok());
            
            assert!(all_men_prefer(&male_matching, &female_matching, &profile));
        }
    }
}
