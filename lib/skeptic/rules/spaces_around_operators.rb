module Skeptic
  module Rules
    class SpacesAroundOperators
      DESCRIPTION = 'Check for spaces around operators'

      OPERATORS_WITHOUT_SPACES_AROUND_THEM = ['**']

      def initialize(data)
        @violations = []
      end

      def apply_to(code, tokens, sexp)
        @violations = tokens.each_cons(3).select do |_, token, _|
          operator_expecting_spaces? token
        end.select do |left, operator, right|
          no_spaces_between?(operator, left) or
          no_spaces_between?(operator, right)
        end.map do |_, operator, _|
          [operator.last, operator.first[0]]
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

      def operator_expecting_spaces?(token)
        token[1] == :on_op and
          not OPERATORS_WITHOUT_SPACES_AROUND_THEM.include? token.last
      end

      def no_spaces_between?(operator, neighbour)
        neighbour.first[0] == operator.first[0] and neighbour[1] != :on_sp
      end
    end
  end
end
