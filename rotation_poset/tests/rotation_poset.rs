#[cfg(test)]
mod tests {
    use rotation_poset::preference_profile::PreferenceProfile;
    use rotation_poset::matching::Matching;
    use rotation_poset::rotation_poset::RotationPoset;
    use rotation_poset::algorithms::matching_comparison::all_men_prefer;

    #[test]
    fn test_rotation_poset_consistency() {
        // Try several sizes and seeds
        let sizes = [2, 3, 4, 5, 8, 10, 100];

        for &n in &sizes {
            for seed in 0..10 {
                // Generate preference profile
                let profile = PreferenceProfile::random(n, Some(seed));

                // Build the rotation poset
                let poset = RotationPoset::from(&profile, true);
                let poset_f = RotationPoset::from(&profile, false);

                assert_eq!(poset.rotations.len(), poset.n_rotations,
                        "Inconsistent value of n_rotations when saving rotations");

                assert_eq!(poset.rotations.len(), poset_f.n_rotations,
                        "Inconsistent value of n_rotations when not saving rotations");
                        
                assert_eq!(poset.rotation_index, poset_f.rotation_index,
                        "Poset computation is different when rotations are not saved");

                // The set of rotations must be >= 2 (first = male_optimal, last = female_optimal)
                assert!(poset.rotations.len() >= 2,
                        "Rotation poset must contain at least first and last rotation");

                // Compute the male-optimal and female-optimal matchings
                let male_opt = Matching::male_optimal(&profile);
                let female_opt = Matching::female_optimal(&profile);

                // Check that the first rotation matches the male-optimal matching
                // (removed empty, introduced = male-opt edges)
                let mut current = male_opt.clone();

                // Now traverse the rotation list (excluding first and last)
                // applying each rotation in sequence
                for (i, rot) in poset.rotations.iter().enumerate() {
                    if i == 0 || i + 1 == poset.rotations.len() {
                        // Skip first and last rotations
                        continue;
                    }

                    let before = current.clone();

                    // Apply the rotation
                    current.apply_rotation(rot);

                    // Check perfect matching
                    assert!(
                        current.is_perfect(),
                        "Matching must remain perfect after applying rotation {}",
                        i
                    );

                    // Check stability
                    assert!(
                        current.is_stable(&profile),
                        "Matching must remain stable after applying rotation {}",
                        i
                    );

                    // Check deterioration (men weakly prefer before over current)
                    assert!(
                        all_men_prefer(&before, &current, &profile),
                        "Each rotation must worsen the matching for all men"
                    );
                }

                // After applying all rotations, we must end with the female-optimal matching
                assert!(
                    current == female_opt,
                    "Final matching must be the female-optimal matching"
                );
            }
        }
    }
}
