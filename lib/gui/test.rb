module SPLATS
  class HumanTraversal
    def select_method methods
      if :gui
        ['What is your name?', methods]
      else
        puts 'What is your name?'
        gets
      end
    end
  end
end
