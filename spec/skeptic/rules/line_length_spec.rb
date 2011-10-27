# encoding: utf-8
require 'spec_helper'

module Skeptic
  module Rules
    describe LineLength do
      describe "detecting long lines" do
        it "calculates the length of the lines" do
          expect_longest_line 2, 9, code(<<-RUBY)
            foo
            something
            plugh
          RUBY
        end

        it "does not get confused by unicode" do
          expect_longest_line 1, 7, 'förstår'
        end
      end

      describe "reporting" do
        it "points out the lines that are over the limit" do
          rule = analyze 5, code(<<-RUBY)
            short
            longer
          RUBY

          rule.should have(1).violations
          rule.violations.should include 'Line 2 is too long: 6 columns'
        end

        it "reports under the name 'Line length (42)'" do
          LineLength.new(42).name.should eq 'Line length (42)'
        end
      end

      def expect_longest_line(line, length, code)
        analyze(code).line_lengths[line].should eq length
      end

      def analyze(limit = 0, code)
        apply_rule LineLength, limit, code
      end
    end
  end
end
