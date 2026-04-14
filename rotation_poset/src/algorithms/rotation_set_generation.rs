use crate::matching::Matching;
use crate::profile::Profile;
use crate::rotations::Rotation;
use crate::rotation_set::RotationSet;
use std::collections::{HashSet, HashMap};

/// Build the rotation set following the Irving–Leather construction.
pub fn build_rotation_set(profile: &Profile, complete_data: bool) -> RotationSet {
    let n = profile.n;

    let mut rp = RotationSet::new(profile);
    let mut current = Matching::male_optimal(profile);
    
    rp.male_optimal_matching = current.clone();
    
    // Step 1: insert the artificial rotation 0
    let mut initial = Rotation::new();
    for m in (0..n).map(|x| x as u32) {
        let w_rank = current.men_to_women[m as usize].unwrap();
        initial.add_introduced(m, w_rank);
    }
    
    grid_update(&mut rp, &initial, profile);
    
    if complete_data {
        rp.rotations_sizes.push(n as u32);
    }

    // Step 2: main Rotation Finding Loop
    let mut men_doomed: HashSet<u32> = HashSet::new();

    for man in (0..n).map(|x| x as u32) {

        let mut queue: Vec<u32> = Vec::new();
        queue.push(man);
        let mut women_next_rank: HashMap<u32, u32> = HashMap::new();      
        let mut next_rank_start = current.men_to_women[man as usize].unwrap() + 1;

        'rotationsearch: loop {
            let mut m = *queue.last().unwrap();
            
            if men_doomed.contains(&m) {
                break; // no more rotation from this man
            }

            // Best acceptable woman after current partner
            let w_rank_opt = best_next_acceptable_woman(&current, m, next_rank_start, profile);
            if w_rank_opt.is_none() {
                break; // no more rotations available from this chain
            }
            
            let mut w_rank = w_rank_opt.unwrap();
            
            let mut w = profile.men_ranking[m as usize][w_rank as usize];

            // Expand until we hit a previously visited woman or we find a doomed man
            while !women_next_rank.contains_key(&w) {
                women_next_rank.insert(w, w_rank);
                m = current.women_to_men[w as usize].unwrap();
                
                queue.push(m);

                if men_doomed.contains(&m) {
                    break 'rotationsearch; // no more rotation from this man
                }

                let w2_rank_opt = best_next_acceptable_woman(&current, m, current.men_to_women[m as usize].unwrap() + 1, profile);

                if w2_rank_opt.is_none() {
                    break 'rotationsearch; // no more rotations available from this chain
                }

                w_rank = w2_rank_opt.unwrap();
                w = profile.men_ranking[m as usize][w_rank as usize];
            }

            // We now have found a rotation cycle
            // w is in women's set, and queue contains the cycle.

            next_rank_start = women_next_rank[&w];

            let rotation = generate_rotation(
                &mut current,
                &mut queue,
                w,
                w_rank,
                &mut women_next_rank,
                profile,
            );

            grid_update(&mut rp, &rotation, profile);

            if complete_data {
                rp.rotations_sizes.push(rotation.introduced.len() as u32);
            }
        }

        // We broke out of the loop, so all men left in the queue are doomed
        // men_doomed.extend(queue.iter());
        men_doomed.extend(queue.into_iter());

    }

    if complete_data {
        rp.rotations_sizes.push(0);
    }

    rp.n_rotations += 1;
    rp.female_optimal_matching = current;
    rp.compute_grid(profile);
    rp
}

/// Updates the grids for a given rotation.
fn grid_update(
    rp: &mut RotationSet,
    rot: &Rotation,
    profile: &Profile,
) {
    for &(m, rank_w) in rot.introduced.iter() {

        let w = profile.men_ranking[m as usize][rank_w as usize];

        rp.women_rotation_index[w as usize].insert(m, rp.n_rotations as u32);
        
    }
    
    rp.n_rotations += 1; // rotation index of the new rotation being added
    
}

/// Generates a rotation starting from the cycle discovered via (queue, w_start).
fn generate_rotation(
    matching: &mut Matching,
    queue: &mut Vec<u32>,
    w_start: u32,
    w_start_rank: u32,
    women_next_rank: &mut HashMap<u32, u32>,
    profile: &Profile,
) -> Rotation {

    // Rotation being built
    let mut rot = Rotation::new();

    // Current woman in the chain
    let mut current_m;
    let mut current_w = w_start;
    let mut current_w_rank = w_start_rank;
    let mut first_iteration = true;

    while women_next_rank.contains_key(&current_w) {

        current_m = queue.pop().unwrap();
        
        if !first_iteration {
            current_w_rank = women_next_rank[&current_w];
        } else {
            first_iteration = false;
        }

        let next_w_rank = matching.men_to_women[current_m as usize].unwrap();

        rot.add_introduced(current_m, current_w_rank);

        women_next_rank.remove(&current_w);

        current_w = profile.men_ranking[current_m as usize][next_w_rank as usize];
    }

    matching.apply_rotation(&rot, profile);
    
    rot
}

/// Find the best acceptable woman for 'm' after 'w'.
/// Returns None if no such woman exists.
fn best_next_acceptable_woman(
    current: &Matching,
    m: u32,
    next_rank_start: u32,
    profile: &Profile,
) -> Option<u32> {
    let n = profile.n;
    let w_rank = next_rank_start as usize;
    // For all men m' that w ranks lower than m, mark unstable
    for i in (w_rank)..n {
        let nw = profile.men_ranking[m as usize][i];
        if current.woman_prefers(nw, m, profile) {
            return Some(i as u32);
        }
    }
    None
}