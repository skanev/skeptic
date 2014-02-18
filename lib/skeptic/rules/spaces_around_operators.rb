module Skeptic
  module Rules
    class SpacesAroundOperators
      DESCRIPTION = 'Check for spaces around operators'

      include SexpVisitor

      OPERATORS_WITHOUT_SPACES_AROUND_THEM = ['**', '::', '...', '..']
      IGNORED_TOKEN_TYPES = [:on_sp, :on_ignored_nl, :on_nl, :on_lparen, :on_symbeg, :on_lbracket, :on_lbrace]

      def initialize(data)
        @violations = []
        @special_tokens_locations = []
      end

      def apply_to(code, tokens, sexp)
        visit sexp

        @violations = tokens.each_cons(3).select do |_, token, _|
          operator_expecting_spaces? token
        end.select do |left, operator, right|
          no_spaces_on_left_of?(operator, left) or
          no_spaces_on_right_of?(operator, right)
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

      def no_spaces_on_left_of?(operator, neighbour)
        neighbour.first[0] == operator.first[0] and neighbour[1] != :on_lparen and
        !special_token? neighbour
      end

      def no_spaces_on_right_of?(operator, neighbour)
        neighbour.first[0] == operator.first[0] and neighbour[1] != :on_rparen and
        !special_token? neighbour
      end

      def whitespace_token?(token)
        token[1] == :on_sp or token[1] == :on_ignored_nl
      end

      def mark_special_tokens(*token_locations)
        @special_tokens_locations.concat(token_locations)
      end

      def special_token?(token)
        IGNORED_TOKEN_TYPES.include? token[1] or
          @special_tokens_locations.include? token.first
      end

      on :blockarg, :rest_param do |ident|
        mark_special_tokens ident.last
      end

      on :args_add_block do |args, block|
        visit args
        if block
          case block.first
            when :symbol_literal, :dyna_symbol
              sexp_location = block.last.last.last
              symbol_location = [sexp_location[0], sexp_location[1] - 1]
              mark_special_tokens symbol_location
            when :vcall, :var_ref
              mark_special_tokens block.last.last
          end
        end
      end

      on :mlhs_add_star, :args_add_star do |_, ident|
        if ident.first == :var_ref or ident.first == :vcall
          mark_special_tokens ident.last.last
        else
          mark_special_tokens ident.last
        end
      end

      on :block_var do |params|
        normal_params = params[1] || []
        unless normal_params.empty?
          right_param = normal_params.last
          right_location = [right_param.last[0],
                            right_param.last[1] ]
          mark_special_tokens normal_params.first.last, normal_params.last.last
        end
      end

      on :unary do |_, token|
        mark_special_tokens token.last
      end
    end
  end
end
