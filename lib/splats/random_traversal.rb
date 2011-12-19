module SPLATS
  # This class is responsible for randomly traversing
  class RandomTraversal
    include Traversal
    # If there's already a seed in use, then initialise the RNG with the seed
    # Also keeps an eye on the seed, for possibly returning it in the future
    def initialize seed=nil
      # I think I'm failing to understand properly how this works, but it seems the only way to get guaranteed results is to run the srand twice and store that number
      if seed
        srand(seed)
        @rand = srand(seed)
      else
        @rand = srand()
      end
    end

    # This is passed a list of methods - will return a randomly selected index
    def select_method methods
      methods[rand(methods.length)]
    end

    def select_arguments arguments
      arguments[rand(arguments.length)]
    end

    def select_decision decisions
      decisions[rand(decisions.length)]
    end

    def continue_descent?
      rand(2) == 0 ? false : true
    end
  end
end
