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
        :@cvar  => :snake_case
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
        :@cvar       => 'class variable'
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
        extracted_name = extract_name(name)
        if bad_name_of?(sexp_type, extracted_name)
          @violations << [sexp_type, extracted_name, extract_line_number(name)]
        end

        visit(body)
      end

      on :symbol do |type, text, location|
        if bad_name_of?(:symbol, text)
          @violations << [:symbol, text, location.first]
        end
      end

      on :@ident, :@ivar, :@cvar do |text, location|
        if bad_name_of?(:@ident, text.match(/\A@*(.+)\z/).captures[0])
          @violations << [sexp_type, text, location.first]
        end
      end

      def bad_name_of?(type, name)
        !CONVENTION_REGEXES[EXPECTED_CONVENTIONS[type]].match(name)
      end
    end
  end
end
