require('graph')

module SPLATS
  # This encapsulates a single test.
  # It is responsible pretty printing the test i.e. writing the code of the test.
  # It will become responsible for executing the test it encapsulates during the generation phase.
  class Test
    def initialize
      @test_lines = []
      @result = nil
      @exception = nil
      @mocks = []
    end

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
          @result = @object = test_line.method.call *arguments
        else
          @result = @object.send(test_line.method, *arguments)
        end
      rescue Exception => e
        @exception = e
        return false
      end
      return true
    end

    def name
      "test_#{hash.abs}"
    end

    # Returns a string of the translation of the abstract code into a
    # test::unit testing method
    def to_s
      graph_gen
      if @exception
        (header + mocks + assert_raises + footer).join("\n")
      else
        (header + mocks + body + assert + footer).join("\n")
      end
    end

    private
    
    def graph_gen
      child_map = @mocks.flat_map {|m| m.__SPLATS_child_objects }
      digraph do
        child_map.each do |node|
          node[1].each do |childnode|
            edge(node[0].__SPLATS_print, Test.construct_value(childnode[1]))
            .label(childnode[0].to_s + Test.args_to_s(childnode[2])
          end 
        end
        save "single_mock_graph", "png"
      end  
    end
    
    # The function header
    def header
      ["def #{name}"]
    end

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
    def body
      # The -2 is because we drop the last line; The last line output by the assert method.
      @test_lines[0..-2] + ["result = " + @test_lines[-1].to_s]
    end

    # The final assert statement
    def assert
      if is_base_class? @result
        ["assert_equal #{result_to_s}, result"]
      elsif @result.__SPLATS_is_mock?
        ["assert_operator #{result_to_s}, :===, result"]
      else
        ["assert_instance_of #{@result.class}, result"]
      end
    end

    def assert_raises
      ["assert_raises #{@exception.class.name} do"] + body + ["end"]
    end

    # The function footer
    def footer
      ["end"]
    end

    def is_base_class? value
      BASE_CLASSES.include? value.class
    end

    # Turns the result from an abstract assert to a string
    def result_to_s
      self.class.construct_value @result
    end

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

    def self.args_to_s args
      if args.empty?
        ""
      else
        "(" << args.map{|a| construct_value a }.join(', ') << ")"
      end
    end


    # Private inner class
    class TestLine
      attr_reader :object, :method, :decisions, :arguments, :output

      def initialize method, arguments, decisions=nil, object=nil
        if method.respond_to? :to_sym
          @method = method.to_sym
        elsif method.respond_to? :call
          @method = method
        else
          raise TypeError.new "Expecting a method or symbol"
        end

        @arguments = arguments
        @decisions = decisions || []
        @object = object
      end

      def to_s
        assignment + object_call + method_name + args_to_s
      end

      private

      def assignment
        if @method.is_a? Method and @method.name == :new
          'object = '
        else
          ""
        end
      end

      def object_call
        if @object
          @object.to_s + '.'
        elsif @method.is_a? Method
          @method.receiver.name + '.'
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
        Test.args_to_s @arguments
      end
           
    end
  end
end
