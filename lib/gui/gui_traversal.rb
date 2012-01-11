require_relative 'decisions.rb'
require_relative 'execution_graph.rb'

module SPLATS
  class GUITraversal
    include Traversal
    
    attr_accessor :graph
    
    def initialize fiber
      @fiber = fiber
      @graph = SPLATS::ExecutionGraph.new
      @init = true
    end
    
    def select_method methods
      if @init
        @current_method = methods[0]
        @graph.add @class.name
        @init = false
        return methods[0]
      end
      
      # Add the available options to the graph
      @graph.add methods

      # Send the GUI controller the options back
      m = @fiber.transfer MethodDecision.new(methods)

      # Set the newly defined method
      @current_method = m
      
      # Push the decision onto the graph and return the user's choice
      @graph.add m
      m
    end
    
    def select_arguments arguments
      # Add the choices to the graph
      @graph.add arguments
      
      # Send the arguments back to the GUI
      arg = @fiber.transfer ArgumentDecision.new(@current_method, arguments)
      
      # Add to the graph and return
      @graph.add arg
      arg
    end
    
    def generate_value type
      # Generate the possible values Mock can take
      decisions = generate_values type
      
      # Add the decisions to the graph
#      @graph.add decisions
      
      # Transfer back to GUI
#      line_number = caller[2].split(':')[1]
      line_number = 12
      decision = @fiber.transfer ValueDecision.new(decisions, line_number)
      
      # Add the decision to the graph and return it
#      @graph.add decision
      decision
    end
    
    def continue_descent?
      # Immediately transfer back to GUI
      cd = @fiber.transfer DescentDecision.new
    end
    
    def continue_generation?
      unless @first_run 
        @first_run = true
      else
        @init = true
        @fiber.transfer GenerationDecision.new
      end
    end

    def notify_exception_raised exception
      @graph.add exception
      @fiber.transfer ExceptionDecision.new(exception)
    end
  end
end
