class TestPrinter

  def initialize (abstractCode)
    @instructions = abstractCode[0..-2]
    @assertInst = abstractCode[-1]
    @name = abstractCode.hash.abs
  end

  def print
    out = ""
    out << header
    out << body
    out << assert
    out << footer
  end

private
  def header
    "def #{@name}\n"
  end

  def body
    ""
  end

  def assert
    "assert_equal #{methodcallToString @assertInst}, #{result}"
  end

  def footer
    "end\n"
  end

  def methodcallToString (line)
    "#{line.obj}.#{line.meth} #{argsToString line.args}"
  end

  def argsToString (argsList)
    if argsList.nil?
      ""
    else
      out = "("
      argsList[0..-2].each{ |a| out << "#{a}," }
      out << "#{argsList[-1]})"
    end
  end

  def result
    @assertInst.out
  end

end
