module SPLATS
  class Core
    def initialize(c)
      @class = c
    end

    def test_class
      # We need to instantiate first, this may result in multiple returned
      # objects, if we can instantiate with parameters
      m = @class.method(:new)
      im = @class.instance_method(:initialize)
      args, @obj = test_method(m, get_params(im))

      @obj.methods.each do |m|
        test_method @obj.method(m)
      end
    end

    def test_method(method, params=nil)
      params = get_params(method) if params.nil?
      req_params, opt_params = params
      puts "%s has %d required%s parameters" %
        [method, req_params, (opt_params ? " and some optional" : "")]

      args = Array.new(req_params) { Mock.new }

      [args, method.call(*args)]
    end

    def get_params(method)
      params = method.arity
      req_params = (params >= 0) ? params : -(params + 1)
      opt_params = params < 0
      [req_params, opt_params]
    end
  end
end
