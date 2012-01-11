require_relative 'decisions.rb'

module SPLATS
  class GUITraversal
    include Traversal
    
    def initialize fiber
      @fiber = fiber
      @init = true
    end
    
    def select_method methods
      if @init
        @current_method = methods[0]
        @init = false
        return methods[0]
      end

      # Send the GUI controller the options back
      @fiber.transfer MethodDecision.new(methods)
    end
    
    def select_arguments arguments
      # Send the arguments back to the GUI
      @fiber.transfer ArgumentDecision.new(@current_method, arguments)
    end
    
    def generate_value type
      # Generate the possible values Mock can take
      decisions = generate_values type
      
      # Transfer back to GUI
      line_number = caller[2].split(':')[1]
      @fiber.transfer ValueDecision.new(decisions, line_number)
    end
    
    def continue_descent?
      @fiber.transfer DescentDecision.new
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
      @fiber.transfer ExceptionDecision.new(exception)
    end
  end
end
