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
