module SPLATS
  # Prints individual tests
  class Test

    # Takes in abstract code in the form of a list of objects with parameters:
    # [obj]  an object
    # [meth] a method on that object
    # [args] an array of arguments to that method
    # [out]  a concrete, exception or variable for the result
    # Representing
    #  out = obj.meth(args)
    # except for the last item in the array, which is interpreted as
    #  assert_equal obj.meth(args),out
=begin    def initialize (abstract_code, output)
      @instructions = abstract_code[0..-2]
      @assert = output
      @name = "test_#{abstract_code.hash.abs}"
      @lines = generate_lines @instructions
    end
=end

    def initialize(abstract_code = nil)
      @test_lines = []
    end
    
    def add_line (method, parameters)
      @test_lines.push(TestLine.new(method, parameters))
    end
    
    def execute
    end

    # Returns a string of the translation of the abstract code into a
    # test::unit test
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
      ["def #{@name}"]@test_lines = []
    end

    # The body of instructions
    def body
      @test_lines.map{ |l| l.to_s }
    end

    # The final assert statement
    def assert
      ["assert_equal result, #{result}"]
    end

    # The function footer
    def footer
      ["end"]
    end

    # Turns the result from an abstract assert to a string
    def result
      case @assert.class
      when Exception
        @assert.class.name
      else
        @assert
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
        if output
          output + ' = '
        elsif method.is_a? Method and method.name == :new
          'object = '
        else
          'result = '
        end
      end

      def object_call
        if object
          object.to_s + '.'
        elsif method.is_a? Method
          method.class.name + '.'
        else
          'object.'
        end
      end

      def method_name
        if method.is_a? Symbol
          method.to_s
        else
          method.name.to_s
        end
      end

      # Turns the array of arguments to a string
      def args_to_s
        if arguments.empty?
          ""
        else
          "(" << arguments.map{ |a| a.to_s}.join(',') << ")"
        end
      end
    end
  end
end
