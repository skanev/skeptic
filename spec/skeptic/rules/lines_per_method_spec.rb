require 'spec_helper'

module Skeptic
  module Rules
    describe LinesPerMethod do
      it_behaves_like 'Rule' do
        subject { LinesPerMethod.new 10 }
      end

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
