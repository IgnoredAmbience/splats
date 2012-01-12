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
    @traversal_method = @traversal_methods.invert[lb.text]
    if @option_area
      @option_area.clear do
        case @traversal_method
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
# @param start_test
def next_button start
  button "Next", :width => 50 do
    if start
      if validate_user_input
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
    if name == "first"
      @version1 = get_ruby_file
      @file = @version1
    elsif name == "second"
      @version2 = get_ruby_file
      @file = @version2
    end
    @main.append do
      next_button nil
      para "You have selected: "; para @file, weight: "bold"
      edit_box :width => '100%', :height => 500, :text => File.read(@file)
    end
  end
end

# Gets a file with a .rb extension
# Doesn't allow the user to cancel!
def get_ruby_file
  begin
    file = ask_open_file
  end while file.nil? || file[-2, 2] != "rb"
  file
end

def get_file_array
  if not @file_array.empty?
    @file_array = File.new(@version1, 'r').read.split("\n")
    @file_array = @file_array.each_with_index.map { |x,i| strong(i+1) + ": " + x }
  end
  @file_array
end

# Reads the file and loads it into a different window, highlighting a function name or line number
def display_file (number, function_name)

  file_array = get_file_array
  choose_line = 0
  # Loop through array and get index of line we're looking for
  file_array.each_with_index do |line, line_number|
    # Highlight if the correct line
    if ((number.to_i == (line_number + 1)) || (function_name && line.index("def " + function_name.to_s)))
      choose_line = line_number
    end
  end

  if choose_line != 0
    # Work out which bit of the array to grab
    start_line = [0, choose_line - 5].max
    end_line = [file_array.length - 1, choose_line + 5].min
    
    # Choose the before text and put into string
    before_text = file_array[start_line..choose_line-1].join("\n")
    before_text.gsub!("<=", "&lt;=")
    before_text.gsub!(">=", "&gt;=")
    # Choose the after text and put into string
    after_text = file_array[choose_line+1..end_line].join("\n")
    after_text.gsub!("<=", "&lt;=")
    after_text.gsub!(">=", "&gt;=")
    
    stack do
      background white
      para before_text, :size => "small", :family => "monospace"
      flow do
        background wheat
        line = file_array[choose_line]
        line.gsub!("<=", "&lt;=")
        line.gsub!(">=", "&gt;=")
        para file_array[choose_line], :size => "small", :family => "monospace"
      end
      
      para after_text, :size => "small", :family => "monospace"
    end
  end
end
