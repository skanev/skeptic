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
