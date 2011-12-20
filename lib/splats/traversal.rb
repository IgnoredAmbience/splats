module SPLATS
  # @abstract Include this module and implement all methods
  module Traversal
    # Select a method from a given array of methods
    # @param [Array<Method,Symbol>] methods Array of viable method calls
    # @return [Method,Symbol] The selected method
    def select_method methods
      raise NotImplementedError
    end

    # Select an argument set from a given array of argument sets
    # @param [Array<Array>] arguments Array of viable argument sets for the
    #   previously returned method
    # @return [Array] The selected argument set
    def select_arguments arguments
      raise NotImplementedError
    end

    # Select a decision from a given array of decisions. A decision is a value
    # that should be returned when a concrete cast is called.
    # TODO: Check that this is our intended input type
    #
    # @param [Array<Object>] decisions
    # @return [Object] The selected decision
    def select_decision decisions
      raise NotImplementedError
    end

    # @return [Boolean] Returns true if we should continue building the test
    def continue_descent?
      raise NotImplementedError
    end

    # @return [Boolean] Returns true if we should generate another test
    def continue_generation?
      raise NotImplementedError
    end

    # Called to notify the traverser that a new traversal is being begun
    # TODO: Consider extension to return name of test
    def notify_new_traversal
    end

    # Called to notify the traverser that an exception has arisen during
    # execution, and that no further progress can be made on this branch
    def notify_exception_raised
    end
  end
end
