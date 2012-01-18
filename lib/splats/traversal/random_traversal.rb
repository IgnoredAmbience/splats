module SPLATS
  # This class is responsible for randomly traversing
  #
  # Includes the Traversal abstract class, see there for interface documentation
  class RandomTraversal
    include Traversal
 
    # @param [Integer] seed The seed to use for test generation
    def initialize seed=nil
      if seed
        @rng = Random.new seed
      else
        @rng = Random.new
      end
    end

    # @return [Integer] The seed used for this traversal object
    def seed
      @rng.seed
    end

    def select_method methods
      methods[@rng.rand(methods.length)]
    end

    def select_arguments arguments
      arguments[@rng.rand(arguments.length)]
    end

    def generate_value type
      decisions = generate_values type
      decisions[@rng.rand(decisions.length)]
    end

    def continue_descent?
      @rng.rand(2) == 0
    end

    def continue_generation?
      @rng.rand(10) != 0
    end
  end
end
