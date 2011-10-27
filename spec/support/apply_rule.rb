module Skeptic
  module SpecSupport
    module ApplyRule
      def apply_rule(rule_class, *args, code)
        tokens = Ripper.lex(code)
        sexp   = Ripper.sexp(code)

        rule_class.new(*args).apply_to(code, tokens, sexp)
      end
    end
  end
end
