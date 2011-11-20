# This is the class-loader for SpLATS
require_relative 'splats/generator'
require_relative 'splats/mock'
require_relative 'splats/test_line'
require_relative 'splats/test_printer'
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
    
    # Creates tests for a class by generating and traversing the tree
    # then generating the code from the abstract syntax
    #
    # @param [Class] testing_class The class to be tested
    def single_class_test(testing_class)
      cur_testing_class = Generator.new(testing_class)
      test_counter = 0
      cur_testing_class.test_class do |test, result|
        test_printer = SPLATS::TestPrinter.new(test, result)
        write(test_printer.print, testing_class ,test_counter)
        test_counter += 1
      end
    end
    
    # Creates tests for every class in @input_classes 
    def multi_class_test 
      @input_classes.each do |cla|
        single_class_test(cla)
      end
    end

    # Takes in the test to output, class being tested and test number
    # Writes to a file - ouput_directory/test_className01.rb     
    #
    # @param [String] test_as_string The finished generated test
    # @param [Class] cla The class being tested
    # @param [Numeric] id Test counter
    def write(test_as_string, cla, id)
      File.open("#{@output_dir}test_#{cla}#{id}.rb", "w") do |x|
        x.puts test_as_string
      end
    end
  end

end
