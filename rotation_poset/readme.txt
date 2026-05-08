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

The edges of the rotation digraph are represented trough the data structure "Dependency", that has the integer attributes "from", "to", and "capacity" (eventually 0).
The output data structure is named "RotationDigraph" and its attributes are an integer "n_rotation", an integer "len", and a pointer Dependency* "data" that represents an array of length len.
The function "get_rotation_digraph" gives a RotationDigraph as output, and the function "free_rotation_digraph(RotationDigraph digraph)" frees the memory allocated for digraph.

For every edge of the rotation digraph with capacity greater than 0, the edge must be inserted in the forcing graph both in its direct version with the given capacity and in its reverse version with infinite capacity.
For every edge of the rotation digraph with capacity 0, the edge only has to be inserted in the forcing graph in its reverse version with infinite capacity.


=== UPDATE ===

There is a new data structure involved in the output named "StablePair", that has the integer attributes "man", "woman" and "rem_rotation".
The attributes man and woman represent the partners in the pairing, while rem_rotation is the index of the rotation that REMOVES the pair.
The data structure "RotationDigraph" has now three more attributes: an integer n_pairs, a pointer StablePair* pairs_list that represents an array of length n_pairs, and a pointer int* starting_indexes that represents an array of length n_rotations.
To avoid confusion, the attributes previously named "data" and "len" have been renamed "dependencies_list" and "n_dependencies" respectively.

The set of stable pairs INTRODUCED by the rotation of index i is the slice of the array pairs_list between starting_indexes[i] and starting_indexes[i+1].
For the final rotation, thus the one with index n_rotations-1, there are no introduced pairs.
The StablePairs inside each slice are sorted according to the attribute man.

Now the function get_rotation_digraph requires the additional input complete_data, an integer meant to represent a boolean.
If you only need the topology of the digraph without specific information about the rotations, as for the previous implementation, set complete_data to 0.
In this way, the attribute n_pairs will be set to 0, and the pointers pairs_list and starting_indexes will be null.
The other three attributes remain unchanged from the previous version.
If you need the complete information about rotations to compute any heuristics, set it to 1.


=== COMPETITOR UPDATE ===

There are new data structures to represent the competitor graph, named Stable Pairs Graph.
The edges of this graph are represented trough the data structure "Arc", that has the integer attributes "from", "to", and "cost" (always 0 or 1).
The output data structure is named "StablePairsGraph" and its attributes are an integer "n_vertices", an integer "n_arcs", and a pointer Arc* "arcs_list" that represents an array of length n_arcs.

The function "get_stable_pairs_graph" takes as input the RotationDigraph structure, which MUST be computed via the function get_rotation_digraph called with the argument complete_data set to 1.
The function "free_stable_pairs_graph(StablePairsGraph spgraph)" frees the memory allocated for spgraph.

The capacity for every edge of the stable pairs graph must be considered 1 if the cost is 1 and infinite if the cost is 0.

