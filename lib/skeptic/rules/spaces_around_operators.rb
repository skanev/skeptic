module Skeptic
  module Rules
    class SpacesAroundOperators
      DESCRIPTION = 'Spaces around operators'

      OPERATORS_WITHOUT_SPACES_AROUND_THEM = ['**']

      def initialize(data)
        @violations = []
      end

      def apply_to(code, tokens, sexp)
        tokens.each_cons(3).select { |_, op, _| operator? op }.each do |left, operator, right|
          if no_spaces_around_operator? operator, left or
             no_spaces_around_operator? operator, right
            @violations << [operator.last, operator.first[0]]
          end
        end
        self
      end

      def violations
        @violations.map do |value, line_number|
          "no spaces around #{value} on line #{line_number}"
        end
      end

      def name
        'Spaces around operators'
      end

      private

      def operator?(token)
        token[1] == :on_op and
          not OPERATORS_WITHOUT_SPACES_AROUND_THEM.include? token.last
      end

      def no_spaces_around_operator?(operator, neighbour)
        neighbour.first[0] == operator.first[0] and neighbour[1] != :on_sp
      end
    end
  end
end
