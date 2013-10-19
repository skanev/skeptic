module Skeptic
  module Rules
    class SpaceAroundOperators
      DESCRIPTION = 'Space around operators'

      def initialize(data)
        @operators_without_space_around_them = []
      end

      def apply_to(code, tokens, sexp)
        lines = code.split("\n")

        tokens.each_cons(3) do |left, middle, right|
          if middle[1] == :on_op and middle.last != '**' #cuz the guide says so
            violation_data = [middle.first, middle.last, lines[middle.first[0] - 1]]
            if no_space_around_operator? middle, left
              @operators_without_space_around_them << [:left] + violation_data
            elsif no_space_around_operator? middle, right
              @operators_without_space_around_them << [:right] + violation_data
            end
          end
        end
        self
      end

      def violations
        @operators_without_space_around_them
        .map do |dir, location, value, snippet|
          "no space in #{dir} of #{value} on line " +
          "#{location.first}: " +
          "#{snippet.lstrip}"
        end
      end

      def name
        'Space around operators'
      end

      private
      def no_space_around_operator?(operator, neighbour)
        neighbour.first[0] == operator.first[0] and
        neighbour[1] != :on_sp
      end
    end
  end
end