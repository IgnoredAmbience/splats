# Mock object to be passed into methods as an unknown parameter
# Inherit from BasicObject so we can have as empty a class as possibly possible
#
# Note: This means that the Kernel module is not included, so you need to
# explicity state Kernel for any builtin functions!

module SPLATS
  class Mock < BasicObject
    def method_missing(symbol, *args, &block)
      ::Kernel.puts "Method '#{symbol}' called with arguments #{args} and #{block.nil? && 'no' || 'a'} block"
    end
  end
end
