require 'graph'

module SPLATS
  class ExecutionGraph
    def initialize
      @execution_path = []
    end
    
    # Adds options to the graph. Can be question or decision.
    # @param [Array] options What to push to the graph
    def add options
      @execution_path.push options
    end
    
    # Saves the graph to a file.
    # If the depth is set, it will generate the nodes from the bottom upwards to that depth.
    # Otherwise, it will draw the whole graph
    # @param [String] filename The name of the file to save the graph to. Defaults to "graph.png"
    # @param [Int] depth The depth to generate backwards to. Defaults to 3.
    def save_graph(filename="graph", depth=3)
      execution_path = @execution_path
      # The naming scheme of the nodes is depth, i and then ii if applicable
      digraph do
        # Something about the blocks that doesn't make sense to me requires this
#        gnn = lambda {|a| a.join("_")}
        depth = 1
        # Loop through the execution path
        execution_path.each_with_index do |ep, i|
          # If the current thing is an Array, it means they are the possible choices
          if ep.is_a? Array
            # Loop through the ep and draw a line from the previous node to all these options
            ep.each_with_index do |option, ii|
#              puts option
              l = "poo"
              node_name = "moo"
#              node_name = gnn.call([depth.to_s, i.to_s, ii.to_s])
              node(node_name, label=l)
              previous_node = "boo"
#              previous_node = gnn.call([depth.to_s, (i-1).to_s])
              # Draw an edge to the previous node
              edge previous_node, node_name            
            end
          else
            node_name = "boo"
#            node_name = gnn.call([depth.to_s, i.to_s])
            node(node_name, ep)
          end
        end
        save "graph", "png"
      end
      filename + ".png"
    end
  end
end
