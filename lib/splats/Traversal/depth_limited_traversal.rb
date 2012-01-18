module SPLATS
  # A complete, depth-limited tree traversal
  #
  # Includes the Traversal abstract class, see there for interface documentation
  class DepthLimitedTraversal
    include Traversal

    # Functions are listed in execution order

    # @param [Integer] maxdepth The maximum depth the traversal should reach
    def initialize(maxdepth=3)
      @maxdepth = maxdepth
      # [[[method, argument, decisions...], layers...], paths...]
      @queue = [[[]]]
    end

    # @return [Boolean] True whilst we've not reached the maxdepth
    def continue_generation?
      @queue.length > 0 and @queue.first.length <= @maxdepth
    end

    # Shifts off next item from queue for use, reinitialises the various
    # iterators used during traversal for the new item
    def notify_new_traversal
      @item = @queue.shift
      @layers = @item.each
      @layer = @layers.next
      @index = 0
    end

    # @see Traversal#select_method
    # @see #select
    def select_method methods
      select methods
    end

    # @see Traversal#select_arguments
    # @see #select
    def select_arguments arguments
      select arguments
    end

    # @see Traversal#generate_value
    # @see #select
    def generate_value type
      values = generate_values type
      select values
    end

    # Stops descent when the item runs out of layers, then appends new layer and
    # reinserts extended item into queue
    # Otherwise, continue descent
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

    # We simply do nothing, the item is not reinserted into the queue
    def notify_exception_raised exception
    end

    private

    # Used to build and read the structure of each of the items within the queue
    #
    # Given a set of options:
    # * If we've not encountered them before, insert all into options in the
    #   queue and return first.
    # * Otherwise, return appropriate item from the information in the layer
    #
    # The function maintains state information regarding which index of the layer
    # it is currently selecting (method, arguments, decision).
    #
    # @param [Array] options The set of options to make a selection from
    # @return [Object] The selected option
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
