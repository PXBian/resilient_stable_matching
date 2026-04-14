#include <iostream>
#include "rotation_poset.h"

int main() {
    int arr_m[] = {
        0, 6, 5, 2, 4, 1, 3,
        6, 1, 4, 5, 0, 2, 3,
        6, 0, 3, 1, 5, 4, 2,
        3, 2, 0, 1, 4, 6, 5,
        1, 2, 0, 3, 4, 5, 6,
        6, 1, 0, 3, 5, 4, 2,
        2, 5, 0, 6, 4, 3, 1};
    int arr_w[] = {
        2, 1, 6, 4, 5, 3, 0,
        0, 4, 3, 5, 2, 6, 1,
        2, 5, 0, 4, 3, 1, 6,
        6, 1, 2, 3, 4, 0, 5,
        4, 6, 0, 5, 3, 1, 2,
        3, 1, 2, 6, 5, 4, 0,
        4, 6, 2, 1, 3, 0, 5
    };
    size_t n = 7;
    
    invert_matrix(arr_w, n);    

    RankingListMatrix men_r = {arr_m, n};
    PositionMapMatrix women_p = {arr_w, n};
    RotationDigraph digraph = get_rotation_digraph(men_r, women_p, 1);

    std::cout << "Number of rotations: " << digraph.n_rotations << ". Number of dependencies: " << digraph.n_dependencies << "." << std::endl;

    for (size_t i = 0; i < digraph.n_rotations; i++) {
        std::cout << digraph.starting_indexes[i] << std::endl;
    }

    std::cout << "Stable pairs in the rotations:" << std::endl;
    int rotation_count = 0;
    for (size_t i = 0; i < digraph.n_pairs; i++) {
        if (i == digraph.starting_indexes[rotation_count + 1]) {
            rotation_count++;
        }
        StablePair pair = digraph.pairs_list[i];
        std::cout << rotation_count << " " << pair.rem_rotation << " " << pair.man << " " << pair.woman << std::endl;
    }

    free_rotation_digraph(digraph);
    return 0;
}