module Skeptic
  class SemicolonDetector
    def initialize(enabled = false)
      @enabled = enabled
    end

    def analyze_tokens(tokens)
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

    def rule_name
      'No semicolons as expression separators'
    end

    def offending_spots
      @locations
    end

    def complaining?
      not @locations.empty?
    end
  end
end
