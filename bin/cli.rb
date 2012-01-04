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

  options[:file] = nil
  opts.on("--object-from-file FILE", "-f", "Test classes from file. File & class must share names") do |file|
    options[:file] = file
  end

  options[:depth] = nil
  opts.on("--depth", "-d", "Search space depth for depth-limited traversal (defaults to 3)") do |depth|
    options[:depth] = depth
  end

  options[:outdir] = nil
  opts.on("--output-directory DIR", "-o", "Output directory (defaults to \"tests\")") do |dir|
    options[:outdir] = dir
  end
  
  options[:seed] = nil
  opts.on("--seed", "-s", "Seed for random traversal. Defaults to 0") do |seed|
    options[:seed] = seed
  end

  options[:traversal] = nil
  opts.on("--traversal-method", "-t", "Tree traversal method. 0: Depth Limited, 1: Human, 2: Random") do |trav|
    options[:traversal] = trav
  end
  
end


begin
  optparse.parse!

  # TODO: Other things may want to go here, eg, if config, assume outdir specified there?
  if options[:file].nil?
    puts optparse
    exit
  end
rescue OptionParser::InvalidOption,OptionParser::MissingArgument
  puts optparse
  exit
end

begin
  controller = SPLATS::TestController.new(options[:file],options[:outdir],options[:depth], options[:seed], options[:traversal])
rescue LoadError
  puts "File doesn't exist"
  exit
end

controller.test_classes
