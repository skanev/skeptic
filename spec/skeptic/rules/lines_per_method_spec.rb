require 'spec_helper'

module Skeptic
  module Rules
    describe LinesPerMethod do
      it_behaves_like 'Rule' do
        subject { LinesPerMethod.new 10 }
      end

      describe "calculating method size" do
        it "works with methods defined by a class" do
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

        it "works with methods defined by a module" do
          code = <<-RUBY
            module Bar
              def foo
                first
                second
              end
            end
          RUBY

          analyze(code).size_of('Bar#foo').should eq 2
        end

        it "works with singleton methods (on a module or a class)" do
          code = <<-RUBY
            class Foo
              def self.bar
                first
                second
              end

              def Foo.baz
                first
                second
              end
            end
          RUBY

          analyze(code).size_of('Foo.bar').should eq 2
          analyze(code).size_of('Foo.baz').should eq 2
        end

        it "works with nested classes" do
          code = <<-RUBY
            module Parent
              class Child
                def method
                  first
                  second
                end
              end
            end
          RUBY

          analyze(code).size_of('Parent::Child#method').should eq 2
        end

        it "works with operators" do
          code = <<-RUBY
            class Foo
              def <=>(other)
                first
                second
              end
            end
          RUBY

          analyze(code).size_of('Foo#<=>').should eq 2
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
          LinesPerMethod.new(2).name.should eq 'Number of lines per method (2)'
        end
      end

      def expect_line_count(count, code)
        code = "class Foo\ndef bar\n#{code}\nend\nend"
        analyze(code).size_of('Foo#bar').should eq count
      end

      def analyze(limit = nil, code)
        apply_rule LinesPerMethod, limit, code
      end
    end
  end
end
