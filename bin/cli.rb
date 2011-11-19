require 'optparse'
require_relative '../lib/splats.rb'

#options parsed so far
options = {}

# Using puts on the opts object (the parameter in the new block for OptionParser)
#   prints out the long & short versions of a flag as well as a description of its purpose

optparse = OptionParser.new do |opts|

  opts.banner = "Usage: cli.rb [options]"

  opts.on("--help", "-h", "Display help screen") do
    puts opts
    exit
  end

  options[:list] = nil
  opts.on("--object-from-file FILES", "-f", Array, "Test classes from files. File & class must share names") do |files|
    options[:list] = files
  end

  options[:config] = nil
  opts.on("--config FILE", "-c", "Configuration file") do |file|
    options[:config] = file
  end

  options[:outdir] = nil
  opts.on("--output-directory DIR", "-o", "Output directory (defaults to \"tests\")") do |dir|
    options[:outdir] = dir
  end

end


begin
  optparse.parse!

  # TODO: Other things may want to go here, eg, if config, assume outdir specified there?
  if !(options[:list].nil? ^ options[:config].nil?)
    puts optparse
    exit
  end
rescue OptionParser::InvalidOption,OptionParser::MissingArgument
  puts optparse
  exit
end

if (!options[:list].nil?)
  SPLATS.load_classes(options[:config])
elsif (!options[:config].nil?)
  SPLATS.load_config(options[:config])
end
