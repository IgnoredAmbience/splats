require '../splats.rb'
require 'green_shoes'
require 'graph'
require 'fiber'
require './gui_elements.rb'

class NilClass
  def to_s
    "Nil"
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
    @page = 1
    @traversal_methods = Hash[:depth => "Depth-Limited", :human => "Manual", :random => "Random"]
    @selected_radio = nil
    
    #TODO Put this in a config file
    # Defaults
    @file = '../../samples/LinkedList.rb'
    @output_dir = 'tests'
    @traversal_method = :depth
    @depth = "asd"
    @seed = "asd"

    # Put in a dummy depth and seed
    @main = stack :margin => 10 do
    end
    next_page
  end
  
  def next_page
    @main.clear
    @main.append do
      case @page
        when 1
          @version1 = ask_for_version "first"
        when 2
          @version2 = ask_for_version "second"
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
    next_button "validate_user_input"
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
    end
  end
  
  def start_tests
    if @traversal_method == :human
      f = nil
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
        controller = SPLATS::TestController.new(@file, @output_dir, @depth, @seed, @traversal_method, @display)
        controller.test_classes
      end
      
      # Call display
      @display.transfer true
      
      # Check we can continue
      check_controller_error
      
      # Display the selections to user
      draw_selections
    else
      controller = SPLATS::TestController.new(@file, @output_dir, @depth, @seed, @traversal_method, @display)
      controller.test_classes
    end
  end
end

def text_display selection
  if @selection["type"] == :y_or_n
    para @selection["question"]
    @selection["options"] = @y_or_n.keys
    # Make method 'nil' as we've moved on
    @method = nil
  else
    if @selection["type"] == "arguments"
      @method ||= "initialise"
      para "Current method:"
      para strong @method
    elsif @selection["type"] == "method"
      para "Select next method to test:"
    end
  end
end

def draw_selections
  @main.clear do
    # Present the question/information to the user
    text_display @selection
    
    # Run through all the options to generate buttons for the user to click
    @selection["options"].each do |o|
      if not o.nil?
        # If the o is a 'new' method, don't display the button either and carry on
        button (label_selection o) do
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
  end
end

def label_selection input
  if input.length == 0
    "No arguments"
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

Shoes.app :title => "SpLATS", :width => 500, :height => 500
