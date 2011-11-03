class TestPrinter

  def initialize (abstractCode)
    @instructions = abstractCode[0..-2]
    @assertInst = abstractCode[-1]
    @name = "test_#{abstractCode.hash.abs}"
  end

  def print
    header << body << assert << footer
  end

private

  def header
    "def #{@name}\n"
  end

  def body
    out = ""
    @instructions.each{ |l| out << "#{"#{l.out} = " if !l.out.nil?}#{methodcallToString l}\n" }
    out
  end

  def assert
    "assert_equal #{methodcallToString @assertInst}, #{result}\n"
  end

  def footer
    "end\n"
  end

  def methodcallToString (line)
    "#{line.obj}.#{line.meth}#{argsToString line.args}"
  end

  def argsToString (argsList)
    if argsList.empty?
      ""
    else
      "(" << argsList.map{ |a| a.to_s}.join(',') << ")"
      #out = "("
      #argsList[0..-2].each{ |a| out << "#{a}," }
      #out << "#{argsList[-1]})"
    end
  end

  def result
    case @assertInst.out.class
    when Exception
      @assertInst.out.class.name
    else
      @assertInst.out
    end
  end

end
