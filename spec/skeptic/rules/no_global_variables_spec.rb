require 'spec_helper'

module Skeptic
  module Rules
    describe NoGlobalVariables do
      it_behaves_like 'Rule' do
        subject { NoGlobalVariables.new }
      end

      describe 'detecting global variables' do
        it 'finds a global variable in code' do
          expect_global_variable '$d = 2'
          expect_global_variable '$e = []'
          expect_global_variable 'def weird;$g = 4;end'
          expect_peace 'no_global_conflicts = 0'
        end

        it "finds a global variable in string interpolation" do
          expect_global_variable '"#{$a}"'
        end
      end

      describe 'reporting' do
        it 'points out lines of global variables' do
          analyzer = analyze <<-RUBY
            a = 2
            $h = 0
            zoo = 2
          RUBY

          analyzer.violations.should include 'You have a global variable $h on line 2'
        end
      end

      def expect_peace(code)
        analyze(code).violations.should be_empty
      end

      def expect_global_variable(code)
        analyze(code).violations.should_not be_empty
      end

      def analyze(code)
        apply_rule NoGlobalVariables, true, code
      end
    end
  end
end
