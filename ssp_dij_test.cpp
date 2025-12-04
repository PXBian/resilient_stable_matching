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

    vector<int> dist, parent, parent_edge;
    vector<int> potential(N, 0);

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
    // 参数解析：n, max_deg, flow_amount
    int n = (argc >= 2 ? stoi(argv[1]) : 5000);
    int max_deg = (argc >= 3 ? stoi(argv[2]) : 5);
    int flow_amount = (argc >= 4 ? stoi(argv[3]) : max(1, n / 5));

    auto prog_start = chrono::high_resolution_clock::now();
    N = n;  // 全局节点数
    int s = 0;
    int t = N - 1;

    vector<vector<Edge>> G(N);

    // 随机数（固定种子，保证两个程序生成同样的图结构）
    std::mt19937 rng(123456);
    std::uniform_int_distribution<int> cap_dist(1, 5);
    std::uniform_int_distribution<int> cost_dist(0, 10);

    // 构造一个分层 DAG：每个点连向后面最多 max_deg 个点
    for (int u = 0; u < n - 1; ++u) {
        for (int step = 1; step <= max_deg; ++step) {
            int v = u + step;
            if (v >= n) break;
            int cap = cap_dist(rng);
            int cost = cost_dist(rng);
            addEdge(G, u, v, cap, cost);
            cap = INFINITY;
            cost = 0;
            addEdge(G, v, u, cap, cost);
        }
    }

    // 可以根据 flow_amount 做一个简单 sanity check：
    // 出边总容量不足的话算法会提示无法发送足够流量
    auto result = minCost(G, s, t, flow_amount);
    int actual_flow = result.first;
    int min_cost = result.second;

    auto prog_end = chrono::high_resolution_clock::now();
    double run_time = chrono::duration<double>(prog_end - prog_start).count();

    cout << "The runtime is " << run_time << " s." << endl;

    if (actual_flow < 0) {
        cout << "Error: Invalid flow computation (negative cycle detected)\n";
    } else if (actual_flow < flow_amount) {
        cout << "Cannot send required flow amount = " << flow_amount << "\n";
        cout << "Actual flow = " << actual_flow
             << ", min_cost = " << min_cost << "\n";
    } else {
        cout << "OK (SSP+Dijkstra). "
             << "n = " << n
             << ", max_deg = " << max_deg
             << ", flow = " << flow_amount
             << ", min_cost = " << min_cost << "\n";
    }


    return 0;
}
