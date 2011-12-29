require_relative '../lib/splats'
require 'test/unit'
require 'set'

class RandomTraversalTest < Test::Unit::TestCase
  def random_all method
    r = SPLATS::RandomTraversal.new
    elems = [1, 'a', 'z', 2]
    set = Set.new elems
    set2 = Set.new
    50.times do
      set2.add(r.send(method, elems))
    end
    assert_equal set, set2, "Not all inputs detected as being output, rerun to ensure not a random result"
  end

  def test_all_options_returned
    random_all :select_method
    random_all :select_arguments
  end

  def test_all_generate_value_options_returned
    r = SPLATS::RandomTraversal.new
    elems = [nil, true, false]
    results = []
    50.times do
      results << r.generate_value(:Bool)
    end
    assert_equal [], (elems - results)
  end

  def test_same_seed_produces_same_result
    r1 = SPLATS::RandomTraversal.new 1
    r2 = SPLATS::RandomTraversal.new 1
    elem = [1, 'a', 'z', 2]
    50.times do
      assert_equal r1.select_method(elem), r2.select_method(elem)
      assert_equal r1.select_arguments(elem), r2.select_arguments(elem)
      assert_equal r1.generate_value(:Bool), r2.generate_value(:Bool)
      assert_equal r1.continue_descent?, r2.continue_descent?
      assert_equal r1.continue_generation?, r2.continue_generation?
    end
  end

  def test_set_seed_returned
    r = SPLATS::RandomTraversal.new 10
    assert_equal r.seed, 10
  end

  def test_random_seed_allocated
    r1 = SPLATS::RandomTraversal.new
    r2 = SPLATS::RandomTraversal.new

    assert_not_equal r1.seed, r2.seed
  end

  def test_does_not_mutate_system_random_number_generator
    srand(100)
    random_numbers = Array.new(7) { rand 10 }

    srand(100)
    new_random_numbers = []

    new_random_numbers << rand(10)
    r = SPLATS::RandomTraversal.new
    new_random_numbers << rand(10)
    r.select_method [1,2,3]
    new_random_numbers << rand(10)
    r.select_arguments [1,2,3]
    new_random_numbers << rand(10)
    r.generate_value :Bool
    new_random_numbers << rand(10)
    r.continue_descent?
    new_random_numbers << rand(10)
    r.continue_generation?
    new_random_numbers << rand(10)

    assert_equal random_numbers, new_random_numbers
  end
end
