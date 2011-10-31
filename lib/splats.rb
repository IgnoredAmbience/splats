# This is the class-loader for SpLATS
require_relative 'splats/core'
require_relative 'splats/mock'

module SPLATS
  def load_config(filename)
    require "yaml"
    config = YAML.load_file(filename)

    # Load the first version modules
    config["modules"].each{ |module_name, classes|
      load root_dir + "/" + config["versions"][0] + "/" + module_name
      classes.each{ |c|
        s = Core.new(Object.const_get(c))
        s.test_class
      }
    }
  end
end
