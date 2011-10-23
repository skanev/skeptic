module Skeptic
  class MethodSizeAnalyzer < SexpVisitor
    def initialize
      super

      env[:line_numbers] = []
      @line_counts = {}
    end

    def analyze(sexp)
      visit sexp
    end

    def method_names
      @line_counts.keys
    end

    def size_of(qualified_method_name)
      @line_counts[qualified_method_name]
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
