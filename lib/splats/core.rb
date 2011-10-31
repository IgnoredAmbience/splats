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

      @class.instance_methods(false).each do |m|
        test_method @obj.method(m)
      end
    end

    def test_method(method, params=nil)
      params = get_params(method) if params.nil?
      req_params, opt_params, rest_params, block_params = params

      puts "%s has %d required parameters, %d optional parameters, %s extra parameters and %s block." %
      [method, req_params.length, opt_params.length,
        (rest_params ? "some" : "no"), (block_params ? "maybe a" : "no")]

      args = Array.new(req_params.length) { Mock.new }
      [args, method.call(*args)]
    end

    def get_params(method)
      params = method.parameters
      req_params, opt_params = [], []

      for p in params
        case p[0]
        when :req
          req_params.push p[1]
        when :opt
          opt_params.push p[1]
        when :rest
          rest_params = p[1]
        when :block
          block_params = p[1]
        end
      end
      [req_params, opt_params, rest_params, block_params]
    end   
  end
end
