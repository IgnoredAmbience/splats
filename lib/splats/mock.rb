module SPLATS
  # Mock object to be passed into methods as an unknown parameter
  #
  # Inherit from BasicObject so we can have as empty a class as possible
  #
  # @note The Kernel module is not included, you need to
  #   explicitly use ::Kernel for to access builtin methods!
  class Mock < BasicObject
    # Rebind all defaulted methods to run via method_missing
    (instance_methods - instance_methods(false) - [:__send__]).each do |method|
      define_method(method) do |*args, &block|
        __send__(:method_missing, method, *args, &block)
      end
    end

    # Global mock identifier counter, for use in output and dependency tracking
    @@id = 0

    # @param [Integer] depth Depth at which Mock objects will no longer spawn
    #   new Mock objects
    # @param [Proc] &branch_block Block which will be yielded to when a value
    #   generation is required. Yields the type as a symbol. (See
    #   Traversal#generate_value)
    def initialize depth=5, &branch_block
      @object = MockImplementation.new self
      @depth = depth
      @child_objects = []
      @id = @@id
      @@id += 1

      # This may turn out to be a horrific idea
      @branch_block = branch_block
    end

    # The catch-all magical method.
    #
    # Tracks all method calls upon the Mock object, does some inference of type
    # by inspecting the method name - reqests a value for that type from the
    # generator, or spawns a new Mock object.
    #
    # @param [Symbol] symbol The symbol for the method called
    # @param args The arguments the method was called with
    # @see BasicObject#method_missing
    def method_missing(symbol, *args, &block)
      if RETURN_TYPES.include? symbol
        result = @branch_block.call RETURN_TYPES[symbol]
      elsif symbol[-1] == '?'
        result = @branch_block.call :Bool
      elsif @object.__SPLATS_orig_respond_to? symbol
        result = @object.__SPLATS_orig_send(symbol, *args, &block)
      else
        if @depth > 0
          result = @branch_block.call :Unknown
          if result == Mock
            result = Mock.new(@depth-1, &@branch_block)
          end
        else
          result = nil
        end
      end
      @child_objects << ([symbol, result, args])
      #::Kernel.puts "?> Method '#{symbol}' called with arguments #{args} on #{__SPLATS_print} returns #{result.__SPLATS_print}"
      result
    end
    
    # Predicate to test if an object is mock 
    # @return true
    def __SPLATS_is_mock?
      true
    end

    # Calls the block provided on construction to retrieve a value for a given
    # type
    #
    # @param [Symbol] type The 'type' (usually Class) of the value to be
    #   generated
    # @see Traversal#generate_value
    def __SPLATS_branch type
      @branch_block.call type
    end

    # The unique id of this Mock object
    # @return [Integer]
    def __SPLATS_id
      @id
    end

    # A printable representation of this Mock object, mostly intended as a
    # variable name
    # @return [String]
    def __SPLATS_print
      "mock#{@id}"
    end

    # Recursively returns the 'tree-of-Mock' data structure using this Mock
    # object as the root
    #
    # @return [<(Mock, <(Symbol, Object[, Object...])>)>] A list of pairs of Mock
    #   object and list of spawned children.
    #   List of spawned children contains method call, returned object and an
    #   (optional) list of parameters passed to the method.
    def __SPLATS_child_objects
      [[self, @child_objects]] + @child_objects.select{|o| o[1].__SPLATS_is_mock?}
                                      .flat_map{|m| m[1].__SPLATS_child_objects}
    end
  end

  # Used for any other non-trivial, but well-defined ruby 'interfaces' such as
  # coerce.
  #
  # This is split out for use in a proxy-fashion as the ruby interpreter likes
  # to call private methods withoug going via method_missing
  class MockImplementation < Object
    # Move all instance methods into the our own namespace
    (instance_methods - instance_methods(false)).each do |method|
      alias_method ("__SPLATS_orig_" + method.to_s).to_sym, method
      private method
    end

    # @param [Mock] mock The Mock that constructs this MockImplementation
    def initialize mock
      @mock = mock
    end

    # This is called when a Ruby object tries to perform an arithemetical
    # operation on a mock
    # Calls to generate a value of the same type as x
    #
    # @return [(X, X)] An array of the parameter x, and a generated value of
    #   the same class as x
    def coerce x
      # Adding branches to the tree with different outcomes of the value of the operation
      item = @mock.__SPLATS_branch x.class.to_s.to_sym
      [x, item]
    end
  end
end

# Add our own methods to BasicObject for dealing with mock objects
class BasicObject
  # Returns whether the object is a mock object
  # @return [false]
  def __SPLATS_is_mock?
    false
  end

  # Inspect command under our namespace, for use with debugging
  #
  # @return [String]
  def __SPLATS_print
    inspect
  end
end
