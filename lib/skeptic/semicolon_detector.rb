module Skeptic
  class SemicolonDetector
    def initialize
    end

    def analyze(code)
      @locations = Ripper.lex(code).
        select { |location, type, token| token == ';' and type == :on_semicolon }.
        map { |location, type, token| location }
    end

    def offending_spots
      @locations
    end

    def complaining?
      not @locations.empty?
    end
  end
end
