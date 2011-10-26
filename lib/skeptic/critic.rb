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

      rules = {
        Rules::SemicolonDetector  => complain_about_semicolons,
        Rules::NestingAnalyzer    => max_nesting,
        Rules::MethodCounter      => methods_per_class,
        Rules::MethodSizeAnalyzer => method_length,
      }

      rules.reject { |rule_type, option| option.nil? }.each do |rule_type, option|
        rule = rule_type.new(option)
        rule.apply_to @tokens, @sexp

        rule.violations.each do |violation|
          @criticism << [violation, rule.rule_name]
        end
      end
    end
  end
end
