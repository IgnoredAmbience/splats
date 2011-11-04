require 'tree'

# Provides ** array mixin ([1,2,3]**3 === [1,2,3]x[1,2,3]x[1,2,3])
require 'cartesian'

module SPLATS
  class Core
    def initialize(c)
      # The class that we are interested in testing
      @class = c
      @tree = initialize_tree
    end

    def initialize_tree
      # We need to instantiate first, this may result in multiple returned
      # objects, if we can instantiate with parameters
      # We can only read the number of parameters from the initialize method,
      # since, def Class.new(*args), prevents any useful detail from being
      # exposed
      m = @class.method(:new)
      im = @class.instance_method(:initialize)
      tree = Tree::TreeNode.new("CONSTRUCTOR", m)
    end

    def test_class(depth = 5)
      depth.times do
        @tree.each_leaf do |leaf|
          path = leaf.parentage.reverse << leaf.content
          puts path
        end
        expand_tree
      end
    end

    def expand_tree
      @tree.each_leaf do |leaf|
        unless leaf.content = nil
          @class.instance_methods.each_with_index do |method, i|
            leaf << Tree::TreeNode.new(i, method)
            generate_parameters! leaf
          end
        end
      end
    end

    def generate_parameters! node
      method = @class.instance_method node.content

      req = opt = 0
      method.parameters.each do |type, name|
        req += 1 if type == :req
        opt += 1 if type == :opt
        # Other types are :rest, :block for * and & syntaxes, respectively
      end

      (req..opt+req).each_with_index do |n, i|
        node << Tree::TreeNode.new(i, Array.new(n) { Mock.new })
      end
    end
  end
end
