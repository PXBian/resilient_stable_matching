#include <iostream>
#include <iomanip>
#include <string>
#include <fstream>
#include <map>
#include <vector>
#include <chrono>
#include <bits/stdc++.h>
#include <lemon/list_graph.h>
#include <lemon/cost_scaling.h>

using namespace lemon;
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

    // Load dependencies (for reference, but not used in graph construction)
    size_t dep_len;
    poset_file >> dep_len;
    for (size_t i = 0; i < dep_len; ++i) {
        size_t from, to, man, woman;
        int gen_is_stable;
        poset_file >> from >> to >> man >> woman >> gen_is_stable;
        // Just skip, not needed for graph construction
    }

    // Load arc_infos
    size_t arc_count;
    poset_file >> arc_count;
    map<pair<int,int>, pair<int, int>> arc_infos;
    for (size_t i = 0; i < arc_count; ++i) {
        int from, to, cost, capacity;
        poset_file >> from >> to >> cost >> capacity;
        arc_infos[make_pair(from, to)] = make_pair(cost, capacity);
    }
    poset_file.close();

    cout << "Number of arcs: " << arc_infos.size() << endl;

    // Build LEMON graph
    auto lemon_graph_start = chrono::high_resolution_clock::now();

    ListDigraph graph;
    ListDigraph::ArcMap<int> cost(graph);
    ListDigraph::ArcMap<int> capacity(graph);
    ListDigraph::NodeMap<int> supply(graph);

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
        arcCounter++;
    }
    
    // 提前释放 arc_infos，减少内存占用
    arc_infos.clear();

    auto lemon_graph_end = chrono::high_resolution_clock::now();
    double lemon_graph_time = chrono::duration<double>(lemon_graph_end - lemon_graph_start).count();

    // CostScaling
    cout << "Starting CostScaling algorithm..." << endl;
    auto cost_start = chrono::high_resolution_clock::now();
    CostScaling<ListDigraph, int, int> cost_mcf(graph);
    cost_mcf.costMap(cost)
       .upperMap(capacity)
       .supplyMap(supply);

    auto cost_result = cost_mcf.run();
    
    long long cost_scaling_cost = -1;
    if (cost_result == CostScaling<ListDigraph, int, int>::OPTIMAL) {
        cost_scaling_cost = cost_mcf.totalCost();
    }
    
    auto cost_end = chrono::high_resolution_clock::now();
    double cost_run_time = chrono::duration<double>(cost_end - cost_start).count();

    cout << "The cost scaling runtime is " << cost_run_time << " s." << endl;

    if (cost_result == CostScaling<ListDigraph, int, int>::OPTIMAL) {
        cout << "OK (LEMON CostScaling). "
             << "n = " << n
             << ", flow = " << flowAmount
             << ", total_cost = " << cost_scaling_cost << "\n";
    } else if (cost_result == CostScaling<ListDigraph, int, int>::INFEASIBLE) {
        cout << "The problem is INFEASIBLE." << endl;
    } else if (cost_result == CostScaling<ListDigraph, int, int>::UNBOUNDED) {
        cout << "The problem is UNBOUNDED." << endl;
    }
    else {
        cout << "EXCEPTION! cost_result = " << cost_result << endl;
    }

    auto total_end = chrono::high_resolution_clock::now();
    double total_time = chrono::duration<double>(total_end - total_start).count();

    // Runtime statistics
    cout << "\n///////////////////////////// RUNTIME STATISTICS //////////////////////////////" << endl;
    cout << "LEMON graph construction time: " << lemon_graph_time << " s." << endl;
    cout << "CostScaling algorithm runtime: " << cost_run_time << " s." << endl;
    cout << "Total time (graph + algorithm): " << lemon_graph_time + cost_run_time << " s." << endl;
    cout << "Total program time: " << total_time << " s." << endl;

    return 0;
}

















