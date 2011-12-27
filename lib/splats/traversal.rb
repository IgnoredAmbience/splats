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

    # Given a type, return a value of that type
    # This function could always return nil as a valid return value
    # This function could raise a NoMethodError, if the method is decided not to
    # exist
    #
    # @param [Symbol] type The symbol of the class of the type of value we wish
    #   to generate
    # @return [Object] The selected decision
    # @raise NoMethodError
    def generate_value type
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
