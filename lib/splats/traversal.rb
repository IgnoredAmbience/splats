# This module enforces an abstract pattern
module Traversal
  def select_method methods
    raise NotImplementedError
  end
  def select_argument arguments
    raise NotImplementedError
  end
  def select_decision decisions
    raise NotImplementedError
  end
  def continue_descent?
    raise NotImplementedError
  end
end

module SPLATS
  # This class is responsible for when a human wants to traverse
  class HumanTraversal
    extend Traversal
    def select_method methods
      begin
        puts "Choose method (1-indexed): (methods: #{methods.inspect})"
        index = gets.to_i
      end while (index < 1 || index > methods.length)
      index
    end
    def select_arguments arguments
      begin
        puts "Choose argument (1-indexed): (methods: #{methods.inspect})"
        index = gets.to_i
      end while (index < 1 || index > arguments.length)
      index
    end
  end

  # This class is responsible for randomly traversing
  class RandomTraversal
    extend Traversal
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
      rand(methods.length) 
    end
    def select_arguments arguments
      rand(arguments.length)
    end
  end
end
