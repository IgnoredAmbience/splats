require 'test/unit'
require 'flexmock/test_unit'
require 'SimpleTest'
class TestSimpleTest < Test::Unit::TestCase
  def test_1073071287937703804
    result = object = SimpleTest.new
    assert_instance_of SimpleTest, result
  end
  def test_1247519904185265696
    mock0 = flexmock("mock0")
    mock0.should_receive(:foo).and_return(nil).once
    mock0.should_receive(:get_sized_thing).and_return(nil).once
    assert_raises NoMethodError do
      object = SimpleTest.new
      result = object.to_s(mock0)
    end
  end
  def test_445624219511657416
    mock1 = flexmock("mock1")
    mock2 = flexmock("mock2")
    mock1.should_receive(:foo).and_return(nil).once
    mock1.should_receive(:get_sized_thing).and_return(mock2).once
    mock2.should_receive(:size).and_return(nil).once
    object = SimpleTest.new
    result = object.to_s(mock1)
    assert_equal "uh oh", result
  end
  def test_2252474186079709268
    mock3 = flexmock("mock3")
    mock4 = flexmock("mock4")
    mock5 = flexmock("mock5")
    mock3.should_receive(:foo).and_return(nil).once
    mock3.should_receive(:get_sized_thing).and_return(mock4).once
    mock4.should_receive(:size).and_return(mock5).once
    mock5.should_receive(:==).with(1).and_return(nil).once
    object = SimpleTest.new
    result = object.to_s(mock3)
    assert_equal "uh oh", result
  end
  def test_566876723572692864
    mock6 = flexmock("mock6")
    mock7 = flexmock("mock7")
    mock8 = flexmock("mock8")
    mock6.should_receive(:foo).and_return(nil).once
    mock6.should_receive(:get_sized_thing).and_return(mock7).once
    mock7.should_receive(:size).and_return(mock8).once
    mock8.should_receive(:==).with(1).and_return(false).once
    object = SimpleTest.new
    result = object.to_s(mock6)
    assert_equal "uh oh", result
  end
  def test_3734454445284304376
    mock9 = flexmock("mock9")
    mock10 = flexmock("mock10")
    mock11 = flexmock("mock11")
    mock9.should_receive(:foo).and_return(nil).once
    mock9.should_receive(:get_sized_thing).and_return(mock10).once
    mock10.should_receive(:size).and_return(mock11).once
    mock11.should_receive(:==).with(1).and_return(true).once
    object = SimpleTest.new
    result = object.to_s(mock9)
    assert_equal "hello", result
  end
  def test_2104044523365434360
    mock12 = flexmock("mock12")
    mock13 = flexmock("mock13")
    mock12.should_receive(:foo).and_return(mock13).once
    mock12.should_receive(:get_sized_thing).and_return(nil).once
    mock13.should_receive(:==).with(1).and_return(nil).once
    assert_raises NoMethodError do
      object = SimpleTest.new
      result = object.to_s(mock12)
    end
  end
  def test_3334889679738203972
    mock14 = flexmock("mock14")
    mock15 = flexmock("mock15")
    mock16 = flexmock("mock16")
    mock14.should_receive(:foo).and_return(mock15).once
    mock14.should_receive(:get_sized_thing).and_return(mock16).once
    mock15.should_receive(:==).with(1).and_return(nil).once
    mock16.should_receive(:size).and_return(nil).once
    object = SimpleTest.new
    result = object.to_s(mock14)
    assert_equal "uh oh", result
  end
  def test_1875659823073566220
    mock17 = flexmock("mock17")
    mock18 = flexmock("mock18")
    mock19 = flexmock("mock19")
    mock20 = flexmock("mock20")
    mock17.should_receive(:foo).and_return(mock18).once
    mock17.should_receive(:get_sized_thing).and_return(mock19).once
    mock18.should_receive(:==).with(1).and_return(nil).once
    mock19.should_receive(:size).and_return(mock20).once
    mock20.should_receive(:==).with(1).and_return(nil).once
    object = SimpleTest.new
    result = object.to_s(mock17)
    assert_equal "uh oh", result
  end
  def test_3630339121774505920
    mock21 = flexmock("mock21")
    mock22 = flexmock("mock22")
    mock23 = flexmock("mock23")
    mock24 = flexmock("mock24")
    mock21.should_receive(:foo).and_return(mock22).once
    mock21.should_receive(:get_sized_thing).and_return(mock23).once
    mock22.should_receive(:==).with(1).and_return(nil).once
    mock23.should_receive(:size).and_return(mock24).once
    mock24.should_receive(:==).with(1).and_return(false).once
    object = SimpleTest.new
    result = object.to_s(mock21)
    assert_equal "uh oh", result
  end
  def test_211786181338934248
    mock25 = flexmock("mock25")
    mock26 = flexmock("mock26")
    mock27 = flexmock("mock27")
    mock28 = flexmock("mock28")
    mock25.should_receive(:foo).and_return(mock26).once
    mock25.should_receive(:get_sized_thing).and_return(mock27).once
    mock26.should_receive(:==).with(1).and_return(nil).once
    mock27.should_receive(:size).and_return(mock28).once
    mock28.should_receive(:==).with(1).and_return(true).once
    object = SimpleTest.new
    result = object.to_s(mock25)
    assert_equal "hello", result
  end
  def test_1328668945345348320
    mock29 = flexmock("mock29")
    mock30 = flexmock("mock30")
    mock29.should_receive(:foo).and_return(mock30).once
    mock29.should_receive(:get_sized_thing).and_return(nil).once
    mock30.should_receive(:==).with(1).and_return(false).once
    assert_raises NoMethodError do
      object = SimpleTest.new
      result = object.to_s(mock29)
    end
  end
  def test_75845420068138144
    mock31 = flexmock("mock31")
    mock32 = flexmock("mock32")
    mock33 = flexmock("mock33")
    mock31.should_receive(:foo).and_return(mock32).once
    mock31.should_receive(:get_sized_thing).and_return(mock33).once
    mock32.should_receive(:==).with(1).and_return(false).once
    mock33.should_receive(:size).and_return(nil).once
    object = SimpleTest.new
    result = object.to_s(mock31)
    assert_equal "uh oh", result
  end
  def test_3626911804254996824
    mock34 = flexmock("mock34")
    mock35 = flexmock("mock35")
    mock36 = flexmock("mock36")
    mock37 = flexmock("mock37")
    mock34.should_receive(:foo).and_return(mock35).once
    mock34.should_receive(:get_sized_thing).and_return(mock36).once
    mock35.should_receive(:==).with(1).and_return(false).once
    mock36.should_receive(:size).and_return(mock37).once
    mock37.should_receive(:==).with(1).and_return(nil).once
    object = SimpleTest.new
    result = object.to_s(mock34)
    assert_equal "uh oh", result
  end
  def test_766399399739627048
    mock38 = flexmock("mock38")
    mock39 = flexmock("mock39")
    mock40 = flexmock("mock40")
    mock41 = flexmock("mock41")
    mock38.should_receive(:foo).and_return(mock39).once
    mock38.should_receive(:get_sized_thing).and_return(mock40).once
    mock39.should_receive(:==).with(1).and_return(false).once
    mock40.should_receive(:size).and_return(mock41).once
    mock41.should_receive(:==).with(1).and_return(false).once
    object = SimpleTest.new
    result = object.to_s(mock38)
    assert_equal "uh oh", result
  end
  def test_819582501241927804
    mock42 = flexmock("mock42")
    mock43 = flexmock("mock43")
    mock44 = flexmock("mock44")
    mock45 = flexmock("mock45")
    mock42.should_receive(:foo).and_return(mock43).once
    mock42.should_receive(:get_sized_thing).and_return(mock44).once
    mock43.should_receive(:==).with(1).and_return(false).once
    mock44.should_receive(:size).and_return(mock45).once
    mock45.should_receive(:==).with(1).and_return(true).once
    object = SimpleTest.new
    result = object.to_s(mock42)
    assert_equal "hello", result
  end
  def test_4145513547249339732
    mock46 = flexmock("mock46")
    mock47 = flexmock("mock47")
    mock46.should_receive(:foo).and_return(mock47).once
    mock46.should_receive(:bar).and_return(nil).once
    mock47.should_receive(:==).with(1).and_return(true).once
    object = SimpleTest.new
    result = object.to_s(mock46)
    assert_equal "hi", result
  end
  def test_2034645345425825872
    mock48 = flexmock("mock48")
    mock49 = flexmock("mock49")
    mock50 = flexmock("mock50")
    mock48.should_receive(:foo).and_return(mock49).once
    mock48.should_receive(:bar).and_return(mock50).once
    mock49.should_receive(:==).with(1).and_return(true).once
    object = SimpleTest.new
    result = object.to_s(mock48)
    assert_equal "hi", result
  end
  def test_776128993804172740
    assert_raises NoMethodError do
      object = SimpleTest.new
      result = object.to_s(nil)
    end
  end
end
