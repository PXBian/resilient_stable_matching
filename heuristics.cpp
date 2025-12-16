#include <iostream>
#include <lemon/list_graph.h>
#include <lemon/maps.h>
#include <lemon/capacity_scaling.h>
#include <lemon/network_simplex.h>
#include <lemon/cost_scaling.h>
#include <lemon/cycle_canceling.h>
#include <limits>
#include <iomanip>
#include <string>
#include <map>
#include <random>
#include <time.h>
#include <chrono>
#include <bits/stdc++.h>
#include "rotations_poset/rotations_poset.h"

using namespace lemon;
using namespace std;

int main(int argv, char** argc) {
    string input_file_name = argc[1];
    size_t n = stoi(argc[2]);
    int flowAmount = stoi(argc[3]);

    size_t* arr_m = new size_t[n * n];
    size_t* arr_w = new size_t[n * n];
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
        // cout << line << endl;
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

    auto prog_start = chrono::high_resolution_clock::now();
    auto construct_poset_start = chrono::high_resolution_clock::now();


    // Construct the rotation poset
    CPreferenceProfile pr = (CPreferenceProfile){ .men = arr_m, .women = arr_w, .len = n };
    CRotationPoset rotation_poset = get_rotation_poset(&pr);

    auto construct_poset_end = chrono::high_resolution_clock::now();
    double poset_time = chrono::duration<double>(construct_poset_end - construct_poset_start).count();

    delete[] arr_m;
    delete[] arr_w;

    cout << "Number of dependencies: " << rotation_poset.len << std::endl;
    cout << "Number of rotations: " << rotation_poset.n_rotations << std::endl;

    // 1. for each man, list all the rotations that he is involved in,
    // 2. then find the flowAmount men with the shortest list of rotations,
    // 3. sum the edges (list length) number flowAmount men
    // 4. return the sum

    auto heuristic_start = chrono::high_resolution_clock::now();

    // Step 1: For each man, collect all rotations he is involved in (only stable edges, gen_is_stable == 1)
    vector<set<size_t>> man_rotations(n);  // man_rotations[i] = set of rotation indices for man i
    
    CDependency* dependencies = rotation_poset.data;
    for (size_t i = 0; i < rotation_poset.len; ++i) {
        CDependency dependency = dependencies[i];
        
        // Only count stable edges (gen_is_stable == 1)
        if (dependency.gen_is_stable == 1) {
            size_t man = dependency.generator.man;
            
            // Add the rotation index (from) to this man's rotation set
            man_rotations[man].insert(dependency.from);
        }
    }

    // Step 2: Create a list of (man_index, rotation_count) pairs and sort by rotation count
    vector<pair<size_t, size_t>> man_rotation_counts;
    for (size_t man = 0; man < n; ++man) {
        man_rotation_counts.push_back({man, man_rotations[man].size()});
    }
    
    // Sort by rotation count (ascending)
    sort(man_rotation_counts.begin(), man_rotation_counts.end(), 
         [](const pair<size_t, size_t>& a, const pair<size_t, size_t>& b) {
             return a.second < b.second;
         });

    // Step 3: Find flowAmount men with shortest rotation lists and sum their edges
    int total_cost = 0;
    int selected_count = min(flowAmount, (int)n);
    
    for (int i = 0; i < selected_count; ++i) {
        size_t rotation_count = man_rotation_counts[i].second;
        // Number of edges = list_length
        total_cost += rotation_count;
    }

    auto heuristic_end = chrono::high_resolution_clock::now();
    double heuristic_run_time = chrono::duration<double>(heuristic_end - heuristic_start).count();
    
    auto prog_end = chrono::high_resolution_clock::now();
    double total_time = chrono::duration<double>(prog_end - prog_start).count();
    
    cout << "The heuristic runtime is " << heuristic_run_time << " s." << endl;
    if (flowAmount > n) {
        cout << "Warning: flowAmount > n, flowAmount = " << flowAmount << ", n = " << n << endl;
    }
    cout << "OK (Heuristic). "
         << "n = " << n
         << ", flow = " << flowAmount
         << ", total_cost = " << total_cost << "\n";
    
    double heuristic_total_time = poset_time + heuristic_run_time;
    
    cout << "\n///////////////////////////// RESULTS //////////////////////////////" << endl;
    cout << "The min_cost = " << total_cost << endl;
    cout << "Construct poset time: " << poset_time << " s, total time: " << total_time << " s." << endl;
    cout << "Heuristic total time: " << heuristic_total_time << " s." << endl;


    // Clean up
    free_c_rotation_poset(rotation_poset);

    return 0;
}
