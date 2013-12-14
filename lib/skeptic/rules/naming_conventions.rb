module Skeptic
  module Rules
    class NamingConventions
      DESCRIPTION = 'Check if the names of variables/methods/classes follow the convention'

      include SexpVisitor

      EXPECTED_CONVENTIONS = {
        class:     :camel_case,
        module:    :camel_case,
        def:       :snake_case,
        defs:      :snake_case,
        symbol:    :snake_case,
        :@ident => :snake_case,
        :@ivar  => :snake_case,
        :@cvar  => :snake_case,
        :@const => :screaming_snake_case
      }

      CONVENTION_EXAMPLES = {
        camel_case:            'CamelCase',
        snake_case:            'snake_case',
        screaming_snake_case:  'SCREAMING_SNAKE_CASE',
      }

      CONVENTION_REGEXES = {
        snake_case:            /\A[a-z_][a-z_0-9]*\z/,
        camel_case:            /\A[A-Z][a-zA-Z0-9]*\z/,
        screaming_snake_case:  /\A[A-Z][A-Z_0-9]*\z/
      }

      NODE_NAMES = {
        class:          'class',
        module:         'module',
        symbol:         'symbol',
        def:            'method',
        defs:           'method',
        :@ident      => 'local variable',
        :@ivar       => 'instance variable',
        :@cvar       => 'class variable',
        :@const      => 'constant'
      }

      def initialize(data)
        @violations = []
      end

      def apply_to(code, tokens, sexp)
        visit sexp
        self
      end

      def violations
        @violations.map do |type, name, line_number|
          "#{NODE_NAMES[type]} named #{name} on line #{line_number}" +
          " is not in #{CONVENTION_EXAMPLES[EXPECTED_CONVENTIONS[type]]}"
        end
      end

      def name
        'Detect bad naming'
      end

      private

      on :class, :module do |name, *, body|
        check_ident sexp_type, name
        visit body
      end

      on :def, :defs do |*, name, params, body|
        check_ident sexp_type, name
        visit params
        visit body
      end

      on :lambda do |params, body|
        visit params if params
        visit body
      end

      on :do_block, :brace_block do |(_, params, _), body|
        visit params if params
        visit body
      end

      on :assign do |target, value|
        if target.first == :var_field
          check_ident target.last.first, target
        end
      end

      on :params do |*params|
        extract_param_idents(params).each do |param_ident|
          check_ident :@ident, param_ident
        end
      end

      on :symbol do |type, text, location|
        check_name :symbol, text, location.first
      end

      def check_ident(type, ident)
        if EXPECTED_CONVENTIONS.key? type
          check_name(type, extract_name(ident), extract_line_number(ident))
        end
      end

      def check_name(type, name, line)
        if bad_name? type, strip_word_punctuation(name)
          @violations << [type, name, line]
        end
      end

      def bad_name?(type, name)
        !name.empty? and !CONVENTION_REGEXES[EXPECTED_CONVENTIONS[type]].match(name)
      end

      def strip_word_punctuation(word)
        word.gsub(/[^[^[:ascii:]]a-zA-Z0-9_]/, '')
      end
    end
  end
end
