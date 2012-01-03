require '../splats.rb'
require './gui_controller.rb'
require 'green_shoes'
require 'graph'

=begin
def conv c
 c.to_s.sub 'Shoes::', ''
end

classes = []
Shoes.constants.each do |c|
 c = eval "Shoes::#{c}"
 if c.is_a? Class
   classes << [conv(c.superclass), conv(c)]
 end
end

digraph do
 classes.each do |p, c|
   edge p, c
 end
 node_attribs << lightblue << filled
 save 'GreenShoesClasses', 'svg'
end

Shoes.app title: 'The Tree of Classes on Green Shoes', width: 1400, height: 400 do
  img = image IO.read('GreenShoesClasses.svg'), width: 1400, height: 400
end
=end

# Present the main application window
Shoes.app(:title => "SpLATS", :width => 500, :height => 500) {
  puts "Shoesapp:", Thread.current
  # Setup the look
  background darkred..red, angle: 130
  # header
  tagline "SpLATS Lazy Automated Test System", :align => "center"
    
  # Initialise variables
  @page = 0
  @traversal_methods = ["Depth-Limited", "Guided", "Random"]
  
  # Uses the traversal methods to generate the choices for what the user can select
  def traversal_buttons
    default = 0
    label_width = 150
    
    # Generate the radio buttons
    @traversal_methods.each_with_index { |method, i|
      flow do
        @r = radio :traversal do
          @traversal_method = i
        end
        
        # Display the label
        para method, width: label_width
        
        # If default is changed, move the last line of the if statement elsewhere!
        if i == default
          @r.checked = true 
          @traversal_method = default
          flow do
            para "What depth?"
            @depth = edit_line :text => 3
          end
        elsif i == 2
          flow do
            para "Seed?"
            @seed = edit_line
          end
        end
      end
    }
  end

  # Define the 'next' button
  def next_button
    button "Next", :width => 50 do
      next_page
    end
  end
  
  def confirm_selections
  end

  # 'Next' page method
  def next_page
    @page += 1
    if @page == 1
      @next_area.clear do
        para "Select which method you would like to use to run the tests"
        traversal_buttons
        button "Select the output directory for the tests" do
          @output_dir = ask_open_folder
          confirm_selections
        end
        @next_button = next_button
      end
    elsif @page == 2
      # Filename, output directory, depth (depth-limited only), seed, traversal method, gui controller
      controller = SPLATS::TestController.new(@file, @output_dir, @depth.text.to_i, @seed.text.to_i, @traversal_method, "moo")
      Thread.new do
        controller.test_classes
      end
    end
  end

  @mainstack = stack :width => '100%' do
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
      @file_info = stack
    end
  end
}

gct = Thread.new {gc = GUIController.new @mainstack}
gct.priority = 100
