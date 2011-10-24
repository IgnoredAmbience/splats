#!/bin/env ruby

def quicksort(array)
  if array.nil? || array.length <= 1
    return array
  end
  pivot = array.pop
  lower  = array.select {|x| x <=  pivot}
  higher = array.select {|x| x > pivot}

  (quicksort higher) + [pivot] + (quicksort lower)
end

puts quicksort [1,2,3,4,5]
