require_relative '../lib/splats'
require 'test/unit'

class Traversal
  include SPLATS::Traversal
end

class TraversalTest < Test::Unit::TestCase
  def test_select_method
    assert_raises NotImplementedError do
      Traversal.new.select_method []
    end
  end

  def test_select_arguments
    assert_raises NotImplementedError do
      Traversal.new.select_arguments []
    end
  end

  def test_generate_value
    assert_equal nil, Traversal.new.generate_value(:Bool)
  end

  def test_continue_descent?
    assert_raises NotImplementedError do
      Traversal.new.continue_descent?
    end
  end

  def test_continue_generation?
    assert_raises NotImplementedError do
      Traversal.new.continue_generation?
    end
  end

  def test_notify_new_traversal
    assert_nothing_raised do
      Traversal.new.notify_new_traversal
    end
  end

  def test_notify_exception_raised
    assert_nothing_raised do
      Traversal.new.notify_exception_raised
    end
  end
end
