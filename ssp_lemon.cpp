#include <iostream>
#include <iomanip>
#include <vector>
#include <lemon/list_graph.h>
#include <lemon/dijkstra.h>
#include <lemon/bellman_ford.h>
#include <lemon/bfs.h>

using namespace lemon;
using namespace std;

// Helper function to print path
void printPath(const ListDigraph& g, 
               ListDigraph::Node source,
               ListDigraph::Node target,
               const Dijkstra<ListDigraph>::PredMap& predMap) {
    
    if (source == target) {
        cout << "Path: " << g.id(source) << endl;
        return;
    }
    
    // Build path in reverse
    vector<ListDigraph::Node> path;
    ListDigraph::Node current = target;
    
    while (current != INVALID) {
        path.push_back(current);
        ListDigraph::Arc pred = predMap[current];
        if (pred == INVALID) {
            if (current != source) {
                cout << "No path exists!" << endl;
                return;
            }
            break;
        }
        current = g.source(pred);
    }
    
    // Print path
    cout << "Path: ";
    for (int i = path.size() - 1; i >= 0; --i) {
        cout << g.id(path[i]);
        if (i > 0) cout << " -> ";
    }
    cout << endl;
}

int main() {
    // Create a directed graph
    ListDigraph graph;
    
    // Create 6 nodes
    vector<ListDigraph::Node> nodes;
    for (int i = 0; i < 6; ++i) {
        nodes.push_back(graph.addNode());
    }
    
    // Create arc weight map
    ListDigraph::ArcMap<int> length(graph);
    
    // Helper function to add edges
    auto addEdge = [&](int from, int to, int weight) {
        ListDigraph::Arc arc = graph.addArc(nodes[from], nodes[to]);
        length[arc] = weight;
    };
    
    // Build the graph
    addEdge(0, 1, 4);   // 0 -> 1, weight 4
    addEdge(0, 2, 2);   // 0 -> 2, weight 2
    addEdge(1, 2, 1);   // 1 -> 2, weight 1
    addEdge(1, 3, 5);   // 1 -> 3, weight 5
    addEdge(2, 1, 3);   // 2 -> 1, weight 3
    addEdge(2, 3, 8);   // 2 -> 3, weight 8
    addEdge(2, 4, 10);  // 2 -> 4, weight 10
    addEdge(3, 4, 2);   // 3 -> 4, weight 2
    addEdge(3, 5, 6);   // 3 -> 5, weight 6
    addEdge(4, 5, 3);   // 4 -> 5, weight 3
    
    ListDigraph::Node source = nodes[0];
    
    cout << "================================================" << endl;
    cout << "  SINGLE-SOURCE SHORTEST PATH (SSP) DEMO" << endl;
    cout << "================================================" << endl;
    cout << "Source Node: " << graph.id(source) << endl;
    cout << "Number of Nodes: " << countNodes(graph) << endl;
    cout << "Number of Arcs: " << countArcs(graph) << endl;
    cout << "================================================" << endl << endl;
    
    // ========================================
    // METHOD 1: Dijkstra's Algorithm
    // ========================================
    cout << "1. DIJKSTRA'S ALGORITHM" << endl;
    cout << "------------------------" << endl;
    cout << "Best for: Non-negative weights, fast performance" << endl;
    cout << "Time Complexity: O((V + E) log V)" << endl << endl;
    
    Dijkstra<ListDigraph> dijkstra(graph, length);
    dijkstra.run(source);
    
    cout << "Shortest distances from node " << graph.id(source) << ":" << endl;
    cout << setw(8) << "Target" << setw(12) << "Distance" << endl;
    cout << "--------------------------------" << endl;
    
    for (int i = 0; i < 6; ++i) {
        cout << setw(8) << i << setw(12);
        if (dijkstra.reached(nodes[i])) {
            cout << dijkstra.dist(nodes[i]) << endl;
        } else {
            cout << "INF" << endl;
        }
    }
    
    cout << "\nDetailed paths:" << endl;
    for (int i = 0; i < 6; ++i) {
        cout << "To node " << i << ": ";
        if (dijkstra.reached(nodes[i])) {
            printPath(graph, source, nodes[i], dijkstra.predMap());
        } else {
            cout << "No path exists!" << endl;
        }
    }
    
    cout << "\n================================================" << endl << endl;
    
    // ========================================
    // METHOD 2: Bellman-Ford Algorithm
    // ========================================
    cout << "2. BELLMAN-FORD ALGORITHM" << endl;
    cout << "-------------------------" << endl;
    cout << "Best for: Graphs with negative weights" << endl;
    cout << "Time Complexity: O(V * E)" << endl << endl;

    BellmanFord<ListDigraph> bf(graph, length);
    bf.run(source);

    // In your LEMON version, negativeCycle() returns a Path<ListDigraph>
    lemon::Path<ListDigraph> negCycle = bf.negativeCycle();

    if (negCycle.length() > 0) {
        cout << "WARNING: Negative cycle detected!" << endl;
    } else {
        cout << "No negative cycles found." << endl;
    }

    cout << "\nShortest distances from node " << graph.id(source) << ":" << endl;
    cout << setw(8) << "Target" << setw(12) << "Distance" << endl;
    cout << "--------------------------------" << endl;

    for (int i = 0; i < 6; ++i) {
        cout << setw(8) << i << setw(12);
        if (bf.reached(nodes[i])) {
            cout << bf.dist(nodes[i]) << endl;
        } else {
            cout << "INF" << endl;
        }
    }
    
    cout << "\n================================================" << endl << endl;
    
    // ========================================
    // METHOD 3: BFS (for unweighted graphs)
    // ========================================
    cout << "3. BREADTH-FIRST SEARCH (BFS)" << endl;
    cout << "------------------------------" << endl;
    cout << "Best for: Unweighted graphs, minimum hops" << endl;
    cout << "Time Complexity: O(V + E)" << endl << endl;
    
    Bfs<ListDigraph> bfs(graph);
    bfs.run(source);
    
    cout << "Minimum hops from node " << graph.id(source) << ":" << endl;
    cout << setw(8) << "Target" << setw(12) << "Hops" << endl;
    cout << "--------------------------------" << endl;
    
    for (int i = 0; i < 6; ++i) {
        cout << setw(8) << i << setw(12);
        if (bfs.reached(nodes[i])) {
            cout << bfs.dist(nodes[i]) << endl;
        } else {
            cout << "INF" << endl;
        }
    }
    
    cout << "\n================================================" << endl;
    
    return 0;
}