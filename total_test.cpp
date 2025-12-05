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

using namespace lemon;
using namespace std;

struct Edge {
    int to;     // terminal
    int rev;    // the index of the reversed edge in G[to]
    int cap;    // remain capacity
    int cost;   // unit cost
};

int N;  // Global: Number of nodes
const int INF = 1e9;
    
// Add edge u->v and its residual 
void addEdge(vector<vector<Edge>> &G, int u, int v, int cap, int cost) {
    Edge fwd{v, G[v].size(), cap, cost};
    Edge rev{u, G[u].size(), 0, -cost};
    G[u].push_back(fwd);
    G[v].push_back(rev);
}

bool dijkstraWithPotentials(vector<vector<Edge>> &G,
                            int s, int t,
                            vector<int>& potential,
                            vector<int>& dist,
                            vector<int>& parent,
                            vector<int>& parent_edge) {
        
    dist.assign(N, INF);
    parent.assign(N, -1);
    parent_edge.assign(N, -1);
    

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

    vector<int> potential(N, 0);  
    vector<int> dist(N), parent(N), parent_edge(N);

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
        for (int v = 0; v < N; ++v) {
            if (dist[v] < INF) {
                potential[v] += dist[v];
            }
        }
    }
        
    return {total_flow, total_cost};
}

int main(int argv, char** argc) {
    int n = stoi(argc[1]);
    int max_deg = stoi(argc[2]);
    int flowAmount = stoi(argc[3]);

    ListDigraph graph;

    ListDigraph::ArcMap<int> cost(graph);
    ListDigraph::ArcMap<int> capacity(graph);
    ListDigraph::NodeMap<int> supply(graph);
    ListDigraph::ArcMap<string> arcLabel(graph);


    vector<ListDigraph::Node> nodes(n);
    for (int i = 0; i < n; ++i) {
        nodes[i] = graph.addNode();
        supply[nodes[i]] = 0;
    }

    ListDigraph::Node s = nodes[0];
    ListDigraph::Node t = nodes[n - 1];

    supply[s] = flowAmount;
    supply[t] = -flowAmount;

    std::mt19937 rng(123456);
    std::uniform_int_distribution<int> cap_dist(1, 5);
    
    N = n;
    int s_index = 0;
    int t_index = N - 1;
    vector<vector<Edge>> G(N);

    int arcCounter = 0;
    int cap = cap_dist(rng);

    for (int u = 0; u < n - 1; ++u) {
        for (int step = 1; step <= max_deg; ++step) {
            int v = u + step;
            if (v >= n) break;
            ListDigraph::Arc b = graph.addArc(nodes[v], nodes[u]);
            cost[b] = 0;
            capacity[b] = INF;
            arcLabel[b] = to_string(v) + "->" + to_string(u) + "#" + to_string(arcCounter);
            ListDigraph::Arc a = graph.addArc(nodes[u], nodes[v]);
            cost[a] = 1;
            capacity[a] = cap;
            arcLabel[a] = to_string(u) + "->" + to_string(v) + "#" + to_string(++arcCounter);

            // self-implemented
            // int v = u + step;
            // if (v >= n) break;
            int ssp_cap = cap;
            int ssp_cost = 1;
            addEdge(G, u, v, ssp_cap, ssp_cost);
            ssp_cap = INF;
            ssp_cost = 0;
            addEdge(G, v, u, ssp_cap, ssp_cost);
        }
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
             << ", max_deg = " << max_deg
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
             << ", max_deg = " << max_deg
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
             << ", max_deg = " << max_deg
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
             << ", max_deg = " << max_deg
             << ", flow = " << flowAmount
             << ", min_cost = " << min_cost << "\n";
    }


    return 0;
}
