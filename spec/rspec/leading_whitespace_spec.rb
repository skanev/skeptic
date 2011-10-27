require 'spec_helper'

describe "code(text)" do
  it "removes the trailing whitespace from the code" do
    code(<<-UNPROCESSED_CODE).should eq <<-PROCESSED_CODE
      def foo
        something
      end
    UNPROCESSED_CODE
def foo
  something
end
PROCESSED_CODE
  end
end
