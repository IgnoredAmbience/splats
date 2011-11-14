# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'splats/class_test_generator.rb'
require 'splats/mock.rb'
require 'splats/tree.rb'
$:.unshift File.join(File.dirname(__FILE__),'..','samples')
require 'simple_methods.rb'

class TestCore < Test::Unit::TestCase

  def test_generate_parameters_initialize_no_method
    m = SimpleMethods.method(:new)
    im = SimpleMethods.instance_method(:initialize)
    node = Tree::TreeNode.new "CONST: new/initialize", m
    node = SPLATS::ClassTestGenerator.generate_parameters! node, im
    node_should_be = Tree::TreeNode.new "CONST: new/initialize", m
    node_should_be << Tree::TreeNode.new("0 params", nil)
    node_should_be << Tree::TreeNode.new("1 params", nil)
    assert (node_should_be.eql?(node))
  end

end
