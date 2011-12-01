# This is the class-loader for SpLATS
require_relative 'splats/generator'
require_relative 'splats/mock'
require_relative 'splats/test'
require_relative 'splats/test_file'
require_relative 'splats/tree'

module SPLATS

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

    load filename

    (Module.constants - constants).map do |sym|
      const_get sym
    end
  end


  # Takes in a ruby code file and a directory to place the generated tests
  class TestController

    # @param [String] input_file The ruby code file to be tested
    # @param [String] output_dir The directory for generated tests to be put. Default: tests/
    # @param [String] depth The depth limit for the search space. Default: 3
    #
    # @note Directory created if necessary
    def initialize(input_file, output_dir, depth)
      @input_classes = SPLATS.load_classes input_file
      @output_dir = output_dir || "tests"
      @depth = depth || 3
      if not File::directory?(output_dir)
        Dir.mkdir(output_dir)
      end
    end
    
    # Creates tests for every class in the given file
    def test_classes
      @input_classes.each do |c|
        single_class_test(c)
      end
    end


    private
    
    # Creates tests for a class by generating and traversing the tree
    # then generating the code from the abstract syntax
    #
    # @param [Class] testing_class The class to be tested
    def single_class_test(testing_class)
      cur_testing_class = Generator.new(testing_class)
      TestFile.open(testing_class,[],@output_dir) do |file|
        cur_testing_class.test_class(@depth) do |test|
          file << test << "\n"
        end
      end
    end
  end

end
