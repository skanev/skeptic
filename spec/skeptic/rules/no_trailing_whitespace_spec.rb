require 'spec_helper'

module Skeptic
  module Rules
    describe NoTrailingWhitespace do
      it_behaves_like 'Rule' do
        subject { NoTrailingWhitespace.new }
      end

      describe "detecting trailing whitespace" do
        it "compains if it finds trailing spaces or tabs" do
          expect_complaint "foo "
          expect_complaint "foo   "
          expect_complaint "foo\t"
          expect_complaint "foo\t\t\t"
          expect_complaint "foo\t "
          expect_complaint "foo \t"
          expect_complaint "foo \nbar"
        end

        it "does not get confused by a trailing newline" do
          expect_fine_and_dandy "foo\nbar"
          expect_fine_and_dandy "foo\nbar\n"
        end
      end

      describe "reporting" do
        it "points out the lines that have trailing whitespace" do
          rule = analyze "foo \nbar"
          rule.should have(1).violations
          rule.violations.should include 'Line 1 has trailing whitespace'
        end

        it "reports under the name 'Trailing Whitespace'" do
          NoTrailingWhitespace.new.name.should eq 'Trailing whitespace'
        end
      end

      def expect_fine_and_dandy(code)
        analyze(code).lines_with_trailing_whitespace.should be_empty
      end

      def expect_complaint(code)
        analyze(code).lines_with_trailing_whitespace.should_not be_empty
      end

      def analyze(code)
        apply_rule NoTrailingWhitespace, code
      end
    end
  end
end
