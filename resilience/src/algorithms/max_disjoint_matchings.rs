use crate::profile::Profile;

/// Compute the resilience as the maximum number of disjoint stable matchings.
pub fn max_disjoint_matchings(profile: &Profile) -> usize {
    let n = profile.n;
    
    let mut resilience = 0;

    let mut next_proposal = vec![0u32; n];
    
    let mut women_to_men = vec![n as u32; n];
    
    'matchingsearch: loop {
            
        let mut free_men: Vec<u32> = (0..n).map(|x| x as u32).collect();
        let mut woman_is_paired = vec![false; n];

        while let Some(man) = free_men.pop() {

            if next_proposal[man as usize] as usize >= n {
                break 'matchingsearch;
            }

            let woman = profile.men_ranking[man as usize][next_proposal[man as usize] as usize];
            next_proposal[man as usize] += 1;            

            if women_to_men[woman as usize] == n as u32 {

                women_to_men[woman as usize] = man;
                woman_is_paired[woman as usize] = true;

            } else {

                let other_man = women_to_men[woman as usize];

                if profile.woman_prefers(woman, man, other_man) {
                    
                    women_to_men[woman as usize] = man;
                    
                    if woman_is_paired[woman as usize] {
                        free_men.push(other_man);
                    } 

                    woman_is_paired[woman as usize] = true;

                } else {
                    free_men.push(man);
                }
            }
        }

        resilience += 1;
    }
    
    resilience
}