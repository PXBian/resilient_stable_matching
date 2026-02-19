#include <iostream>
#include <iomanip>
#include <string>
#include <set>
#include <vector>
#include <algorithm>
#include <chrono>
#include <bits/stdc++.h>
#include "rotations_poset/rotations_poset.h"

using namespace std;

int main(int argv, char** argc) {
    string input_file_name = argc[1];
    size_t n = stoi(argc[2]);
    int flowAmount = stoi(argc[3]);

    // 使用一维数组存储，按行展开
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
    CPreferenceProfile pr = (CPreferenceProfile){ .men = arr_m, .women = arr_w, .len = n };
    CRotationPoset rotation_poset = get_rotation_poset(&pr);

    auto poset_end = chrono::high_resolution_clock::now();
    double poset_time = chrono::duration<double>(poset_end - poset_start).count();

    std::cout << "Number of dependencies: " << rotation_poset.len << std::endl;
    std::cout << "Number of rotations: " << rotation_poset.n_rotations << std::endl;

    // Run heuristic algorithm before freeing rotation_poset
    auto heuristic_start = chrono::high_resolution_clock::now();

    // Step 1: For each man, collect all rotations he is involved in (only stable edges, gen_is_stable == 1)
    vector<set<size_t>> man_rotations(n);  // man_rotations[i] = set of rotation indices for man i
    
    CDependency* deps = rotation_poset.data;
    for (size_t i = 0; i < rotation_poset.len; ++i) {
        CDependency dependency = deps[i];
        
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
    int heuristic_cost = 0;
    int selected_count = min(flowAmount, (int)n);
    
    for (int i = 0; i < selected_count; ++i) {
        size_t rotation_count = man_rotation_counts[i].second;
        // Number of edges = list_length
        heuristic_cost += rotation_count;
    }

    auto heuristic_end = chrono::high_resolution_clock::now();
    double heuristic_run_time = chrono::duration<double>(heuristic_end - heuristic_start).count();

    // 现在可以安全地释放 rotation_poset
    free_c_rotation_poset(rotation_poset);
    
    // 提前释放输入数组，减少内存占用
    delete[] arr_m;
    delete[] arr_w;

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
    cout << "Construct poset time: " << poset_time << " s." << endl;
    cout << "Heuristic algorithm runtime: " << heuristic_run_time << " s." << endl;
    cout << "Total program time: " << total_time << " s." << endl;

    return 0;
}

