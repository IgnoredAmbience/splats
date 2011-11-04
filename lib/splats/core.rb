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

    def to_s
      ""
    end
    
    # We need to instantiate first, this may result in multiple returned
    # objects, if we can instantiate with parameters. <br>
    # We can only read the number of parameters from the initialize method,
    # as def Class.new(*args), prevents any useful detail from being exposed
    def initialize_tree      
      m = @class.method :new
      im = @class.instance_method :initialize
      tree = Tree::TreeNode.new "CONSTRUCTOR", m
      generate_parameters! tree, im
    end

    # Goes through the tree doing magic
    def test_class(depth = 5)
      depth.times do
        @tree.each_leaf do |leaf|
          path = leaf.parentage
          path ||= []
          path.reverse! << leaf.content
        end
        @tree.print_tree
        expand_tree
      end
    end
    
    #Adds a new node to the leaf based on Tom magic
    def expand_tree
      @tree.each_leaf do |leaf|
        if leaf.content
          @class.instance_methods.each_with_index do |method, i|
            newnode = Tree::TreeNode.new(i, method)
            leaf << newnode
            generate_parameters! newnode
          end
        end
      end
    end
    
    #Creates a list of Mock objects based on the number of optional parameters
    #For example, req=2, opt=1 gives [[M, M], [M, M, M]]
    def generate_parameters!(node, method=nil)
      method ||= @class.instance_method node.content

      req = opt = 0
      method.parameters.each do |type, name|
        req += 1 if type == :req
        opt += 1 if type == :opt
        # Other types are :rest, :block for * and & syntaxes, respectively
      end

      (req..opt+req).each_with_index do |n, i|
        node << Tree::TreeNode.new(i, Array.new(n) { Mock.new })
      end

      node
    end
  end
end
