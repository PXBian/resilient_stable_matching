#ifndef GRAPH_H
#define GRAPH_H

#ifdef __cplusplus
extern "C" {
#endif


#include <algorithm>
#include <deque>
#include <limits>
#include <stdexcept>
#include <unordered_map>
#include <utility>
#include <vector>

class Graph {
public:
    struct Edge {
        int to;
        int cost; // 0 or 1
    };

    struct Result {
        bool reachable = false;
        int distance = std::numeric_limits<int>::max();
        std::vector<int> path;
    };

    void add_edge(int from, int to, int cost = 1) {
        if (cost != 0 && cost != 1) {
            throw std::invalid_argument("0-1 BFS supports only costs 0 or 1");
        }
        adj_[from].push_back({to, cost});
        adj_[to]; 
    }

    Result shortest_path(int start, int goal) const {
        if (adj_.find(start) == adj_.end() || adj_.find(goal) == adj_.end()) {
            return {};
        }

        const int INF = std::numeric_limits<int>::max();
        std::unordered_map<int, int> dist;
        std::unordered_map<int, int> parent;

        for (const auto& entry : adj_) {
            dist[entry.first] = INF;
        }

        std::deque<int> dq;
        dist[start] = 0;
        dq.push_back(start);

        while (!dq.empty()) {
            int u = dq.front();
            dq.pop_front();

            if (u == goal) {
                break;
            }

            auto it = adj_.find(u);
            if (it == adj_.end()) {
                continue;
            }

            for (const auto& edge : it->second) {
                int v = edge.to;
                int next_dist = dist[u] + edge.cost;

                if (next_dist < dist[v]) {
                    dist[v] = next_dist;
                    parent[v] = u;

                    if (edge.cost == 0) {
                        dq.push_front(v);
                    } else {
                        dq.push_back(v);
                    }
                }
            }
        }

        if (dist[goal] == INF) {
            return {};
        }

        std::vector<int> path;
        for (int cur = goal;; cur = parent[cur]) {
            path.push_back(cur);
            if (cur == start) {
                break;
            }
        }
        std::reverse(path.begin(), path.end());

        return {true, dist[goal], std::move(path)};
    }

private:
    std::unordered_map<int, std::vector<Edge>> adj_;
};

#ifdef __cplusplus
}
#endif

#endif // GRAPH_H