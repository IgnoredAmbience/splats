#!/bin/env ruby

class QuickSort
  def quicksort(array)
    if array.nil? || array.length <= 1
      return array
    end
    pivot = array.pop
    lower  = array.select {|x| x <=  pivot}
    higher = array.select {|x| x > pivot}

    (quicksort higher) + [pivot] + (quicksort lower)
  end
end
