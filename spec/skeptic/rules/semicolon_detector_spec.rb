require 'spec_helper'

module Skeptic
  module Rules
    describe SemicolonDetector do
      describe "detecting semicolons" do
        it "complains if it finds a semicolon in the code" do
          expect_complaint 'foo; bar'
          expect_complaint 'this; that; other'
          expect_complaint '"#{foo;bar}"'
        end

        it "does not complain for semicolons in literals" do
          expect_fine_and_dandy '"foo;"'
          expect_fine_and_dandy '";"'
          expect_fine_and_dandy '/;/'
        end

        it "can tell the locations of the semicolons" do
          analyze("foo;\n;bar").offending_spots.should =~ [[1, 3], [2, 0]]
        end
      end

      describe "reporting" do
        it "points out file locations with semicolons" do
          analyzer = analyze 'foo; bar'

          analyzer.violations.should include 'You have a semicolon at line 1, column 3'
        end

        it "reports under 'No semicolons'" do
          SemicolonDetector.new(true).rule_name.should eq 'No semicolons as expression separators'
        end
      end

      def expect_fine_and_dandy(code)
        analyze(code).should_not be_complaining
      end

      def expect_complaint(code)
        analyze(code).should be_complaining
      end

      def analyze(code)
        SemicolonDetector.new(true).apply_to Ripper.lex(code), nil
      end
    end
  end
end
