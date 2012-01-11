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
      r = @fiber.transfer MethodDecision.new(methods)
      @current_method = r
    end
    
    def select_arguments arguments
      # Send the arguments back to the GUI
      ad = ArgumentDecision.new(@current_method, arguments)
      @fiber.transfer ad
    end
    
    def generate_value type
      # Generate the possible values Mock can take
      decisions = generate_values type
      
      c_value = nil
      
      # Find out the line number
      caller.each do |c|
        if not c.index "lib/splats"
          c_value = c
          break
        end
      end
      
      # Transfer back to GUI
      @fiber.transfer ValueDecision.new(@current_method, decisions, c_value.split(':')[1])
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
      puts "Exception"
      @fiber.transfer ExceptionDecision.new(exception)
    end
  end
end
