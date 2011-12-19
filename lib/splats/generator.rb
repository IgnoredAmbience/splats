require 'tree'

module SPLATS
  # Generates tests for a given class
  class Generator

    # @param [Class] c The class for the test generator to operate on
    # @param [Traversal] traversal The traversal object to use to direct the
    #   search
    def initialize(c, traversal)
      @class = c
      @tree = nil
      @pass_parameters = [Mock, nil]
      @traversal = traversal
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
      tree = MethodNode.new "CONST: new/initialize", m

      # Use parameters from :initialize for :new, as its type definition (which is varargs)
      # prevents us from getting the detail we need
      im = @class.instance_method :initialize
      generate_parameters! tree, im

      tree
    end

    def produce_test
      test = Test.new
      method = @traversal.select_method [@class.method(:new)]
      args = @traversal.select_arguments generate_parameters(:initialize)
      test.add_line(method, args)

      while @traversal.continue_descent?
        method = @traversal.select_method @class.instance_methods(false)
        args = @traversal.select_arguments generate_parameters(method)
        test.add_line(method, args)
      end
    end

    # Starts the test generation
    #
    # @param [Integer] depth The depth to traverse the search space
    def test_class(depth)
      @tree = initialize_tree
      skipIter = false

      depth.times do
        @tree.each_leaf do |leaf|
          # Flattens tree
          path = leaf.parentage || []
          # leaf.parentage does not contain leaf
          path.reverse! << leaf

          path_content = path.map {|node| node.content}
          puts
          puts "Generating test: " + path_content.inspect

          if skipIter
            puts "Skipping, as we've already done this!"
            skipIter = false

            if leaf.is_a? MockDecision
              next
            end
          end

          test = Test.new

          while path.length > 0
            method = path.shift.content
            parameters = path.shift.content

            decisions = path.take_while{|n| n.is_a? MockDecision }
            decisions.map! {|d| d.content }

            test.add_line(method, parameters, decisions)

            path = path.drop_while {|n| n.is_a? MockDecision }
          end

          test.execute! do |branch_values|
            # Because we're inserting to the tree and traversing pre-order at
            # the same time, we need to skip the next iteration, as we'll have
            # already covered it 'outside' of the traversal
            skipIter = true

            puts "Inserting branches: #{branch_values}"
            mock_decisions = branch_values.map {|v| MockDecision.new v.hash, v}
            mock_decisions.each do |md|
              leaf << md
            end
          end

          yield test
        end

        if tree_expandable?
          expand_tree!
        else
          break
        end
      end
    end


    def tree_expandable?
      not @class.instance_methods(false).empty?
    end

    # Expands the tree by one layer of method/argument sets
    # We use post order because we're modifying leaves as we go down
    # Any other traversal method would be modifying leaves that we'd later
    # visit again, which not terminate.
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
          newnode = MethodNode.new("#{i}: #{method}", method)
          generate_parameters! newnode
          leaf << newnode
        end
      end
    end

    # Expands the given tree node with all possible argument sets
    #
    # @param [Symbol,Method] method Method to retrieve arity information from.
    #   If a symbol is passed, it represents an instance method of the class
    #   under testing.
    # @return [Array<@pass_parameters>] Array of all possible argument sets,
    #   valid for the given method.
    def generate_parameters(method)
      # If it's not a method, try to make it one
      unless method.respond_to? :parameters
        method = @class.instance_method method
      end

      req = method.parameters.count :req
      opt = method.parameters.count :opt
      # Other types are :rest, :block, for * and & syntaxes, respectively

      (req..opt+req).flat_map do |n|
        @pass_parameters.repeated_permutation(n).to_a
      end
    end
  end
end
