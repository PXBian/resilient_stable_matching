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
    

    // Min-heap priority queue for Dijkstra’s algorithm.
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
    string input_file_name = argc[1];
    size_t n = stoi(argc[2]);
    int flowAmount = stoi(argc[3]);

    // 使用二维数组存储（方便后续操作）
    vector<vector<size_t>> arr_m(n, vector<size_t>(n, 0));
    vector<vector<size_t>> arr_w(n, vector<size_t>(n, 0));

    // Read the input file
    ifstream input_file(input_file_name);
    if (!input_file.is_open()) {
        cout << "Error: Failed to open input file " << input_file_name << endl;
        return 1;
    }
    string line;
    size_t line_count = 0;
    while (getline(input_file, line)) {
        cout << line << endl;
        stringstream ss(line);
        string token;
        if (line_count < n) {
            size_t m = line_count, w = 0;
            while (getline(ss, token, ' ')) {
                arr_m[m][w] = stoi(token);
                w++;
            }
        } 
        else {
            size_t w = line_count - n, m = 0;
            while (getline(ss, token, ' ')) {
                arr_w[w][m] = stoi(token);
                m++;
            }
        }
        line_count++;
    }
    input_file.close();

    // 将二维数组转换为连续的一维数组供 C 接口使用
    // 注意：vector<vector<size_t>> 在内存中不是完全连续的，需要手动复制
    size_t* arr_m_flat = new size_t[n * n];
    size_t* arr_w_flat = new size_t[n * n];
    for (size_t i = 0; i < n; ++i) {
        for (size_t j = 0; j < n; ++j) {
            arr_m_flat[i * n + j] = arr_m[i][j];
            arr_w_flat[i * n + j] = arr_w[i][j];
        }
    }

    // Construct the rotation poset
    CPreferenceProfile pr = (CPreferenceProfile){ .men = arr_m_flat, .women = arr_w_flat, .len = n };
    CRotationPoset rotation_poset = get_rotation_poset(&pr);

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
        // man 和 woman 暂时未使用，但保留以备将来使用
        // int man = dependency.generator.man;
        // int woman = dependency.generator.woman;

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

    // 现在可以安全地释放 rotation_poset
    free_c_rotation_poset(rotation_poset);

    ListDigraph graph;

    ListDigraph::ArcMap<int> cost(graph);
    ListDigraph::ArcMap<int> capacity(graph);
    ListDigraph::NodeMap<int> supply(graph);
    ListDigraph::ArcMap<string> arcLabel(graph);


    vector<ListDigraph::Node> nodes(n_rotations);  // 索引从0开始
    for (size_t i = 0; i < n_rotations; ++i) {
        nodes[i] = graph.addNode();
        supply[nodes[i]] = 0;
    }

    ListDigraph::Node s = nodes[0];  // 源节点索引为0
    ListDigraph::Node t = nodes[n_rotations - 1];  // 汇节点索引为n_rotations-1

    supply[s] = flowAmount;
    supply[t] = -flowAmount;

    
    N = n_rotations;  // 图是基于旋转构建的，所以使用旋转数量
    int s_index = 0;  // 索引从0开始
    int t_index = n_rotations - 1;  // 索引从0开始
    vector<vector<Edge>> G(N);  // 索引从0开始

    int arcCounter = 0;

    for (const auto& [edge, info] : arc_infos) {
        int from_idx = edge.first;
        int to_idx = edge.second;
        int edge_cost = info.first;
        int edge_capacity = info.second;

        // 确保索引在有效范围内（索引从0开始）
        if (from_idx < 0 || from_idx >= (int)n_rotations || to_idx < 0 || to_idx >= (int)n_rotations) {
            continue;  // 跳过无效的边
        }

        ListDigraph::Arc b = graph.addArc(nodes[from_idx], nodes[to_idx]);
        cost[b] = edge_cost;
        capacity[b] = edge_capacity;
        arcLabel[b] = to_string(from_idx) + "->" + to_string(to_idx) + "#" + to_string(arcCounter);
        arcCounter++;

        // self-implemented
        addEdge(G, from_idx, to_idx, edge_capacity, edge_cost);
    }

    // Capacity Scaling
    auto prog_start = chrono::high_resolution_clock::now();
    CapacityScaling<ListDigraph, int, int> cs_mcf(graph);
    cs_mcf.costMap(cost)
       .upperMap(capacity)
       .supplyMap(supply);

    auto cs_result = cs_mcf.run();
    auto prog_end = chrono::high_resolution_clock::now();
    double cs_run_time = chrono::duration<double>(prog_end - prog_start).count();

    cout << "The capacity scaling runtime is " << cs_run_time << " s." << endl;

    if (cs_result == CapacityScaling<ListDigraph, int, int>::OPTIMAL) {
        long long totalCost = cs_mcf.totalCost();
        cout << "OK (LEMON CapacityScaling). "
             << "n = " << n
             << ", flow = " << flowAmount
             << ", total_cost = " << totalCost << "\n";
    } else if (cs_result == CapacityScaling<ListDigraph, int, int>::INFEASIBLE) {
        cout << "The problem is INFEASIBLE." << endl;
    } else if (cs_result == CapacityScaling<ListDigraph, int, int>::UNBOUNDED) {
        cout << "The problem is UNBOUNDED." << endl;
    }


    // NetworkSimplex
    prog_start = chrono::high_resolution_clock::now();
    NetworkSimplex<ListDigraph, int, int> ns_mcf(graph);
    ns_mcf.costMap(cost)
       .upperMap(capacity)
       .supplyMap(supply);

    auto ns_result = ns_mcf.run();
    prog_end = chrono::high_resolution_clock::now();
    double ns_run_time = chrono::duration<double>(prog_end - prog_start).count();

    cout << "The network simplex runtime is " << ns_run_time << " s." << endl;

    if (ns_result == NetworkSimplex<ListDigraph, int, int>::OPTIMAL) {
        long long totalCost = ns_mcf.totalCost();
        cout << "OK (LEMON NetworkSimplex). "
             << "n = " << n
             << ", flow = " << flowAmount
             << ", total_cost = " << totalCost << "\n";
    } else if (ns_result == NetworkSimplex<ListDigraph, int, int>::INFEASIBLE) {
        cout << "The problem is INFEASIBLE." << endl;
    } else if (ns_result == NetworkSimplex<ListDigraph, int, int>::UNBOUNDED) {
        cout << "The problem is UNBOUNDED." << endl;
    }


    // CostScaling
    prog_start = chrono::high_resolution_clock::now();
    CostScaling<ListDigraph, int, int> cost_mcf(graph);
    cost_mcf.costMap(cost)
       .upperMap(capacity)
       .supplyMap(supply);

    auto cost_result = cost_mcf.run();
    prog_end = chrono::high_resolution_clock::now();
    double cost_run_time = chrono::duration<double>(prog_end - prog_start).count();

    cout << "The cost scaling runtime is " << cost_run_time << " s." << endl;

    if (cost_result == CostScaling<ListDigraph, int, int>::OPTIMAL) {
        long long totalCost = cost_mcf.totalCost();
        cout << "OK (LEMON CostScaling). "
             << "n = " << n
             << ", flow = " << flowAmount
             << ", total_cost = " << totalCost << "\n";
    } else if (cost_result == CostScaling<ListDigraph, int, int>::INFEASIBLE) {
        cout << "The problem is INFEASIBLE." << endl;
    } else if (cost_result == CostScaling<ListDigraph, int, int>::UNBOUNDED) {
        cout << "The problem is UNBOUNDED." << endl;
    }


    // // CycleCanceling
    // prog_start = chrono::high_resolution_clock::now();
    // CycleCanceling<ListDigraph, int, int> cc_mcf(graph);
    // cc_mcf.costMap(cost)
    //    .upperMap(capacity)
    //    .supplyMap(supply);

    // auto cc_result = cc_mcf.run();
    // prog_end = chrono::high_resolution_clock::now();
    // double cc_run_time = chrono::duration<double>(prog_end - prog_start).count();

    // cout << "The cycle canceling runtime is " << cc_run_time << " s." << endl;

    // if (cc_result == CycleCanceling<ListDigraph, int, int>::OPTIMAL) {
    //     long long totalCost = cc_mcf.totalCost();
    //     cout << "OK (LEMON CycleCanceling). "
    //          << "n = " << n
    //          << ", max_deg = " << max_deg
    //          << ", flow = " << flowAmount
    //          << ", total_cost = " << totalCost << "\n";
    // } else if (cc_result == CycleCanceling<ListDigraph, int, int>::INFEASIBLE) {
    //     cout << "The problem is INFEASIBLE." << endl;
    // } else if (cc_result == CycleCanceling<ListDigraph, int, int>::UNBOUNDED) {
    //     cout << "The problem is UNBOUNDED." << endl;
    // }


    
    // self-implemented SSP
    prog_start = chrono::high_resolution_clock::now();
    auto ssp_result = minCost(G, s_index, t_index, flowAmount);
    int actual_flow = ssp_result.first;
    int min_cost = ssp_result.second;
    prog_end = chrono::high_resolution_clock::now();
    double ssp_run_time = chrono::duration<double>(prog_end - prog_start).count();

    cout << "The self-implemented runtime is " << ssp_run_time << " s." << endl;

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

    // 释放内存
    delete[] arr_m_flat;
    delete[] arr_w_flat;

    return 0;
}
