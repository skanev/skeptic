shared_examples_for 'Rule' do
  let(:code) { 'foo 1' }
  let(:tokens) { Ripper.lex(code) }
  let(:sexp) { Ripper.sexp(code) }

  it "defines a constant DESCRIPTION that contains the rule description" do
    described_class.constants.should include :DESCRIPTION
    described_class.const_get(:DESCRIPTION).should be_a String
  end

  it "defines an #apply_to(code, sexp, tokens) methods that returns the receiver" do
    subject.should respond_to(:apply_to).with(3).arguments
    subject.apply_to(code, tokens, sexp).should eq subject
  end

  it "defines a #violations methods that returns an array of violations" do
    subject.apply_to(code, tokens, sexp)
    subject.should respond_to(:violations).with(0).arguments
    subject.violations.should be_an Array
  end

  it "defines a #name method that returns the name of the rule" do
    subject.should respond_to(:name).with(0).arguments
    subject.name.should be_a String
  end
end
