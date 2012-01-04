module SPLATS
  # Generates tests for a given class
  class Generator

    # @param [Class] c The class for the test generator to operate on
    # @param [Traversal] traversal The traversal object to use to direct the
    #   search
    def initialize(c, traversal)
      @class = c
      @pass_parameters = [Mock, nil]
      @traversal = traversal
    end

    # Displays the Generator as a string
    # @see Object#inspect
    def to_s
      "<SPLATS::Generator @traversal=#{@traversal} @class=#{@class}>"
    end

    # Generates and yields as many tests as the traversal method thinks
    # appropriate
    # @yield [Test] A generated test
    def test_class
      while @traversal.continue_generation?
        yield produce_test 
      end
    end

    # Produces a single test
    # @return [Test] A generated test
    def produce_test
      test = Test.new
      @traversal.notify_new_traversal
      decision = @traversal.method(:select_decision)
      method = @traversal.select_method [@class.method(:new)]
      puts method
            
      args = @traversal.select_arguments generate_parameters(:initialize)
      puts args
      
      test.add_line(method, args)
      continue_execution = test.execute_last &decision

      while continue_execution and @traversal.continue_descent?
        method = @traversal.select_method @class.instance_methods(false)
        args = @traversal.select_arguments generate_parameters(method)
        test.add_line(method, args)
        continue_execution = test.execute_last &decision
      end

      if not continue_execution
        @traversal.notify_exception_raised
      end

      return test
    end

    private

    # Expands the given tree node with all possible argument sets
    #
    # @param [Symbol,Method] method Method to retrieve arity information from.
    #   If a symbol is passed, it represents an instance method of the class
    #   under testing.
    # @return [Array<@pass_parameters>] Array of all possible argument sets,
    #   valid for the given method.
    def generate_parameters(method)
      # If it's not a method, try to make it one
      unless method.respond_to? :parameters
        method = @class.instance_method method
      end

      req = method.parameters.count {|type, o| type == :req}
      opt = method.parameters.count {|type, o| type == :opt}
      # Other types are :rest, :block, for * and & syntaxes, respectively

      (req..opt+req).flat_map do |n|
        @pass_parameters.repeated_permutation(n).to_a
      end
    end
  end
end
