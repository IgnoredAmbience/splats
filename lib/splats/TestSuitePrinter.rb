require_relative "TestPrinter"

# Prints a collection of tests into a suite
class TestSuitePrinter
  
  # Takes in the name of the test, requirements, and an array of TestPrinters
  def initialize (name, reqs, tests)
    @name = name
    @reqs = reqs << "test/unit"
    @tests = tests
  end

  # Returns the final ruby code
  def print
    (requirements + header + tests + footer).join("\n")
  end

private

  # The list of require statements
  def requirements
    @reqs.map{ |r| "require '#{r}'" }
  end

  # The class header
  def header
    ["class #{@name} < Test::Unit::TestCase"]
  end

  # The list of test methods
  def tests
    @tests.map{|t| t.print}
  end
  
  # The class footer
  def footer
    ["end"]
  end

end
