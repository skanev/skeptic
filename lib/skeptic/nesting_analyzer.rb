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

      old = @current
      @current = scope
      yield
      @current = old
    end

    private

    def visit(tree, scope = nil)
      if scope
        with(scope) { super(tree) }
      else
        super(tree)
      end
    end

    on :class do |name, parent, body|
      visit name
      visit parent if parent
      visit body, @current.in_class(extract_name(name))
    end

    on :if, :if_mod, :unless, :unless_mod do |condition, body, alternative|
      key = sexp_type.to_s.gsub(/_mod$/, '').to_sym

      visit condition
      visit body,        @current.push(key)
      visit alternative, @current.push(key) if alternative
    end

    on :while, :while_mod, :until, :until_mod do |condition, body|
      key = sexp_type.to_s.gsub(/_mod$/, '').to_sym

      visit condition, @current.push(key)
      visit body,      @current.push(key)
    end

    on :method_add_block do |invocation, block|
      visit invocation
      visit block, @current.push(:iter)
    end

    on :lambda do |params, body|
      visit params
      visit body, @current.push(:lambda)
    end

    on :for do |params, iterable, body|
      visit params
      visit iterable
      visit body, @current.push(:for)
    end

    on :case do |testable, alternatives|
      visit testable
      visit alternatives, @current.push(:case)
    end

    on :begin do |body|
      visit body, @current.push(:begin)
    end

    on :def do |name, params, body|
      visit name
      visit params
      visit body, @current.in_method(extract_name(name))
    end
  end
end
