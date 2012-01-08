require '../splats.rb'
require 'green_shoes'
require 'graph'
require 'fiber'
require './gui_elements.rb'

class NilClass
  def to_s
    "nil"
  end
end

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
    @version1 = '../../samples/LinkedList.rb'
    @version2 = '../../samples/version2/LinkedList.rb'
    @output_dir = 'tests'
    @traversal_method = :depth
    @depth = 2
    @seed = 0
    
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
      # Keeps ticking to ensure the logo stays in the bottom right corner
      @logo = image("fly.png").move (width - 100), (height - 100)
      every(1) do
        unless height == @height
          @logo.clear
          @logo = image("fly.png").move (width - 100), (height - 100)
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
          false
        elsif @depth.to_i == 0
          @option_area.clear do
            display_depth_box true
          end
          false
        else
          @depth = @depth.to_i
          true
        end
      when :random
        # Seed as 0 is perfectly acceptable
        if not @seed == "0" && @seed.to_i == 0
          @option_area.clear do
            display_seed_box true
          end
          false
        else
          true
        end
      else
        true
    end
  end
  
  def start_tests
    if @traversal_method == :human
      f = nil
      @depth = 1
      # Cheeky Fiber stuff - create a dummy fiber to allow the
      # transfer methods to work, but keep returning control to
      # this main thread
      @display = Fiber.new do |input|
        while input
          @selection = f.transfer @choice
          @choice = Fiber.yield @selection
        end
      end
      
      # Wrap the test controller in a fiber, passing the GUI fiber in
      # This determines the value of selection
      f = Fiber.new do |input|
        controller = SPLATS::TestController.new(@version1, @output_dir, @depth, @seed, @traversal_method, @display)
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

def text_display selection
  if @selection["type"] == :y_or_n
    para @selection["question"]
    @selection["options"] = @y_or_n.keys
    # Make method 'nil' as we've moved on, and depth 1 again
    @method = nil
    @depth = 1
  else
    if @selection["type"] == "arguments"
      @method ||= "initialise"
      flow do
        para "Current method:", :width => 300
        para strong @method
      end
    elsif @selection["type"] == "method"
      @depth += 1
      para "Select next method to test (current depth)"
    elsif @selection["type"] == "decision"
      para "Choose decision for type on line number " + @selection["line_number"]
    end
  end
end

def draw_selections
  @main.clear do
    # Present the question/information to the user
    text_display @selection
    
    # Run through all the options to generate buttons for the user to click
    flow do
      @selection["options"].each do |o|
        l = label_selection o
        
        # If the o is a 'new' method, don't display the button either and carry on
        button l do
          if @selection["type"] == "method"
            @method = o            
          end
          if @y_or_n.keys.include? o
            @display.transfer @y_or_n[o]
          else
            @display.transfer o
          end
          # Refresh the screen
          draw_selections
        end
      end
    end
    if @selection["type"] == "decision"
      read_with_line_numbers
    end
    display_graph
  end
end

def display_graph
  image("graph.png")
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
