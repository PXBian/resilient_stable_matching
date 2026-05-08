#include <iostream>
#include <string>
#include <chrono>
#include <fstream>
#include <vector>
#include <queue>
#include <limits>
#include <bits/stdc++.h>
#include "rotation_poset/rotation_poset.h"

using namespace std;

// Def1 dual is the one-unit case of the Def2 min-cost flow.
// Since all stable-pairs graph capacities are positive for one unit of flow,
// the total cost is just the 0/1 shortest path from source to sink.
struct ZeroOneGraph {
    int n;
    vector<vector<pair<int, int>>> graph;

    ZeroOneGraph(int n) : n(n), graph(n) {}

    void add_edge(int u, int v, int cost) {
        graph[u].push_back({v, cost});
    }

    pair<bool, int> shortest_path_cost(int s, int t) const {
        const int INF_DIST = numeric_limits<int>::max() / 4;
        vector<int> dist(n, INF_DIST);
        deque<int> q;
        dist[s] = 0;
        q.push_back(s);

        while (!q.empty()) {
            int v = q.front();
            q.pop_front();
            for (const auto& [to, cost] : graph[v]) {
                if (dist[v] + cost >= dist[to]) continue;
                dist[to] = dist[v] + cost;
                if (cost == 0) {
                    q.push_front(to);
                } else {
                    q.push_back(to);
                }
            }
        }

        return {dist[t] != INF_DIST, dist[t]};
    }
};

int main(int argc, char** argv) {
    if (argc != 3) {
        cerr << "Use: " << argv[0] << " <input_file> <n>" << endl;
        return 1;
    }

    string input_file_name = argv[1];
    size_t n = stoull(argv[2]);
    const int flowAmount = 1;

    int* arr_m = new int[n * n];
    int* arr_w = new int[n * n];
    for (size_t i = 0; i < n * n; ++i) {
        arr_m[i] = 0;
        arr_w[i] = 0;
    }

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
        } else {
            size_t w = line_count - n, m = 0;
            while (getline(ss, token, ' ')) {
                arr_w[w * n + m] = stoi(token);
                m++;
            }
        }
        line_count++;
    }
    input_file.close();

    auto total_start = chrono::high_resolution_clock::now();

    auto poset_start = chrono::high_resolution_clock::now();
    invert_matrix(arr_w, n);
    RankingListMatrix men_matrix = { .data = arr_m, .n = n };
    PositionMapMatrix women_matrix = { .data = arr_w, .n = n };
    RotationDigraph rotation_poset = get_rotation_digraph(men_matrix, women_matrix, 1);
    auto poset_end = chrono::high_resolution_clock::now();
    double poset_time = chrono::duration<double>(poset_end - poset_start).count();

    cout << "Number of rotations: " << rotation_poset.n_rotations << endl;
    cout << "Number of stable pairs: " << rotation_poset.n_pairs << endl;
    size_t n_rotations = rotation_poset.n_rotations;

    auto spg_start = chrono::high_resolution_clock::now();
    StablePairsGraph spg = get_stable_pairs_graph(rotation_poset);
    auto spg_end = chrono::high_resolution_clock::now();
    double spg_time = chrono::duration<double>(spg_end - spg_start).count();

    free_rotation_digraph(rotation_poset);
    delete[] arr_m;
    delete[] arr_w;

    size_t n_vertices = spg.n_vertices;
    size_t n_arcs = spg.n_arcs;
    cout << "Number of vertices in stable pairs graph: " << n_vertices << endl;
    cout << "Number of arcs in stable pairs graph: " << n_arcs << endl;

    auto graph_start = chrono::high_resolution_clock::now();

    ZeroOneGraph graph((int)n_vertices);
    for (size_t i = 0; i < n_arcs; ++i) {
        Arc arc = spg.arcs_list[i];
        if ((size_t)arc.from >= n_vertices || (size_t)arc.to >= n_vertices) continue;
        int cost = (int)arc.cost;   // 0 or 1
        graph.add_edge((int)arc.from, (int)arc.to, cost);
    }

    auto graph_end = chrono::high_resolution_clock::now();
    double graph_build_time = chrono::duration<double>(graph_end - graph_start).count();

    free_stable_pairs_graph(spg);

    cout << "Starting Def1 Dual 0/1 shortest path..." << endl;
    auto algo_start = chrono::high_resolution_clock::now();
    auto [reachable, total_cost] = graph.shortest_path_cost(0, (int)n_vertices - 1);
    auto algo_end = chrono::high_resolution_clock::now();
    double algo_time = chrono::duration<double>(algo_end - algo_start).count();

    cout << "The competitor (Def1 Dual) runtime is " << algo_time << " s." << endl;

    if (reachable) {
        cout << "OK (Competitor Def1 Dual). "
             << "n = " << n
             << ", flow = " << flowAmount
             << ", total_cost = " << total_cost << "\n";
    } else {
        cout << "INFEASIBLE (Competitor Def1 Dual). "
             << "n = " << n
             << ", flow = " << flowAmount << "\n";
    }

    auto total_end = chrono::high_resolution_clock::now();
    double total_time = chrono::duration<double>(total_end - total_start).count();

    cout << "\n///////////////////////////// RUNTIME STATISTICS //////////////////////////////" << endl;
    cout << "Construct poset time: " << poset_time << " s." << endl;
    cout << "Stable pairs graph construction time: " << spg_time << " s." << endl;
    double graph_plus_algo_time = graph_build_time + algo_time;
    cout << "Total time (graph + algorithm): " << graph_plus_algo_time << " s." << endl;
    cout << "Total program time: " << total_time << " s." << endl;

    // {
    //     string basename = input_file_name;
    //     size_t slash = basename.find_last_of("/\\");
    //     if (slash != string::npos) basename = basename.substr(slash + 1);
    //     size_t inst = basename.find("_instance");
    //     if (inst != string::npos) basename = basename.substr(0, inst);
    //     size_t last_ = basename.rfind('_');
    //     string dataset = (last_ != string::npos) ? basename.substr(0, last_) : basename;
    //     ofstream csv("runtime_output/competitor_runtime_stats.csv", ios::app);
    //     if (csv.is_open()) {
    //         if (csv.tellp() == 0) {
    //             csv << "dataset,method,n,flowAmount,total_cost,rotations_num,arc_num,poset_time,algorithm_runtime,graph_plus_algo_time,total_program_time\n";
    //         }
    //         long long cost_out = reachable ? total_cost : -1;
    //         csv << dataset << ",competitor," << n << "," << flowAmount << "," << cost_out
    //             << "," << n_rotations << "," << n_arcs
    //             << "," << poset_time << "," << algo_time << "," << graph_plus_algo_time << "," << total_time << "\n";
    //         csv.close();
    //     }
    // }

    return 0;
}
