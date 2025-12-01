#include <bits/stdc++.h>
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
        
    potential.assign(N, 0);
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

    vector<int> potential, dist, parent, parent_edge;

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



int main(int argc, char** argv) {
    int t = stoi(argv[1]);
    int flow_amount = t + 1;
    
    // 节点编号映射
    const int a  = 0; // source s
    const int v0 = 1;
    const int v1 = 2;
    const int v2 = 3;
    const int v3 = 4;
    const int v4 = 5;
    const int v5 = 6;
    const int z  = 7; // sink t

    N  = 8; // Number of nodes
    const int INF = 1e9;
    vector<vector<Edge>> G(N);  // adjustcancy list for forcing graph
    
    // Forward arcs in the forcing graph (cost=1, cap=number of labels)
    addEdge(G, a,  v0, 2, 1);
    addEdge(G, a,  v1, 2, 1);
    addEdge(G, v0, v1, 1, 1);
    addEdge(G, a,  v3, 1, 1);
    addEdge(G, a,  v4, 1, 1);
    addEdge(G, a,  v5, 1, 1);
    addEdge(G, v0, v2, 1, 1);
    addEdge(G, v1, v2, 1, 1);
    addEdge(G, v1, v5, 1, 1);
    addEdge(G, v1, v4, 1, 1);
    addEdge(G, v2, v3, 1, 1);
    addEdge(G, v3, z,  2, 1);
    addEdge(G, v2, z,  1, 1);
    addEdge(G, v4, z,  2, 1);
    addEdge(G, v5, z,  2, 1);
    
    // Reverse arcs for the forcing graph (cost = 0, cap = INF)
    addEdge(G, v0, a,  INF, 0); // r1: v0 -> a
    addEdge(G, v1, v0, INF, 0); // r2: v1 -> v0
    addEdge(G, v2, v1, INF, 0); // r3: v2 -> v1
    addEdge(G, v4, v1, INF, 0); // r4: v4 -> v1
    addEdge(G, v3, v2, INF, 0); // r5: v3 -> v2
    addEdge(G, v5, v4, INF, 0); // r6: v5 -> v4
    addEdge(G, z,  v3, INF, 0); // r7: z -> v3
    addEdge(G, z,  v5, INF, 0); // r8: z -> v5
    

    pair<int,int> result = minCost(G, a, z, flow_amount);
    int actual_flow = result.first, min_cost = result.second;
    
    if (actual_flow < 0) {
        cout << "Error: Invalid flow computation (negative cycle detected)\n";
    } 
    else if (actual_flow < flow_amount) {
        cout << "Cannot send required flow amount = " << flow_amount << "\n";
        cout << "Actual flow = " << actual_flow << ", min_cost = " << min_cost << "\n";
    } 
    else {
        cout << "Send " << flow_amount << " flow successfully! " << "min_cost = " << min_cost << "\n";
    }
    
    return 0;
}