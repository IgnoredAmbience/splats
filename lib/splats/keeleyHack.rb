# Look it's obviously horrible, I am trying things to see what happens

class SplatsMain
    attr_accessor :testClass 

    def initialize (testClass)
        @testClass = testClass
    end

    def test
        for methodName in @testClass.methods
            begin
                puts methodName
                puts testClass.send(methodName).arity
                #testClass.send(methodName).send(nil)
            rescue Exception => e
                puts e.message
            end
        end
    end
end
