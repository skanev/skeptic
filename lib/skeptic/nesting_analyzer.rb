module Skeptic
  class NestingAnalyzer < SexpVisitor
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

    def with(scope)
      @nestings << scope

      @current, old = scope, @current
      yield
      @current = old
    end

    private

    on :class do |name, parent, body|
      visit name
      visit parent if parent

      with @current.in_class(extract_name(name)) do
        visit body
      end
    end

    on :if, :if_mod, :unless, :unless_mod do |condition, body, alternative|
      key = sexp_type.to_s.gsub(/_mod$/, '').to_sym

      visit condition

      with @current.push(key) do
        visit body
        visit alternative if alternative
      end
    end

    on :while, :while_mod, :until, :until_mod do |condition, body|
      key = sexp_type.to_s.gsub(/_mod$/, '').to_sym

      with @current.push(key) do
        visit condition
        visit body
      end
    end

    on :method_add_block do |invocation, block|
      visit invocation

      with @current.push(:iter) do
        visit block
      end
    end

    on :lambda do |params, body|
      with @current.push(:lambda) do
        visit params
        visit body
      end
    end

    on :for do |params, iterable, body|
      visit params
      visit iterable

      with @current.push(:for) do
        visit body
      end
    end

    on :case do |testable, alternatives|
      visit testable

      with @current.push(:case) do
        visit alternatives
      end
    end

    on :begin do |body|
      with @current.push(:begin) do
        visit body
      end
    end

    on :def do |name, params, body|
      visit name
      visit params

      with @current.in_method(extract_name(name)) do
        visit body
      end
    end
  end
end
