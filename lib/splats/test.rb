module SPLATS
  # This encapsulates a single test.
  # It is responsible pretty printing the test i.e. writing the code of the test.
  # It will become responsible for executing the test it encapsulates during the generation phase.
  class Test

    def initialize
      @test_lines = []
    end

    def add_line (method, parameters)
      @test_lines.push(TestLine.new(method, parameters))
    end

    def add_result (result)
      @result = result
    end

    def execute
    end

    def name
      "test_#{hash.abs}"
    end

    # Returns a string of the translation of the abstract code into a
    # test::unit testing method
    def to_s
      (header + body + assert + footer).join("\n")
    end

    # Loops through the test lines
    def each
      yield @test_lines.each
    end

    private

    # The function header
    def header
      ["def #{name}"]
    end

    # The body of instructions
    def body
      # The -2 is because we drop the last line; The last line output by the assert method.
      @test_lines[0..-2]
    end

    # The final assert statement
    def assert
      ["assert_equal #{@test_lines[-1]}, #{result_to_s}"]
    end

    # The function footer
    def footer
      ["end"]
    end

    # Turns the result from an abstract assert to a string
    def result_to_s
      case @result.class
      when Exception
        @result.class.name
      else
        @result
      end
    end

    # Private inner class
    TestLine = Class.new do
      attr_reader :object, :method, :arguments, :output

      def initialize method, arguments, object=nil, output=nil
        if method.respond_to? :to_sym
          @method = method.to_sym
        elsif method.respond_to? :call
          @method = method
        else
          raise TypeError.new "Expecting a method or symbol"
        end

        @arguments = arguments
        @object = object
        @output = output
      end

      def to_s
        assignment + object_call + method_name + args_to_s
      end

      private

      def assignment
        if @output
          @output + ' = '
        elsif @method.is_a? Method and @method.name == :new
          'object = '
        else
          ""
        end
      end

      def object_call
        if @object
          @object.to_s + '.'
        elsif @method.is_a? Method
          @method.class.name + '.'
        else
          'object.'
        end
      end

      def method_name
        if @method.is_a? Symbol
          @method.to_s
        else
          @method.name.to_s
        end
      end

      # Turns the array of arguments to a string
      def args_to_s
        if @arguments.empty?
          ""
        else
          "(" << @arguments.join(',') << ")"
        end
      end
    end
  end
end
