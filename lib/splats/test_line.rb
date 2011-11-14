module SPLATS
  class TestLine
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

