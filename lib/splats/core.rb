require 'tree'

# Provides ** array mixin ([1,2,3]**3 === [1,2,3]x[1,2,3]x[1,2,3])
require 'cartesian'

module SPLATS
  class Core
    attr_reader :tree

    def initialize(c)
      # The class that we are interested in testing
      @class = c
      @tree = initialize_tree
    end

    def to_s
      ""
    end

    def initialize_tree
      # We need to instantiate first, this may result in multiple returned
      # objects, if we can instantiate with parameters
      # We can only read the number of parameters from the initialize method,
      # since, def Class.new(*args), prevents any useful detail from being
      # exposed
      m = @class.method :new
      im = @class.instance_method :initialize
      tree = Tree::TreeNode.new "CONST: new/initialize", m
      generate_parameters! tree, im
    end

    def test_class(depth = 5)
      depth.times do
        @tree.each_leaf do |leaf|
          path = leaf.parentage
          path ||= []
          path.reverse! << leaf.content
        end
        expand_tree
      end
    end

    def expand_tree
      @tree.postordered_each do |leaf|
        if leaf.is_leaf? and leaf.content
          @class.instance_methods(include_super=false).each_with_index do |method, i|
            newnode = Tree::TreeNode.new("#{i}: #{method}", method)
            generate_parameters! newnode
            leaf << newnode
          end
        end
      end
    end

    def generate_parameters!(node, method=nil)
      method ||= @class.instance_method node.content

      req = opt = 0
      method.parameters.each do |type, name|
        req += 1 if type == :req
        opt += 1 if type == :opt
        # Other types are :rest, :block for * and & syntaxes, respectively
      end

      (req..opt+req).each_with_index do |n, i|
        node << Tree::TreeNode.new("#{n} params", Array.new(n) { Mock.new })
      end

      node
    end
  end
end

module Tree
  class TreeNode
    def postordered_each(&block) # :yields: node
      children { |child| child.postordered_each(&block) }
      yield self
    end
  end
end
