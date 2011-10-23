require 'spec_helper'

module Skeptic
  describe MethodSizeAnalyzer do
    it "can count the size of a method" do
      code = <<-RUBY
        class Foo
          def bar
            first
            second
          end
        end
      RUBY

      analyze(code).size_of('Foo#bar').should eq 2
    end

    it "does not count empty lines" do
      expect_line_count 2, <<-RUBY
        foo

        bar
      RUBY
    end

    it "does not count lines containing one end" do
      expect_line_count 2, <<-RUBY
        if foo
          bar
        end
      RUBY
    end

    it "can tell the names of the methods found" do
      analyzer = analyze <<-RUBY
        class Foo
          def bar; end
          def baz; end
        end

        class Qux
          def waldo; end
          def plugh; end
        end
      RUBY

      analyzer.method_names.should =~ %w[Foo#bar Foo#baz Qux#waldo Qux#plugh]
    end

    def expect_line_count(count, code)
      code = "class Foo\ndef bar\n#{code}\nend\nend"
      analyze(code).size_of('Foo#bar').should eq count
    end

    def analyze(code)
      analyzer = MethodSizeAnalyzer.new
      analyzer.analyze Ripper.sexp(code)
      analyzer
    end
  end
end
