module Skeptic
  module Rules
    class NestingAnalyzer
      include SexpVisitor

      def initialize(limit = nil)
        env[:scope] = Scope.new
        @scopes = []
        @limit  = limit
      end

      def apply_to(tokens, sexp)
        visit sexp
        self
      end

      def nestings
        @scopes.uniq
      end

      def deepest_nesting
        @scopes.max_by(&:depth)
      end

      def with(scope)
        @scopes << scope

        env.scoped scope: scope do
          yield
        end
      end

      def violations
        return [] if @limit.nil?

        @scopes.select { |scope| scope.depth > @limit }.map do |scope|
          "#{scope.location} has #{scope.depth} levels of nesting: #{scope.levels.join(' > ')}"
        end
      end

      def rule_name
        "Maximum nesting depth (#@limit)"
      end

      private

      def scope
        env[:scope]
      end

      on :class do |name, parent, body|
        visit name
        visit parent if parent

        with scope.in_class(extract_name(name)) do
          visit body
        end
      end

      on :if, :if_mod, :unless, :unless_mod do |condition, body, alternative|
        key = sexp_type.to_s.gsub(/_mod$/, '').to_sym

        visit condition

        with scope.push(key) do
          visit body
          visit alternative if alternative
        end
      end

      on :while, :while_mod, :until, :until_mod do |condition, body|
        key = sexp_type.to_s.gsub(/_mod$/, '').to_sym

        with scope.push(key) do
          visit condition
          visit body
        end
      end

      on :method_add_block do |invocation, block|
        visit invocation

        with scope.push(:iter) do
          visit block
        end
      end

      on :lambda do |params, body|
        with scope.push(:lambda) do
          visit params
          visit body
        end
      end

      on :for do |params, iterable, body|
        visit params
        visit iterable

        with scope.push(:for) do
          visit body
        end
      end

      on :case do |testable, alternatives|
        visit testable

        with scope.push(:case) do
          visit alternatives
        end
      end

      on :begin do |body|
        with scope.push(:begin) do
          visit body
        end
      end

      on :def do |name, params, body|
        visit name
        visit params

        with scope.in_method(extract_name(name)) do
          visit body
        end
      end
    end
  end
end
