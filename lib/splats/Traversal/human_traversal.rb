module SPLATS
  # This class is responsible for when a human wants to traverse by hand
  #
  # Each method is simply a call out to the console to request an option be
  # entered
  #
  # Includes the Traversal abstract class, see there for interface documentation
  class HumanTraversal
    include Traversal
    
    def initialize
      @init = true
    end

    # Continually asks the user to pick a number in the range of the options
    # @param [String] type The type of the decision the user must make
    # @param [Array] options The options to present the user
    def ask_input_options(type, options)
      begin
        puts "Choose #{type} (1-indexed) : #{options.inspect}"
        index = gets.to_i
      end while (index < 1 || index > options.length)
      options[index-1]
    end

    # Continually asks the user until they put in y, Y, n or N
    # @param [String] question The question the user must answer yes or no to
    def ask_input_yes_no question
      begin
        puts "#{question} (Y or N)"
        # 'gets' includes the newline, so need chomp to prevent the include? from returning false
        decision = gets.chomp
      end while (not (["Y", "y", "N", "n"].include? decision))
      decision == 'Y' || decision == 'y'
    end

    # @see Traversal#select_method
    def select_method methods
      if @init
        @current_method = methods[0]
        @init = false
        return @current_method
      end
      ask_input_options("method", methods)
    end

    # @see Traversal#select_arguments
    def select_arguments arguments
      ask_input_options("argument", arguments)
    end

    # @see Traversal#generate_value
    def generate_value type
      decisions = generate_values type
      ask_input_options("decision", decisions)
    end

    # @see Traversal#continue_descent?
    def continue_descent?
      ask_input_yes_no "Continue descent?"
    end

    # @see Traversal#continue_generation?
    def continue_generation?
      unless @firstrun
        @firstrun = true
      else
        @init = true
        ask_input_yes_no "Continue generation?"
      end
    end
  end
end

