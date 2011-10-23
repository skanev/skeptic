require 'spec_helper'

module Skeptic
  describe MethodCounter do
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

    def analyze(code)
      counter = MethodCounter.new
      counter.analyze Ripper.sexp(code)
      counter
    end

    def expect_method_count(class_name, count, code)
      analyze(code).methods_in(class_name).should eq count
    end
  end
end
