require_relative "test"

module SPLATS
  class TestFile < File

    # @param[Class] klass The class having tests printed
    # @param[Array] reqs The list of file requirements
    # @param[String] out_dir The output directory
    def self.open(klass, reqs, out_dir, &block)
      super("#{out_dir}/test_#{klass}.rb","w",nil) do |file|
        file << ((requirements reqs) + (header klass)).join("\n") << "\n"
        yield file
        file << footer
      end
    end

    private

    # The list of require statements
    def self.requirements reqs
      (['test/unit'] + reqs).map{ |r| "require '#{r}'" }
    end

    # The class header
    def self.header klass
      ["class test_#{klass} < Test::Unit::TestCase"]
    end

    # The class footer
    def self.footer
      "end"
    end

  end
end
