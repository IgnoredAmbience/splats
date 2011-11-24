module SPLATS
  # This encapsulates a single test.
  # It is responsible pretty printing the test i.e. writing the code of the test.
  # It will become responsible for executing the test it encapsulates during the generation phase.
  class Test

    def initialize
      @test_lines = []
    end

    def add_line (method, parameters, decisions)
      @test_lines.push(TestLine.new(method, parameters, decisions))
    end

    # Executes the test, sets the result parameter as the result of execution
    #
    # @yield
    def execute!
      object = result = nil
      @test_lines.each do |test_line|
        # Construct any arguments that are Mocks
        arguments = test_line.arguments.map do |arg|
          if arg == Mock
            arg.new do |branches|
              # Passes options back to Generator to put into tree, or the option
              # taken from the tree
              if test_line.decisions.empty?
                yield branches
                result = branches.shift
              else
                result = test_line.decisions.shift
              end
              puts "Using branch: #{result}"
              result
            end
          else
            arg
          end
        end

        begin
          if test_line.method.respond_to? :call
            object = test_line.method.call *arguments
          else
            result = object.send test_line.method, *arguments
          end
        rescue Exception => e
          puts "!> " + e.to_s
          result = e
          break
        end
      end

      puts "=> " + result.inspect
      @result = result
    end

    def name
      "test_#{hash.abs}"
    end

    # Returns a string of the translation of the abstract code into a
    # test::unit testing method
    def to_s
      if @result.is_a? Exception
        (header + assert_raises + footer).join("\n")
      else
        (header + body + assert + footer).join("\n")
      end
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

    def assert_raises
      ["assert_raises #{@result.class.name} do"] + body + ["end"]
    end

    # The function footer
    def footer
      ["end"]
    end

    # Turns the result from an abstract assert to a string
    def result_to_s
      if @result.is_a? TypeError
         "\"" + @result.to_s + "\""
      elsif @result.is_a? NilClass
        "nil"
      else
        @result
      end
    end

    # Private inner class
    class TestLine
      attr_reader :object, :method, :decisions, :arguments, :output

      def initialize method, arguments, decisions, object=nil, output=nil
        if method.respond_to? :to_sym
          @method = method.to_sym
        elsif method.respond_to? :call
          @method = method
        else
          raise TypeError.new "Expecting a method or symbol"
        end

        @arguments = arguments
        @decisions = decisions
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
