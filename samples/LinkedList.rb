class LinkedList
  def initialize(item = nil)
    @item = nil
    @next = nil
    push item if item
  end

  # Recursive
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

  # Recursive
  def include?(item)
    @item == item or (not @next.nil? and @next.include? item)
  end

  # Iterative
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

  protected 
  attr_accessor :item, :next
end

