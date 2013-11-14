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
          rule = analyze code("pythoh + perl")

          rule.should have(0).violations
        end

        it "doesnt't check for spaces around **" do
          rule = analyze code("2 **java")

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
          rule = analyze code("2+ z")

          rule.should have(1).violations
        end
      end

      describe "reporting" do
        it "reports under the name 'Spaces around operators'" do
          SpacesAroundOperators.new(nil).name.should eq 'Spaces around operators'
        end
      end

      def analyze(code)
        apply_rule SpacesAroundOperators, nil, code
      end
    end
  end
end
