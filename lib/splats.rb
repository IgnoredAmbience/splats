# This is the class-loader for SpLATS
require_relative 'splats/class_test_generator'
require_relative 'splats/mock'

module SPLATS
  def self.load_config(filename)
    require "yaml"
    config = YAML.load_file(filename)

    # Load the first version modules
    config["modules"].each{ |module_name, classes|
      load root_dir + "/" + config["versions"][0] + "/" + module_name
      classes.each{ |c|
        s = ClassTestGenerator.new(Object.const_get(c))
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
end
