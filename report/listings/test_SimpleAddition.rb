require 'test/unit'
require 'flexmock/test_unit'
require 'Addition'
class TestAddition < Test::Unit::TestCase
  def test_52357944239004904
    result = object = Addition.new
    assert_instance_of Addition, result
  end
  def test_3186095972929339832
    mock0 = flexmock("mock0")
    mock0.should_receive(:coerce).with(1).and_return([1, nil]).once
    assert_raises TypeError do
      object = Addition.new
      result = object.add(mock0)
    end
  end
  def test_2445483995603540400
    mock1 = flexmock("mock1")
    mock1.should_receive(:coerce).with(1).and_return([1, -1]).once
    object = Addition.new
    result = object.add(mock1)
    assert_equal 0, result
  end
  def test_1845467242524294964
    mock2 = flexmock("mock2")
    mock2.should_receive(:coerce).with(1).and_return([1, 1]).once
    object = Addition.new
    result = object.add(mock2)
    assert_equal 2, result
  end
  def test_4446194171701086472
    mock3 = flexmock("mock3")
    mock3.should_receive(:coerce).with(1).and_return([1, 0]).once
    object = Addition.new
    result = object.add(mock3)
    assert_equal 1, result
  end
  def test_1755352279379595164
    assert_raises TypeError do
      object = Addition.new
      result = object.add(nil)
    end
  end
end
