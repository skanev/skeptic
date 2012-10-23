module Skeptic
  module Rules
    class NoTrailingWhitespace
      DESCRIPTION = 'Disallows trailing whitespace'

      attr_reader :lines_with_trailing_whitespace

      def initialize(enable = false)
        @lines_with_trailing_whitespace = []
      end

      def apply_to(code, tokens, sexp)
        code.lines.each_with_index do |line, index|
          @lines_with_trailing_whitespace << index + 1 if line.chomp =~ /\s+$/
        end
        self
      end

      def violations
        @lines_with_trailing_whitespace.map do |line|
          "Line #{line} has trailing whitespace"
        end
      end

      def name
        "Trailing whitespace"
      end
    end
  end
end
