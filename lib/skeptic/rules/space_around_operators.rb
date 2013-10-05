module Skeptic
  module Rules
    class SpaceAroundOperators
      DESCRIPTION = 'Space around operators'

      include SexpVisitor

      def initialize(e: nil)
        @operators = []
        env[:operators] = []
      end

      def apply_to(code, tokens, sexp)
        lines = code.split("\n")

        tokens.each_cons(3) do |left, middle, right|
          if middle[1] == :on_op and middle.last != '**' #cuz batsov says so
            if no_space_around_operator? middle, left
              @operators <<
                [:left, middle.first, middle.last, lines[middle.first[0] - 1]]
            elsif no_space_around_operator? middle, right
              @operators <<
                [:right, middle.first, middle.last, lines[middle.first[0] - 1]]
            end
          end
        end
        self
      end

      def violations
        @operators.map do |dir, location, value, snippet|
          "no space in #{dir} of #{value} on " +
          "#{location.first} " +
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