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

  options[:outdir] = [false,false, :notgiven] # -o , -O, directory
  opts.on("--output-directory DIR", "-o", "Output directory (defaults to \"tests/\") Fails if directory already exists") do |dir|
    options[:outdir][0] = true 
    options[:outdir][2] = dir
  end
  
  opts.on("--output-directory-force DIR", "-O", "Output directory (defaults to \"tests/\") May overwrite if directory already exists") do |dir|
    options[:outdir][1] = true 
    options[:outdir][2] = dir
  end
  
  options[:depth] = [false, nil]
  opts.on("--depth [DEP]", "-d", "Use depth limited traversal with search space provided depth DEP (default 3)") do |depth|
    options[:depth] = [true, depth]
  end 
  
  options[:random] = [false, nil]
  opts.on("--random [SEED]", "-r", "Use random traversal with provided SEED (default 0)") do |seed|
    options[:random] = [true, seed]
  end
  
  options[:manual] = [false]
  opts.on("--manual", "-m", "Use manual traversal") do |seed|
    options[:manual] = [true]
  end

  options[:generate] = false
  opts.on("--generate", "-G", "Generate a set of tests for the given file") do |gen|
    options[:generate] = true
  end
  
  options[:compare] = false
  opts.on("--compare", "-C", "Generate a set of tests based on the first file, and then run those tests on the second file") do |comp|
    options[:compare] = true
  end

  options[:comparee] = nil
  opts.on("--comparee-object-from-file FILE", "-g", "Second test classes from file. File & class must share names") do |file|
    options[:comparee] = file
  end
end


begin
  optparse.parse!

  # TODO: Other things may want to go here, eg, if config, assume outdir specified there?
  # TODO: Check not multiple traversals
  if options[:file].nil?
    puts "Error: No file provided"
    puts
    puts optparse
    exit
  end  
  
  if [options[:manual][0], options[:random][0], options[:depth][0]].count(true) > 1
    puts "Error: Maximum of one traversal method"
    puts 
    puts optparse
    exit
  end
  
  if options[:outdir][0] and options[:outdir][1]
    puts "Error: Use -o OR -O, not both"
    puts
    puts optparse
    exit
  end 
  if options[:outdir][0] and (File::directory?(options[:outdir][2]) or # If directory exists
    (options[:outdir][2] == :notgiven and File::directory?("tests/")) ) # If default directory exists
    puts "Error: Directory already exists, use -O to risk overwriting"
    puts 
    puts optparse
    exit
  end

  if options[:generate] == options[:compare]
    puts "Error: You must either be comparing two outputs, or generating an output. You cannot do both"
    puts
    puts optparse
  end

  if options[:compare] and options[:comparee].nil?
    puts "Error: You have requested that a comparison be done without specifying two files"
    puts
    puts optparse
  end

rescue OptionParser::InvalidOption,OptionParser::MissingArgument => e
  puts "Error: #{e}"
  puts 
  puts optparse
  exit
end

begin
  if options[:manual][0]
    traversal_object = SPLATS::HumanTraversal.new()
  elsif options[:random][0] 
    traversal = :random
    if options[:random][1].nil?
      seed = 0
    else 
      seed = options[:random][1].to_i
    end    
    traversal_object = SPLATS::RandomTraversal.new(seed)
    
  else #depth limited default
    traversal = :depth
    if options[:depth][1].nil?
      depth = 3
    else
      depth = options[:depth][1].to_i
    end    
    traversal_object = SPLATS::DepthLimitedTraversal.new(depth)
  end
  
  controller = SPLATS::TestController.new(options[:file], options[:comparee],options[:outdir][2], traversal_object)
rescue LoadError
  puts "#{$!} doesn't exist"
  exit
end

controller.test_classes
