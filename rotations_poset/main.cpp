#include <iostream>
#include "rotations_poset.h"

int main() {

    size_t arr_m[] = {
        0, 6, 5, 2, 4, 1, 3,
        6, 1, 4, 5, 0, 2, 3,
        6, 0, 3, 1, 5, 4, 2,
        3, 2, 0, 1, 4, 6, 5,
        1, 2, 0, 3, 4, 5, 6,
        6, 1, 0, 3, 5, 4, 2,
        2, 5, 0, 6, 4, 3, 1};
    size_t arr_w[] = {
        2, 1, 6, 4, 5, 3, 0,
        0, 4, 3, 5, 2, 6, 1,
        2, 5, 0, 4, 3, 1, 6,
        6, 1, 2, 3, 4, 0, 5,
        4, 6, 0, 5, 3, 1, 2,
        3, 1, 2, 6, 5, 4, 0,
        4, 6, 2, 1, 3, 0, 5
    };
    size_t n = 7;

    CPreferenceProfile pr = (CPreferenceProfile){ .men = arr_m, .women = arr_w, .len = n };
    CRotationPoset rotation_poset = get_rotation_poset(&pr);

    std::cout << "Number of dependencies: " << rotation_poset.len << std::endl;
    std::cout << "Number of rotations: " << rotation_poset.n_rotations << std::endl;

    free_c_rotation_poset(rotation_poset);

    return 0;
}
