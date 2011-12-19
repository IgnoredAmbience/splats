module SPLATS
  class Traversal
    def select_method methods
      raise NotImplementedError
    end
    
    def select_arguments arguments
      raise NotImplementedError
    end

    def select_decision decisions
      raise NotImplementedError
    end

    def continue_descent?
      raise NotImplementedError
    end
  end
end