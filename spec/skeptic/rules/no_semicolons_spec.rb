require 'spec_helper'

module Skeptic
  module Rules
    describe NoSemicolons do
      it_behaves_like 'Rule' do
        subject { NoSemicolons.new }
      end

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
          analyze("foo;\n;bar").semicolon_locations.should =~ [[1, 3], [2, 0]]
        end
      end

      describe "reporting" do
        it "points out file locations with semicolons" do
          analyzer = analyze 'foo; bar'

          analyzer.violations.should include 'You have a semicolon at line 1, column 3'
        end

        it "reports under 'No semicolons'" do
          NoSemicolons.new(true).name.should eq 'No semicolons as expression separators'
        end
      end

      def expect_fine_and_dandy(code)
        analyze(code).semicolon_locations.should be_empty
      end

      def expect_complaint(code)
        analyze(code).semicolon_locations.should_not be_empty
      end

      def analyze(code)
        apply_rule NoSemicolons, true, code
      end
    end
  end
end
