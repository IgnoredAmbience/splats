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
    
    def delete(nodeVal)
                    
    end

    def each(node=self.rootNode, &block)
        if (node != nil)
            yield(node.value)
        
        each(node.left, &block)
        each(node.right, &block)
        end
    end
   
    class Node
        def initialize(nodeVal, leftVal=nil, rightVal=nil)
            @value, @left, @right = nodeVal, leftVal, rightVal
        end

        attr_accessor :value, :left, :right
        def insert(insertValue)
            if insertValue < @value
	            if @left == nil
                    @left = Node.new(insertValue)
                else
                    @left.insert(insertValue)
                end
            else 
                if @right == nil
                    @right = Node.new(insertValue)
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
    end
end
