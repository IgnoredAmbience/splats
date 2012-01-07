# Select the output directory
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
  para "Choose a traversal method:"
  @list_box = list_box items: @traversal_methods.values do |lb|
    if @option_area
      @option_area.clear do
        case @traversal_methods.invert[lb.text]
          when :depth
            display_depth_box false
          when :human
            @option_area.clear
          when :random
            display_seed_box false
        end
      end
    end
  end
  
  # Highlight the default choice in the list box
  @list_box.choose(@traversal_methods[@traversal_method])
  
  # Set the default options thing
  @option_area = stack :height => 120, :margin => 10 do
    case @traversal_method
      when :depth
        display_depth_box false
      when :random
        display_seed_box false
      else
        para ""
    end
  end
end

# Define the depth box
# @param error Whether or not to display the error
def display_depth_box error
  para "Which depth to traverse to?"
  if error == "zero"
    para "Depth cannot be zero", :stroke => red
  elsif error
    para "Must be integer", :stroke => red
  end
  edit_line :text => @depth, :margin => 5 do |db|
    @depth = db.text
  end
end

# Display the seed box
# @param error Whether or not to display the error
def display_seed_box error
  para "Seed?"
  if error
    para "Must be integer", :stroke => red
  end
  seed_text = edit_line :text => @seed, :margin => 5 do |sb|
    @seed = sb.text
  end
end

# Define the 'next' button
def next_button function
  button "Next", :width => 50 do
    if function
      if (send function)
        start_tests
      end
    else
      next_page
    end
  end
end

# Displays the button asking user to select the file to test
def ask_for_version name
  button_name = "Load " + name + " version of the code"
  button button_name do
    # Gets the version and displays file info
    get_ruby_file
    @main.append do
      next_button nil
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
