require 'tree'

# Provides ** array mixin ([1,2,3]**3 === [1,2,3]x[1,2,3]x[1,2,3])
require 'cartesian'

module SPLATS
  # Generates tests for a given class
  class Generator
    attr_reader :tree

    # @param [Class] c The class for the test generator to operate on
    def initialize c
      @class = c
      @tree = nil
      @pass_parameters = [Mock, nil]
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
          test = Test.new

          puts "Generating test: " + path_content.inspect
          while path_content.length > 0
            method = path_content.shift
            parameters = path_content.shift
            test.add_line(method, parameters)
          end
          test.add_result (execute_test test)
          yield test
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

      (req..opt+req).each do |n|
        if n == 1
          iter = @pass_parameters.map{|p| [p]}.each
        else
          iter = (@pass_parameters ** n).each
        end

        if iter.count == 0
          leaf << Tree::TreeNode.new("", [])
        else
          iter.each do |args|
            leaf << Tree::TreeNode.new(args.hash, args)
          end
        end
      end
    end

    # Executes a given test
    #
    # @param [Test] test
    def execute_test test
      object = result = nil
      test.each do |test_line|
        begin
          # Construct any arguments that are Classes
          arguments = test_line.arguments.map do |arg|
            if arg.is_a? Class
              arg.new
            else
              arg
            end
          end

          if test_line.method.respond_to? :call
            object = test_line.method.call *arguments
          else
            result = object.send test_line.method, *arguments
          end
        rescue Exception => e
          puts "!> " + e.to_s
        end
      end

      puts "=> " + result.inspect
      result
    end
  end
end
