#include <iostream>
#include <iomanip>
#include <string>
#include <fstream>
#include <map>
#include <bits/stdc++.h>
#include "rotations_poset/rotations_poset.h"

using namespace std;

int main(int argv, char** argc) {
    if (argv < 4) {
        cout << "Usage: " << argc[0] << " <input_file> <n> <flowAmount> <output_file>" << endl;
        return 1;
    }

    string input_file_name = argc[1];
    size_t n = stoi(argc[2]);
    int flowAmount = stoi(argc[3]);
    string output_file_name = argc[4];

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

    // Construct the rotation poset
    CPreferenceProfile pr = (CPreferenceProfile){ .men = arr_m, .women = arr_w, .len = n };
    CRotationPoset rotation_poset = get_rotation_poset(&pr);

    size_t n_rotations = rotation_poset.n_rotations;

    // Construct the forcing graph with info on arcs
    map<pair<int,int>, pair<int, int>> arc_infos;
    CDependency* dependencies = rotation_poset.data;
    const int INF = 1e9;
    for (size_t i = 0; i < rotation_poset.len; ++i) {
        CDependency dependency = dependencies[i];
        int from = dependency.from;
        int to = dependency.to;

        pair<int,int> cur_pair = make_pair(from, to);
        if (arc_infos.find(cur_pair) == arc_infos.end()) {
            pair<int,int> rev_pair = make_pair(to, from);
            arc_infos[rev_pair] = make_pair(0, INF);
            if (dependency.gen_is_stable) {
                arc_infos[cur_pair] = make_pair(1, 1);
            }
        } 
        else {
            if (dependency.gen_is_stable) {
                arc_infos[cur_pair].second++;
            }
        }
    }

    // Save to file
    ofstream out_file(output_file_name);
    if (!out_file.is_open()) {
        cout << "Error: Failed to open output file " << output_file_name << endl;
        free_c_rotation_poset(rotation_poset);
        delete[] arr_m;
        delete[] arr_w;
        return 1;
    }

    // Write n, n_rotations and flowAmount
    out_file << n << " " << n_rotations << " " << flowAmount << "\n";
    
    // Write dependencies (for heuristic algorithm)
    out_file << rotation_poset.len << "\n";
    for (size_t i = 0; i < rotation_poset.len; ++i) {
        CDependency dep = dependencies[i];
        out_file << dep.from << " " << dep.to << " "
                 << dep.generator.man << " " << dep.generator.woman << " "
                 << (int)dep.gen_is_stable << "\n";
    }
    
    // Write arc_infos (for graph construction)
    out_file << arc_infos.size() << "\n";
    for (const auto& [edge, info] : arc_infos) {
        out_file << edge.first << " " << edge.second << " " 
                 << info.first << " " << info.second << "\n";
    }

    out_file.close();

    // 释放资源
    free_c_rotation_poset(rotation_poset);
    delete[] arr_m;
    delete[] arr_w;

    cout << "Poset saved to " << output_file_name << endl;
    cout << "n_rotations: " << n_rotations << ", flowAmount: " << flowAmount << endl;
    cout << "Number of arcs: " << arc_infos.size() << endl;

    return 0;
}

