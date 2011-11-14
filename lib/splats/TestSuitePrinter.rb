require_relative "TestPrinter"

module SPLATS
# Prints a collection of tests into a suite
  class TestSuitePrinter
    
    # Takes in
		# * the name for the test suite
		# * any required files
		# * an array of TestPrinter objects
    def initialize (name, reqs, tests)
      @name = name
      @reqs = reqs << "test/unit"
      @tests = tests
    end

    # Returns a string of the suite of tests in test::unit
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
end
