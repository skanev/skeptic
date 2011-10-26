require 'spec_helper'

module Skeptic
  module Rules
    describe MethodSizeAnalyzer do
      describe "calculating method size" do
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
      end

      describe "reporting" do
        it "can tell which methods are too long" do
          analyzer = analyze 1, <<-RUBY
            class Foo
              def bar
                one
                two
                three
              end
            end
          RUBY

          analyzer.violations.should include 'Foo#bar is 3 lines long'
        end

        it "reports under 'Number of lines per method'" do
          MethodSizeAnalyzer.new(2).rule_name.should eq 'Number of lines per method (2)'
        end
      end

      def expect_line_count(count, code)
        code = "class Foo\ndef bar\n#{code}\nend\nend"
        analyze(code).size_of('Foo#bar').should eq count
      end

      def analyze(limit = nil, code)
        MethodSizeAnalyzer.new(limit).analyze_sexp Ripper.sexp(code)
      end
    end
  end
end
