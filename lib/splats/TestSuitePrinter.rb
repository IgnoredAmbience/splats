require_relative "TestPrinter"

class TestSuitePrinter
  
  def initialize (name, reqs, tests)
    @name = name
    @reqs = reqs << "test/unit"
    @tests = tests
  end

  def print
    requirements << header << tests << footer
  end

private

  def requirements
    @reqs.map{ |r| "require '#{r}'" }.join("\n") << "\n"
  end

  def header
    "class #{@name} < Test::Unit::TestCase\n"
  end

  def tests
    @tests.map{|t| t.print}.join("\n")
  end
  
  def footer
    "end\n"
  end

end
