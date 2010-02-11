require 'rubygems'
require 'graphviz'
require 'max_flow/graph'
require 'max_flow/draw'



g = Graph.new
"1".upto "8" do |i|
  g.add_node i
end
iter = 8
g.connect "1", "2", 0, 38, 7+1+6+4+8+2
g.connect "1", "3", 0, 1, 1
g.connect "1", "4", 0, 2, 2
g.connect "2", "3", 0, 8, 8
g.connect "2", "5", 0, 10, 6+4
g.connect "2", "6", 0, 13, 7+1+2
g.connect "3", "5", 0, 26, 1+8+2
g.connect "4", "8", 0, 27, 2+4+8+2
g.connect "5", "4", 0, 24, 4+8+2
g.connect "5", "7", 0, 8, 6
g.connect "5", "8", 0, 1, 1
g.connect "6", "3", 0, 2, 2
g.connect "6", "7", 0, 1, 1
g.connect "6", "8", 0, 7, 7
g.connect "7", "8", 0, 7, 1+6
g.source = "1"
g.target = "8"
res_graph = g.to_residual_graph
level_graph = LevelGraph.new(res_graph)
DrawGraph.new(g).draw("img/#{iter}-graph.png")
DrawResidualGraph.new(res_graph).draw("img/#{iter}_res_graph.png")
DrawLevelGraph.new(level_graph).draw("img/#{iter}_level_graph.png")


