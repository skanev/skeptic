module Skeptic
  module Rules
    class MethodSizeAnalyzer
      include SexpVisitor

      def initialize(limit = nil)
        super()

        env[:line_numbers] = []
        @line_counts = {}
        @limit = limit
      end

      def analyze_sexp(sexp)
        visit sexp
        self
      end

      def method_names
        @line_counts.keys
      end

      def size_of(qualified_method_name)
        @line_counts[qualified_method_name]
      end

      def violations
        return [] if @limit.nil?

        @line_counts.select { |name, lines| lines > @limit }.map do |name, lines|
          "#{name} is #{lines} lines long"
        end
      end

      def rule_name
        "Number of lines per method (#@limit)"
      end

      private

      on :class do |name, parent, body|
        class_name = [env[:class], extract_name(name)].compact.join('::')

        env.scoped :class => class_name do
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
