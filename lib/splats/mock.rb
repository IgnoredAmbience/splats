# SPLATS - SpLATS Lazy Automated Testing System
module SPLATS
  # Mock object to be passed into methods as an unknown parameter
  # Inherit from BasicObject so we can have as empty a class as possible <br>
  # Note: This means that the Kernel module is not included, so you need to
  # explicity state Kernel for any builtin functions!
  class Mock < BasicObject
    # Prints information about the failed method call
    def method_missing(symbol, *args, &block)
      ::Kernel.puts "Method '#{symbol}' called with arguments #{args} and #{block.nil? && 'no' || 'a'} block"
      if symbol == :inspect
        "<Mock Object>"
      end
    end
  end
end
