module SPLATS
  class DepthLimitedTraversal
    include Traversal

    # Functions are listed in execution order

    def initialize(maxdepth=3)
      @maxdepth = maxdepth

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
    end

    def select_method methods
      select methods, 0
    end

    def select_arguments arguments
      select arguments, 1
    end

    def continue_descent?
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

    def select options, index
      if not @layer[index]
        # Add other options to queue
        (1...options.length).each do |idx|
          new_layer = @layer.clone
          new_layer << idx
          new_item = @item.clone
          new_item[-1] = new_layer
          @queue << new_item
        end
        @layer << 0
      end

      options[@layer[index]]
    end
  end
end
