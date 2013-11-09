module Skeptic
  module Rules
    class NamingConventions
      DESCRIPTION = 'Check if the names of variables/methods/classes follow the convention'

      include SexpVisitor

      EXPECTED_CONVENTIONS = {
        class:     :camel_case,
        module:    :camel_case,
        def:       :snake_case,
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
          " is not #{CONVENTION_EXAMPLES[EXPECTED_CONVENTIONS[type]]}"
        end
      end

      def name
        'Detect bad naming'
      end

      private

      on :class, :module, :def do |name, *args, body|
        extracted_name = strip_name_suffix(extract_name(name))
        if bad_name? sexp_type, extracted_name
          @violations << [sexp_type, extracted_name, extract_line_number(name)]
        end

        visit body
      end

      on :symbol do |type, text, location|
        if bad_name? :symbol, text
          @violations << [:symbol, text, location.first]
        end
      end

      on :@ident, :@ivar, :@cvar, :@const do |text, location|
        if bad_name? sexp_type, strip_name_prefix(text)
          @violations << [sexp_type, text, location.first]
        end
      end

      def bad_name?(type, name)
        !CONVENTION_REGEXES[EXPECTED_CONVENTIONS[type]].match(name)
      end

      def strip_name_suffix(name)
        name.sub(/[!?]\z/, '')
      end

      def strip_name_prefix(name)
        name.sub(/\A@{1,2}/, '')
      end
    end
  end
end
