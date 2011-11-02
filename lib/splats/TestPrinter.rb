class TestPrinter

  def initialize (abstractCode)
    @instructions = abstractCode[0..-2]
    @assertInst = abstractCode[-1]
    @name = abstractCode.hash
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
  end

  def assert
  end

  def footer
    "end\n"
  end

end
