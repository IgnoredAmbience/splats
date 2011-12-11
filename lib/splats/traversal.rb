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
    # There is code duplication because I believe these methods will all be slightly different
    def select_method methods
      begin
        puts "Choose method (1-indexed): (methods: #{methods.inspect})"
        index = gets.to_i
      end while (index < 1 || index > methods.length)
      index
    end
    def select_arguments arguments
      begin
        puts "Choose argument (1-indexed): (arguments: #{arguments.inspect})"
        index = gets.to_i
      end while (index < 1 || index > arguments.length)
      index
    end
    def select_decision decisions
      begin
        puts "Choose decision (1-indexed): (decisions: #{decisions.inspect})"
        index = gets.to_i
      end while (index < 1 || index > decisions.length)
      index
    end
    def continue_descent?
      begin puts "Continue with descent? (Y or N)"
        # 'gets' includes the newline, so need chomp to prevent the include? from returning false
        decision = gets.chomp
        puts ["Y", "y", "N", "n"].include? decision
      end while (not (["Y", "y", "N", "n"].include? decision))
      (decision == 'Y' || decision == 'y') ? true : false
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
