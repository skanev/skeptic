module Skeptic
  class Critic
    attr_accessor :lines_per_method
    attr_accessor :max_nesting_depth
    attr_accessor :methods_per_class
    attr_accessor :no_semicolons
    attr_accessor :line_length

    attr_reader :criticism

    def initialize
      @criticism = []
    end

    def criticize(code)
      @code   = code
      @tokens = Ripper.lex(code)
      @sexp   = Ripper.sexp(code)

      rules = {
        Rules::LinesPerMethod  => lines_per_method,
        Rules::MaxNestingDepth => max_nesting_depth,
        Rules::MethodsPerClass => methods_per_class,
        Rules::NoSemicolons    => no_semicolons,
        Rules::LineLength      => line_length,
      }

      rules.reject { |rule_type, option| option.nil? }.each do |rule_type, option|
        rule = rule_type.new(option)
        rule.apply_to @code, @tokens, @sexp

        rule.violations.each do |violation|
          @criticism << [violation, rule.name]
        end
      end
    end
  end
end
