module SPLATS
  # This class is responsible for randomly traversing
  class RandomTraversal
    include Traversal
    # If there's already a seed in use, then initialise the RNG with the seed
    # Also keeps an eye on the seed, for possibly returning it in the future
    def initialize seed=nil
      if seed
        @rng = Random.new seed
      else
        @rng = Random.new
      end
    end

    def seed
      @rng.seed
    end

    # This is passed a list of methods - will return a randomly selected item
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
