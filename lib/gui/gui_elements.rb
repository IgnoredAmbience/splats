# Uses the traversal methods to generate the choices for what the user can select
def traversal_buttons
  default = 1
  label_width = 150
  
  # Generate the radio buttons
  @traversal_methods.each_with_index { |method, i|
    flow do
      @r = radio :traversal do
        @traversal_method = i
      end
      
      # Display the label
      para method, width: label_width
      
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
  }
end

# Define the 'next' button
def next_button
  button "Next", :width => 50 do
    next_page
  end
end

# Define the 'radio' flows
def radio_flow (element, bg=nil)
  flow do
    if bg
      background bg
    end
    if element == "depth"
      para "What depth?"
      @depth = edit_line :text => 3, :margin => 5
    elsif element == "seed"
      para "Seed?"
      @seed = edit_line :margin => 5
    end
  end
end
