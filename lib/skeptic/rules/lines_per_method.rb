module Skeptic
  module Rules
    class LinesPerMethod
      DESCRIPTION = 'Limit the number of lines in each method'

      include SexpVisitor

      def initialize(limit = nil)
        env[:line_numbers] = []
        @line_counts = {}
        @limit = limit
      end

      def apply_to(code, tokens, sexp)
        visit sexp
        self
      end

      def size_of(qualified_method_name)
        @line_counts[qualified_method_name]
      end

      def violations
        @line_counts.select { |name, lines| lines > @limit }.map do |name, lines|
          "#{name} is #{lines} lines long"
        end
      end

      def name
        "Number of lines per method (#@limit)"
      end

      private

      on :class do |name, parent, body|
        class_name = [env[:module], extract_name(name)].compact.join('::')

        env.scoped :class => class_name do
          visit body
        end
      end

      on :module do |name, body|
        module_name = [env[:module], extract_name(name)].compact.join('::')

        env.scoped :class => module_name do
          visit body
        end
      end

      on :def do |name, params, body|
        method_name = extract_name(name)

        env.scoped method: method_name, line_numbers: [] do
          visit body

          lines = env[:line_numbers].uniq.compact.length

          full_name = "#{env[:class]}##{env[:method]}"
          @line_counts[full_name] = lines + @line_counts.fetch(full_name, 0)
        end
      end

      on :@ident, :@const, :@gvar, :@ivar, :@cvar, :@int, :@float, :@tstring_content, :@kw do |text, location|
        env[:line_numbers] << location.first
      end
    end
  end
end
