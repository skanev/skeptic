require 'spec_helper'

module Skeptic
  describe Environment do
    let(:env) { Environment.new }

    it "maps names to objects" do
      env[:foo] = 42
      env[:foo].should eq 42
    end

    it "returns nil for names that are not set" do
      env[:foo].should be_nil
    end

    it "allows environments to be extender" do
      env.push foo: 2
      env[:foo].should eq 2
    end

    it "allows environments to be unextended" do
      env[:foo] = 1
      env.push foo: 2
      env.pop
      env[:foo].should eq 1
    end

    it "looks up undefined names in the closure" do
      env[:foo] = 1
      env.push
      env[:foo].should eq 1
    end

    it "can be extended for a block" do
      executed_block = false

      env[:foo] = 1
      env.scoped do
        env[:foo] = 2
        env[:foo].should eq 2
        executed_block = true
      end

      executed_block.should be_true
      env[:foo].should eq 1
    end
  end
end
