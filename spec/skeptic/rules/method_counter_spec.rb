require 'spec_helper'

module Skeptic
  module Rules
    describe MethodCounter do
      describe "counting methods" do
        it "counts methods defined in classes" do
          expect_method_count 'Foo', 2, <<-RUBY
            class Foo
              def bar; end
              def baz; end
            end
          RUBY
        end

        it "counts methods defined in modules" do
          expect_method_count 'Foo', 2, <<-RUBY
            module Foo
              def bar; end
              def baz; end
            end
          RUBY
        end

        it "counts method defined when the class is reopened" do
          expect_method_count 'Foo', 2, <<-RUBY
            class Foo; def bar; end; end
            class Foo; def baz; end; end
          RUBY
        end

        it "counts redefining the method as a new method" do
          expect_method_count 'Foo', 2, <<-RUBY
            class Foo
              def bar; end
              def bar; end
            end
          RUBY
        end

        it "works with multiple classes" do
          counter = analyze <<-RUBY
            class Foo; def name; end; end
            class Bar; def name; end; end
          RUBY

          counter.methods_in('Foo').should eq 1
          counter.methods_in('Bar').should eq 1
        end

        it "can tell names of the classes found" do
          counter = analyze <<-RUBY
            class Foo; def name; end; end
            class Bar; def name; end; end
          RUBY

          counter.class_names.should =~ %w[Foo Bar]
        end

        it "recognizes qualified module names" do
          expect_method_count 'Foo::Bar', 1, <<-RUBY
            class Foo::Bar; def baz; end; end
          RUBY
        end

        it "recognizes modules nested under other modules" do
          expect_method_count 'Foo::Bar', 1, <<-RUBY
            class Foo; module Bar; def baz; end; end; end
          RUBY
        end
      end

      describe "reporting" do
        it "reports classes, violating the rule" do
          analyzer = analyze 1, <<-RUBY
            class Foo
              def bar; end
              def baz; end
            end
          RUBY

          analyzer.violations.should include 'Foo has 2 methods: #bar, #baz'
        end

        it "reports under 'Number of methods per class'" do
          MethodCounter.new(42).rule_name.should eq 'Number of methods per class (42)'
        end
      end

      def analyze(limit = nil, code)
        MethodCounter.new(limit).apply_to nil, Ripper.sexp(code)
      end

      def expect_method_count(class_name, count, code)
        analyze(code).methods_in(class_name).should eq count
      end
    end
  end
end
