class SplatsMain
    attr_accessor :testClass 

    def initialize (testClass)
        @testClass = testClass
    end

    def test()
        for methodName in @testClass.methods
            begin
                testClass.send(methodName).send(nil)
            rescue Exception => e
                puts e.message
            end
        end
    end
end
