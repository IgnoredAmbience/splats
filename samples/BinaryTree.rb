class BinaryTree
    attr_accessor :rootNode

    def initialize(nodeVal)
        @rootNode = Node.new(nodeVal)
    end

    def insert(insertVal)
        self.rootNode.insert(insertVal)
    end

    def find(nodeVal)
        self.rootNode.findNode(nodeVal)
    end
    
    def delete(deleteValue)
        nodeToDelete = self.rootNode.findNode(deleteValue)
        puts nodeToDelete
        if nodeToDelete.leaf?
            nodeToDelete.delete_parent_reference
        elsif nodeToDelete.left ^ nodeToDelete.right
            if nodeToDelete.left
                nodeToDelete.delete_parent_reference(nodeToDelete.left)
            else
                nodeToDelete.delete_parent_reference(nodeToDelete.right)
            end
        else
            
        end
    end

    def each(node=self.rootNode, &block)
        if (node != nil)
            each(node.left, &block)
            yield(node.value)
            each(node.right, &block)
        end
    end
   
    class Node
        def initialize(nodeVal, parent=nil, leftVal=nil, rightVal=nil)
            @value, @parent, @left, @right = nodeVal, parent, leftVal, rightVal
        end

        attr_accessor :value, :parent, :left, :right
        def insert(insertValue)
            if insertValue < @value
	            if @left == nil
                    @left = Node.new(insertValue, self)
                else
                    @left.insert(insertValue)
                end
            else 
                if @right == nil
                    @right = Node.new(insertValue, self)
                else
                    @right.insert(insertValue)
                end
            end
        end

        def leaf?
            self.left == nil && self.right == nil
        end

        def findNode(nodeVal)
            if nodeVal == self.value
                return self
            elsif nodeVal < self.value
                if self.left != nil
                    self.left.findNode(nodeVal)
                else
                    return nil
                end
            elsif nodeVal > self.value 
                if self.right != nil
                    self.right.findNode(nodeVal)
                else
                    return nil
                end
            end
        end 	

	def delete_parent_reference(newVal=nil)
        if self.parent.left == self
            self.parent.left = newVal
        else 
            self.parent.right = newVal
        end
        if newVal
            newVal.parent = self.parent
        end
    end
    
    def smallest_child
        current_node = self
        while current_node.left
            current_node = current_node.left
        return current_node
    end

    end
end
