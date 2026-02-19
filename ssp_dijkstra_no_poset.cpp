#include <iostream>
#include <limits>
#include <iomanip>
#include <string>
#include <fstream>
#include <map>
#include <vector>
#include <chrono>
#include <bits/stdc++.h>

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

    while (total_flow < max_flow) {
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

    // Build self-implemented graph
    auto self_graph_start = chrono::high_resolution_clock::now();

    N = n_rotations;
    int s_index = 0;
    int t_index = n_rotations - 1;
    vector<vector<Edge>> G(N);

    for (const auto& [edge, info] : arc_infos) {
        int from_idx = edge.first;
        int to_idx = edge.second;
        int edge_cost = info.first;
        int edge_capacity = info.second;

        if (from_idx < 0 || from_idx >= (int)n_rotations || to_idx < 0 || to_idx >= (int)n_rotations) {
            continue;
        }

        addEdge(G, from_idx, to_idx, edge_capacity, edge_cost);
    }
    
    // 提前释放 arc_infos，减少内存占用
    arc_infos.clear();

    auto self_graph_end = chrono::high_resolution_clock::now();
    double self_graph_time = chrono::duration<double>(self_graph_end - self_graph_start).count();
    
    // self-implemented SSP
    cout << "Starting self-implemented SSP algorithm..." << endl;
    auto ssp_start = chrono::high_resolution_clock::now();
    auto ssp_result = minCost(G, s_index, t_index, flowAmount);
    int actual_flow = ssp_result.first;
    int min_cost = ssp_result.second;
    auto ssp_end = chrono::high_resolution_clock::now();
    double ssp_run_time = chrono::duration<double>(ssp_end - ssp_start).count();

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

    auto total_end = chrono::high_resolution_clock::now();
    double total_time = chrono::duration<double>(total_end - total_start).count();

    // Runtime statistics
    cout << "\n///////////////////////////// RUNTIME STATISTICS //////////////////////////////" << endl;
    cout << "Self-implemented graph construction time: " << self_graph_time << " s." << endl;
    cout << "SSP+Dijkstra algorithm runtime: " << ssp_run_time << " s." << endl;
    cout << "Total time (graph + algorithm): " << self_graph_time + ssp_run_time << " s." << endl;
    cout << "Total program time: " << total_time << " s." << endl;

    return 0;
}

















