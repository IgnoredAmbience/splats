require_relative 'tree'

module SPLATS
  class DepthLimitedTraversal
    include Traversal

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
=begin

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
=end
  end
end
