use crate::matching::Matching;
use crate::preference_profile::PreferenceProfile;
use crate::rotations::Rotation;
use crate::rotation_poset_extended::RotationPosetExtended;
use std::collections::{HashSet, HashMap};

/// Build the rotation poset following the Irving–Leather construction.
pub fn build_rotation_poset_extended(profile: &PreferenceProfile) -> RotationPosetExtended {
    let n = profile.n;

    let mut rp = RotationPosetExtended::new(n);
    let mut current = Matching::male_optimal(profile);
    
    // Step 1: insert the artificial rotation 0
    let mut initial = Rotation::new();
    for m in 0..n {
        let w = current.men_to_women[m].unwrap();
        initial.add_introduced(m, w);
    }

    
    rp.rotations.push(initial);
    
    grid_update(&mut rp, 0, profile);

    // Step 2: main Rotation Finding Loop
    let mut men_doomed: HashSet<usize> = HashSet::new();

    for man in 0..n {
        

        let mut queue: Vec<usize> = Vec::new();
        queue.push(man);
        let mut women_next_partner: HashMap<usize, usize> = HashMap::new();      

        'rotationsearch: loop {
            let mut m = *queue.last().unwrap();
            
            if men_doomed.contains(&m) {
                break; // no more rotation from this man
            }

            // Best acceptable woman after current partner
            let w_opt = best_next_acceptable_woman(&rp, profile, m, current.men_to_women[m].unwrap());
            if w_opt.is_none() {
                break; // no more rotations available from this chain
            }
            let mut w = w_opt.unwrap();

            // Expand until we hit a previously visited woman or we find a doomed man
            while !women_next_partner.contains_key(&w) {
                women_next_partner.insert(w, m);
                m = current.women_to_men[w].unwrap();
                
                
                queue.push(m);

                if men_doomed.contains(&m) {
                    break 'rotationsearch; // no more rotation from this man
                }

                let w2 = best_next_acceptable_woman(&rp, profile, m, current.men_to_women[m].unwrap());

                if w2.is_none() {
                    break 'rotationsearch; // no more rotations available from this chain
                }
                w = w2.unwrap();
            }

            // We now have found a rotation cycle
            // w is in women's set, and queue contains the cycle.
            let rotation = generate_rotation(
                &mut current,
                &mut queue,
                w,
                &mut women_next_partner,
            );
            let idx = rp.rotations.len();
            
            rp.rotations.push(rotation);
            grid_update(&mut rp, idx, profile);
        }

        // We broke out of the loop, so all men left in the queue are doomed
        men_doomed.extend(queue.iter());

    }

    // Step 3: Add final matching as a dummy rotation
    let mut final_rot = Rotation::new();
    for m in 0..n {
        if let Some(w) = current.men_to_women[m] {
            final_rot.add_removed(m, w);
        }
    }
    rp.rotations.push(final_rot);
    // No grid update required
    rp
}

/// Updates the grids for a given rotation.
fn grid_update(
    rp: &mut RotationPosetExtended,
    rot_idx: usize,
    profile: &PreferenceProfile,
) {
    let rot = &rp.rotations[rot_idx];
    for &(m, w) in rot.introduced.iter() {
        // rank of w in m's preferences
        let rm = profile.men[m].position[w];

        // Mark (m, rm) as stable edge produced by rot_idx
        rp.stable_grid[m][rm] = Some(true);
        rp.rotation_index[m][rm] = Some(rot_idx);
        
        // rank of m in w's preferences
        let rw = profile.women[w].position[m];

        // For all men m' that w ranks lower than m, mark unstable
        for m2 in profile.women[w].ranking.iter().skip(rw + 1) {
            let m2 = *m2;
            let rm2 = profile.men[m2].position[w];

            if rp.stable_grid[m2][rm2].is_some() {
                break;
            }

            rp.stable_grid[m2][rm2] = Some(false);
            rp.rotation_index[m2][rm2] = Some(rot_idx);
        }
    }
}

/// Generates a rotation starting from the cycle discovered via (queue, w_start).
fn generate_rotation(
    matching: &mut Matching,
    queue: &mut Vec<usize>,
    w_start: usize,
    women_next_partner: &mut HashMap<usize, usize>,
) -> Rotation {
    // The man that closes the rotation cycle:
    
    let next_last_man = women_next_partner[&w_start];

    // Rotation being built
    let mut rot = Rotation::new();

    // Current woman in the chain
    let mut current_w = w_start;
    let mut first_iteration = true;
    // Pop men from the back of the queue until we reach next_last_man (excluded)
    while let Some(current_m) = queue.pop() {

        
        if current_m == next_last_man && !first_iteration {
            // Stop before removing next_last_man from the queue
            queue.push(current_m);
            break;
        }
        first_iteration = false;
        
        // Remove current woman from the hashmap
        women_next_partner.remove(&current_w);
        
        // Get the man's current partner
        let next_w = matching.men_to_women[current_m]
            .expect("Every man in the queue must currently be matched");

        // Add removed pair
        rot.removed.insert((current_m, next_w));

        // Add introduced pair
        rot.introduced.insert((current_m, current_w));

        // Update matching
        matching.set_pair(current_m, current_w);

        // Move to next woman in the chain
        current_w = next_w;
    }

    rot
}

/// Find the best acceptable woman for 'm' after 'w'.
/// Returns None if no such woman exists.
fn best_next_acceptable_woman(
    rp: &RotationPosetExtended,
    profile: &PreferenceProfile,
    m: usize,
    w: usize,
) -> Option<usize> {
    let n = profile.n;
    // rank of w in m's preferences
    let rank = profile.men[m].position[w];

    // For all men m' that w ranks lower than m, mark unstable
    for i in (rank+1)..n {
        let nw = profile.men[m].ranking[i];
        if rp.stable_grid[m][i].is_none() {
            return Some(nw);
        }
    }
    None
}