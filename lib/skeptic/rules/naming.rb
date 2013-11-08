module Skeptic
  module Rules
    class Naming
      DESCRIPTION = 'Check if the names of variables/methods/classes follow the convention'

      include SexpVisitor

      EXPECTED_PRACTICE = {
        class:     :camel_case,
        module:    :camel_case,
        def:       :snake_case,
        symbol:    :snake_case,
        :@ident => :snake_case,
        :@ivar  => :snake_case,
        :@cvar  => :snake_case
      }

      PRACTICE_NAMES = {
        camel_case:            'CamelCase',
        snake_case:            'snake_case',
        screaming_snake_case:  'SCREAMING_SNAKE_CASE'
      }

      PRACTICE_REGEXES = {
        snake_case:            /\A[a-z_][a-z_0-9]*\z/,
        camel_case:            /\A[A-Z][a-zA-Z0-9]*\z/,
        screaming_snake_case:  /\A[A-Z][A-Z_0-9]*\z/
      }

      NAME_TYPES = {class: :class, module: :module, symbol: :symbol, def: :method}

      def initialize(data)
        @violations = []
      end

      def apply_to(code, tokens, sexp)
        visit sexp
        self
      end

      def violations
        @violations.map do |type, name, line_number|
          "#{NAME_TYPES[type]} named #{name} on line #{line_number} is not #{PRACTICE_NAMES[EXPECTED_PRACTICE[type]]}"
        end
      end

      def name
        'Naming of variables, symbols and constants'
      end

      private

      on :class, :module, :def do |name, *args, body|
        extracted_name = extract_name(name)
        unless styled?(sexp_type, extracted_name)
          @violations << [sexp_type, extracted_name, extract_line(name)]
        end

        visit(body)
      end

      on :symbol do |type, text, location|
        unless styled?(:symbol, text)
          @violations << [:symbol, text, location.first]
        end
      end

      on :@ident, :@ivar, :@cvar do |text, location|
        unless styled?(:@ident, text.match(/\A@*(.+)\z/).captures[0])
          @violations << [sexp_type, text, location.first]
        end
      end

      def styled?(type, name)
        !!PRACTICE_REGEXES[EXPECTED_PRACTICE[type]].match(name)
      end
    end
  end
end
