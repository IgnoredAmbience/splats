to_test = ["classes", "classes2"]

to_test.each{ |c|
  constants = Module.constants
  load c + '.rb'
  (Module.constants - constants).each{|mc|
    puts Kernel.const_get(mc).instance_methods(false)
  }
}
