#include <bits/stdc++.h>
using namespace std;

struct Edge {
    int to, rev, cap, cost;
};

int N;
const int INF = 1e9;

void addEdge(vector<vector<Edge>>& G, int u, int v, int cap, int cost) {
    Edge fwd{v, (int)G[v].size(), cap, cost};
    Edge rev{u, (int)G[u].size(), 0, 0};
    G[u].push_back(fwd);
    G[v].push_back(rev);
}

bool bfs01(vector<vector<Edge>>& G, int s, int t,
           vector<int>& dist, vector<int>& parent, vector<int>& parentEdge) {
    dist.assign(N, INF);    // dist[u] means the current shortest distance from s to u
    parent.assign(N, -1);
    parentEdge.assign(N, -1);
    
    deque<int> dq;
    dq.push_back(s);
    dist[s] = 0;
    
    while (!dq.empty()) {
        int u = dq.front();
        dq.pop_front();
        
        for (int i = 0; i < G[u].size(); ++i) {
            Edge& e = G[u][i];
            if (e.cap <= 0) continue;   // Only consider edges with remaining capacity
            
            int v = e.to;
            int newDist = dist[u] + e.cost;
            
            if (newDist < dist[v]) {    // Update distance if a shorter path is found
                dist[v] = newDist;
                parent[v] = u;
                parentEdge[v] = i;
                
                if (e.cost == 0) {
                    dq.push_front(v);   // 0-cost edges: higher priority
                } else {
                    dq.push_back(v);
                }
            }
        }
    }
    
    return dist[t] < INF;
}

pair<int, int> minCost(vector<vector<Edge>>& G, int s, int t, int maxFlow) {
    int totalFlow = 0, totalCost = 0;
    vector<int> dist, parent, parentEdge;
    
    while (totalFlow < maxFlow) {
        // Find augmenting path
        if (!bfs01(G, s, t, dist, parent, parentEdge)) break;
        
        // Find bottleneck
        int pathFlow = maxFlow - totalFlow;
        for (int v = t; v != s; v = parent[v]) {
            int u = parent[v];
            int idx = parentEdge[v];
            pathFlow = min(pathFlow, G[u][idx].cap);
        }
        
        // Calculate cost
        int pathCost = 0;
        for (int v = t; v != s; v = parent[v]) {
            int u = parent[v];
            int idx = parentEdge[v];
            pathCost += G[u][idx].cost;
        }
        
        // Update flow
        totalFlow += pathFlow;
        totalCost += pathFlow * pathCost;
        
        // Update residual graph
        for (int v = t; v != s; v = parent[v]) {
            int u = parent[v];
            int idx = parentEdge[v];
            G[u][idx].cap -= pathFlow;      // Decrease forward capacity
            int revIdx = G[u][idx].rev;
            G[v][revIdx].cap += pathFlow;   // Increase capacity of reverse edges (allow flow cancellation)
        }
    }
    
    return {totalFlow, totalCost};
}

int main(int argc, char** argv) {
    int t = stoi(argv[1]);
    int flowAmount = t + 1;
    
    const int a = 0, v0 = 1, v1 = 2, v2 = 3, v3 = 4, v4 = 5, v5 = 6, z = 7;
    
    N = 8;
    vector<vector<Edge>> G(N);
    
    // Forward arcs (cost=1)
    addEdge(G, a, v0, 2, 1);
    addEdge(G, a, v1, 2, 1);
    addEdge(G, v0, v1, 1, 1);
    addEdge(G, a, v3, 1, 1);
    addEdge(G, a, v4, 1, 1);
    addEdge(G, a, v5, 1, 1);
    addEdge(G, v0, v2, 1, 1);
    addEdge(G, v1, v2, 1, 1);
    addEdge(G, v1, v5, 1, 1);
    addEdge(G, v1, v4, 1, 1);
    addEdge(G, v2, v3, 1, 1);
    addEdge(G, v3, z, 2, 1);
    addEdge(G, v2, z, 1, 1);
    addEdge(G, v4, z, 2, 1);
    addEdge(G, v5, z, 2, 1);
    
    // Reverse arcs (cost=0, cap=INF)
    addEdge(G, v0, a, INF, 0);
    addEdge(G, v1, v0, INF, 0);
    addEdge(G, v2, v1, INF, 0);
    addEdge(G, v4, v1, INF, 0);
    addEdge(G, v3, v2, INF, 0);
    addEdge(G, v5, v4, INF, 0);
    addEdge(G, z, v3, INF, 0);
    addEdge(G, z, v5, INF, 0);
    
    auto [flow, cost] = minCost(G, a, z, flowAmount);
    
    if (flow < flowAmount) {
        cout << "Cannot send required flow = " << flowAmount << endl;
        cout << "Actual flow = " << flow << ", cost = " << cost << endl;
    } 
    else {
        cout << "Find the min cost for given flow." << endl;
        cout << "Flow = " << flowAmount << ", min_cost = " << cost << endl;
    }
    
    return 0;
}