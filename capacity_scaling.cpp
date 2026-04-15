#include <iostream>
#include <lemon/list_graph.h>
#include <lemon/maps.h>
#include <lemon/capacity_scaling.h>
#include <limits>
#include <iomanip>
#include <string>
#include <map>
#include <chrono>
#include <fstream>
#include <bits/stdc++.h>
#include "rotation_poset/rotation_poset.h"

using namespace lemon;
using namespace std;

int main(int argv, char** argc) {
    string input_file_name = argc[1];
    size_t n = stoi(argc[2]);
    int flowAmount = stoi(argc[3]);

    // 使用一维数组存储，按行展开
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
    RotationDigraph rotation_poset = get_rotation_digraph(men_matrix, women_matrix, 0);

    auto poset_end = chrono::high_resolution_clock::now();
    double poset_time = chrono::duration<double>(poset_end - poset_start).count();

    std::cout << "Number of dependencies: " << rotation_poset.n_dependencies << std::endl;
    std::cout << "Number of rotations: " << rotation_poset.n_rotations << std::endl;

    size_t n_rotations = rotation_poset.n_rotations;

    // Construct the forcing graph with info on arcs
    map<pair<int,int>, pair<int, int>> arc_infos;
    Dependency* dependencies = rotation_poset.dependencies_list;
    const int INF = 1e9;
    for (size_t i = 0; i < rotation_poset.n_dependencies; ++i) {
        Dependency dep = dependencies[i];
        int from = dep.from;
        int to = dep.to;
        arc_infos[make_pair(to, from)] = make_pair(0, INF);
        if (dep.capacity > 0) {
            arc_infos[make_pair(from, to)] = make_pair(1, (int)dep.capacity);
        }
    }

    cout << "Number of arcs: " << arc_infos.size() << endl;

    // 现在可以安全地释放 rotation_poset
    free_rotation_digraph(rotation_poset);
    
    // 提前释放输入数组，减少内存占用
    delete[] arr_m;
    delete[] arr_w;

    // Build LEMON graph
    auto lemon_graph_start = chrono::high_resolution_clock::now();

    ListDigraph graph;
    ListDigraph::ArcMap<int> cost(graph);
    ListDigraph::ArcMap<int> capacity(graph);
    ListDigraph::NodeMap<int> supply(graph);
    // ListDigraph::ArcMap<string> arcLabel(graph);  // Commented out to reduce memory usage

    vector<ListDigraph::Node> nodes(n_rotations);
    for (size_t i = 0; i < n_rotations; ++i) {
        nodes[i] = graph.addNode();
        supply[nodes[i]] = 0;
    }

    ListDigraph::Node s = nodes[0];
    ListDigraph::Node t = nodes[n_rotations - 1];

    supply[s] = flowAmount;
    supply[t] = -flowAmount;

    int arcCounter = 0;

    for (const auto& [edge, info] : arc_infos) {
        int from_idx = edge.first;
        int to_idx = edge.second;
        int edge_cost = info.first;
        int edge_capacity = info.second;

        if (from_idx < 0 || from_idx >= (int)n_rotations || to_idx < 0 || to_idx >= (int)n_rotations) {
            continue;
        }

        ListDigraph::Arc b = graph.addArc(nodes[from_idx], nodes[to_idx]);
        cost[b] = edge_cost;
        capacity[b] = edge_capacity;
        // arcLabel[b] = to_string(from_idx) + "->" + to_string(to_idx) + "#" + to_string(arcCounter);  // Commented out to reduce memory usage
        arcCounter++;
    }
    
    // 提前释放 arc_infos，减少内存占用
    size_t arc_num = arc_infos.size();
    arc_infos.clear();

    auto lemon_graph_end = chrono::high_resolution_clock::now();
    double lemon_graph_time = chrono::duration<double>(lemon_graph_end - lemon_graph_start).count();

    // Capacity Scaling
    cout << "Starting CapacityScaling algorithm..." << endl;
    auto cs_start = chrono::high_resolution_clock::now();
    CapacityScaling<ListDigraph, int, int> cs_mcf(graph);
    cs_mcf.costMap(cost)
       .upperMap(capacity)
       .supplyMap(supply);

    auto cs_result = cs_mcf.run();
    
    long long cs_cost = -1;
    if (cs_result == CapacityScaling<ListDigraph, int, int>::OPTIMAL) {
        cs_cost = cs_mcf.totalCost();
    }
    
    auto cs_end = chrono::high_resolution_clock::now();
    double cs_run_time = chrono::duration<double>(cs_end - cs_start).count();

    cout << "The capacity scaling runtime is " << cs_run_time << " s." << endl;

    if (cs_result == CapacityScaling<ListDigraph, int, int>::OPTIMAL) {
        cout << "OK (LEMON CapacityScaling). "
             << "n = " << n
             << ", flow = " << flowAmount
             << ", total_cost = " << cs_cost << "\n";
    } else if (cs_result == CapacityScaling<ListDigraph, int, int>::INFEASIBLE) {
        cout << "The problem is INFEASIBLE." << endl;
    } else if (cs_result == CapacityScaling<ListDigraph, int, int>::UNBOUNDED) {
        cout << "The problem is UNBOUNDED." << endl;
    }
    else {
        cout << "EXCEPTION! cs_result = " << cs_result << endl;
    }

    auto total_end = chrono::high_resolution_clock::now();
    double total_time = chrono::duration<double>(total_end - total_start).count();

    // Runtime statistics
    cout << "\n///////////////////////////// RUNTIME STATISTICS //////////////////////////////" << endl;
    cout << "Construct poset time: " << poset_time << " s." << endl;
    // cout << "LEMON graph construction time: " << lemon_graph_time << " s." << endl;
    // cout << "CapacityScaling algorithm runtime: " << cs_run_time << " s." << endl;
    double graph_plus_algo_time = lemon_graph_time + cs_run_time;
    cout << "Total time (graph + algorithm): " << graph_plus_algo_time << " s." << endl;
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
        long cost_out = (cs_result == CapacityScaling<ListDigraph, int, int>::OPTIMAL) ? (long)cs_cost : -1;
        ofstream csv("runtime_output/capacity_scaling_runtime_stats.csv", ios::app);
        if (csv.is_open()) {
            if (csv.tellp() == 0) {
                csv << "dataset,method,n,flowAmount,total_cost,rotations_num,arc_num,poset_time,algorithm_runtime,graph_plus_algo_time,total_program_time\n";
            }
            csv << dataset << ",capacity_scaling," << n << "," << flowAmount << "," << cost_out
                << "," << n_rotations << "," << arc_num
                << "," << poset_time << "," << cs_run_time << "," << graph_plus_algo_time << "," << total_time << "\n";
            csv.close();
        }
    }

    return 0;
}
