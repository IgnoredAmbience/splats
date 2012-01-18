require_relative "test"

module SPLATS
  # Wraps the inbuilt File class in something to more easily print Tests
  class TestFile < File

    # Behaves similarly to File.open, but automates some parameters and adds others
    # @param [Class] klass The class having tests printed
    # @param [Array] reqs The list of file requirements
    # @param [String] out_dir The output directory
    # @yield [File] The file to write to
    def self.open(klass, reqs, out_dir, &block)
      super("#{out_dir}/test_#{klass}.rb","w",nil) do |file|
        reqs << klass
        file << ((requirements reqs) + (header klass)).join("\n") << "\n"
        yield file
        file << footer
      end
    end

    private

    # Produces the require statements
    # @param [<#to_s>] reqs The list of file requirements
    # @return [<String>] The list of require statements
    def self.requirements reqs
      (['test/unit', 'flexmock/test_unit']).map{ |r| "require '#{r}'" } + reqs.map{ |r| "require_relative '#{r}'" }
    end

    # Produces the class header
    # @param [Class] klass The class under test
    # @return [<String>] The class header
    def self.header klass
      ["class Test#{klass} < Test::Unit::TestCase"]
    end

    # Produces the class footer
    # @return [String] The footer
    def self.footer
      "end"
    end

  end
end
