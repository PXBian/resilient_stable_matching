use crate::profile::Profile;
use crate::matching::Matching;

pub fn gale_shapley_male_optimal(profile: &Profile) -> Matching {
    let n = profile.n;

    let mut matching = Matching::new(n);

    let mut next_proposal = vec![0u32; n];

    let mut free_men: Vec<u32> = (0..n).map(|x| x as u32).collect();

    while let Some(man) = free_men.pop() {
        let woman = profile.men_ranking[man as usize][next_proposal[man as usize] as usize];
        next_proposal[man as usize] += 1;

        match matching.women_to_men[woman as usize] {
            None => {
                matching.set_pair(man, next_proposal[man as usize] - 1, profile);
            }
            Some(other_man) => {
                if matching.woman_prefers(woman, man, profile) {
                    matching.set_pair(man, next_proposal[man as usize] - 1, profile);

                    matching.man_gets_single(other_man);
                    free_men.push(other_man);
                } else {
                    free_men.push(man);
                }
            }
        }
    }


    matching
}
