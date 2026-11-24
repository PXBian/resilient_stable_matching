--- INPUT ---

The library contains two data structures for the input:
    
    "RankingListMatrix": 
    Its attributes are an integer "n" and a pointer int* "data" that represents an array of length n^2.
    It is meant to be the (n x n) matrix containing the preference ranking of the represented set over the other.
    This means that if i have the RankingListMatrix "men_ranking" and men_ranking[i][j] = k it means that woman k is the j-th best option according to man i.

    "PreferenceMapMatrix":
    Its attributes are an integer "n" and a pointer int* "data" that represents an array of length n^2.
    It is meant to be the (n x n) matrix containing the position of the elements of the other set in the ranking of the represented set.
    This means that if i have the PositionMapMatrix "women_position" and women_ranking[i][j] = k it means that man j is the k-th best option according to woman i.

The rows men_ranking[i] and men_position[i] are the reverse permutation of each other, and the same holds for women_ranking and women_position.
The library contains the procedure "invert_matrix(int* matrix, int n)" that turns the input matrix from a ranking matrix to the corrispondig position matrix or viceversa.

The function "get_rotation_digraph(RankingListMatrix men, PositionMapMatrix women)" requires as input the RankingListMatrix representing men preferences and the PositionMapMatrix representing women preferences.
If your available input is just the ranking matrix for both men and women preferences, please call the invert_matrix function on the ranking matrix representing women preferences.


--- OUTPUT ---

The data structure named "StablePair" has an attribute named rem_rotation representing the index of the rotation that REMOVES the pair.

The function "get_rotation_digraph" gives a RotationDigraph as output, and the function "free_rotation_digraph(RotationDigraph digraph)" frees the memory allocated for digraph.
The set of stable pairs INTRODUCED by the rotation of index i is the slice of the array pairs_list between starting_indexes[i] and starting_indexes[i+1].
For the final rotation, thus the one with index n_rotations-1, there are no introduced pairs.
The StablePairs inside each slice are sorted according to the attribute man.
The Dependencies are unsorted.
The function get_rotation_digraph requires as additional inputs find_dependencies and find_pairs, two integers meant to represent booleans.
If find_dependencies is set to 1 and find_pairs is set to 0, the arrays starting_indexes and pairs_list will be null pointers, and n_pairs will be set to 0.
If find_dependencies is set to 0 and find_pairs is set to 1, the arrays starting_indexes and dependencies_list will be null pointers, n_dependencies will be set to 0 and all the StablePairs in pairs_list will have 0 as placeholder for the rem_rotation attribute.
Finally, if they are both set to 1 the data of the rotation digraph will be complete and if they are both set to 0 the function will pretend that find_dependencies is set to 1.

The function "get_linking_pair_network" gives a LinkingPairNetwork as output, and the function "free_linking_pair_network(LinkingPairNetwork lpn)" frees the memory allocated for lpn.
The input for get_linking_pair_network requires as input a RotationDigraph computed with a meaningful dependencies_list, and the integer n.
To recover the linking pairs relative to a forward arc in the lpn one must look for them in the pairs_list in the RotationDigraph. 
Resilience and tau-resilience are respectively shortest paths and minimum cost tau-flow for this network.

The function "get_girl_path_graph" takes as input the RotationDigraph structure, which MUST be computed via the function get_rotation_digraph called with both find_pairs and find_dependencies set to 1, and the PreferenceMapMatrix relative to women.
The function "free_girl_path_graph(GirlPathGraph gpg)" frees the memory allocated for spgraph.
If i != 0, the arc between vertex i and vertex j corresponds to the pair in pairs_list[n+i-1], while if i == 0 it corresponds to a pair of the male-optimal matching, or multiple pairs if j is also the sink.
Resilience and tau-resilience are respectively shortest paths and minimum cost tau-flow for this graph.

The function "resilience_via_packing" computes the resilience as the maximum number of disjoint stable matchings.
