require 'spec_helper'

module Skeptic
  module Rules
    describe CheckSyntax do
      it_behaves_like 'Rule'

      describe "checking syntax" do
        it "validates valid Ruby 1.9 programs" do
          expect_passing '->(song) { song.name }'
        end

        it "detects syntax errors" do
          expect_failing 'foo {'
        end
      end

      describe "reporting" do
        it "reports syntax errors" do
          rule = apply_rule CheckSyntax, 'foo {'

          rule.should have(1).violations
          rule.violations.first.should match /\AInvalid syntax:/
        end

        it "reports under 'Syntax check'" do
          CheckSyntax.new.name.should eq 'Syntax check'
        end
      end

      def expect_failing(code)
        apply_rule(CheckSyntax, code).violations.should_not be_empty
      end

      def expect_passing(code)
        apply_rule(CheckSyntax, code).violations.should be_empty
      end
    end
  end
end
