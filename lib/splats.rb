# This is the class-loader for SpLATS
require_relative 'splats/generator'
require_relative 'splats/mock'
require_relative 'splats/test_line'
require_relative 'splats/test_printer'
require_relative 'splats/tree'

module SPLATS
  def self.load_config(filename)
    require "yaml"
    config = YAML.load_file(filename)

    # Load the first version modules
    config["modules"].each{ |module_name, classes|
      load root_dir + "/" + config["versions"][0] + "/" + module_name
      classes.each{ |c|
        s = Generator.new(Object.const_get(c))
        s.test_class
      }
    }
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

    (Module.constants - constants).map { |sym| const_get sym }
  end
  class TestController
    #Stores the classes in the file and output directory
    #Creates the output directory if it doesn't exist
    def initialize(input_file, output_dir)
      @input_classes = SPLATS.load_class input_file
      @output_dir = output_dir
      if not File::directory?(output_dir)
        Dir.mkdir(output_dir)
      end
    end
    
    # Creates tests for a class by generating and traversing the tree
    # Then generating the code from the abstract syntax
    def single_class_test(testing_class)
      cur_testing_class = Generator.new(testing_class)
      test_counter = 0
      cur_testing_class.test_class { |test, result|
        test_printer = SPLATS::TestPrinter.new(test, result)
        write(test_printer.print, testing_class ,test_counter)
        test_counter += 1
      }
    end
    
    # Creates tests for every class in @input_classes 
    def multi_class_test 
      @input_classes.each do |cla|
      single_class_test(cla)
      end
    end

    # Takes in the test to output, class being tested and test number
    # Writes to a file - ouput_directory/test_className01.rb     
    def write(test_as_string, cla, id)
      File.open("#{@output_dir}test_#{cla}#{id}.rb", "w") do |x|
        x.puts test_as_string
      end
    end
  end

end
