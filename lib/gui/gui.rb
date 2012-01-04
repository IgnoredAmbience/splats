require '../splats.rb'
require 'green_shoes'
require 'graph'
require 'fiber'
require './gui_elements.rb'

class SPLATSGUI < Shoes

  url '/', :setup
  
  # Setup the main application window
  def setup
    # Setup the look
    background darkred..red, angle: 130
    # header
    tagline "SpLATS Lazy Automated Test System", :align => "center"
      
    # Initialise variables
    @page = 0
    @traversal_methods = ["Depth-Limited", "Guided", "Random"]
    
    #TODO Put this in a config file
    # Defaults
    @file = '/home/caz/Uni/splats/samples/LinkedList.rb'
#    @file = '/home/caz/Uni/splats/lib/gui/gui.rb'
    @output_dir = '/home/caz/Uni/splats/lib/gui/tests'
#    @depth = edit_line :text => 3
#    @seed = edit_line :text => 0
    @traversal_method = 1

    @mainstack = stack :width => '100%' do
      @next_area = stack
      next_page
    end
  end
  
  def confirm_selections
    continue = false
    
    #TODO make this prettier!
    if (@traversal_method == 0 && @depth.text.to_i == 0)
      # Complain about the depth, and reset the seed
      @depth_flow.clear do
        radio_flow("depth", red)
      end
      @seed_flow.clear do
        radio_flow("seed")
      end
      continue = false
    else
      continue = true
    end
    
    if (@traversal_method == 2 && @seed.text.to_i == 0)
      # Complain about the seed, and reset the depth
      @seed_flow.clear do
        radio_flow("seed", red)
      end
      @depth_flow.clear do
        radio_flow("depth")
      end
      continue = false
    else
      continue = true
    end
    continue
  end
  
  # 'Next' page method
  def next_page
    @page += 1
    if @page == 1
      # The next area is when there's a next button
      @next_area = stack :width => '100%' do
        button "Load first version of code", :width => 50, :align => "center" do
          # Shoes doesn't offer file types with the dialog
          # This repeatedly asks until a .rb is chosen
          begin
            @file = ask_open_file
          end while @file[-2, 2] != "rb"
          
          # Because there's a cancel button, need to check the file again
          if @file[-2, 2] == "rb"
            # Tell the user what they have chosen
            @file_info.clear do
              para "You have selected: "; para @file, weight: "bold"
            end
            # Display the next button
            @next_button.clear {next_button}
            # Load the file into a text box
            @file_info.append{file_box = edit_box :width => '100%', :height => 500, :text => File.read(@file)}
          end
        end
        # Weird bug - seem to need the brackets to format everything correctly
        @next_button = stack {}
        @file_info = stack {}
      end
    elsif @page == 2
#      @next_area = stack :width => '100%' do
      @next_area.clear do
        para "Select which method you would like to use to run the tests"
        traversal_buttons
        button "Select the output directory for the tests" do
          @output_dir = ask_open_folder
          confirm_selections
        end
        @next_button = next_button
      end
    elsif @page == 3
      if confirm_selections
        @i = 1
        display = f = nil
        @selection = []
        
        # Cheeky Fiber stuff - create a dummy fiber to allow the
        # transfer methods to work, but keep returning control to
        # this main thread
        display = Fiber.new do |input|
          while input
            @selection = f.transfer @choice
            @choice = Fiber.yield @selection
          end
        end
        
        # Wrap the test controller in a fiber, passing the GUI fiber in
        # This determines the value of selection
        f = Fiber.new do |input|
          controller = SPLATS::TestController.new(@file, @output_dir, @depth, @seed, @traversal_method, display)
          controller.test_classes
        end
        
        # Call display
        display.transfer true
        
        # Handles the user's choices
        @next_area.clear
        @next_area = stack do
          button "Click!" do
            # Loop through the selection, and ask the user which they'd like
            puts "pre"
            #TODO if there's an error message returned, don't make the button do anything
            @selection.each do |sel|
              button sel.to_s do
                
              end
            end
            puts "post"
            # This determines the value of 'choice'
            @i += 1
            display.transfer(@i)
          end
        end
      else
        @page -= 1
      end
    end
  end
end

Shoes.app :title => "SpLATS", :width => 500, :height => 500
