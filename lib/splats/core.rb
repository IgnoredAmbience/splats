require 'tree'

module SPLATS
  class Core
    def initialize(c)
      # The class that we interested in testing
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

      # Indexing not unique = may cause future problems
      generate_parameters(im).each_with_index {|params, i|
        tree << Tree::TreeNode.new(i, params)
      }

      tree
    end

    def expand_tree


    # Takes a method object and generates a list of parameters to test it with
    def generate_parameters(method)
      param_options = []

      req = opt = 0
      method.parameters.each {|type, name|
        req += 1 if type == :req
        opt += 1 if type == :opt
        # Other types are :rest, :block for * and & syntaxes, respectively
      }

      (req..opt+req).each { |n|
        param_options.push(Array.new(n) { Mock.new })
      }
      param_options
    end
  end
end
