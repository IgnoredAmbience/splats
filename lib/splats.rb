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
    def initialize(input_file, output_dir, depth, seed, traversal, fiber=nil)
      if fiber
        require 'green_shoes'
      end
      @fiber = fiber
      @input_classes = SPLATS.load_classes input_file
      @output_dir = output_dir || "tests"
      @depth = depth || 3
      case traversal
        when 1
          @traversal = SPLATS::HumanTraversal.new(fiber)
        when 2
          seed = seed || 0
          @traversal = SPLATS::RandomTraversal.new(seed, fiber)
        else
          @traversal = SPLATS::DepthLimitedTraversal.new(@depth, fiber)
      end
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
        single_class_test c
      end
    end


    private
    
    # Creates tests for a class by generating and traversing the tree
    # then generating the code from the abstract syntax
    #
    # @param [Class] testing_class The class to be tested
    def single_class_test testing_class
      generator = Generator.new(testing_class, @traversal)
      TestFile.open(testing_class,[],@output_dir) do |file|
        generator.test_class do |test|
          file << test << "\n"
        end
      end
    end
  end

end
