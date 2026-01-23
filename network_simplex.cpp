#include <iostream>
#include <lemon/list_graph.h>
#include <lemon/maps.h>
#include <lemon/network_simplex.h>
#include <limits>
#include <iomanip>
#include <string>
#include <map>
#include <chrono>
#include <bits/stdc++.h>
#include "rotations_poset/rotations_poset.h"

using namespace lemon;
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

    cout << "Number of arcs: " << arc_infos.size() << endl;

    // 现在可以安全地释放 rotation_poset
    free_c_rotation_poset(rotation_poset);

    // Build LEMON graph
    auto lemon_graph_start = chrono::high_resolution_clock::now();

    ListDigraph graph;
    ListDigraph::ArcMap<int> cost(graph);
    ListDigraph::ArcMap<int> capacity(graph);
    ListDigraph::NodeMap<int> supply(graph);
    ListDigraph::ArcMap<string> arcLabel(graph);

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
        arcLabel[b] = to_string(from_idx) + "->" + to_string(to_idx) + "#" + to_string(arcCounter);
        arcCounter++;
    }

    auto lemon_graph_end = chrono::high_resolution_clock::now();
    double lemon_graph_time = chrono::duration<double>(lemon_graph_end - lemon_graph_start).count();

    // NetworkSimplex
    cout << "Starting NetworkSimplex algorithm..." << endl;
    auto ns_start = chrono::high_resolution_clock::now();
    NetworkSimplex<ListDigraph, int, int> ns_mcf(graph);
    ns_mcf.costMap(cost)
       .upperMap(capacity)
       .supplyMap(supply);

    auto ns_result = ns_mcf.run();
    
    long long ns_cost = -1;
    if (ns_result == NetworkSimplex<ListDigraph, int, int>::OPTIMAL) {
        ns_cost = ns_mcf.totalCost();
    }
    
    auto ns_end = chrono::high_resolution_clock::now();
    double ns_run_time = chrono::duration<double>(ns_end - ns_start).count();

    cout << "The network simplex runtime is " << ns_run_time << " s." << endl;

    if (ns_result == NetworkSimplex<ListDigraph, int, int>::OPTIMAL) {
        cout << "OK (LEMON NetworkSimplex). "
             << "n = " << n
             << ", flow = " << flowAmount
             << ", total_cost = " << ns_cost << "\n";
    } else if (ns_result == NetworkSimplex<ListDigraph, int, int>::INFEASIBLE) {
        cout << "The problem is INFEASIBLE." << endl;
    } else if (ns_result == NetworkSimplex<ListDigraph, int, int>::UNBOUNDED) {
        cout << "The problem is UNBOUNDED." << endl;
    }
    else {
        cout << "EXCEPTION! ns_result = " << ns_result << endl;
    }

    auto total_end = chrono::high_resolution_clock::now();
    double total_time = chrono::duration<double>(total_end - total_start).count();

    // Runtime statistics
    cout << "\n///////////////////////////// RUNTIME STATISTICS //////////////////////////////" << endl;
    cout << "Construct poset time: " << poset_time << " s." << endl;
    cout << "LEMON graph construction time: " << lemon_graph_time << " s." << endl;
    cout << "NetworkSimplex algorithm runtime: " << ns_run_time << " s." << endl;
    cout << "Total time (poset + graph + algorithm): " << poset_time + lemon_graph_time + ns_run_time << " s." << endl;
    cout << "Total program time: " << total_time << " s." << endl;

    // 释放内存
    delete[] arr_m;
    delete[] arr_w;

    return 0;
}
