class Graph
  attr_accessor :nodes, :label_to_node, :source, :target
  
  def initialize()
    self.nodes = []
    self.label_to_node = {}
  end
  
  def add_node(label)
    node = Node.new(label)
    self.nodes << node
    self.label_to_node[label] = node
    node
  end
  
  def get_node(label)
    self.label_to_node[label]
  end
  
  def connect(from, to, lower, upper, current = 0)
    edge = get_node(from).add_neighbour(get_node(to), lower, upper, current)
    get_node(to).add_parent(get_node(from), edge)
  end
  
  def remove_node(node)
    self.nodes.delete(node)
    self.label_to_node.delete(node.label)
    node.neighbours.keys.each{|neighbour| neighbour.remove_parent(node)}
  end
  
  def to_residual_graph
    res_graph = Graph.new
    clone_nodes(res_graph)
    self.nodes.each do |node|
      node.neighbours.each do |neighbour, edge| 
        res_graph.connect(node.label, neighbour.label, 0, edge.to_upper) if edge.below_upper?
        res_graph.connect(neighbour.label, node.label, 0, edge.to_lower) if edge.above_lower?
      end
    end
    res_graph.source = self.source
    res_graph.target = self.target
    res_graph
  end
  
  def clone_nodes(target_graph)
    self.label_to_node.keys.each{|label| target_graph.add_node(label)}
  end
end

class LevelGraph < Graph
  attr_accessor :level_to_nodes
  attr_accessor :label_to_llabel
  
  def initialize(residual_graph)
    super()
    self.level_to_nodes =  Hash.new { |hash, key| hash[key] = []} 
    self.label_to_llabel = {}
    self.source = residual_graph.source
    self.target = residual_graph.target
    from_residual_graph(residual_graph)
  end
  
  def from_residual_graph(graph)
    bfs(graph.get_node(graph.source), graph)
    self.level_to_nodes.each do |level, nodes|
      nodes.each do |node|
        label = "#{node.label}\n#{level}"
        add_node(label)
        self.label_to_llabel[node.label] = label
      end
    end

    self.level_to_nodes.each do |level, nodes|
      next if level == "inf"
      nodes.each do |node|
        node.neighbours.each do |neighbour, edge|
          if self.level_to_nodes[level+1].include? neighbour
            connect(self.label_to_llabel[node.label], self.label_to_llabel[neighbour.label], 0, edge.upper)
          end
        end
      end
    end
  end
  
  def bfs(start, graph)
    visited_nodes = []
    level = 0
    current = []
    current << start
    next_level = []
    while current.size > 0
      current.each do |node|
        next if visited_nodes.include?(node)
        visited_nodes << node
        node.neighbours.each do |neighbour, edge|
          next if visited_nodes.include?(neighbour)
          next_level << neighbour
        end
      end
      self.level_to_nodes[level] = current.uniq        
      level += 1
      current = next_level.uniq - visited_nodes
      next_level = []
    end
    self.level_to_nodes["inf"] = graph.nodes - visited_nodes
  end
  
  def source_node
    self.get_node(self.label_to_llabel[self.source])
  end
  
  def target_node
    self.get_node(self.label_to_llabel[self.target])
  end
  
  def has_source_target_path?
    source = self.source_node
    target = self.target_node
    visited_nodes = []
    current = []
    current << source
    next_level = []
    while current.size > 0
      current.each do |node|
        next if visited_nodes.include?(node)
        visited_nodes << node
        node.neighbours.each do |neighbour, edge|
          next if visited_nodes.include?(neighbour)
          next_level << neighbour
        end
      end
      current = next_level.uniq - visited_nodes
      next_level = []
    end
    visited_nodes.include? target
  end
  
  def has_path_from_source_to_node?(node)
    visited_nodes = []
    current = []
    current << node
    next_parents = []
    while current.size > 0
      current.each do |cur|
        visited_nodes << cur
        next_parents += cur.parents.keys
      end
      current = next_parents.uniq
      next_parents = []
    end
    visited_nodes.include? self.source_node    
  end
  
  def has_path_from_node_to_target?(node)
    visited_nodes = []
    current = []
    current << node
    next_neighbours = []
    while current.size > 0
      current.each do |cur|
        visited_nodes << cur
        next_neighbours += cur.neighbours.keys
      end
      current = next_neighbours.uniq
      next_neighbours = []
    end
    visited_nodes.include? self.target_node    
  end
  
  def has_s_t_path_with?(node)
    self.has_path_from_source_to_node?(node) && self.has_path_from_node_to_target?(node)
  end
  
  def get_minimal_potential_node
    sorted = self.nodes.sort{|x,y| x.potential <=> y.potential}
    sorted.each do |node|
      if has_s_t_path_with?(node)
        return node
      else
        self.remove_node(node)
      end
    end
  end
  
  def get_source_target_path_trough(node)
    current = []
    get_node_to_target_path(node)
    get_source_to_node_path(node)
  end
  
  def get_node_to_target_path(node)
      if node == self.target_node
        node
      else
        path = {}
        node.neighbours.each do |neighbour|
        if has_node_to_target_path?(neighbour)
          path[neighbour] = get_node_to_target_path(neighbour)
        end
        path        
      end
    end
  end
  
  
end

class Node
  attr_accessor :label, :neighbours, :parents, :potential
  
  def initialize(label)
    self.label = label
    self.neighbours = {}
    self.parents = {}
    self.potential = 0
  end
  
  def <=>(other)
    self.label <=> other.label
  end
  
  def potential 
    incoming = 0
    parents.each do |parent, edge| 
      incoming += edge.upper
    end
    outgoing = 0
    neighbours.each do |neighbour, edge|
      outgoing += edge.upper
    end
    return 0 if parents.size == 0 && neighbours.size == 0
    return outgoing if parents.size == 0 && neighbours.size != 0
    return incoming if parents.size != 0 && neighbours.size == 0
    incoming < outgoing ? incoming : outgoing
  end
  
  def add_neighbour(neighbour, lower, upper, current)
    edge =  Edge.new(lower, upper, current)
    self.neighbours[neighbour] = edge
    edge
  end
  
  def remove_neightbour(neighbour)
    self.neighbours.delete neighbour
  end
  
  def add_parent(parent, edge)
    self.parents[parent] = edge
  end
  
  def remove_parent(parent)
    self.parents.delete parent
  end
  
  def to_s
    label
  end
end

class Edge
  attr_accessor :lower, :upper, :current
  
  def initialize(lower, upper, current = 0)
    self.lower = lower
    self.upper = upper
    self.current = current
  end
    
  def to_upper
    self.upper - self.current
  end
  
  def to_lower
    self.current - self.lower
  end
    
  def below_upper?
    self.current < self.upper
  end
  
  def above_lower? 
    self.current > self.lower
  end
end