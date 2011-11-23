require 'tree'

module Tree
  class TreeNode
    def postordered_each(&block) # :yields: node
      children { |child| child.postordered_each(&block) }
      yield self
    end

    def eql? other
      # Loop through each node in this, and each node in the other.
      # Generate an array and then compare the values of the array
    end
  end
  
  class MockDecision < TreeNode
  end
  
  class MethodNode < TreeNode
  end
  
  class DecisionNode < TreeNode
  end
end
