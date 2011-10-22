require 'spec_helper'

module Skeptic
  describe Scope do
    it "contains levels of nesting" do
      Scope.new(nil, nil, [:for, :if]).levels.should eq [:for, :if]
      Scope.new(nil, nil, []).levels.should eq []
      Scope.new.levels.should eq []
    end

    it "can be compared to another scope" do
      Scope.new(nil, nil, [:for, :if]).should eq Scope.new(nil, nil, [:for, :if])
      Scope.new(nil, nil, []).should_not eq Scope.new(nil, nil, [:if])
      Scope.new('Bar', nil).should_not eq Scope.new('Foo', nil)
      Scope.new(nil, 'bar').should_not eq Scope.new(nil, 'foo')
    end

    it "can be extended and unextended" do
      Scope.new.push(:if).should eq Scope.new(nil, nil, [:if])
      Scope.new(nil, nil, [:for, :if]).pop.should eq Scope.new(nil, nil, [:for])

      Scope.new.in_class('Foo').should eq Scope.new('Foo')
      Scope.new.in_method('bar').should eq Scope.new(nil, 'bar')
    end

    it "can tell its depth" do
      Scope.new(nil, nil, [:for]).depth.should eq 1
      Scope.new(nil, nil, [:for, :if]).depth.should eq 2
      Scope.new(nil, nil, [:for, :if, :if]).depth.should eq 3
    end
  end
end
