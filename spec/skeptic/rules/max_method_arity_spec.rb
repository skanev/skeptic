# encoding: utf-8
require 'spec_helper'

module Skeptic
  module Rules
    describe MaxMethodArity do
      let(:limit) { MaxMethodArity::MAX_METHOD_ARITY }

      it_behaves_like 'Rule' do
        subject { MaxMethodArity.new }
      end

       describe "limiting method arity" do
        it "works with for a method without parameters" do
          do_not_expect_complaint limit, <<-RUBY
            class Foo
              def bar; end
            end
          RUBY
        end

        it "works with for multiple methods" do
          do_not_expect_complaint 4, <<-RUBY
            class Foo
              def bar; end
              def baz(x, y, z); end
            end
          RUBY
        end

        it "works for class methods" do
          do_not_expect_complaint 2, <<-RUBY
            class Foo
              def Foo.bar(x); end
              def Foo.baz(y); end
            end
          RUBY
        end

        it "works for class methods defined in a class block" do
          do_not_expect_complaint 2, <<-RUBY
            class Foo
              class << self
                def boo(x); end
              end
            end
          RUBY
        end

        it "catches violations for instance methods" do
          expect_complaint 1, <<-RUBY
            class Foo
              def foo(x, y); end
            end
          RUBY
        end

        it "catches violations for multiple instance methods" do
          expect_complaint 1, <<-RUBY
            class Foo
              def foo(x, y); end
              def bar(a, b, c); end
            end
          RUBY
        end

        it "doesn't complain when the number of parameters is equal to the limit" do
          do_not_expect_complaint 2, <<-RUBY
            class Foo
              def foo(x, y); end
            end
          RUBY
        end
      end

      describe "reporting" do
        it "can report methods that have more arguments than permitted" do
          analyzer = analyze 1, <<-RUBY
            class Foo
              def bar(x, y); end
            end
          RUBY

          analyzer.violations.should include 'Foo#bar has 2 arguments (maximum method arity: 1)'
        end

        it "can report nested methods that have more arguments than permitted" do
          analyzer = analyze 3, <<-RUBY
            module Foo
              module Bar
                class Baz
                  def alphabet(a, b, c, d, e, f, g); end
                end
              end
            end
          RUBY

          analyzer.violations.should include 'Foo::Bar::Baz#alphabet has 7 arguments (maximum method arity: 3)'
        end

        it "can reports correctly class methods defined in a class block" do
          analyzer = analyze 1, <<-RUBY
            class Baz
              def self.perimeter(a, b); end
            end
          RUBY

          analyzer.violations.should include 'Baz.perimeter has 2 arguments (maximum method arity: 1)'
        end

        it "can report class methods that have more arguments than permitted" do
          analyzer = analyze 1, <<-RUBY
            class Foo
              def Foo.bar(x, y); end
            end
          RUBY

          analyzer.violations.should include 'Foo.bar has 2 arguments (maximum method arity: 1)'
        end

        it "reports under 'Maximum method arity'" do
          MaxMethodArity.new(42).name.should eq 'Maximum method arity (42)'
        end
      end

      def analyze(limit, code)
        apply_rule MaxMethodArity, limit, code
      end

      def expect_complaint(limit, code)
        analyze(limit, code).violations.should_not be_empty
      end

      def do_not_expect_complaint(limit, code)
        analyze(limit, code).violations.should be_empty
      end
    end
  end
end