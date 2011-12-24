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
        path << d.select_method([1,2])
        path << d.select_arguments([1,2])
      end while d.continue_descent?
      paths << path
    end

    d1 = [1,2].repeated_permutation(2).to_a
    d2 = [1,2].repeated_permutation(4).to_a
    expected = d1 + d2

    assert_empty expected - paths, "Not all expected items were returned"

    paths.each_cons(2) do |pair|
      assert_operator pair[0].length, :<=, pair[1].length, "Path length should not shrink"
    end

    assert_empty paths - expected, "Unexpected items were returned"
  end

  def test_exception
    d = SPLATS::DepthLimitedTraversal.new 2
    paths = []

    while d.continue_generation?
      d.notify_new_traversal
      path = []
      begin
        path << d.select_method([1])
        args = d.select_arguments([1,2])
        path << args

        if args == 2
          d.notify_exception_raised
          break
        end
      end while d.continue_descent?
      paths << path
    end

    expected = [[1,1], [1,2], [1,1,1,1], [1,1,1,2]]
    assert_empty expected - paths, "Not all expected items were returned"
    assert_empty paths - expected, "Unexpected items were returned"
  end
end
