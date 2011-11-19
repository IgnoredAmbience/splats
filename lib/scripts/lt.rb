load "../splats.rb"

x = SPLATS::TestController.new("../../samples/LinkedList.rb", "generated_tests/")
x.multi_class_test
