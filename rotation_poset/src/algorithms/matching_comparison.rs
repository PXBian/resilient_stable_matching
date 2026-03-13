use crate::matching::Matching;
use crate::preference_profile::PreferenceProfile;

/// Returns true if every man weakly prefers `m1` to `m2`.
///
/// Weak preference definition:
/// - If m1 gives the man a partner and m2 does not → m1 is better.
/// - If both give a partner, use strict preference.
/// - If both give the same partner → equal, OK.
/// - If m1 makes the man single and m2 gives a partner → m1 is worse.
///
pub fn all_men_prefer(
    m1: &Matching,
    m2: &Matching,
    profile: &PreferenceProfile,
) -> bool {
    let n = profile.n;

    for man in 0..n {
        let p1 = m1.men_to_women[man];
        let p2 = m2.men_to_women[man];

        match (p1, p2) {
            (Some(w1), Some(w2)) => {
                if profile.men[man].prefers(w2, w1) {
                    return false;
                }
            }

            (Some(_), None) => {
                // m1 gives a partner, m2 doesn't → OK
                continue;
            }

            (None, Some(_)) => {
                // m1 makes man single but m2 gives partner → NOT OK
                return false;
            }

            (None, None) => {
                // both single → equal → OK
                continue;
            }
        }
    }

    true
}
