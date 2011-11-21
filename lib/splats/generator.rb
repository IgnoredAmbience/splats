require 'tree'

# Provides ** array mixin ([1,2,3]**3 === [1,2,3]x[1,2,3]x[1,2,3])
# require 'cartesian'

module SPLATS
  # Keeps track of the class being tested and does much of the testing
  class Generator
    attr_reader :tree

    # Stores the class and initialises the tree
    def initialize(c)
      # The class that we are interested in testing
      @class = c
      @tree = nil
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
      tree = Tree::TreeNode.new "CONST: new/initialize", m
      generate_parameters! tree, im
    end

    # Goes through the tree doing magic
    def test_class(depth = 5)
      @tree = initialize_tree

      depth.times do
        @tree.each_leaf do |leaf|
          # Flatten each leaf out as a path to it in the tree
          path = leaf.parentage || []
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

    #Adds a new node to the leaf based on Tom magic
    def expand_tree!
      @tree.postordered_each do |leaf|
        expand_leaf! leaf
      end
    end

    def expand_leaf! leaf
      if leaf.is_leaf? and leaf.content
        @class.instance_methods(false).each_with_index do |method, i|
          newnode = Tree::TreeNode.new("#{i}: #{method}", method)
          generate_parameters! newnode
          leaf << newnode
        end
      end
    end

    #Creates a list of Mock objects based on the number of optional parameters
    #For example, req=2, opt=1 gives [[M, M], [M, M, M]]
    def generate_parameters!(node, method=nil)
      # If and only if method doesn't have a value, assign
      method ||= @class.instance_method node.content

      req = opt = 0
      method.parameters.each do |type, name|
        req += 1 if type == :req
        opt += 1 if type == :opt
        # Other types are :rest, :block for * and & syntaxes, respectively
      end

      (req..opt+req).each_with_index do |n, i|
        node << Tree::TreeNode.new("#{n} params", Array.new(n) { Mock.new })
      end

      node
    end

    # Loops through the test object and does stuff on test lines
    def execute_test test
      object = result = nil
      test.each do |test_line|
        begin
          if test_line.method.respond_to? :call
            object = test_line.method.call *test_line.arguments
          else
            result = object.send test_line.method, *test_line.arguments
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
