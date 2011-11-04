class TestPrinter

  def initialize (abstract_code)
    @instructions = abstract_code[0..-2]
    @assert_inst = abstract_code[-1]
    @name = "test_#{abstract_code.hash.abs}"
  end

  def print
    header << body << assert << footer
  end

private

  def header
    "def #{@name}\n"
  end

  def body
    @instructions.map{ |l| instruction_to_s l }.join("\n") << "\n"
  end

  def assert
    "assert_equal #{methodcall_to_s @assert_inst}, #{result}\n"
  end

  def footer
    "end\n"
  end

  def instruction_to_s (line)
    "#{"#{line.out} = " if !line.out.nil?}#{methodcall_to_s line}"
  end

  def methodcall_to_s (line)
    "#{line.obj}.#{line.meth}#{args_to_s line.args}"
  end

  def args_to_s (args_list)
    if args_list.empty?
      ""
    else
      "(" << args_list.map{ |a| a.to_s}.join(',') << ")"
    end
  end

  def result
    case @assert_inst.out.class
    when Exception
      @assert_inst.out.class.name
    else
      @assert_inst.out
    end
  end

end
