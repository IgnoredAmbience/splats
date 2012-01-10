require '/home/caz/Uni/splats/lib/splats/Traversal/decisions.rb'

module SPLATS
  
  # This class is responsible for when a human wants to traverse
  class HumanTraversal
    include Traversal
    
    def initialize(fiber)
      p "init"
      # gc initially stood for gui_controller...
      @gc = fiber
      @init = false
    end

    # There is code duplication because I believe these methods will all be slightly different
    def select_method methods
      p "select method"
      # If it's the initialiser just return
      if not @init
        @init = true
        methods[0]
      else
        # If not being controlled through the GUI
        if @gc.nil?
          begin
            puts "Choose method (1-indexed): (methods: #{methods.inspect})"
            index = gets.to_i
          end while (index < 1 || index > methods.length)
          methods[index-1]
        else
          # Send the GUI controller the options back
          @gc.transfer MethodDecision.new(methods)
        end
      end
    end

    def select_arguments(method, arguments)
      p "select arg"
      if @gc.nil?
        begin
          puts "Choose argument (1-indexed): (arguments: #{arguments.inspect})"
          index = gets.to_i
        end while (index < 1 || index > arguments.length)
        arguments[index-1]
      else
        @gc.transfer ArgumentDecision.new(method, arguments)
      end
    end

    def generate_value type
      p "gen value"
      decisions = generate_values type

      if @gc.nil?
        begin
          puts "Choose decision (1-indexed): (decisions: #{decisions})"
          index = gets.to_i
        end while (index < 1 || index > decisions.length)
        decisions[index-1]
      else
        @gc.transfer ValueDecision.new(decisions, caller[2].split(':')[1])
      end
    end

    def continue_descent?
      p "cont desc"
      if @gc.nil?
        begin puts "Continue with descent? (Y or N)"
          # 'gets' includes the newline, so need chomp to prevent the include? from returning false
          decision = gets.chomp
        end while (not (["Y", "y", "N", "n"].include? decision))
        decision == 'Y' || decision == 'y'
      else
          @gc.transfer DescentDecision.new
      end
    end

    def continue_generation?
      p "cont gen"
      # Put init back to false
      @init = false
      unless @firstrun
        @firstrun = true
      else
        if @gc.nil?
          begin puts "Continue with generation? (Y or N)"
            # 'gets' includes the newline, so need chomp to prevent the include? from returning false
            decision = gets.chomp
          end while (not (["Y", "y", "N", "n"].include? decision))
          decision == 'Y' || decision == 'y'
        else
          @gc.transfer GenerationDecision.new
        end
      end
    end
    
    def notify_exception_raised exception_raised
      puts exception_raised
    end
  end
end
