require 'optparse'

#options parsed so far
options = {}

# This optparse library appears to be pretty damn cool
# Using puts on the opts object (the parameter in the new block for OptionParser)
#   prints out the long & short versions of a flag as well as a description of its purpose

OptionParser.new do |opts|

#  This is the general shape of a flag option
#  opts.on("--some-flag", "-s", "Flag description") do |flag|
#    options[:flagName] = flag
#    puts flag
#  end

  opts.on("--help", "-h", "Display help screen") do |flag|
    puts opts
    exit
  end



# end.parse! is doable because OptionParse.new return itself if passed a block
end.parse!
