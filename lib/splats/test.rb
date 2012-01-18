module SPLATS
  # This encapsulates a single test.
  #
  # It is responsible for pretty printing the test i.e. writing the code of the test.
  #
  # It is also responsible for executing and maintaining the execution state
  # of the test it encapsulates during the generation phase.
  class Test
    def initialize
      @test_lines = []
      @result = nil
      @exception = nil
      @mocks = []
    end

    # Adds a test line to the test
    # @param [Symbol] method The method to be called
    # @param [Array] parameters The parameters to be passed to the method
    def add_line (method, parameters)
      @test_lines.push(TestLine.new(method, parameters))
    end

    # Executes the most recently added line to the test
    # @return [boolean] Returns false if an exception was raised on the
    #   execution of this line
    def execute_last &decision
      return execute_line @test_lines[-1], &decision
    end

    # Executes the entire test
    def execute_all &decision
      @result = nil
      @exception = nil

      @test_lines.each do |line|
        break if not execute_line line, &decision
      end
      unless @exception
        #puts "=> " + @result.inspect
      end
    end

    # Executes the TestLine, sets the result parameter as the result of execution
    #
    # @return [boolean] Returns false if an exception was raised on the
    #   execution of this line
    def execute_line test_line, &decision
      #puts "X> Executing #{test_line}"
      # Construct any arguments that are Mocks
      arguments = test_line.arguments.map! do |arg|
        if arg == SPLATS::Mock
          mock = arg.new &decision
          @mocks << mock
          mock
        else
          arg
        end
      end

      begin
        if test_line.method.respond_to? :call
          @object = (test_line.method.call(*arguments))
					@result = @object
        else
          @result = @object.send(test_line.method, *arguments)
        end
      rescue Exception => e
        @exception = e
        return false
      end
      return true
    end

    # Returns the name of the test
    # @return [String] The name of the test
    def name
      "test_#{hash.abs}"
    end

    # Returns a string of the translation of the abstract code into a
    # test::unit testing method
    # @return [String] The statements of the test
    def to_s
      if @exception
        (header + mocks + assert_raises + footer).join("\n")
      else
        (header + mocks + body + assert + footer).join("\n")
      end
    end

    private

    # The function header
    # @return [<String>] The function definition statement
    def header
      ["def #{name}"]
    end

    # Produces a set of statements to recreate the execution sequence of all
    # mock objects used by the test
    # @return [<String>] The mock execution statements
    def mocks
      calls = @mocks.flat_map {|m| m.__SPLATS_child_objects }

      constructors = []

      expects = calls.flat_map do |c|
        recv = c[0]
        constructors << (recv.__SPLATS_print + ' = flexmock("' + recv.__SPLATS_print + '")')
        c[1].map do |call|
          line  = recv.__SPLATS_print
          line += ".should_receive(#{call[0].inspect})"
          (line += ".with" + self.class.args_to_s(call[2])) unless call[2].empty?
          line += '.and_return(' + self.class.construct_value(call[1]) + ').once'
        end
      end

      constructors + expects
    end

    # The body of instructions
    # @return [<String>] The test execution statements
    def body
      # The -2 is because we drop the last line; The last line output by the assert method.
      @test_lines[0..-2] + ["result = " + @test_lines[-1].to_s]
    end

    # The final assert statement
    # @return [<String>] The assert statement
    def assert
      if is_base_class? @result
        ["assert_equal #{result_to_s}, result"]
      elsif @result.__SPLATS_is_mock?
        ["assert_operator #{result_to_s}, :===, result"]
      else
        ["assert_instance_of #{@result.class}, result"]
      end
    end

    # The statements wrapping a body of execution statements if an exception is
    # expected to be raised during their execution
    # @return [<String>] Raises exectuion statements
    def assert_raises
      ["assert_raises #{@exception.class.name} do"] + body + ["end"]
    end

    # The function footer
    # @return [<String>] The footer statement
    def footer
      ["end"]
    end

    # True if the given value is determined to be a 'primitive'
    #
    # @note Mock objects should ''NOT'' be passed into this.
    # @param [Object] value The object to test for primitivity
    def is_base_class? value
      BASE_CLASSES.include? value.class
    end

    # Turns the result from an abstract assert to a string
    def result_to_s
      self.class.construct_value @result
    end

    # Produces a string suitable for use in a source file to construct a
    # primitive type
    #
    # @param [Object] value The object to drop to string
    # @return [String] The object represented as a string suitable for use in
    #   source
    def self.construct_value value
      if value.__SPLATS_is_mock?
        value.__SPLATS_print
      elsif value.is_a? NilClass
        "nil"
      elsif value.is_a? Exception
        value.class.name
      elsif value.is_a? Array
        "[" << value.map{|v| construct_value v}.join(', ') << "]"
      else
        value.inspect
      end
    end

    # Produces an argument list suitable for use with a method call
    #
    # @param [<Object>] args The array of arguments
    # @return [String] The argument string
    def self.args_to_s args
      if args.empty?
        ""
      else
        "(" << args.map{|a| construct_value a }.join(', ') << ")"
      end
    end


    # Internal representation of one line of execution within a Test
    class TestLine
      attr_reader :method, :arguments, :output

      # @param [Symbol] method The method
      # @param [<nil,Mock>] arguments The argument template to use
      def initialize method, arguments
        if method.respond_to? :to_sym
          @method = method.to_sym
        elsif method.respond_to? :call
          @method = method
        else
          raise TypeError.new "Expecting a method or symbol"
        end

        @arguments = arguments
      end

      # @return [String] String representation of the TestLine
      def to_s
        assignment + object_call + method_name + args_to_s
      end

      private

      # @return [String] Assignment of the constructor
      def assignment
        if @method.is_a? Method and @method.name == :new
          'object = '
        else
          ""
        end
      end

      # @return [String] The object/class name with . appended
      def object_call
        if @method.is_a? Method
          @method.receiver.name + '.'
        else
          'object.'
        end
      end

      # @return [String] Method name
      def method_name
        if @method.is_a? Symbol
          @method.to_s
        else
          @method.name.to_s
        end
      end

      # @return [String] The argument string
      def args_to_s
        Test.args_to_s @arguments
      end
    end
  end
end
