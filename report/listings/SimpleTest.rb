# Adapted from http://www.doc.ic.ac.uk/~tora/LazyJavaCheck/Test.java-v1.txt
class SimpleTest
  def to_s(obj)
    x = obj.foo
    if x == 1
      obj.bar
      @str = "hi"
    else
      sized_thing = obj.get_sized_thing
      if sized_thing.size == 1
        @str = "hello"
      else
        @str = "uh oh"
      end
    end
    @str
  end
end
