use crate::rotation_digraph::RotationDigraph;

#[repr(C)]
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct Arc {
    pub from: u32, 
    pub to: u32,
    pub cost: u32, // 0 or 1, backward/parallel or forward arc
    pub capacity: u32, // n for backward arcs, number of linking pairs for forward arcs
}

#[repr(C)]
pub struct LinkingPairNetwork {
    pub n_rotations: usize, // number of rotations
    pub arcs_list: *mut Arc, // pointer
    pub n_arcs: usize, // length
}

impl LinkingPairNetwork {
    pub fn from_rotation_digraph(digraph: &RotationDigraph, n: usize) -> Self {
        let n_rotations = digraph.n_rotations;
        
        let mut arcs_list = Vec::with_capacity(2 * digraph.n_dependencies);
        
        for i in 0..digraph.n_dependencies {
            let dep = unsafe { *digraph.dependencies_list.add(i) };
            let back_arc = Arc {
                from: dep.to,
                to: dep.from,
                cost: 0,
                capacity: n as u32,
            };
            arcs_list.push(back_arc);

            if dep.capacity != 0 {
                let for_arc = Arc {
                    from: dep.from,
                    to: dep.to,
                    cost: 1,
                    capacity: dep.capacity,
                };
                arcs_list.push(for_arc);    
            }
        }
        
        let arcs_list_ptr = arcs_list.as_mut_ptr();
        let arcs_list_len = arcs_list.len();

        std::mem::forget(arcs_list); // avoids the deallocation

        LinkingPairNetwork {
            n_rotations,
            arcs_list: arcs_list_ptr,
            n_arcs: arcs_list_len,
        }
    }
}