# Uses the traversal methods to generate the choices for what the user can select
def traversal_buttons
  default = 1
  label_width = 150
  
  # Generate the radio buttons
  @traversal_methods.each_with_index { |method, i|
    flow do
      @r = radio :traversal, width: 50  do
        @traversal_method = i
      end
      para method, width: label_width
    end
=begin    
        flow do  
      if i == 0
        @depth_flow = radio_flow("depth")
      elsif i == 2
        @seed_flow = radio_flow("seed")
      end
      if i == default
        @r.checked = true 
        @traversal_method = default
      end
    end
=end
  }
end

def get_output_dir
  button "Select the output directory for the tests" do
    @output_dir = ask_open_folder
    if @output_dir
      @output_display.clear do
        para "Current output directory:"
        para strong @output_dir
      end
    end
  end
end

def display_traversal_buttons
  label_width = 150
  default = :human
  traversals = Hash["Depth-Limited" => :depth, "Manual" => :human, "Random" => :random]
  
  traversals.each do |name, method|
    flow do
      @r = radio :traversal do
        @traversal_method = method
      end
      para name, width: label_width
      if method == default
        @r.checked = true
      end
    end
    # If depth-limited, ask for a depth (defaults to 3)
    if method == :depth
      para "Which depth to traverse to?"
      @depth_box = edit_line :text => 3, :margin => 5
    # If random, ask for a seed (defaults to 0 in box, but will be random)
    elsif method == :random
      para "Seed?"
      @seed_box = edit_line :text => 0, :margin => 5
    end
  end
end

# Define the 'radio' flows
def radio_flow (element, bg=nil)
  flow do
    if bg
      background bg
    end
    if element == "depth"
      para "What depth?", width: 150
      @depth = edit_line :text => 3, :margin => 5
    elsif element == "seed"
      para "Seed?", width: 150
      @seed = edit_line :margin => 5
    end
  end
end

# Define the 'next' button
def next_button
  button "Next", :width => 50 do
    next_page
  end
end

# Displays the button asking user to select the file to test
def ask_for_version name
  button_name = "Load " + name + " version of the code"
  button button_name do
    # Gets the version and displays file info
    get_ruby_file
    @mainstack.append do
      next_button
      para "You have selected: "; para @file, weight: "bold"
      edit_box :width => '100%', :height => 500, :text => File.read(@file)
    end
    @file
  end
end

# Gets a file with a .rb extension
# Doesn't allow the user to cancel!
def get_ruby_file
  begin
    @file = ask_open_file
  end while @file.nil? || @file[-2, 2] != "rb"
end
