module SPLATS
  class Decision
    attr_accessor :depth
    attr_reader :options
    
    def initialize options
      @options = options
    end
    
    # Whether or not to draw/update the graph of progress
    def display_graph?
      false
    end
    
    # Whether or not to push the decision onto the stack
    def update_execution_path?
      false
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
    
    # Whether or not to update the method stored
    # This should only be overridden by MethodDecision
    def change_method?
      false
    end
    
    # This tidies up the answer sent back to the Traversal class
    def final_answer input
      input
    end
    
    # This is for those yes or no questions
    def yes_or_no
      ["Yes", "No"]
    end
    
    # Whether or not to show the snippet of file, usually no
    def display_file
      ""
    end
  end

  class MethodDecision < Decision
    
    def change_method?
      true
    end 
    
    def display_graph?
      true
    end
    
    def update_execution_path?
      true
    end
    
    def get_question
      "Select next method to test (current depth: " + strong(@depth.to_s) + ")."
    end
    
  end

  class ArgumentDecision < Decision
    
    def initialize(method, options)
      puts method
      @current_method = method
      @options = options
    end
    
    def display_graph?
      true
    end
    
    def update_execution_path?
      true
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
    
    def display_file
      "method"
    end
  end

  class ValueDecision < Decision
  
    def initialize(options, line_number)
      @options = options
      @line_number = line_number
    end
    
    def get_line_number
      @line_number
    end
    
    def get_question
      "Choose decision for type on line number " + @line_number
    end
    
    def display_file
      "line_number"
    end
    
  end

  class DescentDecision < Decision
    
    def initialize
      @options = yes_or_no
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
      @options = yes_or_no
      @exception = exception
    end
    
    def final_answer input
      input == yes_or_no[0]
    end
    
    def get_question
      "Continue generation?"
    end
    
    # Resets the depth to 1
    def update_depth
      @depth = 1
      @depth
    end
  end
  
  class ExceptionDecision < Decision
    def initialize e
      @e = e
      @options = ["OK"]
    end
    def get_question
      "Exception " + strong(@exception.to_s) + " raised."
    end
  end
end
