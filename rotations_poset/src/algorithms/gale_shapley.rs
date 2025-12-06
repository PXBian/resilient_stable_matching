use crate::preference_profile::PreferenceProfile;
use crate::matching::Matching;

/// Esegue l’algoritmo Gale–Shapley male-optimal.
/// Restituisce un Matching stabile.
pub fn gale_shapley_male_optimal(profile: &PreferenceProfile) -> Matching {
    let n = profile.n;

    // Matching vuoto: tutti disaccoppiati
    let mut matching = Matching::new(n);

    // Per ogni uomo tiene traccia a chi ha già proposto
    let mut next_proposal = vec![0usize; n];

    // Lista degli uomini "liberi"
    let mut free_men: Vec<usize> = (0..n).collect();

    while let Some(man) = free_men.pop() {
        // Uomo propone alla sua prossima preferenza
        let woman = profile.men[man].ranking[next_proposal[man]];
        next_proposal[man] += 1;

        match matching.women_to_men[woman] {
            None => {
                // Donna libera → accetta automaticamente
                matching.set_pair(man, woman);
            }
            Some(other_man) => {
                // Donna già accoppiata → decide in base alle preferenze
                if matching.woman_prefers(woman, man, profile) {
                    // Donna preferisce il nuovo uomo → rimpiazza
                    matching.set_pair(man, woman);

                    // L'altro uomo torna libero
                    matching.man_gets_single(other_man);
                    free_men.push(other_man);
                } else {
                    // Donna rifiuta → uomo rimane libero
                    free_men.push(man);
                }
            }
        }
    }


    matching
}

/// Esegue l’algoritmo Gale–Shapley female-optimal.
/// Restituisce un Matching stabile (il migliore per le donne).
pub fn gale_shapley_female_optimal(profile: &PreferenceProfile) -> Matching {
    let n = profile.n;

    // Matching vuoto
    let mut matching = Matching::new(n);

    // Per ogni donna tiene traccia del prossimo uomo a cui proporre
    let mut next_proposal = vec![0usize; n];

    // Lista delle donne libere
    let mut free_women: Vec<usize> = (0..n).collect();

    while let Some(woman) = free_women.pop() {
        // Donna propone al suo prossimo uomo preferito
        let man = profile.women[woman].ranking[next_proposal[woman]];
        next_proposal[woman] += 1;

        match matching.men_to_women[man] {
            None => {
                // Uomo libero → accetta automaticamente
                matching.set_pair(man, woman);
            }
            Some(other_woman) => {
                // Uomo già accoppiato → decide in base alle sue preferenze
                if matching.man_prefers(man, woman, profile) {
                    // Uomo preferisce la nuova donna → rimpiazza
                    matching.set_pair(man, woman);

                    // L'altra donna diventa libera
                    matching.woman_gets_single(other_woman);
                    free_women.push(other_woman);
                } else {
                    // Uomo rifiuta → donna rimane libera
                    free_women.push(woman);
                }
            }
        }
    }

    matching
}
