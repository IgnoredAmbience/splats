require 'optparse'
require_relative '../lib/splats.rb'


#options parsed so far
options = {}

# This optparse library appears to be pretty damn cool
# Using puts on the opts object (the parameter in the new block for OptionParser)
#   prints out the long & short versions of a flag as well as a description of its purpose

OptionParser.new do |opts|

  #  This is the general shape of a flag option
  #  opts.on("--some-flag", "-s", "Flag description") do |flag|
  #    options[:flagName] = flag
  #  end

  opts.on("--help", "-h", "Display help screen") do |flag|
    puts opts
    exit
  end

  # Apparently I need to put FILE in CAPS to tell
  # optparser that this flag expects an argument
  opts.on("--object-from-file FILE", "-f", "Test class from file. File & class must share names") do |flag|

    if (not (require_relative flag)) #try to load the passed in file
      puts "Failed to load #{flag}"
      exit
    end

    # strip out absolute file name (i.e. the class name) & pass this class off to the tester
    # Kernel.const_get gives the class with the name as the flag
    flagAsSymbol = File.basename(flag,'.rb').to_s # .rb parameter lops .rb off the end
    flagAsClass = Kernel.const_get(flagAsSymbol)

    t = Splats::Core.new(flagAsClass)
    t.test_class

    exit
  end



  # end.parse! is doable because OptionParse.new return itself if passed a block
end.parse!
