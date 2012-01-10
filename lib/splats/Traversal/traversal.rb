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
    # @param [String] the method we are picking arguments for
    # @param [Array<Array>] arguments Array of viable argument sets for the
    #   previously returned method
    # @return [Array] The selected argument set
    def select_arguments(method, arguments)
      raise NotImplementedError
    end

    # Given a type, return a value of that type
    # This function could always return nil as a valid return value
    # This function could raise a NoMethodError, if the method is decided not to
    # exist
    # By default this returns the first element of generate_values, as raising a
    #   NotImplementedError would erroneously carry through to the executing
    #   method.
    #
    # @param [Symbol] type The symbol of the class of the type of value we wish
    #   to generate
    # @return [Object] The selected decision
    # @raise NoMethodError
    def generate_value type
      generate_values(type)[0]
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
    # @param [Exception] exception The exception that was raised
    def notify_exception_raised exception
    end

    # Given a type (inclusive of :Bool), return a default list of values to try
    #   for that type.
    #
    # @param [Symbol] type The symbol of the class of types to return.
    # @return [Array] An array containing elements of that type.
    def generate_values type
      values = [nil]
      case type
      when :Bool
        values + [true, false]
      when :Integer
        values + [0, 1, -1]
      when :Float
        values + [0.0, 1.1, -1.1]
      when :String
        values + ["", "string"]
      when :Symbol
        values + [:Symbol]
      when :Array
        values + [[]]
      when :Hash
        values + [{}]
      end
    end
  end
end
