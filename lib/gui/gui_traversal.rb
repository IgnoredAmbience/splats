require_relative 'decisions.rb'
require_relative 'execution_graph.rb'

module SPLATS
  class GUITraversal
    include Traversal
    
    def initialize fiber
      @fiber = fiber
      @graph = SPLATS::ExecutionGraph.new
      @init = true
    end
    
    def select_method methods
      if @init
        @current_method = methods[0]
        @graph.add @current_method
        @init = false
        return @current_method
      end
      
      # Add the available options to the graph
      @graph.add methods
      
      # Send the GUI controller the options back
      method = @fiber.transfer MethodDecision.new(methods)
      
      # Set the newly defined method
      @current_method = method
      
      # Push the decision onto the graph and return the user's choice
      @graph.add method
      method
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
      @graph.add decisions
      
      # Transfer back to GUI
      decision = @fiber.transfer ValueDecision.new(decisions, caller[2].split(':')[1])
      
      # Add the decision to the graph and return it
      @graph.add decision
      decision
    end
    
    def continue_descent?
      # Immediately transfer back to GUI
      @fiber.transfer DescentDecision.new
    end
    
    def continue_generation?
      unless @first_run 
        @init = true
        @first_run = true
      else
        @fiber.transfer GenerationDecision.new
      end
    end

    def notify_exception_raised exception
      @graph.add exception
      @fiber.transfer ExceptionDecision.new(exception)
    end
  end
end
