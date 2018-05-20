module NetworkX
  class MultiGraph < Graph
    def new_edge_key(node_1, node_2)
      return 0 if @adj[node_1][node_2] == nil
      key = @adj[node_1][node_2].length
      while @adj[node_1][node_2].key?(key) do
        key += 1
      end
      key
    end

    def add_edge(node_1, node_2, **edge_attrs)
      add_node(node_1)
      add_node(node_2)
      key = new_edge_key(node_1, node_2)
      all_edge_attrs = @adj[node_1][node_2] || {}
      all_edge_attrs[key] = edge_attrs
      @adj[node_1][node_2] = all_edge_attrs
      @adj[node_2][node_1] = all_edge_attrs
    end

    def remove_edge(node_1, node_2, key=nil)
      raise KeyError, "#{node_1} is not a valid node." unless @nodes.key?(node_1)
      raise KeyError, "#{node_2} is not a valid node" unless @nodes.key?(node_2)
      raise KeyError, 'The given edge is not a valid one.' unless @adj[node_1].key?(node_2)
      raise KeyError, 'The given edge is not a valid one.' if key != nil && !@adj[node_1][node_2].key?(key)
      if key == nil
        super(node_1, node_2)
        return
      end
      @adj[node_1][node_2].delete(key)
      @adj[node_2][node_1].delete(key)
    end

    def size(is_weighted=false)
      if is_weighted
        graph_size = 0
        @adj.each do |_, hash_val|
          hash_val.each { |_, v| v.each { |_, attrs| graph_size += attrs[:weight] if attrs.key?(:weight) } }
        end
        return graph_size / 2
      end
      number_of_edges
    end
    
    def number_of_edges
      num = 0
      @adj.each { |_, v| v.each { |key, keyval| num += keyval.length }}
      num / 2
    end

    def has_edge(node_1, node_2, key=nil)
      super(node_1, node_2) if key == nil
      return true if @nodes.key?(node_1) and @adj[node_1].key?(node_2) && @adj[node_1][node_2].key?(key)
      false
    end

    def to_undirected
      graph = NetworkX::Graph.new(@graph)
      @nodes.each { |node, node_attr| graph.add_node(node, node_attr) }
      @adj.each_key do |node_1|
        @adj[node_1].each_key do |node_2|
          edge_attrs = {}
          @adj[node_1][node_2].each_key { |key| edge_attrs.merge!(@adj[node_1][node_2][key]) }
          graph.add_edge(node_1, node_2, edge_attrs)
        end
      end
      graph
    end

    def subgraph(nodes)
      case nodes
      when Array, Set
        sub_graph = NetworkX::MultiGraph.new(@graph)
        nodes.each do |u, _|
          raise KeyError, "#{u} does not exist in the current graph!" unless @nodes.key?(u)
          sub_graph.add_node(u, @nodes[u])
          @adj[u].each do |v, edge_val|
            edge_val.each { |_, keyval| sub_graph.add_edge(u, v, keyval) if @adj[u].key?(v) && nodes.include?(v) }
          end
          return sub_graph
        end
      else
        raise ArgumentError, 'Expected Argument to be Array or Set of nodes, '\
                             "received #{nodes.class.name} instead."
      end
    end

    def edge_subgraph(edges)
      case edges
      when Array, Set
        sub_graph = NetworkX::MultiGraph.new(@graph)
        edges.each do |u, v|
          raise KeyError, "#{u} does not exist in the graph!" unless @nodes.key?(u)
          raise KeyError, "#{v} does not exist in the graph!" unless @nodes.key?(v)
          raise KeyError, "Edge between #{u} and #{v} does not exist in the graph!" unless @adj[u].key?(v)
          sub_graph.add_node(u, @nodes[u])
          sub_graph.add_node(v, @nodes[v])
          @adj[u][v].each { |key, keyval| sub_graph.add_edge(u, v, keyval) }
        end
        return sub_graph
      else
        raise ArgumentError, 'Expected Argument to be Array or Set of edges, '\
        "received #{edges.class.name} instead."
      end
    end
  end
end