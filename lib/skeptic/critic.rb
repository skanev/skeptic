module Skeptic
  class Critic
    attr_accessor *Rules.table.slugs

    attr_reader :criticism

    def initialize(options = {})
      @criticism = []

      options.each do |key, value|
        send "#{key}=", value
      end
    end

    def criticize(code)
      @code   = code
      @tokens = Ripper.lex(code)
      @sexp   = Ripper.sexp(code)

      Rules.table.each_rule do |rule_class, slug, option|
        next unless send(slug)

        rule = rule_class.new send(slug)
        rule.apply_to @code, @tokens, @sexp

        rule.violations.each do |violation|
          @criticism << [violation, rule.name]
        end
      end
    end
  end
end
