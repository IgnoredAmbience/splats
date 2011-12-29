require 'simple_cov'
SimpleCov.start

# Colours!
require 'minitest/pride'

$:.unshift File.join(File.dirname(__FILE__),'..','lib')
$:.unshift File.join(File.dirname(__FILE__))

require 'splats'
require 'tc_traversal'
require 'tc_random_traversal'
require 'tc_depth_limited_traversal'

