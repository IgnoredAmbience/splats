# Will initialise the mock class based upon a config file
# Using yaml for config

require "yaml"
root_dir = "/homes/cg408/Group/splats/lib/splats/"
config = YAML.load_file(root_dir + "config.yml")

load root_dir + "core" + ".rb"

# Load the first version modules
config["modules"].each{ |module_name, classes|
  load root_dir + "/" + config["versions"][0] + "/" + module_name
  classes.each{ |c|
    s = SPLATS::Core.new(Object.const_get(c))
    s.test_class
  }
}
