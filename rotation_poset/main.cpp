#include <iostream>
#include "rotation_poset.h"
#include <algorithm> 
#include <numeric>   
#include <random>    
#include <chrono>
#include <sys/resource.h> // For getrusage (Linux/macOS)
#include <string>
#include <fstream>

// To read peak memory usage in KB
long getPeakRSS() {
    struct rusage usage;
    getrusage(RUSAGE_SELF, &usage);
    return usage.ru_maxrss; 
    // For Linux is KB, for macOS is byte
}

void run_test(const std::string& name, void (*func)(CPreferenceProfile), size_t n, unsigned int seed, CPreferenceProfile profile) {
    
    std::cout << "Test " << name << " with n=" << n << ", seed=" << seed << std::endl;

    long memory_before = getPeakRSS()/1024; // Because I have a MacOS
    
    auto start = std::chrono::high_resolution_clock::now();
    
    // Esecuzione della tua funzione
    func(profile);
    
    auto finish = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double, std::milli> duration = finish - start;
    long memory_after = getPeakRSS()/1024;

    std::ofstream file("measurements.csv", std::ios::app);
    
    if (file.is_open()) {
        file << name << "," 
             << n << "," 
             << seed << "," 
             << duration.count() << "," 
             << memory_after - memory_before << "\n";
        file.close();
    } else {
        std::cerr << "Impossible to open file measurements.csv" << std::endl;
    }

    std::cout << "Test done." << std::endl;
}

void generate_preferences(size_t n, size_t*& arr_m, size_t*& arr_w, unsigned int seed) {
    //std::random_device rd;
    std::mt19937 g(seed); // g(rd()); // Use random seed for different runs

    arr_m = new size_t[n * n];
    arr_w = new size_t[n * n];

    for (size_t i = 0; i < n; i++) {
        size_t* start_row_m = &arr_m[i * n];
        size_t* start_row_w = &arr_w[i * n];

        std::iota(start_row_m, start_row_m + n, 0);
        std::iota(start_row_w, start_row_w + n, 0);

        std::shuffle(start_row_m, start_row_m + n, g);
        std::shuffle(start_row_w, start_row_w + n, g);
    }
}

void test_rotation_poset(CPreferenceProfile profile) {
    CRotationPoset rotation_poset = get_rotation_poset(&profile);
    std::cout << "Number of rotations: " << rotation_poset.n_rotations <<", Number of dependencies: " << rotation_poset.len << std::endl;
    free_c_rotation_poset(rotation_poset);
}

void test_rotation_poset_extended(CPreferenceProfile profile) {
    CRotationPosetExtended rotation_poset_extended = get_rotation_poset_extended(&profile);
    std::cout << "Number of rotations: " << rotation_poset_extended.n_rotations <<", Number of dependencies: " << rotation_poset_extended.len << std::endl;
    free_c_rotation_poset_extended(rotation_poset_extended);
}

int main(int argc, char* argv[]) {
    if (argc < 4) {
        std::cerr << "Use: " << argv[0] << " <n> <seed> <test_extended (0 or 1)>" << std::endl;
        return 1;
    }

    try {
        size_t n = std::stoull(argv[1]);
        unsigned int seed = static_cast<unsigned int>(std::stoul(argv[2]));
        bool extended = (std::string(argv[3]) == "1" || std::string(argv[3]) == "true");

        size_t* arr_m;
        size_t* arr_w;
        generate_preferences(n, arr_m, arr_w, seed);

        CPreferenceProfile pr = (CPreferenceProfile){ .men = arr_m, .women = arr_w, .len = n };
        if (extended) {
            run_test("extended", test_rotation_poset_extended, n, seed, pr);
        } else {
            run_test("simple", test_rotation_poset, n, seed, pr);
        }

        delete[] arr_m;
        delete[] arr_w;

    } catch (const std::exception& e) {
        std::cerr << "Error in argument format: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}

/*
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
*/