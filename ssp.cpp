#include <iostream>
#include <limits>
#include <iomanip>
#include <string>
#include <map>
#include <chrono>
#include <bits/stdc++.h>
#include "rotations_poset/rotations_poset.h"

using namespace std;

struct Edge {
    int to;     // terminal
    int rev;    // the index of the reversed edge in G[to]
    int cost;   // unit cost
    int cap;    // remain capacity
};

int N;  // Global: Number of nodes
const int INF = 1e9;
    
// Add edge u->v and its residual 
void addEdge(vector<vector<Edge>> &G, int u, int v, int cap, int cost) {
    Edge fwd{v, static_cast<int>(G[v].size()), cost, cap};
    Edge rev{u, static_cast<int>(G[u].size()), -cost, 0};
    G[u].push_back(fwd);
    G[v].push_back(rev);
}

bool dijkstraWithPotentials(vector<vector<Edge>> &G,
                            int s, int t,
                            vector<int>& potential,
                            vector<int>& dist,
                            vector<int>& parent,
                            vector<int>& parent_edge) {
    int graph_size = G.size();
    dist.assign(graph_size, INF);
    parent.assign(graph_size, -1);
    parent_edge.assign(graph_size, -1);
    

    // Min-heap priority queue for Dijkstra's algorithm.
    // element pair<int,int>: <dist[u], u>
    // Aim: 1. Always extract the node with the smallest tentative distance
    //      2. Update neighbors
    //      3. Push new distance estimates into the queue
    priority_queue<pair<int, int>, vector<pair<int, int>>, greater<pair<int, int>>> pq;
    
    dist[s] = 0;
    pq.push({0, s});
    
    while (!pq.empty()) {
        auto [d, u] = pq.top();
        pq.pop();

        if (d > dist[u]) continue;
        
        for (int i = 0; i < (int)G[u].size(); ++i) {
            Edge &e = G[u][i];
            
            if (e.cap <= 0) continue;
            
            int v = e.to;
            int reduced_cost = e.cost + potential[u] - potential[v];
            int new_dist = dist[u] + reduced_cost;
            
            // Find a new min distance, update
            if (new_dist < dist[v]) {
                dist[v] = new_dist;
                parent[v] = u;
                parent_edge[v] = i;
                pq.push({new_dist, v});
            }
        }
    }
        
    return dist[t] < INF;
}

// Use Dijkstra with potentials to iterate tau times (flow number) to return the min-cost
pair<int, int> minCost(vector<vector<Edge>> &G, int s, int t, int max_flow) {
    int total_flow = 0;
    int total_cost = 0;
    int graph_size = G.size();

    vector<int> potential(graph_size, 0);  
    vector<int> dist(graph_size), parent(graph_size), parent_edge(graph_size);

    // int iteration = 0;
    while (total_flow < max_flow) {
        // iteration++;
        
        // Use Dijkstra with potentials to find the min-cost path
        if (!dijkstraWithPotentials(G, s, t, potential, dist, parent, parent_edge)) {
            break;
        }
        
        // Find bottleneck capacity on the path t -> s
        int path_flow = max_flow - total_flow;
        for (int v = t; v != s; v = parent[v]) {
            int u = parent[v];
            int edge_idx = parent_edge[v];
            path_flow = min(path_flow, G[u][edge_idx].cap);
        }
        
        // Calculate actual path cost（Use original costs, not reduced costs）
        // Reduced costs are only for finding the path
        int path_cost = 0;
        for (int v = t; v != s; v = parent[v]) {
            int u = parent[v];
            int edge_idx = parent_edge[v];
            path_cost += G[u][edge_idx].cost;
        }
        
        // Update flow and cost
        total_flow += path_flow;
        total_cost += path_flow * path_cost;
        
        // Update residual graph
        for (int v = t; v != s; v = parent[v]) {
            int u = parent[v];
            int edge_idx = parent_edge[v];
            
            // Decrease forward edge capacity
            G[u][edge_idx].cap -= path_flow;
            
            // Increase reverse edge capacity
            int revIdx = G[u][edge_idx].rev;
            G[v][revIdx].cap += path_flow;
        }
        
        // Update potentials: ensures reduced costs remain non-negative in the next iteration
        for (int v = 0; v < graph_size; ++v) {
            if (dist[v] < INF) {
                potential[v] += dist[v];
            }
        }
    }
        
    return {total_flow, total_cost};
}

int main(int argv, char** argc) {
    auto total_start = chrono::high_resolution_clock::now();
    
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

    auto poset_start = chrono::high_resolution_clock::now();

    // Construct the rotation poset
    CPreferenceProfile pr = (CPreferenceProfile){ .men = arr_m, .women = arr_w, .len = n };
    CRotationPoset rotation_poset = get_rotation_poset(&pr);

    auto poset_end = chrono::high_resolution_clock::now();
    double poset_time = chrono::duration<double>(poset_end - poset_start).count();

    std::cout << "Number of dependencies: " << rotation_poset.len << std::endl;
    std::cout << "Number of rotations: " << rotation_poset.n_rotations << std::endl;

    // 保存 rotation_poset 的数据，因为后面会释放它
    size_t n_rotations = rotation_poset.n_rotations;

    // Construct the forcing graph with info on arcs
    // Key: <man, woman>
    // Value: <cost, capacity>
    map<pair<int,int>, pair<int, int>> arc_infos;
    CDependency* dependencies = rotation_poset.data;
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

    // Build self-implemented graph
    auto self_graph_start = chrono::high_resolution_clock::now();

    N = n_rotations;  // 图是基于旋转构建的，所以使用旋转数量
    int s_index = 0;
    int t_index = n_rotations - 1;
    vector<vector<Edge>> G(N);  // 索引从0开始

    for (const auto& [edge, info] : arc_infos) {
        int from_idx = edge.first;
        int to_idx = edge.second;
        int edge_cost = info.first;
        int edge_capacity = info.second;

        // 确保索引在有效范围内（rotation索引从0开始）
        if (from_idx < 0 || from_idx >= (int)n_rotations || to_idx < 0 || to_idx >= (int)n_rotations) {
            continue;  // 跳过无效的边
        }

        // self-implemented
        addEdge(G, from_idx, to_idx, edge_capacity, edge_cost);
    }

    auto self_graph_end = chrono::high_resolution_clock::now();
    double self_graph_time = chrono::duration<double>(self_graph_end - self_graph_start).count();

    // self-implemented SSP
    cout << "Starting self-implemented SSP algorithm..." << endl;
    auto algorithm_start = chrono::high_resolution_clock::now();
    auto ssp_result = minCost(G, s_index, t_index, flowAmount);
    int actual_flow = ssp_result.first;
    int min_cost = ssp_result.second;
    auto algorithm_end = chrono::high_resolution_clock::now();
    double algorithm_run_time = chrono::duration<double>(algorithm_end - algorithm_start).count();

    cout << "The self-implemented runtime is " << algorithm_run_time << " s." << endl;

    if (actual_flow < 0) {
        cout << "Error: Invalid flow computation (negative cycle detected)\n";
    } else if (actual_flow < flowAmount) {
        cout << "Cannot send required flow amount = " << flowAmount << "\n";
        cout << "Actual flow = " << actual_flow
             << ", min_cost = " << min_cost << "\n";
    } else {
        cout << "OK (SSP+Dijkstra). "
             << "n = " << n
             << ", flow = " << flowAmount
             << ", min_cost = " << min_cost << "\n";
    }

    auto total_end = chrono::high_resolution_clock::now();
    double total_time = chrono::duration<double>(total_end - total_start).count();

    // Print timing results
    cout << "\n///////////////////////////// TIMING RESULTS //////////////////////////////" << endl;
    cout << "Construct poset time: " << poset_time << " s." << endl;
    cout << "Self-implemented graph construction time: " << self_graph_time << " s." << endl;
    cout << "SSP+Dijkstra algorithm runtime: " << algorithm_run_time << " s." << endl;
    cout << "Total time (excluding poset): " << self_graph_time + algorithm_run_time << " s." << endl;
    cout << "Total time (including poset): " << total_time << " s." << endl;

    // 释放内存
    delete[] arr_m;
    delete[] arr_w;

    return 0;
}

