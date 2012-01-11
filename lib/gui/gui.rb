require 'green_shoes'
require 'graph'
require 'fiber'
require_relative 'gui_elements.rb'
require_relative '../splats.rb'
require_relative 'gui_traversal.rb'

class SPLATSGUI < Shoes

  url '/', :setup
  
  # Setup the main application window
  def setup
    # Setup the look
    background wheat..peru, angle: 45
    # header
    tagline "SpLATS Lazy Automated Test System", :align => "center"
    
    # Initialise variables
    @y_or_n = Hash["Yes" => true, "No" => false]
    @page = 3
    @traversal_methods = Hash[:depth => "Depth-Limited", :human => "Manual", :random => "Random"]
    @selected_radio = nil
    
    #TODO Put this in a config file
    # Defaults
    @version1 = File.join(File.dirname(__FILE__), '../../samples/LinkedList.rb')
    @version2 = File.join(File.dirname(__FILE__), '../../samples/version2/LinkedList.rb')
    @output_dir = 'tests'
    @traversal_method = :human
    @depth = 2
    @seed = 0
    @file_array = [1,2,3]
    
    # Shoes height and width initialise - to keep an eye on them
    @height = height
    @width = width

    # Put in a dummy depth and seed
    @main = stack :margin => 10 do
    end
      
    next_page
  end
  
  def next_page
    @main.clear
    @main.append do
      logo_name = File.join(File.dirname(__FILE__), "fly.png")
      # Keeps ticking to ensure the logo stays in the bottom right corner
      @logo = image(logo_name).move (width - 100), (height - 100)
      every(1) do
        unless height == @height
          @logo.clear
          @logo = image(logo_name).move (width - 100), (height - 100)
        end
      end
      case @page
        when 1
          # Loads the version 1 variable with the file info
          ask_for_version "first"
        when 2
          # Loads the version 2 variable with the file info
          ask_for_version "second"
        when 3
          page_3
        else
          para "Nothing left to do!"
      end
    end
    # Increment the page
    @page += 1
  end
  
  def page_3
    display_traversal_buttons
    get_output_dir
    @output_display = flow do
      para "Current output directory:"
      para strong @output_dir
    end
    next_button true
  end
  
  # Checks that depth and seed are correct to continue
  def validate_user_input
    case @traversal_methods.invert[@list_box.text]
      when :depth
        if @depth == "0"
          @option_area.clear do
            display_depth_box "zero"
          end
          return false
        elsif @depth.to_i == 0
          @option_area.clear do
            display_depth_box true
          end
          return false
        else
          @depth = @depth.to_i
        end
      when :random
        # Seed as 0 is perfectly acceptable
        if not @seed == "0" && @seed.to_i == 0
          @option_area.clear do
            display_seed_box true
          end
          return false
        end
    end
    true
  end
  
  def start_tests
    if @traversal_method == :human
      f = nil
      @depth = 1
      @execution_path = []
      
      # Cheeky Fiber stuff - create a dummy fiber to allow the
      # transfer methods to work, but keep returning control to
      # this main thread
      @display = Fiber.new do |input|
        while input
          @decision = f.transfer @choice
          @choice = Fiber.yield @decision
        end
      end

      # Instantiate the GUI Traversal
      @traversal = SPLATS::GUITraversal.new @display
      
      # Wrap the test controller in a fiber, passing the GUI fiber in
      # This determines the value of selection
      f = Fiber.new do |input|
        controller = SPLATS::TestController.new(@version1, nil, @output_dir, @traversal)
        controller.test_classes
      end
      
      # Call display
      @display.transfer true
      
      # Check we can continue
      check_controller_error
      
      # Display the selections to user
      draw_selections
    else
      controller = SPLATS::TestController.new(@version1, @output_dir, @depth, @seed, @traversal_method, @display)
      controller.test_classes
    end
  end
end

def draw_selections
  @main.clear do
    # Set the current depth in the decision
    @decision.depth = @depth
    # Present the question to the user
    para @decision.get_question
    
    # Run through all the options to generate clickable buttons
    flow do
      @decision.options.each do |o|
        # Get label for the option
        l = label_selection o
        
        # Generate the button
        button l do
          # Decide whether or not to change the method
          if @decision.change_method?
            @method = o
          end
          # Update the depth
          @depth = @decision.update_depth
          # Send the user's answer back
          @display.transfer (@decision.final_answer o)
          # Refresh the screen
          draw_selections
        end
      end
    end
    
    # If the decision says to display a file, do so
    case @decision.display_file?
      when "line_number"
        display_file(@decision.line_number, nil)
      when "method"
        display_file(nil, @method)
    end
    
    # If the decision says to display a graph, do so
    if @decision.display_graph?
#      display_graph
    end
  end
end

# This method requires passing variables between blocks, so there are a few assignment swaps...
def display_graph
  # Generate the graph
  graph_png = @traversal.graph.save_graph
  if not @graph
    graph = graph_image = nil
    @graph_window = window :title => "Progress graph" do
      @graph = stack do
        @graph_image = image(graph_png)
      end
      graph = @graph
      graph_image = @graph_image
    end
    @graph = graph
    @graph_image = graph_image
  else
    @graph.app do
      @graph_image.clear
      @graph_image = image(graph_png)
    end
  end
end

def label_selection input
  if input.nil?
    return "nil"
  elsif input.is_a? Array
    if input.length == 0
      "No arguments"
    else
      input.inspect
    end
  else
    input.to_s
  end
end

def check_controller_error
  if @selection
    if @selection[0] == :error
      alert(@selection[1])
      #TODO don't terminate
      exit
    end
  end
end

@app = Shoes.app :title => "SpLATS", :width => 500
