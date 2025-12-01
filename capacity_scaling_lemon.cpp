#include <iostream>
#include <lemon/list_graph.h>
#include <lemon/maps.h>  // Add this line - provides RangeMap
#include <lemon/capacity_scaling.h>
#include <limits>
#include <iomanip>
#include <string>
#include <map>

using namespace lemon;
using namespace std;

int main(int argv, char** argc) {
    // Create a directed graph
    ListDigraph graph;
    const int INF = std::numeric_limits<int>::max();
    int t = stoi(argc[1]);
    
    // // Create nodes
    // ListDigraph::Node s = graph.addNode();  // Source node
    // ListDigraph::Node v1 = graph.addNode(); // Intermediate node 1
    // ListDigraph::Node v2 = graph.addNode(); // Intermediate node 2
    // ListDigraph::Node v3 = graph.addNode(); // Intermediate node 3
    // ListDigraph::Node t = graph.addNode();  // Target (sink) node
    
    // // Create arcs (directed edges)
    // ListDigraph::Arc a1 = graph.addArc(s, v1);
    // ListDigraph::Arc a2 = graph.addArc(s, v2);
    // ListDigraph::Arc a3 = graph.addArc(v1, v2);
    // ListDigraph::Arc a4 = graph.addArc(v1, v3);
    // ListDigraph::Arc a5 = graph.addArc(v2, v3);
    // ListDigraph::Arc a6 = graph.addArc(v2, t);
    // ListDigraph::Arc a7 = graph.addArc(v3, t);
    
    // // Define arc costs (cost per unit flow)
    // ListDigraph::ArcMap<int> cost(graph);
    // cost[a1] = 1;
    // cost[a2] = 2;
    // cost[a3] = 1;
    // cost[a4] = 3;
    // cost[a5] = 2;
    // cost[a6] = 4;
    // cost[a7] = 1;
    
    // // Define arc capacities (upper bounds)
    // ListDigraph::ArcMap<int> capacity(graph);
    // capacity[a1] = 15;
    // capacity[a2] = 10;
    // capacity[a3] = 5;
    // capacity[a4] = 10;
    // capacity[a5] = 8;
    // capacity[a6] = 10;
    // capacity[a7] = 20;
    
    // // Define supply/demand at nodes
    // ListDigraph::NodeMap<int> supply(graph);
    // supply[s] = 20;
    // supply[v1] = 0;
    // supply[v2] = 0;
    // supply[v3] = 0;
    // supply[t] = -20;

    ListDigraph::ArcMap<int> cost(graph);
    ListDigraph::ArcMap<int> capacity(graph);
    ListDigraph::NodeMap<int> supply(graph);

    int flowAmount = t + 1;
    // Create nodes
    ListDigraph::Node a = graph.addNode();  // Source node
    supply[a] = flowAmount;
    ListDigraph::Node v0 = graph.addNode();
    supply[v0] = 0;
    ListDigraph::Node v1 = graph.addNode();
    supply[v1] = 0;
    ListDigraph::Node v2 = graph.addNode();
    supply[v2] = 0;
    ListDigraph::Node v3 = graph.addNode();
    supply[v3] = 0;
    ListDigraph::Node v4 = graph.addNode();
    supply[v4] = 0;
    ListDigraph::Node v5 = graph.addNode();
    supply[v5] = 0;
    ListDigraph::Node z = graph.addNode();  // Target (sink) node
    supply[z] = -flowAmount;
    

    //  Forcing Graph
    ListDigraph::ArcMap<string> arcLabel(graph);
    // Create arcs and their info (directed edges)
    ListDigraph::Arc A_a_0_0 = graph.addArc(a, v0);
    cost[A_a_0_0] = 1;
    capacity[A_a_0_0] = 1;
    arcLabel[A_a_0_0] = "<0,5>";
    ListDigraph::Arc A_a_0_1 = graph.addArc(a, v0);
    cost[A_a_0_1] = 1;
    capacity[A_a_0_1] = 1;
    arcLabel[A_a_0_1] = "<6,2>";
    
    ListDigraph::Arc A_a_1_0 = graph.addArc(a, v1);
    cost[A_a_1_0] = 1;
    capacity[A_a_1_0] = 1;
    arcLabel[A_a_1_0] = "<1,4>";
    ListDigraph::Arc A_a_1_1 = graph.addArc(a, v1);
    cost[A_a_1_1] = 1;
    capacity[A_a_1_1] = 1;
    arcLabel[A_a_1_1] = "<5,0>";

    ListDigraph::Arc A_0_1_0 = graph.addArc(v0, v1);
    cost[A_0_1_0] = 1;
    capacity[A_0_1_0] = 1;
    arcLabel[A_0_1_0] = "<6,5>";

    ListDigraph::Arc A_a_3_0 = graph.addArc(a, v3);
    cost[A_a_3_0] = 1;
    capacity[A_a_3_0] = 1;
    arcLabel[A_a_3_0] = "<4,1>";

    ListDigraph::Arc A_a_4_0 = graph.addArc(a, v4);
    cost[A_a_4_0] = 1;
    capacity[A_a_4_0] = 1;
    arcLabel[A_a_4_0] = "<2,6>";
    ListDigraph::Arc A_a_5_0 = graph.addArc(a, v5);
    cost[A_a_5_0] = 1;
    capacity[A_a_5_0] = 1;
    arcLabel[A_a_5_0] = "<3,3>";
    
    ListDigraph::Arc A_0_2_0 = graph.addArc(v0, v2);
    cost[A_0_2_0] = 1;
    capacity[A_0_2_0] = 1;
    arcLabel[A_0_2_0] = "<0,2>";
    
    ListDigraph::Arc A_1_2_0 = graph.addArc(v1, v2);
    cost[A_1_2_0] = 1;
    capacity[A_1_2_0] = 1;
    arcLabel[A_1_2_0] = "<5,4>";

    ListDigraph::Arc A_1_5_0 = graph.addArc(v1, v5);
    cost[A_1_5_0] = 1;
    capacity[A_1_5_0] = 1;
    arcLabel[A_1_5_0] = "<1,5>";
    
    ListDigraph::Arc a7 = graph.addArc(v1, v4);
    cost[a7] = 1;
    capacity[a7] = 1;
    arcLabel[a7] = "<6,0>";

    ListDigraph::Arc A_2_3_0 = graph.addArc(v2, v3);
    cost[A_2_3_0] = 1;
    capacity[A_2_3_0] = 1;
    arcLabel[A_2_3_0] = "<0,5>";

    ListDigraph::Arc A_3_z_0 = graph.addArc(v3, z);
    cost[A_3_z_0] = 1;
    capacity[A_3_z_0] = 1;
    arcLabel[A_3_z_0] = "<0,1>";
    ListDigraph::Arc A_3_z_1 = graph.addArc(v3, z);
    cost[A_3_z_1] = 1;
    capacity[A_3_z_1] = 1;
    arcLabel[A_3_z_1] = "<4,4>";
    
    ListDigraph::Arc A_2_z_0 = graph.addArc(v2, z);
    cost[A_2_z_0] = 1;
    capacity[A_2_z_0] = 1;
    arcLabel[A_2_z_0] = "<5,2>";
    
    ListDigraph::Arc A_4_z_0 = graph.addArc(v4, z);
    cost[A_4_z_0] = 1;
    capacity[A_4_z_0] = 1;
    arcLabel[A_4_z_0] = "<6,6>";
    ListDigraph::Arc A_4_z_1 = graph.addArc(v4, z);
    cost[A_4_z_1] = 1;
    capacity[A_4_z_1] = 1;
    arcLabel[A_4_z_1] = "<2,0>";

    ListDigraph::Arc A_5_z_0 = graph.addArc(v5, z);
    cost[A_5_z_0] = 1;
    capacity[A_5_z_0] = 1;
    arcLabel[A_5_z_0] = "<1,3>";
    ListDigraph::Arc A_5_z_1 = graph.addArc(v5, z);
    cost[A_5_z_1] = 1;
    capacity[A_5_z_1] = 1;
    arcLabel[A_5_z_1] = "<3,5>";
    
    // The reverse arcs for the original rotation poset
    ListDigraph::Arc r1 = graph.addArc(v0, a);
    cost[r1] = 0;
    capacity[r1] = INF;
    arcLabel[r1] = "v0 -> a (reverse)";
    
    ListDigraph::Arc r2 = graph.addArc(v1, v0);
    cost[r2] = 0;
    capacity[r2] = INF;
    arcLabel[r2] = "v1 -> v0 (reverse)";
    
    ListDigraph::Arc r3 = graph.addArc(v2, v1);
    cost[r3] = 0;
    capacity[r3] = INF;
    arcLabel[r3] = "v2 -> v1 (reverse)";
    
    ListDigraph::Arc r4 = graph.addArc(v4, v1);
    cost[r4] = 0;
    capacity[r4] = INF;
    arcLabel[r4] = "v4 -> v1 (reverse)";
    
    ListDigraph::Arc r5 = graph.addArc(v3, v2);
    cost[r5] = 0;
    capacity[r5] = INF;
    arcLabel[r5] = "v3 -> v2 (reverse)";
    
    ListDigraph::Arc r6 = graph.addArc(v5, v4);
    cost[r6] = 0;
    capacity[r6] = INF;
    arcLabel[r6] = "v5 -> v4 (reverse)";
    
    ListDigraph::Arc r7 = graph.addArc(z, v3);
    cost[r7] = 0;
    capacity[r7] = INF;
    arcLabel[r7] = "z -> v3 (reverse)";
    
    ListDigraph::Arc r8 = graph.addArc(z, v5);
    cost[r8] = 0;
    capacity[r8] = INF;
    arcLabel[r8] = "z -> v5 (reverse)";

    
    
    // Create CapacityScaling algorithm instance
    CapacityScaling<ListDigraph, int, int> cs(graph);
    
    // Set the supply map, cost map, and upper bound (capacity) map
    cs.supplyMap(supply);
    cs.costMap(cost);
    cs.upperMap(capacity);
    
    // Run the algorithm
    CapacityScaling<ListDigraph, int, int>::ProblemType result = cs.run();
    
    // Check the result
    if (result == CapacityScaling<ListDigraph, int, int>::OPTIMAL) {
        cout << "========================================" << endl;
        cout << "   MINIMUM COST FLOW SOLUTION FOUND    " << endl;
        cout << "========================================" << endl << endl;
        
        cout << "**Total Minimum Cost: " << cs.totalCost() << "**" << endl << endl;
        
        // Get the flow map
        ListDigraph::ArcMap<int> flow(graph);
        cs.flowMap(flow);
        
        // Display flow on arcs with positive flow
        cout << "========================================" << endl;
        cout << "   ACTIVE FLOW PATHS (Flow > 0)        " << endl;
        cout << "========================================" << endl;
        cout << left << setw(25) << "Arc" 
             << setw(10) << "Flow" 
             << setw(12) << "Capacity" 
             << setw(10) << "Cost" 
             << setw(12) << "Total Cost" << endl;
        cout << string(70, '-') << endl;
        
        for (ListDigraph::ArcIt arc(graph); arc != INVALID; ++arc) {
            if (flow[arc] > 0) {
                string cap_str = (capacity[arc] == INF) ? "INF" : to_string(capacity[arc]);
                cout << left << setw(25) << arcLabel[arc]
                     << setw(10) << flow[arc]
                     << setw(12) << cap_str
                     << setw(10) << cost[arc]
                     << setw(12) << (flow[arc] * cost[arc]) << endl;
            }
        }
        
        cout << endl;
        
        // // Display all arcs (including zero flow)
        // cout << "========================================" << endl;
        // cout << "   ALL ARCS (Complete Network)         " << endl;
        // cout << "========================================" << endl;
        // cout << left << setw(25) << "Arc" 
        //      << setw(10) << "Flow" 
        //      << setw(12) << "Capacity" 
        //      << setw(10) << "Cost" 
        //      << setw(12) << "Total Cost" << endl;
        // cout << string(70, '-') << endl;
        
        // for (ListDigraph::ArcIt arc(graph); arc != INVALID; ++arc) {
        //     string cap_str = (capacity[arc] == INF) ? "INF" : to_string(capacity[arc]);
        //     cout << left << setw(25) << arcLabel[arc]
        //          << setw(10) << flow[arc]
        //          << setw(12) << cap_str
        //          << setw(10) << cost[arc]
        //          << setw(12) << (flow[arc] * cost[arc]) << endl;
        // }
        
        // cout << endl;
        
    } else if (result == CapacityScaling<ListDigraph, int, int>::INFEASIBLE) {
        cout << "The problem is INFEASIBLE." << endl;
        cout << "The flow constraints cannot be satisfied." << endl;
    } else if (result == CapacityScaling<ListDigraph, int, int>::UNBOUNDED) {
        cout << "The problem is UNBOUNDED." << endl;
        cout << "There exists a negative cost cycle." << endl;
    }
    
    return 0;
}