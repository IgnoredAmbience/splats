# This is the class-loader for SpLATS
require_relative 'splats/generator'
require_relative 'splats/mock'
require_relative 'splats/test'
require_relative 'splats/tree'

module SPLATS
  # Loads a configuration file, written in YAML, outlining the classes to test
  #
  # Example:
  #  modules:
  #   classes.rb: [Testing1]
  #  versions:
  #    - 1.1
  #    - 1.2
  #
  # @param [String] filename The YAML configuration file to load
  def self.load_config(filename)
    require "yaml"
    config = YAML.load_file(filename)

    # Load the modules of the baseline version of the code being tested
    config["modules"].each do |module_name, classes|
      load root_dir + "/" + config["versions"][0] + "/" + module_name
      classes.each do |c|
        s = Generator.new(Object.const_get(c))
        s.test_class
      end
    end
  end

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
  def self.load_class filename
    constants = Module.constants

    load filename

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
    def initialize(input_file, output_dir)
      @input_classes = SPLATS.load_class input_file
      @output_dir = output_dir
      if not File::directory?(output_dir)
        Dir.mkdir(output_dir)
      end
    end
    
    # Creates tests for every class in @input_classes 
    def multi_class_test 
      @input_classes.each do |c|
        single_class_test(c)
      end
    end

    # Takes in the test to output, class being tested and test number
    # Writes to a file - ouput_directory/test_className.rb
    #
    # @param [String] test The finished generated test
    # @param [Class] c The class being tested
    # @param [Numeric] id Test counter
    def write(test, c)
      File.open("#{@output_dir}test_#{c}.rb", "w") do |x|
        x.puts test
      end
    end
    
    private
    
    # Creates tests for a class by generating and traversing the tree
    # then generating the code from the abstract syntax
    #
    # @param [Class] c The class to be tested
    def single_class_test(c)
      generator = Generator.new(c)
      generator.test_class do |test|
        write(test, c)
      end
    end
  end

end
