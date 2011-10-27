require 'spec_helper'

module Skeptic
  describe RuleTable do
    let(:table) { RuleTable.new }

    class TestRule
      DESCRIPTION = 'A test rule'
    end

    it "allows registering rules" do
      table.register TestRule, :int

      table.rules.should include TestRule
    end

    it "can the slugs for all rules" do
      table.register TestRule, :int

      table.slugs.should eq [:test_rule]
    end

    it "can iterate over all rules" do
      table.register TestRule, :int

      table.enum_for(:each_rule).should include [TestRule, :test_rule, :int, 'A test rule']
    end
  end
end
