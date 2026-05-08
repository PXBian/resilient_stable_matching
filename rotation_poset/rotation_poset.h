#ifndef MYFFI_H
#define MYFFI_H

#include <stddef.h>  // per size_t

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    int from; 
    int to;       
    int capacity;
} Dependency;

typedef struct {
    int man; 
    int woman;       
    int rem_rotation;
} StablePair;

typedef struct {
    int* starting_indexes; // pointer
    size_t n_rotations; // number of rotations
    StablePair* pairs_list; // pointer
    size_t n_pairs; // length
    Dependency* dependencies_list; // pointer
    size_t n_dependencies; // length
} RotationDigraph;

typedef struct {
    int* data; // pointer
    size_t n;
} RankingListMatrix;

typedef struct {
    int* data; // pointer
    size_t n;
} PositionMapMatrix;

typedef struct {
    int from; 
    int to;
    int cost;
} Arc;

typedef struct {
    size_t n_vertices; // number of vertices
    Arc* arcs_list; // pointer
    size_t n_arcs; // length
} StablePairsGraph;

extern RotationDigraph get_rotation_digraph(RankingListMatrix men, PositionMapMatrix women, int complete_data);
extern void free_rotation_digraph(RotationDigraph digraph);
extern StablePairsGraph get_stable_pairs_graph(RotationDigraph digraph);
extern void free_stable_pairs_graph(StablePairsGraph graph);

void invert_matrix(int* matrix, size_t n) {
    int* temp = (int*)malloc(n * sizeof(int));

    for (int i = 0; i < n; i++) {
        int* row = &matrix[i * n];
        for (int j = 0; j < n; j++) {
            temp[j] = row[j];
        }
        for (int j = 0; j < n; j++) {
            row[temp[j]] = j;
        }
    }
    
    free(temp);
}

#ifdef __cplusplus
}
#endif

#endif // MYFFI_H
