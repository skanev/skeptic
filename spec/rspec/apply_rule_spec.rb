require 'spec_helper'

describe "apply_rule(rule, *args, code)" do
  let(:code) { 'call 1' }
  let(:tokens) { Ripper.lex(code) }
  let(:sexp) { Ripper.sexp(code) }

  it "applies rule.new(*args) to code" do
    rule_class = double('rule class')
    rule = double('rule')

    rule_class.should_receive(:new).with('argument', 'list').and_return rule
    rule.should_receive(:apply_to).with(code, tokens, sexp).and_return rule

    apply_rule(rule_class, 'argument', 'list', code).should eq rule
  end
end
