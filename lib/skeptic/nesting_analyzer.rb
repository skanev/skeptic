module Skeptic
  class NestingAnalyzer
    def initialize
      @current = Scope.new
      @nestings = []
    end

    def analyze(tree)
      visit tree
    end

    def nestings
      @nestings.uniq
    end

    def deepest_nesting
      @nestings.max_by(&:depth)
    end

    def ident(key)
      new_scope = @current.push(key)
      with(new_scope) { yield }
    end

    def with(scope)
      @nestings << scope

      old = @current
      @current = scope
      yield
      @current = old
    end

    private

    def visit(tree, scope = nil)
      if scope
        with(scope) { process tree }
      else
        process tree
      end
    end

    def process(sexp)
      if Symbol === sexp[0]
        type = sexp[0]
        args = sexp.drop(1)
        scope = @current

        case type
          when :if, :if_mod, :unless, :unless_mod
            condition, body, alternative = *args
            key = type.to_s.gsub(/_mod$/, '').to_sym

            visit condition
            visit body,        scope.push(key)
            visit alternative, scope.push(key) if alternative

          when :while, :while_mod, :until, :until_mod
            condition, body = *args
            key = type.to_s.gsub(/_mod$/, '').to_sym

            visit condition, scope.push(key)
            visit body,      scope.push(key)

          when :method_add_block
            invocation, block = *args

            visit invocation
            visit block, scope.push(:iter)

          when :lambda
            params, body = *args

            visit params
            visit body, scope.push(:lambda)

          when :for
            params, iterable, body = *args

            visit params
            visit iterable
            visit body, scope.push(:for)

          when :case
            testable, alternatives = *args

            visit testable
            visit alternatives, scope.push(:case)

          when :begin
            visit args.first, scope.push(:begin)

          when :class
            name, parent, body = *args

            visit name
            visit parent if parent
            visit body, scope.in_class(extract_name(name))

          when :def
            name, params, body = *args

            visit name
            visit params
            visit body, scope.in_method(extract_name(name))

          else
            any sexp
        end
      else
        any sexp
      end
    end

    def extract_name(tree)
      type, first, second = *tree
      case type
        when :const_path_ref then "#{extract_name(first)}::#{extract_name(second)}"
        when :const_ref then extract_name(first)
        when :var_ref then extract_name(first)
        when :@const then first
        when :@ident then first
        else '<unknown>'
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
