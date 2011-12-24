require 'simple_cov'
SimpleCov.start

$:.unshift File.join(File.dirname(__FILE__),'..','lib')
$:.unshift File.join(File.dirname(__FILE__))

require 'splats'
require 'tc_traversal'

