require 'graph'

module SPLATS
  class ExecutionGraph
    def initialize
      @execution_path = []
    end
    
    # Adds options to the graph. Can be question or decision.
    # @param [Array] options What to push to the graph
    def add options
      @execution_path << options
    end
    
    # Saves the graph to a file.
    # If the depth is set, it will generate the nodes from the bottom upwards to that depth.
    # Otherwise, it will draw the whole graph
    # @param [String] filename The name of the file to save the graph to. Defaults to "graph.png"
    # @param [Int] depth The depth to generate backwards to. Defaults to 3.
    def save_graph(filename="graph.png", depth=3)
      digraph do
        # Loop through the execution path
        @execution_path.each_with_index do |ep, i|
          puts "node: " + ep.to_s
          # If the current thing is an Array, it means they are the possible choices
          if ep.is_a? Array
            # Loop through the ep and draw a line from the previous node to all these options
            ep.each_with_index do |option, ii|
              puts "decisions" + option.to_s
            end
          else
          end
        end
      end
    end
  end
end
