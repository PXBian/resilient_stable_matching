#include <iostream>
#include <iomanip>
#include <string>
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
    std::cout << "Poset construction time: " << poset_time << " s." << std::endl;

    // 现在可以安全地释放 rotation_poset
    free_c_rotation_poset(rotation_poset);
    
    // 提前释放输入数组，减少内存占用
    delete[] arr_m;
    delete[] arr_w;

    auto total_end = chrono::high_resolution_clock::now();
    double total_time = chrono::duration<double>(total_end - total_start).count();
    std::cout << "Total time: " << total_time << " s." << std::endl;

    return 0;
}


















