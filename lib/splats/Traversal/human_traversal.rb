module SPLATS
  # This class is responsible for when a human wants to traverse by hand
  #
  # Each method is simply a call out to the console to request an option be
  # entered
  #
  # Includes the Traversal abstract class, see there for interface documentation
  class HumanTraversal
    include Traversal

    # There is code duplication because I believe these methods will all be slightly different

    # @see Traversal#select_method
    def select_method methods
      begin
        puts "Choose method (1-indexed): (methods: #{methods.inspect})"
        index = gets.to_i
      end while (index < 1 || index > methods.length)
      methods[index-1]
    end

    # @see Traversal#select_arguments
    def select_arguments arguments
      begin
        puts "Choose argument (1-indexed): (arguments: #{arguments.inspect})"
        index = gets.to_i
      end while (index < 1 || index > arguments.length)
      arguments[index-1]
    end

    # @see Traversal#generate_value
    def generate_value type
      begin
        decisions = generate_values type
        puts "Choose decision (1-indexed): (decisions: #{decisions})"
        index = gets.to_i
      end while (index < 1 || index > decisions.length)
      decisions[index-1]
    end

    # @see Traversal#continue_descent?
    def continue_descent?
      begin puts "Continue with descent? (Y or N)"
        # 'gets' includes the newline, so need chomp to prevent the include? from returning false
        decision = gets.chomp
      end while (not (["Y", "y", "N", "n"].include? decision))
      decision == 'Y' || decision == 'y'
    end

    # @see Traversal#continue_generation?
    def continue_generation?
      unless @firstrun
        @firstrun = true
      else
        begin puts "Continue with generation? (Y or N)"
          # 'gets' includes the newline, so need chomp to prevent the include? from returning false
          decision = gets.chomp
        end while (not (["Y", "y", "N", "n"].include? decision))
        decision == 'Y' || decision == 'y'
      end
    end
  end
end

