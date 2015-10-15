module Skeptic
  module Rules
    class SpacesAroundOperators
      DESCRIPTION = 'Check for spaces around operators'

      include SexpVisitor

      OPERATORS_WITHOUT_SPACES_AROUND_THEM = ['**', '::', '...', '..']
      IGNORED_TOKEN_TYPES = [:on_sp, :on_ignored_nl, :on_nl, :on_lparen, :on_symbeg, :on_lbracket, :on_lbrace]
      LEFT_LIMIT_TOKEN_TYPES = [:on_lparen, :on_lbracket]
      RIGHT_LIMIT_TOKEN_TYPES = [:on_rparen, :on_rbracket]
      WHITESPACE_TOKEN_TYPES = [:on_sp, :on_nl, :on_ignored_nl]

      def initialize(data)
        @violations = []
        @special_tokens_locations = []
        @unary_token_locations = []
      end

      def apply_to(code, tokens, sexp)
        visit sexp

        mark_unary tokens

        @violations = tokens.each_cons(3).select do |_, token, _|
          operator_expecting_spaces? token
        end.select do |left, operator, right|
          no_spaces_around? operator, left, right
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

      def no_spaces_around?(operator, left, right)
        return false if unary_operator?(operator)

        if LEFT_LIMIT_TOKEN_TYPES.include?(left[1])
          mark_special_tokens right.first
        end
        if range_operator?(left)
          mark_special_tokens left.last
        end
        no_spaces_on_left_of?(operator, left) or
        no_spaces_on_right_of?(operator, right)
      end

      def no_spaces_on_left_of?(operator, neighbour)
        neighbour.first[0] == operator.first[0] and
        !LEFT_LIMIT_TOKEN_TYPES.include?(neighbour[1]) and
        !range_operator?(neighbour) and
        !special_token?(neighbour)
      end

      def no_spaces_on_right_of?(operator, neighbour)
        neighbour.first[0] == operator.first[0] and
        !RIGHT_LIMIT_TOKEN_TYPES.include?(neighbour[1]) and
        !special_token?(neighbour)
      end

      def range_operator?(operator)
        operator.last[0..1] == '..'
      end

      def mark_special_tokens(*token_locations)
        @special_tokens_locations.concat(token_locations)
      end

      def special_token?(token)
        IGNORED_TOKEN_TYPES.include? token[1] or
          @special_tokens_locations.include? token.first
      end

      def unary_operator?(token)
        token[1] == :on_op and @unary_token_locations.include?(token[0])
      end

      def mark_unary(tokens)
        @unary_token_locations = []
        last_significant_token = nil
        tokens.each do |token|
          if token[1] == :on_op
            if last_significant_token == :on_op
              @unary_token_locations << token[0]
            end
            last_significant_token = :on_op
          elsif !WHITESPACE_TOKEN_TYPES.include?(token[1])
            last_significant_token = token[1]
          end
        end
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
            when :call
              token = block
              while token.first == :call
                token = token[1]
              end
              mark_special_tokens token.last.last
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
