require_relative "test"

module SPLATS
# Prints a collection of tests into a suite
  class TestSuitePrinter
    
    # Takes in
    # * the name for the test suite
    # * any required files
    # * an array of TestPrinter objects
    def initialize (klass, reqs, file = $stdout)
      @klass = klass
      @reqs = reqs << "test/unit"
      @file = file
      @tests = []
      
      @file << (requirements + header).join("\n") << "\n"
    end

    def << test
      @file << test << "\n"
    end

    def close
      @file << footer
    end

    # Returns a string of the suite of tests in test::unit
    def to_s
      (requirements + header + @tests + footer).join("\n")
    end

  private

    # The list of require statements
    def requirements
      @reqs.map{ |r| "require '#{r}'" }
    end

    # The class header
    def header
      ["class test_#{@klass} < Test::Unit::TestCase"]
    end

    # The class footer
    def footer
      "end"
    end

  end
end
