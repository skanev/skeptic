module Skeptic
  module Rules
    class LineLength
      attr_reader :line_lengths

      def initialize(limit)
        @limit = limit
        @line_lengths = {}
      end

      def apply_to(code, tokens, sexp)
        code.lines.each_with_index do |line, index|
          @line_lengths[index + 1] = line.chomp.length
        end
        self
      end

      def violations
        @line_lengths.select { |line, length| length > @limit }.map do |line, length|
          "Line #{line} is too long: #{length} columns"
        end
      end

      def name
        "Line length (#@limit)"
      end
    end
  end
end
