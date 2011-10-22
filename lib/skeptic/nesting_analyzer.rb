module Skeptic
  class NestingAnalyzer
    def initialize
      @current = Nesting.new nil, nil, []
      @nestings = []
    end

    def analyze(tree)
      visit tree
    end

    def nestings
      @nestings.uniq
    end

    def deepest_nesting
      @nestings.max_by(&:size)
    end

    def ident(key)
      new_nesting = @current.push(key)
      with(new_nesting) { yield }
    end

    def with(nesting)
      @nestings << nesting

      old = @current
      @current = nesting
      yield
      @current = old
    end

    private

    def visit(tree, nesting = nil)
      if nesting
        with(nesting) { process tree }
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

    class Nesting
      attr_accessor :class_name, :method_name, :levels

      def initialize(class_name, method_name, levels)
        @class_name = class_name
        @method_name = method_name
        @levels = levels
      end

      def ==(other)
        other.kind_of?(Nesting) and
          self.class_name == other.class_name and
          self.method_name == other.method_name and
          self.levels == other.levels
      end

      def push(level)
        copy { |n| n.levels.push level }
      end

      def pop
        copy { |n| n.levels.pop }
      end

      def in_class(class_name)
        copy { |n| n.class_name = class_name }
      end

      def in_method(method_name)
        copy { |n| n.method_name = method_name }
      end

      def size
        levels.length
      end

      def to_s
        location = if class_name and method_name then "#{class_name}##{method_name}"
          elsif class_name then "#{class_name}#[body]"
          elsif method_name then "Object##{method_name}"
          else "[top-level]"
        end

        "#{location} #{@levels.join(' ')}"
      end

      def inspect
        "#<Nesting: #{to_s}>"
      end

      private

      def copy(&block)
        Nesting.new(class_name, method_name, levels.dup).tap(&block)
      end
    end
  end
end
