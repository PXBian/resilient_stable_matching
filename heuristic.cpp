#include <iostream>
#include <iomanip>
#include <string>
#include <set>
#include <vector>
#include <algorithm>
#include <chrono>
#include <fstream>
#include <bits/stdc++.h>
#include "rotation_poset/rotation_poset.h"

using namespace std;

int main(int argv, char** argc) {
    string input_file_name = argc[1];
    size_t n = stoi(argc[2]);
    int flowAmount = stoi(argc[3]);

    int* arr_m = new int[n * n];
    int* arr_w = new int[n * n];
    for (size_t i = 0; i < n * n; ++i) {
        arr_m[i] = 0;
        arr_w[i] = 0;
    }

    // Read the input file
    ifstream input_file(input_file_name);
    if (!input_file.is_open()) {
        cout << "Error: Failed to open input file " << input_file_name << endl;
        delete[] arr_m;
        delete[] arr_w;
        return 1;
    }
    string line;
    size_t line_count = 0;
    while (getline(input_file, line)) {
        stringstream ss(line);
        string token;
        if (line_count < n) {
            size_t m = line_count, w = 0;
            while (getline(ss, token, ' ')) {
                arr_m[m * n + w] = stoi(token);
                w++;
            }
        } 
        else {
            size_t w = line_count - n, m = 0;
            while (getline(ss, token, ' ')) {
                arr_w[w * n + m] = stoi(token);
                m++;
            }
        }
        line_count++;
    }
    input_file.close();

    // Total runtime starts AFTER reading the input file (exclude I/O time)
    auto total_start = chrono::high_resolution_clock::now();

    auto poset_start = chrono::high_resolution_clock::now();

    // Construct the rotation poset
    invert_matrix(arr_w, n);
    RankingListMatrix men_matrix = { .data = arr_m, .n = n };
    PositionMapMatrix women_matrix = { .data = arr_w, .n = n };
    RotationDigraph rotation_poset = get_rotation_digraph(men_matrix, women_matrix, 1);

    auto poset_end = chrono::high_resolution_clock::now();
    double poset_time = chrono::duration<double>(poset_end - poset_start).count();

    std::cout << "Number of dependencies: " << rotation_poset.n_dependencies << std::endl;
    std::cout << "Number of rotations: " << rotation_poset.n_rotations << std::endl;

    // Run heuristic algorithm before freeing rotation_poset
    auto heuristic_start = chrono::high_resolution_clock::now();

    // Count how many non-artificial rotations each man appears in.
    // Rotation 0 is an artificial initial rotation containing every man once,
    // while the final rotation n_rotations - 1 introduces no pairs.
    vector<size_t> man_rotation_count(n, 0);
    if (rotation_poset.starting_indexes != nullptr && rotation_poset.pairs_list != nullptr) {
        for (size_t r = 1; r + 1 < rotation_poset.n_rotations; ++r) {
            size_t begin = rotation_poset.starting_indexes[r];
            size_t end = rotation_poset.starting_indexes[r + 1];
            for (size_t idx = begin; idx < end; ++idx) {
                StablePair pair = rotation_poset.pairs_list[idx];
                if (pair.man >= 0 && static_cast<size_t>(pair.man) < n) {
                    man_rotation_count[pair.man]++;
                }
            }
        }
    }

    // Step 1: For each rotation, accumulate stable out-capacity.
    size_t n_rot = rotation_poset.n_rotations;
    vector<size_t> rotation_capacity(n_rot, 0);

    Dependency* deps = rotation_poset.dependencies_list;
    for (size_t i = 0; i < rotation_poset.n_dependencies; ++i) {
        Dependency dep = deps[i];
        if (dep.capacity > 0) {
            rotation_capacity[dep.from] += dep.capacity;
        }
    }

    // Step 2: Collect only rotations with stable out-capacity > 0, then sort ascending
    vector<size_t> nonzero_caps;
    for (size_t r = 0; r < n_rot; ++r) {
        if (rotation_capacity[r] > 0) {
            nonzero_caps.push_back(rotation_capacity[r]);
        }
    }
    sort(nonzero_caps.begin(), nonzero_caps.end());

    // Step 3: Sum the flowAmount smallest nonzero capacities as heuristic cost
    int heuristic_cost = 0;
    int selected_count = min(flowAmount, (int)nonzero_caps.size());

    for (int i = 0; i < selected_count; ++i) {
        heuristic_cost += nonzero_caps[i];
    }

    auto heuristic_end = chrono::high_resolution_clock::now();
    double heuristic_run_time = chrono::duration<double>(heuristic_end - heuristic_start).count();

    size_t n_rotations = n_rot;
    size_t arc_num = rotation_poset.n_dependencies;
    free_rotation_digraph(rotation_poset);

    delete[] arr_m;
    delete[] arr_w;

    auto total_end = chrono::high_resolution_clock::now();
    double total_time = chrono::duration<double>(total_end - total_start).count();

    // Print results
    // cout << "The heuristic runtime is " << heuristic_run_time << " s." << endl;
    if (flowAmount > (int)n) {
        cout << "Warning: flowAmount > n, flowAmount = " << flowAmount << ", n = " << n << endl;
    }
    cout << "OK (Heuristic). "
         << "n = " << n
         << ", flow = " << flowAmount
         << ", total_cost = " << heuristic_cost << "\n";

    // cout << "man_rotation_count (excluding artificial rotation 0):";
    // for (size_t m = 0; m < n; ++m) {
    //     cout << " " << m << ":" << man_rotation_count[m];
    // }
    // cout << "\n";

    // Runtime statistics
    cout << "\n///////////////////////////// RUNTIME STATISTICS //////////////////////////////" << endl;
    cout << "Construct poset time: " << poset_time << " s." << endl;
    cout << "Heuristic algorithm runtime: " << heuristic_run_time << " s." << endl;
    cout << "Total program time: " << total_time << " s." << endl;

    // Append runtime stats to CSV (dataset, method, n, flowAmount, total_cost, rotations_num, arc_num, poset_time, algorithm_runtime, graph_plus_algo_time, total_program_time)
    {
        string basename = input_file_name;
        size_t slash = basename.find_last_of("/\\");
        if (slash != string::npos) basename = basename.substr(slash + 1);
        size_t inst = basename.find("_instance");
        if (inst != string::npos) basename = basename.substr(0, inst);
        size_t last_ = basename.rfind('_');
        string dataset = (last_ != string::npos) ? basename.substr(0, last_) : basename;
        ofstream csv("runtime_output/heuristic_runtime_stats.csv", ios::app);
        if (csv.is_open()) {
            if (csv.tellp() == 0) {
                csv << "dataset,method,n,flowAmount,total_cost,rotations_num,arc_num,poset_time,algorithm_runtime,graph_plus_algo_time,total_program_time\n";
            }
            double graph_plus_algo_time = heuristic_run_time; 
            csv << dataset << ",heuristic," << n << "," << flowAmount << "," << heuristic_cost
                << "," << n_rotations << "," << arc_num
                << "," << poset_time << "," << heuristic_run_time << "," << graph_plus_algo_time << "," << total_time << "\n";
            csv.close();
        }
    }

    return 0;
}
