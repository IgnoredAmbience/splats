require_relative "test"

module SPLATS

  # Wraps the inbuilt File class in something to more easily print Tests
  class TestFile < File

    # Behaves similarly to File.open, but automates some parameters and adds others
    # @param [Class] klass The class having tests printed
    # @param [Array] reqs The list of file requirements
    # @param [String] out_dir The output directory
    def self.open(klass, reqs, out_dir, &block)
      super("#{out_dir}/test_#{klass}.rb","w",nil) do |file|
        reqs << klass
        file << ((requirements reqs) + (header klass)).join("\n") << "\n"
        yield file
        file << footer
      end
    end

    private

    # The list of require statements
    def self.requirements reqs
      (['test/unit', 'flexmock/test_unit']).map{ |r| "require '#{r}'" } + reqs.map{ |r| "require_relative '#{r}'" }
    end

    # The class header
    #
    # @param [Class] klass Name of the class being tested
    def self.header klass
      ["class Test#{klass} < Test::Unit::TestCase"]
    end

    # The class footer
    def self.footer
      "end"
    end

  end
end
