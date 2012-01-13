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
    @page = 1
    @traversal_methods = Hash[:depth => "Depth-Limited", :human => "Manual", :random => "Random"]
    @selected_radio = nil
    @file_array = [1,2,3]
    
    #TODO Put this in a config file
    # Defaults
    @version1 = @version2 = ""
    @output_dir = 'tests'
    @traversal_method = :human
    @depth = 2
    @seed = 0
    @path_tracker = []
    
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
        if @seed == "0" || @seed == 0
          return true
        end
        # If clearly not an integer, display falsity
        if @seed.to_i == 0
          @option_area.clear do
            display_seed_box true
          end
          return false
        end
    end
    true
  end
  
  def start_tests
    case @traversal_method
    when :human
      f = nil
      @depth = 1
      
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
      traversal = SPLATS::GUITraversal.new(@display)
      
      # Wrap the test controller in a fiber, passing the GUI fiber in
      # This determines the value of selection
      f = Fiber.new do |input|
        controller = SPLATS::TestController.new(@version1, @version2, @output_dir, traversal)
        controller.test_classes
      end
      
      # Call display
      @display.transfer true
      
      # Check we can continue
      check_controller_error
      
      # Display the selections to user
      draw_selections
    when :depth
      traversal = SPLATS::DepthLimitedTraversal.new(@depth.to_i)
      controller = SPLATS::TestController.new(@version1, @version2, @output_dir, traversal)
      controller.test_classes
      alert("Test generation complete")
    when :random
      traversal = SPLATS::RandomTraversal.new(@seed.to_i)
      controller = SPLATS::TestController.new(@version1, @version2, @output_dir, traversal)
      controller.test_classes
      alert("Test complete with seed #{traversal.seed}")
    end
  end
end

def draw_selections
  # Draw a graph if requested
  if @decision.display_graph
    # If depth is 1, add :new to the path track
    if @depth == 1
      @path_tracker = []
      add_decision_to_path_tracker "new"
    end
    # First push the options to the execution tracker
    add_options_to_path_tracker @decision.options
    draw_graph
    display_graph
  end
  
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
          # Format the choice with final answer
          fa = @decision.final_answer o
          
          # If the object wants the method to change, change it to the final answer
          if @decision.change_method?
            @method = fa
          end
          
          # If the decision was graphable, add the information to a tracker
          if @decision.display_graph
            add_decision_to_path_tracker fa
          end
          
          # Update the depth on the decision
          @depth = @decision.update_depth

          # This call will update the @choice and @decision variables
          @display.transfer (fa)
          
          # Once the decision has been updated
          if @decision.continue?
            # Refresh the screen
            draw_selections
          else
            alert("Testing complete")
            exit
          end
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
  end
end

# Everything crashes with the decisions, to need to pass through
# an additional function to add to the path tracker
def add_decision_to_path_tracker decision
  @path_tracker.push decision.inspect
end

# Because everything crashes when trying to read a decision array,
# have to pass it through here
def add_options_to_path_tracker options
  temp = []
  options.each do |o|
    temp.push (o.inspect)
  end
  @path_tracker.push temp
end

def draw_graph
  path_tracker = @path_tracker
  outside_depth = @depth
  
  # Generate and save the graph
  digraph do
    depth = 1
        
    path_tracker.each_with_index do |n, index|
      # If node is an array then it's a set of decisions
      if n.is_a? Array
        # If the graph has just been initialized
        if @graph_init
          @graph_init = false
          # Set the previous node
          previous_node = [(index-1), depth].join("_")
        else
          # Find the index of the previous node
          if path_tracker[index-1] == "\"nil\""
            p path_tracker[index-2]
            to_look_for = "nil"
          else
            to_look_for = path_tracker[index-1]
          end
          pni = (path_tracker[index-2]).index to_look_for
          previous_node = [(index-2), (depth-1), pni].join("_")
        end
        
        # Loop through all possible decisions and create a node for them
        n.each_with_index do |decision, ii|
          node_name = [index, depth, ii].join("_")
          node(node_name, decision)
          edge previous_node, node_name
        end
        
        # If currently on the last choices, make the previous green
        if index == path_tracker.length - 1
          node(previous_node).attributes << filled
          node(previous_node).attributes << green
        end

      # Otherwise it's a choice
      else
        # Only care about the initialize method in the choice
        # If it's the initialize method, reset depth to 1
        if n == "new".inspect
          depth = 1
          node_name = [index.to_s, depth.to_s].join("_")
          node(node_name, "initialize")
          @graph_init = true
        else
          depth += 1
        end
      end
    end
    save "graph", "png"
  end
end

# This method requires passing variables between blocks, so there are a few assignment swaps...
def display_graph
  filename = "graph.png"
  # Generate the graph
  if not @graph
    graph = graph_image = nil
    @graph_window = window :title => "Progress graph" do
      @graph = stack do
        @graph_image = image(filename)
      end
      graph = @graph
      graph_image = @graph_image
    end
    @graph = graph
    @graph_image = graph_image
  else
    @graph.app do
      @graph_image.clear
      @graph_image = image(filename)
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
