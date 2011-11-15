module SPLATS
  # Prints individual tests
  class TestPrinter

    # Takes in abstract code in the form of a list of objects with parameters:
    # [obj]  an object
    # [meth] a method on that object
    # [args] an array of arguments to that method
    # [out]  a concrete, exception or variable for the result
    # Representing
    #  out = obj.meth(args)
    # except for the last item in the array, which is interpreted as
    #  assert_equal obj.meth(args),out
    def initialize (abstract_code, output)
      @instructions = abstract_code[0..-2]
      @assert = output
      @name = "test_#{abstract_code.hash.abs}"
    end

    # Returns a string of the translation of the abstract code into a
    # test::unit test
    def print
      (header + body + assert + footer).join("\n")
    end

    private

    # The function header
    def header
      ["def #{@name}"]
    end

    # The body of instructions
    def body
      @instructions.map{ |l| l.to_s }
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
  end
end
