# Simple LinkedList class
# Implements a shed-load of derived functions thanks to the Enumerable mixin, if
# we don't actually want to test all of that, then we should probably swap it
# out for hand-written ones.
class LinkedList
  include Enumerable

  def initialize(item = nil)
    @item = nil
    @next = nil
    push item if item
  end

  # Recursive implementation
  def push(item)
    if @item.nil?
      @item = item
    elsif @next.nil?
      @next = LinkedList.new item
    else
      @next.push item
    end

    self
  end

  # Iterative implementation
  def pop
    if @next.nil?
      i = @item
      @item = nil
      unless i.nil?
        return i
      else
        raise "List is empty"
      end
    end

    elem = self

    while elem
      if elem.next.next.nil?
        i = elem.next.item
        elem.next = nil
        return i
      else
        elem = elem.next
      end
    end
  end

  # Iterative implementation
  def delete!(item)
    prev = nil
    curr = self

    while curr
      if curr.item == item
        if prev
          prev.next = curr.next
          return self
        else
          if curr.next
            return curr.next
          else
            curr.item = nil
            return curr
          end
        end
      else
        prev = curr
        curr = curr.next
      end
    end
  end

  # Required for the Enumerable mixin
  def each
    elem = self
    while elem and elem.item
      yield elem.item
      elem = elem.next
    end
  end

  protected 
  attr_accessor :item, :next
end

