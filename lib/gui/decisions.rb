module SPLATS
  class Decision
    attr_accessor :depth, :continue, :choice, :reset
    attr_reader :options, :update_execution_path, :change_method, :display_graph, :display_file, :line_number
    alias_method :update_execution_path?, :update_execution_path
    alias_method :continue?, :continue
    alias_method :change_method?, :change_method
    alias_method :display_graph?, :display_graph
    alias_method :display_file?, :display_file
    
    def initialize options
      @options = options
      @update_execution_path = false
      @change_method = false
      @continue = true
      @display_graph = false
      @display_file = false
      @reset = false
    end
    
    def yes_or_no
      ["Yes", "No"]
    end
    
    # Usually just returns the current depth
    def update_depth
      @depth
    end
    
    # Gets what the user is asked when they need to answer this question
    def get_question
      raise NotImplementedError
    end
    
    # Make inputs bold
    # @param [String] input to make bold
    def strong input
      "<b>" + input + "</b>"
    end
    
    # This tidies up the answer sent back to the Traversal class
    def final_answer input
      if input.nil?
        return "nil"
      end
      input
    end
  end

  class MethodDecision < Decision
    def initialize methods
      super(methods)
      @change_method = true
      @display_graph = true
      @update_execution_path = true
    end
    
    def get_question
      "Select next method to test (current depth: " + strong(@depth.to_s) + ")."
    end
    
  end

  class ArgumentDecision < Decision
    
    def initialize(method, options)
      super(options)
      @current_method = method
      @display_graph = true
      @update_execution_path = true
      @display_file = "method"
    end
    
    def get_question
      # When method is initialize, it won't present nicely without the name
      if @current_method.respond_to?('name')
        name = @current_method.name.to_s
      else
        name = @current_method.to_s
      end
      "Choose an argument for " + strong(name) + " method."
    end
  end

  class ValueDecision < Decision
  
    def initialize(method, options, line_number)
      super(options)
      @line_number = line_number
      @display_file = "line_number"
      @display_graph = true
      @current_method = method
    end
    
    def get_question
      "Choose decision for type on line number #{strong(@line_number.to_s)} for method #{strong(@current_method.to_s)}."
    end
    
  end

  class DescentDecision < Decision
    
    def initialize
      super(yes_or_no)
    end
    
    def get_question
      "Continue descent?"
    end
    
    def final_answer input
      input == yes_or_no[0]
    end
    
    # Increments the depth
    def update_depth
      @depth += 1
      @depth
    end
  end
  
  class GenerationDecision < Decision
    
    def initialize exception=nil
      super(yes_or_no)
      @exception = exception
    end
    
    def final_answer input
      @continue = (input == yes_or_no[0])
    end
    
    def get_question
      "Continue generation?"
    end
    
    # Resets the depth to 1
    def update_depth
      @depth = 1
    end
    
    def change_method?
      true
    end
  end
  
  class ExceptionDecision < Decision
    def initialize e
      super(["OK"])
      @e = e
    end
    def get_question
      "Exception " + strong(@e.to_s) + " raised."
    end
  end
end
