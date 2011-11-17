# SPLATS - SpLATS Lazy Automated Testing System
module SPLATS
  # Mock object to be passed into methods as an unknown parameter
  # Inherit from BasicObject so we can have as empty a class as possible <br>
  # Note: This means that the Kernel module is not included, so you need to
  # explicity state Kernel for any builtin functions!
  class Mock < BasicObject
    # Rebind all inherited public methods to run via method_missing
    (instance_methods - instance_methods(false)).each do |method|
      private method
    end

    # Prints information about the failed method call
    def method_missing(symbol, *args, &block)
      ::Kernel.puts "Method '#{symbol}' called with arguments #{args} and #{block.nil? && 'no' || 'a'} block"
      if Mock.private_instance_methods.include?(symbol)
        __send__(symbol, *args, &block)
      else
        ::Kernel.puts "  No binding found"
        nil
      end
    end

    def __SPLATS_is_mock?
      true
    end

    private
    # Note the defaulted inclusion of [:==, :equal?, :!, :!=, :instance_eval,
    # :instance_exec, :__send__, :__id__, :initialize, :singleton_method_added,
    # :singleton_method_removed, :singleton_method_undefined]

    # We cannot evaluate an object to false, it just /isn't/ possible in ruby.
    # But we /can/ (re)define methods on nil!

    def inspect
      "<Mock Object>"
    end

    def to_r
      0
    end

    def coerce
      [args[0], to_r]
    end

    def to_str
      ""
    end

    def to_ary
      []
    end
  end
end
