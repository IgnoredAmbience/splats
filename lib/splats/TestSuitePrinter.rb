require_relative "TestPrinter"

class TestSuitePrinter
  
  def initialize (name, reqs, tests)
    @name = name
    @reqs = reqs
    @tests = tests
  end

  def print
    out = ""
    out << requirements
    out << header
    out << tests
    out << footer
  end

private

  def requirements
    out = "require \"test/unit\"\n"
    @reqs.each{ |r| out << "require \"#{r}\"\n"}
    out
  end

  def header
    "class #{@name} < Test::Unit::TestCase\n"
  end

  def tests
    out = ""
    @tests.each{ |t| out << t.print}
    out
  end
  
  def footer
    "end\n"
  end


end
