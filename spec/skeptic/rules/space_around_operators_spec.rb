# encoding: utf-8
require 'spec_helper'

module Skeptic
  module Rules
    describe SpaceAroundOperators do
      it_behaves_like 'Rule' do
        subject { SpaceAroundOperators.new }
      end

      describe "detecting operators without space around them" do
        it "checks for space around operators" do
          rule = analyze code(<<-RUBY)
            def s
              'x'+'z'
            end
          RUBY

          rule.should have(1).violations
          rule.violations.should include 'no space in left of + on 2 \'x\'+\'z\''
        end

        it "checks for space left of an operator" do
          rule = analyze code(<<-RUBY)
            2+ d
          RUBY

          rule.should have(1).violations
          rule.violations.should include 'no space in left of + on 1 2+ d'
        end

        it "checks for space right of an operator" do
          rule = analyze code(<<-RUBY)
            f +g
          RUBY

          rule.should have(1).violations
          rule.violations.should include 'no space in right of + on 1 f +g'
        end

        it "checks for valid operators with space around em" do
          rule = analyze code(<<-RUBY)
            python + perl
          RUBY

          rule.should have(0).violations
        end

        it "doesnt't check for spaces around **" do
          rule = analyze code(<<-RUBY)
            2 **java
          RUBY

          rule.should have(0).violations
        end

        it "checks for multiple operators" do
          rule = analyze code(<<-RUBY)
            a = 2 +f
            b = 4+ g
            c = x+2+5
            e = 4
            f=2+z-z
          RUBY

          rule.should have(7).violations
        end

        it "checks once for an operator" do
          rule = analyze code(<<-RUBY)
            2+ a
          RUBY

          rule.should have(1).violations
        end
      end

      describe "reporting" do
        it "reports under the name 'Space around operators'" do
          SpaceAroundOperators.new.name.should eq 'Space around operators'
        end
      end

      def analyze(code)
        apply_rule SpaceAroundOperators, code
      end
    end
  end
end
