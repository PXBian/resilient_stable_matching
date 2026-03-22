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

void run_test(const std::string& name, void (*func)(RankingListMatrix, PositionMapMatrix), size_t n, unsigned int seed, RankingListMatrix men, PositionMapMatrix women, const std::string& output_file) {
    
    std::cout << "Test " << name << " with n=" << n << ", seed=" << seed << std::endl;

    long memory_before = getPeakRSS(); 
    
    auto start = std::chrono::high_resolution_clock::now();
    
    func(men, women);
    
    auto finish = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double, std::milli> duration = finish - start;
    long memory_after = getPeakRSS();

    long memory_delta = memory_after - memory_before;
    #ifdef __APPLE__
        memory_delta /= 1024; // Convert from bytes to KB for macOS
    #endif

    std::ofstream file(output_file, std::ios::app);
    
    if (file.is_open()) {
        file << name << "," 
             << n << "," 
             << seed << "," 
             << duration.count() << "," 
             << memory_delta << "\n";
        file.close();
    } else {
        std::cerr << "Impossible to open file " << output_file << std::endl;
    }

    std::cout << "Test done." << std::endl;
}

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

void test_rotation_poset(RankingListMatrix men, PositionMapMatrix women) {
    RotationDigraph digraph = get_rotation_digraph(men, women);
    std::cout << "Number of rotations: " << digraph.n_rotations <<", Number of dependencies: " << digraph.len << std::endl;
    free_rotation_digraph(digraph);
}

int main(int argc, char* argv[]) {
    if (argc < 4) {
        std::cerr << "Use: " << argv[0] << " <n> <seed> <output_file>" << std::endl;
        return 1;
    }

    try {
        size_t n = std::stoull(argv[1]);
        unsigned int seed = static_cast<unsigned int>(std::stoul(argv[2]));
        std::string output_file = argv[3];

        int* arr_m;
        int* arr_w;
        generate_preferences(n, arr_m, arr_w, seed);

        RankingListMatrix men = {arr_m, n};
        PositionMapMatrix women = {arr_w, n};

        run_test("simple32", test_rotation_poset, n, seed, men, women, output_file);

        delete[] arr_m;
        delete[] arr_w;

    } catch (const std::exception& e) {
        std::cerr << "Error in argument format: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}