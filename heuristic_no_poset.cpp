#include <iostream>
#include <iomanip>
#include <string>
#include <fstream>
#include <map>
#include <vector>
#include <set>
#include <algorithm>
#include <chrono>
#include <bits/stdc++.h>

using namespace std;

int main(int argv, char** argc) {
    if (argv < 2) {
        cout << "Usage: " << argc[0] << " <poset_file>" << endl;
        return 1;
    }

    string poset_file_name = argc[1];

    // Total runtime starts from loading poset file
    auto total_start = chrono::high_resolution_clock::now();

    // Load poset from file
    ifstream poset_file(poset_file_name);
    if (!poset_file.is_open()) {
        cout << "Error: Failed to open poset file " << poset_file_name << endl;
        return 1;
    }

    size_t n, n_rotations;
    int flowAmount;
    poset_file >> n >> n_rotations >> flowAmount;

    // Load dependencies and process on-the-fly to reduce memory usage
    // Step 1: For each man, collect all rotations he is involved in (only stable edges, gen_is_stable == 1)
    auto heuristic_start = chrono::high_resolution_clock::now();
    
    vector<set<size_t>> man_rotations(n);  // man_rotations[i] = set of rotation indices for man i
    
    size_t dep_len;
    poset_file >> dep_len;
    // Process dependencies on-the-fly instead of storing them all
    for (size_t i = 0; i < dep_len; ++i) {
        size_t from, to, man, woman;
        int gen_is_stable;
        poset_file >> from >> to >> man >> woman >> gen_is_stable;
        
        // Only count stable edges (gen_is_stable == 1)
        if (gen_is_stable == 1) {
            // Add the rotation index (from) to this man's rotation set
            man_rotations[man].insert(from);
        }
    }

    // Load arc_infos (not used in heuristic, but need to skip)
    size_t arc_count;
    poset_file >> arc_count;
    for (size_t i = 0; i < arc_count; ++i) {
        int from, to, cost, capacity;
        poset_file >> from >> to >> cost >> capacity;
    }
    poset_file.close();

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
    int heuristic_cost = 0;
    int selected_count = min(flowAmount, (int)n);
    
    for (int i = 0; i < selected_count; ++i) {
        size_t rotation_count = man_rotation_counts[i].second;
        // Number of edges = list_length
        heuristic_cost += rotation_count;
    }

    auto heuristic_end = chrono::high_resolution_clock::now();
    double heuristic_run_time = chrono::duration<double>(heuristic_end - heuristic_start).count();

    auto total_end = chrono::high_resolution_clock::now();
    double total_time = chrono::duration<double>(total_end - total_start).count();

    // Print results
    cout << "The heuristic runtime is " << heuristic_run_time << " s." << endl;
    if (flowAmount > (int)n) {
        cout << "Warning: flowAmount > n, flowAmount = " << flowAmount << ", n = " << n << endl;
    }
    cout << "OK (Heuristic). "
         << "n = " << n
         << ", flow = " << flowAmount
         << ", total_cost = " << heuristic_cost << "\n";

    // Runtime statistics
    cout << "\n///////////////////////////// RUNTIME STATISTICS //////////////////////////////" << endl;
    cout << "Heuristic algorithm runtime: " << heuristic_run_time << " s." << endl;
    cout << "Total program time: " << total_time << " s." << endl;

    return 0;
}


