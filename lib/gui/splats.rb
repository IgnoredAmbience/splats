require 'test'

# Present the main application window
Shoes.app(:title => "SpLATS", :width => 500, :height => 500){
  # Initialise variables
  @page = 0
  @traversal_methods = ['Guided', 'Depth-First', 'Breadth-First']

  # Define the 'next' button
  def next_button
    button "Next", :width => 50 do
      next_page
    end
  end

  # 'Next' page method
  def next_page
    @page += 1
    if @page == 1
      @next_area.clear do
        @traversal_methods.map! do |method|
          flow { @r = radio :traversal; para method }
          [@r, method]
        end
      end
    elsif @page == 2
      selected = @traversal_methods.map { |r, method| method if r.checked? }
      # Load the generator ? clear the next button ?
    end
  end

  stack :width => '100%' do
    # The contents stack deals with everything in the window
    @contents = stack do
      # The next area is when there's a next button
      @next_area = flow do
        para "Please select version 1 of the code to test\n"
        button "Load", :width => 50 do
          # Shoes doesn't offer file types with the dialog
          # This repeatedly asks until a .rb is chosen
          begin
            @file = ask_open_file
          end while @file[-2, 2] != "rb"

          # Because there's a cancel button, need to check the file again
          if @file[-2, 2] == "rb"
            # Display the next button
            @next_button.append {next_button}
          end
        end
      end
      @next_button = stack
    end
  end
=begin
  stack do
    parent = oval :top => 0, :left => 0, :radius => 50
    parent.click do
      fill white
      oval 10, 10, 50
    end
  end
=end
}
