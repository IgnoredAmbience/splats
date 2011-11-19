require 'tree'

# Provides ** array mixin ([1,2,3]**3 === [1,2,3]x[1,2,3]x[1,2,3])
# require 'cartesian'

module SPLATS
  # Generates tests for a given class
  class Generator
    attr_reader :tree

    # Stores the class
    def initialize c
      @class = c
      @tree = nil
    end

    def to_s
      "<SPLATS::Generator @class=#{@class}>"
    end

    # Initializes the tree
    # This is split out from the constructor for testing purposes
    #
    # @return [Tree::TreeNode] Newly constructed tree containing class constructor
    def initialize_tree
      # Insert constructor into tree
      m = @class.method :new
      tree = Tree::TreeNode.new "CONST: new/initialize", m

      # Use parameters from :initialize for :new, as its type definition
      # prevents us from getting the detail we need
      im = @class.instance_method :initialize
      generate_parameters! tree, im

      tree
    end

    # Starts the test generation
    #
    # @param [Integer] depth The depth to traverse the search space
    def test_class(depth = 5)
      @tree = initialize_tree

      depth.times do
        @tree.each_leaf do |leaf|
          # Flatten each leaf out as a path to it in the tree
          path = leaf.parentage || []
          # leaf.parentage does not contain leaf
          path.reverse! << leaf

          path_content = path.map {|node| node.content}

          puts "Running test: " + path_content.inspect
          test = TestLine.from_path path_content
          result = execute_test test
          yield(test, result)
        end
        expand_tree!
      end
    end

    private

    # Expands the tree by one layer of method/argument sets
    def expand_tree!
      @tree.postordered_each do |leaf|
        expand_leaf! leaf
      end
    end

    # Expands a leaf of the tree with methods to execute, followed by parameters
    # for that method
    #
    # @param [Tree::TreeNode] leaf
    def expand_leaf! leaf
      if leaf.is_leaf? and leaf.content
        @class.instance_methods(false).each_with_index do |method, i|
          newnode = Tree::TreeNode.new("#{i}: #{method}", method)
          generate_parameters! newnode
          leaf << newnode
        end
      end
    end

    # Expands the given tree node with all possible argument sets
    #
    # @param [Tree::TreeNode<Symbol, Method>] leaf Leaf to be expanded with
    #   arguments. Arity information will be retrieved from the instance method
    #   of the given symbol
    # @param [Method] method If given, arity information will always be
    #   retrieved from this method.
    def generate_parameters!(leaf, method=nil)
      # If and only if method doesn't have a value, assign
      method ||= @class.instance_method leaf.content

      req = opt = 0
      method.parameters.each do |type, name|
        req += 1 if type == :req
        opt += 1 if type == :opt
        # Other types are :rest, :block for * and & syntaxes, respectively
      end

      (req..opt+req).each_with_index do |n, i|
        leaf << Tree::TreeNode.new("#{n} params", Array.new(n) { Mock.new })
      end
    end

    # Executes a given test
    #
    # @param [Array<TestLine>] test_lines
    def execute_test test_lines
      object = result = nil
      test_lines.each do |test|
        begin
          if test.method.respond_to? :call
            object = test.method.call *test.arguments
          else
            result = object.send test.method, *test.arguments
          end
        rescue Exception => e
          puts "!> " + e.to_s
        end
      end

      puts "=> " + result.inspect + "\n\n"
      result
    end
  end
end
