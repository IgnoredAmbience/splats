# This is the class-loader for SpLATS
require_relative 'splats/generator'
require_relative 'splats/mock'
require_relative 'splats/test'
require_relative 'splats/test_file'
require_relative 'splats/Traversal/traversal'
require_relative 'splats/Traversal/human_traversal'
require_relative 'splats/Traversal/random_traversal'
require_relative 'splats/Traversal/depth_limited_traversal'

module SPLATS

  BASE_CLASSES = [
    Integer,
    String,
    Fixnum,
    Float,
    Array,
    TrueClass,
    FalseClass,
    NilClass,
    Hash
  ]

  RETURN_TYPES = {
    :! => :Bool,
    :!= => :Bool,
    :== => :Bool,
    :=== => :Bool,
    :< => :Bool,
    :> => :Bool,
    :>= => :Bool,
    :<= => :Bool,
    :to_a => :Array,
    :to_ary => :Array,
#    :to_c => :Complex,
#    :to_d => :BigDecimal,
    :to_f => :Float,
    :to_hash => :Hash,
    :to_i => :Integer,
    :to_int => :Integer,
#    :to_r => :Rational,
    :to_s => :String,
    :to_str => :String,
    :inspect => :String,
    :to_sym => :Symbol,
  }


  # Loads given file and returns classes defined within
  #
  # This does *not* guarantee that any other code held within the file will not
  # be executed.
  #
  # A second call to this method with the same filename will return an empty
  # list (unless a new class has been defined in the file).
  #
  # @param [String] filename The ruby source file to load
  # @return [Array<Class>] The classes defined within the file
  def self.load_classes filename
    constants = Module.constants
    
    # Have to wrap in thread because otherwise causes seg fault in GUI
    t = Thread.new do
      load filename
    end
    t.join

    (Module.constants - constants).map do |sym|
      const_get sym
    end
  end


  # Takes in a ruby code file and a directory to place the generated tests
  class TestController

    # @param [String] input_file The ruby code file to be tested
    # @param [String] output_dir The directory for generated tests to be put
    #
    # @note Directory created if necessary
    def initialize(input_file, regression_file, output_dir, traversal)
      @input_classes = SPLATS.load_classes input_file
      @regression_file = regression_file
      if output_dir == :notgiven || output_dir.nil?
        @output_dir = "tests/"
      else 
        @output_dir = output_dir
      end
      #@depth = param || 3
      @traversal = traversal       
      if not File::directory?(@output_dir)
        Dir.mkdir(@output_dir)
      end
    end
    
    # Creates tests for every class in the given file
    # If GUI and the input classes is empty, need to end
    # @param If GUI, need to pass the response of the user
    # into the test
    def test_classes
      if(@fiber && @input_classes.size == 0)
        @fiber.transfer [:error, "Could not find any classes"]
      end
      @input_classes.each do |c|
        if @regression_file.nil?
          single_class_test(c)
        else
          double_class_test(c,@regression_file)
        end
      end
    end


    private
    
    # Creates tests for a class by generating and traversing the tree
    # then generating the code from the abstract syntax
    #
    # @param [Class] testing_class The class to be tested
    def single_class_test(testing_class)
      cur_testing_class = Generator.new(testing_class, @traversal)
      TestFile.open(testing_class,[],@output_dir) do |file|
        cur_testing_class.test_class do |test|
          file << test << "\n"
        end
      end
    end

    def double_class_test(first_test_class, second_test_class)
      cur_testing_class = Generator.new(first_test_class, @traversal)

      require "test/unit"
      require "flexmock/test_unit"
      
      cur_testing_class.test_class do |test|
        eval("class TestClass < ::Test::Unit::TestCase\ninclude FlexMock::TestCase\n" + test.to_s + "\n" + 'end')
      end
      
      ::Test::Unit::Runner.class_variable_set :@@stop_auto_run, true

      t = MiniTest::Unit.new
      t.run
      t.errors
      t.failures
      
      Object.send(:remove_const, first_test_class.name.to_sym)

      load second_test_class

      t = MiniTest::Unit.new
      t.run
      t.errors
      t.failures

    end

    
  end
end
