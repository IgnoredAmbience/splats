# Prints individual tests

class TestPrinter

  # Takes in abstract code in the form [object, method, [args], result]
  def initialize (abstract_code)
    @instructions = abstract_code[0..-2]
    @assert_inst = abstract_code[-1]
    @name = "test_#{abstract_code.hash.abs}"
  end

  # Returns a string of the ruby translation of the abstract code
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
    @instructions.map{ |l| instruction_to_s l }
  end

  # The final assert statement
  def assert
    ["assert_equal #{methodcall_to_s @assert_inst}, #{result}"]
  end

  # The function footer
  def footer
    ["end"]
  end

  # Converts a non-assert abstract instruction to ruby as a string
  def instruction_to_s (line)
    "#{"#{line.out} = " if !line.out.nil?}#{methodcall_to_s line}"
  end

  # Converts the object, method and arguments from an abstract line to a ruby method call as a string
  def methodcall_to_s (line)
    "#{line.obj}.#{line.meth}#{args_to_s line.args}"
  end

  # Turns the array of arguments to a string
  def args_to_s (args_list)
    if args_list.empty?
      ""
    else
      "(" << args_list.map{ |a| a.to_s}.join(',') << ")"
    end
  end

  # Turns the result from an abstract assert to a string
  def result
    case @assert_inst.out.class
    when Exception
      @assert_inst.out.class.name
    else
      @assert_inst.out
    end
  end

end
