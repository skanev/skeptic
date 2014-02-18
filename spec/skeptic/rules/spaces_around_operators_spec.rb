# encoding: utf-8
require 'spec_helper'

module Skeptic
  module Rules
    describe SpacesAroundOperators do
      it_behaves_like 'Rule' do
        subject { SpacesAroundOperators.new(nil) }
      end

      describe "detecting operators without spaces around them" do
        it "checks for spaces around operators" do
          rule = analyze code(<<-RUBY)
            def s
              'x'+'z'
            end
          RUBY

          rule.should have(1).violations
          rule.violations.should include 'no spaces around + on line 2'
        end

        it "checks for spaces left of an operator" do
          rule = analyze code("2+ d")

          rule.should have(1).violations
          rule.violations.should include 'no spaces around + on line 1'
        end

        it "checks for spaces right of an operator" do
          rule = analyze code("f +z")

          rule.should have(1).violations
          rule.violations.should include 'no spaces around + on line 1'
        end

        it "checks for valid operators with spaces around em" do
          expect_violations_count "pythoh + perl", 0
        end

        it "doesnt't check for spaces around **" do
          expect_violations_count "2 **java", 0
        end

        it "doesn't check for spaces around ::" do
          expect_violations_count "W::A", 0
        end

        it "checks for multiple operators" do
          code = <<-RUBY
            a = 2 +f
            b = 4+ g
            c = x+2+5
            e = 4
            f=2+z-z
          RUBY

          expect_violations_count code, 7
        end

        it "checks once for an operator" do
          expect_violations_count "2+ z", 1
        end

        it "doesn't check unary operators near brackets" do
          expect_violations_count "{:up => [-1, 1]}", 0
          expect_violations_count "{-1 => 2}", 0          
        end

        it "doesn't check block arguments" do
          expect_violations_count "a(&b)", 0
          expect_violations_count "def a(&c); end", 0
        end

        it "doesnt't check splat arguments" do
          expect_violations_count "a(*b)", 0
          expect_violations_count "def a(*c, d); end", 0
        end

        it "doesn't check block as symbol arguments" do
          expect_violations_count "a.map(&:to_s)", 0
        end

        it "doesn't check operator method names" do
          expect_violations_count "def |(other);true;end", 0
        end

        it "doesn't check splatted variables in assignment" do
          expect_violations_count "*a, b = [2, 3, 4]", 0
          expect_violations_count "$a, b = [4, 5]", 0
        end
      end

      describe "reporting" do
        it "reports under the name 'Spaces around operators'" do
          SpacesAroundOperators.new(nil).name.should eq 'Spaces around operators'
        end
      end

      def expect_violations_count(code, count)
        rule = analyze(code)

        rule.should have(count).violations
      end

      def analyze(code)
        apply_rule SpacesAroundOperators, nil, code
      end
    end
  end
end
