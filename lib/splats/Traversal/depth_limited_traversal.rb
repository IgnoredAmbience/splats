module SPLATS
  class DepthLimitedTraversal
    include Traversal

    # Functions are listed in execution order

    def initialize(maxdepth=3, gui_controller)
      @maxdepth = maxdepth
      @gc = gui_controller
      
      # [[[method, argument, decisions...], layers...], paths...]
      @queue = [[[]]]
    end

    def continue_generation?
      @queue.length > 0 and @queue.first.length <= @maxdepth
    end

    def notify_new_traversal
      @item = @queue.shift
      @layers = @item.each
      @layer = @layers.next
      @index = 0
    end

    def select_method methods
      select methods
    end

    def select_arguments arguments
      select arguments
    end

    def generate_value type
      values = generate_values type
      select values
    end

    def continue_descent?
      @index = 0
      begin
        @layer = @layers.next
      rescue StopIteration
        @item << []
        @queue << @item
        false
      else
        true
      end
    end

    def notify_exception_raised
      # We simply do nothing, the item is not reinserted into the queue
    end

    private

    def select options
      # Count through current choice in layer
      # 0=method, 1=argument set, 2..=mock decisions
      index = @index
      @index += 1

      if not @layer[index]
        # Add other options to queue
        (1...options.length).each do |idx|
          new_layer = @layer.clone
          new_layer << idx
          new_item = @item.clone
          new_item[-1] = new_layer
          @queue.unshift(new_item)
        end
        @layer << 0
      end

      options[@layer[index]]
    end
  end
end
