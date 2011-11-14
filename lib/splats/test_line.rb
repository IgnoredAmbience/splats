module SPLATS
  class TestLine
    attr_reader :method, :arguments

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

    def method_name
      if method.is_a? Symbol
        method.to_s
      else
        method.owner.name + method.name.to_s
      end
    end

    def to_s
      method_name + arguments
    end
  end
end

