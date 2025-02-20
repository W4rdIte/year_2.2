import os
from igraph import Graph, plot
import random
import matrix_generator


def make_experiment():
    rng = random.Random()

    N = 100000
    avg_packet = 12000

    passed_ex = 0

    G = Graph()

    with open("cities.txt", "r") as f:
        nodes = f.readlines()

    nodes = [node.strip() for node in nodes]

    G.add_vertices(nodes)

    with open("connections.txt", "r") as f:
        lines = f.readlines()

    edges = [(line.strip().split()[0], line.strip().split()[1]) for line in lines]
    capacities = [int(line.strip().split()[2]) for line in lines]
    reliabilities = [float(line.strip().split()[3]) for line in lines]

    G.add_edges(edges)

    # capacities = [int(capacity * 1.3) for capacity in capacities]

    G.es["capacity"] = capacities
    G.es["reliability"] = reliabilities

    traffic_matrix = matrix_generator.generate_traffic_matrix()

    for i in range(N):

        print(round(i / N * 100), "%")

        A = G.copy()

        for edge in A.es:
            rand_numb = rng.random()

            if rand_numb > edge["reliability"]:
                A.es[edge.index].delete()

        if not A.is_connected():
            continue

        flows = {edge.index: 0 for edge in A.es}

        flag = False

        for source in A.vs:
            for target in A.vs:
                if source != target:
                    path = A.get_shortest_paths(source, target)[0]

                    for j in range(len(path) - 1):
                        edge_id = A.get_eid(path[j], path[j + 1])
                        flows[edge_id] += traffic_matrix[source["name"]][target["name"]]

        for edge in A.es:
            if flows[edge.index] * avg_packet >= edge["capacity"]:
                break

        if flag:
            continue
        # S = sum(len(values) for values in traffic_matrix.values())
        S = 0

        for city1 in traffic_matrix:
            for city2 in traffic_matrix[city1]:
                S += traffic_matrix[city1][city2]

        X = 0

        for edge in A.es:
            X += flows[edge.index] / (
                (edge["capacity"] / avg_packet - flows[edge.index])
            )

        T = X / S

        if T > 0.040:
            continue

        passed_ex += 1

    print(passed_ex / N)


def main():
    make_experiment()


if __name__ == "__main__":
    main()
