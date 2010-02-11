class DrawGraph
  attr_accessor :graph
  
  def initialize(graph)
    self.graph = graph
  end

  def draw(filename)
    g = GraphViz.new( :G, :type => :digraph )
    label_to_graphviznode = {}
    graph.label_to_node.keys.each do |label|
      label_to_graphviznode[label] = g.add_node(label)
    end
    graph.nodes.each do |node|
      node.neighbours.each do |neighbour, edge|
        g.add_edge(label_to_graphviznode[node.label], label_to_graphviznode[neighbour.label], :label => "#{edge.lower} ≤ #{edge.current} ≤ #{edge.upper}")
      end
    end
    
    g.output(:png => filename)
  end  
end

class DrawResidualGraph
  attr_accessor :graph
  
  def initialize(graph)
    self.graph = graph
  end
  
  def draw(filename)
    g = GraphViz.new( :G, :type => :digraph )
    label_to_graphviznode = {}
    graph.label_to_node.each do |label, node|
      label_to_graphviznode[label] = g.add_node(label)
    end
    graph.nodes.each do |node|
      node.neighbours.each do |neighbour, edge|
        g.add_edge(label_to_graphviznode[node.label], label_to_graphviznode[neighbour.label], :label => "#{edge.upper}")
      end
    end
    
    g.output(:png => filename)
  end
end

class DrawLevelGraph
  attr_accessor :graph
  
  def initialize(graph)
    self.graph = graph
  end
  
  def draw(filename)
    g = GraphViz.new( :G, :type => :digraph )
    label_to_graphviznode = {}
    graph.label_to_node.each do |label, node|
      label_to_graphviznode[label] = g.add_node("#{label} -- #{node.potential}")
    end
    graph.nodes.each do |node|
      node.neighbours.each do |neighbour, edge|
        g.add_edge(label_to_graphviznode[node.label], label_to_graphviznode[neighbour.label], :label => "#{edge.upper}")
      end
    end
    
    g.output(:png => filename)
  end
end
