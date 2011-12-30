module SPLATS
  # This class is responsible for when a human wants to traverse
  class HumanTraversal
    include Traversal

    # There is code duplication because I believe these methods will all be slightly different
    def select_method methods
      begin
        puts "Choose method (1-indexed): (methods: #{methods.inspect})"
        index = gets.to_i
      end while (index < 1 || index > methods.length)
      methods[index-1]
    end

    def select_arguments arguments
      begin
        puts "Choose argument (1-indexed): (arguments: #{arguments.inspect})"
        index = gets.to_i
      end while (index < 1 || index > arguments.length)
      arguments[index-1]
    end

    def select_decision decisions
      begin
        puts "Choose decision (1-indexed): (decisions: #{decisions.inspect})"
        index = gets.to_i
      end while (index < 1 || index > decisions.length)
      decisions[index-1]
    end

    def continue_descent?
      begin puts "Continue with descent? (Y or N)"
        # 'gets' includes the newline, so need chomp to prevent the include? from returning false
        decision = gets.chomp
      end while (not (["Y", "y", "N", "n"].include? decision))
      decision == 'Y' || decision == 'y'
    end

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

