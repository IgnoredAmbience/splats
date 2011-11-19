# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'splats/class_test_generator.rb'
require 'splats/mock.rb'
require 'splats/tree.rb'
$:.unshift File.join(File.dirname(__FILE__),'..','samples')

class TestCore < Test::Unit::TestCase

  class TestClass
    def initialize(item = nil)
      @item = item
    end
    def one_required_parameter(param)
      puts param
    end
    def one_required_one_optional_parameter(req_param, opt_param=nil)
      puts req_param
      puts opt_param
    end
    def no_parameters
      put 'no'
    end
    def argc_parameters(*params)
      puts params
    end
  end

  def setup
    @test_gen = SPLATS::ClassTestGenerator.new(TestClass)
    @tree = Tree::TreeNode.new "CONST: new/initialize", TestClass.method(:new)
    @tree_should_be = Tree::TreeNode.new("CONST: new/initialize", nil)
  end

  def test_generate_parameters_initialize
    @tree = @test_gen.generate_parameters! @tree, TestClass.instance_method(:initialize)
    @tree_should_be << Tree::TreeNode.new("0 params", nil)
    @tree_should_be << Tree::TreeNode.new("1 params", nil)
    assert (@tree_should_be.eql?(@tree))
  end

  def test_generate_parameters_argc
    @tree = @test_gen.generate_parameters! @tree, TestClass.instance_method(:argc_parameters)
    @tree_should_be << Tree::TreeNode.new("0 params", nil)
    assert @tree_should_be.eql?(@tree)
  end

  def test_generate_parameters_no_parameters
    @tree = @test_gen.generate_parameters! @tree, TestClass.instance_method(:no_parameters)
    @tree_should_be << Tree::TreeNode.new("0 params", nil)
    assert @tree_should_be.eql?(@tree)
  end

  def test_generate_parameters_one_required_one_optional_parameter
    @tree = @test_gen.generate_parameters! @tree, TestClass.instance_method(:one_required_one_optional_parameter)
    @tree_should_be << Tree::TreeNode.new("1 params", nil)
    @tree_should_be << Tree::TreeNode.new("2 params", nil)
    assert @tree_should_be.eql?(@tree)
  end

  def test_generate_parameters_one_required_parameter
    @tree = @test_gen.generate_parameters! @tree, TestClass.instance_method(:one_required_parameter)
    @tree_should_be << Tree::TreeNode.new("1 params", nil)
    assert @tree_should_be.eql?(@tree)
  end

end
