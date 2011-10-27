module Skeptic
  module SpecSupport
    module LeadingWhitespace
      def code(code)
        leading_whitespace = code[/\A(\s+)/, 1]
        code.gsub(/^#{leading_whitespace}/m, '')
      end
    end
  end
end
