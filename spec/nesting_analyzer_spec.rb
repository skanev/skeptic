require 'spec_helper'

module Skeptic
  describe NestingAnalyzer do
    describe "structure analysis" do
      it "counts all conditional forms as a level of nesting" do
        expect_deepest_nesting :if, 'if condition?; action; end'
        expect_deepest_nesting :if, 'if condition? then action end'
        expect_deepest_nesting :if, 'action if condition?'
        expect_deepest_nesting :unless, 'action unless condition?'
        expect_deepest_nesting :unless, 'unless condition?; action; end'
        expect_deepest_nesting :unless, 'unless condition? then action end'
        expect_deepest_nesting :if, :if, 'a if b? if c?'
      end

      it "counts else blocks as a level of nesting" do
        expect_deepest_nesting :if, :unless, 'if a?; else; foo unless b? end'
        expect_deepest_nesting :if, :unless, 'if a?; elsif? b?; else; foo unless c? end'
        expect_deepest_nesting :unless, :if, 'unless a?; else; foo if b? end'
      end

      it "counts elsif blocks as a level of nesting" do
        expect_deepest_nesting :if, :unless, 'if a?; elsif b?; foo unless c?; end'
        expect_deepest_nesting :if, :unless, 'if a?; elsif b?; foo unless c?; else; end'
      end

      it "counts unbound loops as a level of nesting" do
        expect_deepest_nesting :while, :if, 'while a?; b if c? end'
        expect_deepest_nesting :while, :if, '(a if b?) while c?'
        expect_deepest_nesting :until, :if, 'until a?; b if c? end'
        expect_deepest_nesting :until, :if, '(a if b?) until c?'
      end

      it "counts blocks as a level of nesting" do
        expect_deepest_nesting :iter, :if, 'a { b if c? }'
        expect_deepest_nesting :iter, :if, 'a(1) { b if c? }'
        expect_deepest_nesting :iter, :if, 'a do; b if c?; end'
        expect_deepest_nesting :iter, :if, 'a(1) do; b if c?; end'

        expect_deepest_nesting :iter, :if, 'loop { a if b }'
      end

      it "counts lambdas as a level of nesting" do
        expect_deepest_nesting :iter, :if, 'lambda { a if b }'
        expect_deepest_nesting :iter, :if, 'Proc.new { a if b }'
        expect_deepest_nesting :lambda, :if, '-> { a if b }'
      end

      it "counts for loops as a level of nesting" do
        expect_deepest_nesting :for, :if, 'for a in b; c if d; end'
      end

      it "counts case statements as a level of nesting" do
        expect_deepest_nesting :case, :if, 'case a; when b; c if d?; end'
        expect_deepest_nesting :case, :if, 'case a; when b; when c; d if e?; end'
        expect_deepest_nesting :case, :if, 'case a; when b; else; d if e?; end'
      end

      it "counts begin blocks as a level of nesting" do
        expect_deepest_nesting :begin, :if, 'begin; a if b; end'
      end

      it "does not count the method invocation as a block" do
        expect_a_nesting :if, 'a((b if c)) { d }'
        expect_a_nesting :iter, :if, 'a.b { c if d? }.e { g }'
        expect_a_nesting :iter, :unless, 'a.b { c unless d? }.c { }'
      end

      it "does not count the if condition as a level of nesting" do
        expect_a_nesting :iter, 'a if b { c }'
      end
    end

    describe "nesting location" do
      it "recognizes top-level code" do
        nestings('a if b').should include nesting(nil, nil, :if)
      end

      it "recognizes classes" do
        nestings('class A; a if b; end').should include nesting('A', nil, :if)
        nestings('class A::B; a if b; end').should include nesting('A::B', nil, :if)
      end

      it "recognizes methods" do
        nestings('def a; b if c; end').should include nesting(nil, 'a', :if)
        nestings('class A; def b; c if d; end; end').should include nesting('A', 'b', :if)
      end
    end

    describe NestingAnalyzer::Nesting do
      it "describes a level of nesting" do
        nesting(nil, nil, :for, :if).levels.should eq [:for, :if]
        nesting(nil, nil).levels.should eq []
      end

      it "can be compared to another nesting" do
        nesting(nil, nil, :for, :if).should eq nesting(nil, nil, :for, :if)
        nesting(nil, nil).should_not eq nesting(nil, nil, :if)
        nesting('Bar', nil).should_not eq nesting('Foo', nil)
        nesting(nil, 'bar').should_not eq nesting(nil, 'foo')
      end

      it "can be extended and unextended" do
        nesting(nil, nil, :for).push(:if).should eq nesting(nil, nil, :for, :if)
        nesting(nil, nil, :for, :if).pop.should eq nesting(nil, nil, :for)
        nesting(nil, nil, :for).in_class('Foo').should eq nesting('Foo', nil, :for)
        nesting(nil, nil, :for).in_method('bar').should eq nesting(nil, 'bar', :for)
      end

      it "knows its size" do
        nesting(nil, nil, :for).size.should eq 1
        nesting(nil, nil, :for, :if).size.should eq 2
        nesting(nil, nil, :for, :if, :if).size.should eq 3
      end
    end

    def nesting(class_name, method_name, *levels)
      NestingAnalyzer::Nesting.new(class_name, method_name, levels)
    end

    def nestings(code)
      analyze(code).nestings
    end

    def expect_a_nesting(*levels, code)
      analyze(code).nestings.should include nesting(nil, nil, *levels)
    end

    def expect_deepest_nesting(*levels, code)
      analyze(code).deepest_nesting.should eq nesting(nil, nil, *levels)
    end

    def analyze(code)
      tree = Ripper.sexp code
      analyzer = NestingAnalyzer.new
      analyzer.analyze tree
      analyzer
    end
  end
end
