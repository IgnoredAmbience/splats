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
    background red..darkred, angle: 120
    # header
    tagline "SpLATS Lazy Automated Test System", :align => "center"
      
    # Initialise variables
    @y_or_n = Hash["Yes" => true, "No" => false]
    @page = 3
    @traversal_methods = Hash["Depth-Limited" => :depth, "Manual" => :human, "Random" => :random]
    
    #TODO Put this in a config file
    # Defaults
    @file = '../../samples/LinkedList.rb'
    @output_dir = 'tests'
    @traversal_method = :human
    @depth = 3
    @seed = 0

    # Put in a dummy depth and seed
    @main = stack do
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
          display_traversal_buttons
          get_output_dir
          @output_display = flow do
            para "Current output directory:"
            para strong @output_dir
          end
          next_button "validate_user_input"
        else
          para "Nothing left to do!"
      end
    end
    # Increment the page
    @page += 1
  end
  
  # Checks that depth and seed are correct to continue
  def validate_user_input
    case @traversal_method
      when :depth
        puts @depth_box.text
      when :random
        puts @seed_box.text
    end
    false
  end
  
  def start_tests
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
  @next_area.clear do
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
puts input
  if input.length == 0
    "No arguments"
  else
    input.to_s
  end
end

def check_controller_error
  if @selection[0] == :error
    alert(@selection[1])
    #TODO don't terminate
    exit
  end
end

Shoes.app :title => "SpLATS", :width => 500, :height => 500
