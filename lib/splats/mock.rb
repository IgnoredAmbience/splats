# SPLATS - SpLATS Lazy Automated Testing System
module SPLATS
  # Mock object to be passed into methods as an unknown parameter
  # Inherit from BasicObject so we can have as empty a class as possible <br>
  # Note: This means that the Kernel module is not included, so you need to
  # explicitly state Kernel for any builtin functions!
  class Mock < BasicObject
    # Rebind all defaulted methods to run via method_missing
    (instance_methods - instance_methods(false) - [:__send__]).each do |method|
      define_method(method) do |*args, &block|
        __send__(:method_missing, method, *args, &block)
      end
    end

    @@id = 0

    def initialize &branch_block
      @object = MockImplementation.new self
      @child_objects = []
      @id = @@id
      @@id += 1

      # This may turn out to be a horrific idea
      @branch_block = branch_block
    end

    # Prints information about the failed method call
    def method_missing(symbol, *args, &block)
      #::Kernel.puts "Method '#{symbol}' called with arguments #{args} on mock ##{@id}"
      if @object.__SPLATS_orig_respond_to? symbol
        result = @object.__SPLATS_orig_send(symbol, *args, &block)
      else
        result = Mock.new &@branch_block
        @child_objects << [symbol, result]
      end
      result
    end

    # Predicate to test if an object is mock 
    # @return true
    def __SPLATS_is_mock?
      true
    end

    # Adds branches to the tree based on varying results of operations
    def __SPLATS_branch method, branches
      @branch_block.call branches
    end

    def __SPLATS_print
      puts "Mock #'#{@id} had #{child_objects.length} methods called on it. List names?>'"
    end
  end

  class MockImplementation < Object
    (instance_methods - instance_methods(false)).each do |method|
      alias_method ("__SPLATS_orig_" + method.to_s).to_sym, method
      private method
    end

    def initialize mock
      @mock = mock
    end

    def to_s
      inspect
    end

    def inspect
      "<Mock Object>"
    end

    def to_r
      0
    end

    # This is called when a Ruby object tries to perform an arithemetical operation on a mock
    def coerce x
      # Adding branches to the tree with different outcomes of the value of the operation
      item = @mock.__SPLATS_branch :coerce, [0, 1, -1]
      [x, item]
    end

    def to_str
      ""
    end

    def to_ary
      []
    end
  end
end

# These classes adds to Object our own functions for dealing with mock objects
class BasicObject
  def __SPLATS_is_mock?
    false
  end
end
