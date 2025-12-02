#include <iostream>
#include <lemon/list_graph.h>
#include <lemon/maps.h>  // Add this line - provides RangeMap
#include <lemon/capacity_scaling.h>
#include <limits>
#include <iomanip>
#include <string>
#include <map>
#include <random>
#include <time.h>
#include <chrono>

using namespace lemon;
using namespace std;

int main(int argv, char** argc) {
    // 参数解析：n, max_deg, flowAmount
    int n = (argv >= 2 ? stoi(argc[1]) : 5000);
    int max_deg = (argv >= 3 ? stoi(argc[2]) : 5);
    int flowAmount = (argv >= 4 ? stoi(argc[3]) : max(1, n / 5));

    auto prog_start = chrono::high_resolution_clock::now();
    ListDigraph graph;

    // 图上的各种 map
    ListDigraph::ArcMap<int> cost(graph);
        // 单位费用
    ListDigraph::ArcMap<int> capacity(graph);
        // 上界容量
    ListDigraph::NodeMap<int> supply(graph);
        // 供给/需求
    ListDigraph::ArcMap<string> arcLabel(graph);
        // 只是为了 debug/一致性，性能不依赖它

    // 创建 n 个节点
    vector<ListDigraph::Node> nodes(n);
    for (int i = 0; i < n; ++i) {
        nodes[i] = graph.addNode();
        supply[nodes[i]] = 0;
    }

    ListDigraph::Node s = nodes[0];
    ListDigraph::Node t = nodes[n - 1];

    supply[s] = flowAmount;
    supply[t] = -flowAmount;

    // 随机数，与 ssp_dij 保持同样种子 & 分布
    std::mt19937 rng(123456);
    std::uniform_int_distribution<int> cap_dist(1, 5);
    std::uniform_int_distribution<int> cost_dist(0, 10);

    int arcCounter = 0;

    // 构造同样结构的分层 DAG
    for (int u = 0; u < n - 1; ++u) {
        for (int step = 1; step <= max_deg; ++step) {
            int v = u + step;
            if (v >= n) break;
            ListDigraph::Arc a = graph.addArc(nodes[u], nodes[v]);
            cost[a] = cost_dist(rng);
            capacity[a] = cap_dist(rng);
            arcLabel[a] =
                to_string(u) + "->" + to_string(v) + "#" + to_string(++arcCounter);
        }
    }

    // 配置 CapacityScaling 最小费用流
    CapacityScaling<ListDigraph, int, int> mcf(graph);
    mcf.costMap(cost)
       .upperMap(capacity)
       .supplyMap(supply);

    auto result = mcf.run();

    auto prog_end = chrono::high_resolution_clock::now();
    double run_time = chrono::duration<double>(prog_end - prog_start).count();

    if (result == CapacityScaling<ListDigraph, int, int>::OPTIMAL) {
        long long totalCost = mcf.totalCost();
        cout << "OK (LEMON CapacityScaling). "
             << "n = " << n
             << ", max_deg = " << max_deg
             << ", flow = " << flowAmount
             << ", total_cost = " << totalCost << "\n";
    } else if (result == CapacityScaling<ListDigraph, int, int>::INFEASIBLE) {
        cout << "The problem is INFEASIBLE." << endl;
    } else if (result == CapacityScaling<ListDigraph, int, int>::UNBOUNDED) {
        cout << "The problem is UNBOUNDED." << endl;
    }
    cout << "The runtime is " << run_time << " s." << endl;

    return 0;
}
