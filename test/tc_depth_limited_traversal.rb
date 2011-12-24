require_relative '../lib/splats'
require 'test/unit'

class DepthLimitedTraversalTest < Test::Unit::TestCase
  def test_normal
    d = SPLATS::DepthLimitedTraversal.new 2
    paths = []
    
    while d.continue_generation?
      d.notify_new_traversal
      path = []
      begin
        path << d.select_method([0,1])
        path << d.select_arguments([0,1])
      end while d.continue_descent?
      paths << path
    end

    d1 = [0,1].repeated_permutation(2).to_a
    d2 = [0,1].repeated_permutation(4).to_a
    expected = d1 + d2

    assert_empty expected - paths, "Not all expected items were returned"

    paths.each_cons(2) do |pair|
      assert_operator pair[0].length, :<=, pair[1].length, "Path length should not shrink"
    end

    assert_empty paths - expected, "Unexpected items were returned"
  end

  def test_exception_pruning
    d = SPLATS::DepthLimitedTraversal.new 2
    paths = []

    while d.continue_generation?
      d.notify_new_traversal
      path = []
      begin
        path << d.select_method([0])
        args = d.select_arguments([0,1])
        path << args

        if args == 1
          d.notify_exception_raised
          break
        end
      end while d.continue_descent?
      paths << path
    end

    expected = [[0,0], [0,1], [0,0,0,0], [0,0,0,1]]
    assert_empty expected - paths, "Not all expected items were returned"
    assert_empty paths - expected, "Unexpected items were returned - pruning not working as expected!"
  end
end
