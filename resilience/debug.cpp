#include <iostream>
#include "resilience.h"
#include "graph.h"
#include <random>    

void generate_preferences(size_t n, int*& arr_m, int*& arr_w, unsigned int seed) {
    //std::random_device rd;
    std::mt19937 g(seed); // g(rd()); // Use random seed for different runs

    arr_m = new int[n * n];
    arr_w = new int[n * n];

    for (size_t i = 0; i < n; i++) {
        int* start_row_m = &arr_m[i * n];
        int* start_row_w = &arr_w[i * n];

        std::iota(start_row_m, start_row_m + n, 0);
        std::iota(start_row_w, start_row_w + n, 0);

        std::shuffle(start_row_m, start_row_m + n, g);
        std::shuffle(start_row_w, start_row_w + n, g);
    }
}

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
/*      

    size_t n = 100;
    unsigned int seed = 1;

    int* arr_m;
    int* arr_w;
    generate_preferences(n, arr_m, arr_w, seed);
*/ 
    RankingListMatrix men_r = {arr_m, n};
    PositionMapMatrix women_p = {arr_w, n};


    RotationDigraph test = get_rotation_digraph(men_r, women_p, 0, 1);

    std::cout << "Stable pairs in the rotations:" << std::endl;
    
    for (size_t i = 0; i < test.n_pairs; i++) {
        StablePair pair = test.pairs_list[i];
        std::cout << pair.man << " " << pair.woman << std::endl;
    }

    // Resilience via LPN
    RotationDigraph digraph = get_rotation_digraph(men_r, women_p, 1, 1);
    
    /*
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
    */

    LinkingPairNetwork linking_pair_network = get_linking_pair_network(digraph, n);

    Graph lpn;
    for (size_t i = 0; i < linking_pair_network.n_arcs; i++) {
        lpn.add_edge(linking_pair_network.arcs_list[i].from, linking_pair_network.arcs_list[i].to, linking_pair_network.arcs_list[i].cost);
    }

    auto res_lpn = lpn.shortest_path(0, digraph.n_rotations - 1);

    int resilience_lpn = res_lpn.distance;
    std::cout <<"Resilience via lpn: " << resilience_lpn << std::endl;

    // Resilience via Girl Path Graph

    GirlPathGraph girl_path_graph = get_girl_path_graph(digraph, women_p);

    /*
    std::cout << "Number of vertices in girl path graph: " << girl_path_graph.n_vertices << std::endl;
    std::cout << "Number of arcs in girl path graph: " << girl_path_graph.n_arcs << std::endl;
    std::cout << "Arcs in girl path graph:" << std::endl;
    for (size_t i = 0; i < girl_path_graph.n_arcs; i++) {
        Arc arc = girl_path_graph.arcs_list[i];
        std::cout << arc.from << " -> " << arc.to << " (cost: " << arc.cost << ", capacity: " << arc.capacity << ")" << std::endl;
    }
    */
   
    Graph gpg;
    for (size_t i = 0; i < girl_path_graph.n_arcs; i++) {
        gpg.add_edge(girl_path_graph.arcs_list[i].from, girl_path_graph.arcs_list[i].to, girl_path_graph.arcs_list[i].cost);
    }

    auto res_gpg = gpg.shortest_path(0, girl_path_graph.n_vertices - 1);

    int resilience_gpg = res_gpg.distance;
    std::cout <<"Resilience via gpg: " << resilience_gpg << std::endl;
    
    // Resilience via Packing

    int resilience_packing = resilience_via_packing(men_r, women_p);
    std::cout <<"Resilience via pkg: " << resilience_packing << std::endl;

    free_rotation_digraph(digraph);
    free_girl_path_graph(girl_path_graph);
    
    return 0;
}

    