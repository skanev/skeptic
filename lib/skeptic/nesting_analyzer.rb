module Skeptic
  class NestingAnalyzer
    def initialize
      @nesting = []
      @nestings = []
    end

    def analyze(tree)
      visit tree
    end

    def nestings
      @nestings.uniq
    end

    def deepest_nesting
      @nestings.max_by(&:length)
    end

    def ident(key)
      @nesting.push key
      @nestings << @nesting.dup
      yield
      @nesting.pop
    end

    private

    def visit(sexp)
      if Symbol === sexp[0]
        type = sexp[0]
        args = sexp.drop(1)
        case type
          when :if, :if_mod, :unless, :unless_mod
            condition, body, alternative = *args
            key = type.to_s.gsub(/_mod$/, '').to_sym

            visit condition
            ident(key) do
              visit body
              visit alternative if alternative
            end
          when :while, :while_mod, :until, :until_mod
            condition, body = *args
            key = type.to_s.gsub(/_mod$/, '').to_sym

            ident(key) do
              visit condition
              visit body
            end
          when :method_add_block
            invocation, block = *args

            visit invocation
            ident(:iter) { visit block }
          when :lambda
            params, body = *args

            visit params
            ident(:lambda) { visit body }
          when :for
            params, iterable, body = *args

            visit params
            visit iterable
            ident(:for) { visit body }
          when :case
            testable, alternatives = *args

            visit testable
            ident(:case) { visit alternatives }
          when :begin
            body = args.first

            ident(:begin) { visit body }
          else
            any sexp
        end
      else
        any sexp
      end
    end

    def any(sexp)
      range = Symbol === sexp[0] ? 1..-1 : 0..-1
      sexp[range].each do |subtree|
        if Array === subtree && !(Fixnum === subtree[0])
          visit subtree
        end
      end
    end
  end
end
