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

  options[:outdir] = "tests"
  opts.on("--output-directory DIR", "-o", "Output directory (defaults to \"tests\")") do |dir|
    options[:outdir] = dir
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
	controller = SPLATS::TestController.new(options[:file],options[:outdir])
rescue LoadError
	puts "File doesn't exist"
	exit
end

controller.test_classes
