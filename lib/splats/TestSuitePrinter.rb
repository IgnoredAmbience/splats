require_relative "TestPrinter"

# Prints a collection of tests into a suite
class TestSuitePrinter
  
  # Takes in the name of the test, requirements, and an array of TestPrinters
  def initialize (name, reqs, tests)
    @name = name
    @reqs = reqs << "test/unit"
    @tests = tests
  end

  def print
    (requirements + header + tests + footer).join("\n")
  end

private

  def requirements
    @reqs.map{ |r| "require '#{r}'" }
  end

  def header
    ["class #{@name} < Test::Unit::TestCase"]
  end

  def tests
    @tests.map{|t| t.print}
  end
  
  def footer
    ["end"]
  end

end
