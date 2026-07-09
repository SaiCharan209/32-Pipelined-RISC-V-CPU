/* main.c - Bellman-Ford (4 Nodes, 6 Edges) */

#define INF 0x7FFFFFFF
#define V 4
#define E 6

// Safe Memory Offsets (RAM starts at 0x2000)
#define OUTPUT_PORT ((volatile int *)0x00002100)
#define DONE_FLAG *((volatile unsigned int *)0x00002180)

struct Edge {
    int u, v, weight;
};

int main() {
    // 1. Initialize 4-Node Graph via instructions
    volatile struct Edge edges[E];
    edges[0].u = 0; edges[0].v = 1; edges[0].weight = 1;
    edges[1].u = 0; edges[1].v = 2; edges[1].weight = 4;
    edges[2].u = 0; edges[2].v = 3; edges[2].weight = 9;
    edges[3].u = 1; edges[3].v = 2; edges[3].weight = 2;
    edges[4].u = 1; edges[4].v = 3; edges[4].weight = 6;
    edges[5].u = 2; edges[5].v = 3; edges[5].weight = 3;

    int dist[V];

    // 2. Initialize distances
    for (int i = 0; i < V; i++) {
        dist[i] = INF;
    }
    dist[0] = 0;

    // 3. Relax all edges V - 1 times (3 times)
    for (int i = 1; i < V; i++) {
        for (int j = 0; j < E; j++) {
            int u = edges[j].u;
            int v = edges[j].v;
            int weight = edges[j].weight;
            
            if (dist[u] != INF && dist[u] + weight < dist[v]) {
                dist[v] = dist[u] + weight;
            }
        }
    }

    // 4. Write the final 4 distances to the Output Port
    for (int i = 0; i < V; i++) {
        OUTPUT_PORT[i] = dist[i];
    }

    // 5. Trigger the Testbench
    DONE_FLAG = 0xDEADBEEF;

    return 0; 
}