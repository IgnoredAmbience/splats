require 'tree'

module Tree
  class TreeNode
    def postordered_each(&block) # :yields: node
      children { |child| child.postordered_each(&block) }
      yield self
    end

    # Says that trees are equal if the keys are the same
    def eql? other
      # Loop through each node in this, and each node in the other.
      self_values = []
      other_values = []

      self.preordered_each() { |node|
        self_values.push(node.name)
      }

      other.preordered_each() { |node|
        other_values.push(node.name)
      }

      self_values == other_values
    end
  end
end