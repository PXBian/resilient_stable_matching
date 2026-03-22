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
    Dependency* data; // pointer
    size_t len;       // length
    size_t n_rotations; // number of rotations
} RotationDigraph;

typedef struct {
    int* data; // pointer
    size_t n;
} RankingListMatrix;

typedef struct {
    int* data; // pointer
    size_t n;
} PositionMapMatrix;

extern RotationDigraph get_rotation_digraph(RankingListMatrix men, PositionMapMatrix women);
extern void free_rotation_digraph(RotationDigraph digraph);

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
