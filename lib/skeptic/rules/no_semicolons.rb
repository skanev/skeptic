module Skeptic
  module Rules
    class NoSemicolons
      def initialize(enabled = false)
        @enabled = enabled
      end

      def apply_to(tokens, sexp)
        @locations = tokens.
          select { |location, type, token| token == ';' and type == :on_semicolon }.
          map { |location, type, token| location }
        self
      end

      def violations
        @locations.map do |line, column|
          "You have a semicolon at line #{line}, column #{column}"
        end
      end

      def name
        'No semicolons as expression separators'
      end

      def semicolon_locations
        @locations
      end
    end
  end
end
