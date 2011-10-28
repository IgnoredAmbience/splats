require "yaml"
root_dir = "/homes/cg408/Group/splats/lib/splats/"
config = YAML.load_file(root_dir + "config.yml")
test_structure = []

# Grab the names of the modules to test
config["modules"].each{ |module_name|
  # Load each module
  load root_dir + version + "/" + cl
  puts module_name
}

=begin
# Loop through each version defined in the config file
config.each { |module_name,classes|
  # Caluclate the current module constants
  constants = Module.constants

  # Loop through each class defined in the config
  classes.each { |cl|
    # Load the module
    load root_dir + version + "/" + cl
    i = 0
    # Loop through each loaded class and populate the test structure
    (Module.constants - constants).each{ |module_name|
      puts Kernel.const_get(module_name).instance_methods(false)
    }
  }
}
=end
