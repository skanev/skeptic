module Skeptic
  class Critic
    attr_accessor :complain_about_semicolons
    attr_accessor :max_nesting
    attr_accessor :methods_per_class
    attr_accessor :method_length

    attr_reader :criticism

    def initialize
      @criticism = []
    end

    def criticize(code)
      @code   = code
      @tokens = Ripper.lex(code)
      @sexp   = Ripper.sexp(code)

      look_for_semicolons
      analyze_nesting
      analyze_method_count
      analyze_method_length
    end

    private

    def add_criticism(message, type)
      @criticism << [message, type]
    end

    def look_for_semicolons
      analyzer = SemicolonDetector.new(complain_about_semicolons).analyze_tokens(@tokens)

      analyzer.violations.each do |violation|
        add_criticism violation, analyzer.rule_name
      end
    end

    def analyze_nesting
      return if max_nesting.nil?

      analyzer = NestingAnalyzer.new(max_nesting).analyze_sexp(@sexp)

      analyzer.violations.each do |violation|
        add_criticism violation, analyzer.rule_name
      end
    end

    def analyze_method_count
      return if methods_per_class.nil?

      analyzer = MethodCounter.new(methods_per_class).analyze_sexp(@sexp)

      analyzer.violations.each do |violation|
        add_criticism violation, analyzer.rule_name
      end
    end

    def analyze_method_length
      return if method_length.nil?

      analyzer = MethodSizeAnalyzer.new(method_length).analyze_sexp(@sexp)

      analyzer.violations.each do |violation|
        add_criticism violation, analyzer.rule_name
      end
    end
  end
end
