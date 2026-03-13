#ifndef MYFFI_H
#define MYFFI_H

#include <stddef.h>  // per size_t

#ifdef __cplusplus
extern "C" {
#endif


typedef struct {
    size_t* men;
    size_t* women;
    size_t len;
} CPreferenceProfile;

typedef struct {
    size_t man;
    size_t woman;
} CPair;

typedef struct {
    size_t from; 
    size_t to;       
    CPair generator; // pair causing the dependency
    uint8_t gen_is_stable; // 1 if stable, 0 otherwise
} CDependency;

typedef struct {
    CDependency* data; // pointer
    size_t len;       // length
    size_t n_rotations; // number of rotations
} CRotationPoset;

typedef struct {
    size_t from; 
    size_t to;       
    CPair generator; // pair causing the dependency
    uint8_t gen_is_stable; // 1 if stable, 0 otherwise
} CDependencyExtended;

typedef struct {
    CDependencyExtended* data; // pointer
    size_t len;       // length
    size_t n_rotations; // number of rotations
} CRotationPosetExtended;


extern CRotationPoset get_rotation_poset(const CPreferenceProfile* c_profile);
extern void free_c_rotation_poset(CRotationPoset poset);

extern CRotationPosetExtended get_rotation_poset_extended(const CPreferenceProfile* c_profile);
extern void free_c_rotation_poset_extended(CRotationPosetExtended poset);

#ifdef __cplusplus
}
#endif

#endif // MYFFI_H
