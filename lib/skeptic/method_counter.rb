module Skeptic
  class MethodCounter
    def initialize
      @methods = Hash.new { |hash, key| hash[key] = [] }
      @scope = []
    end

    def analyze(tree)
      visit tree
    end

    def with(scope)
      old = @current
      @current = scope
      yield
      @current = old
    end

    def methods_in(class_name)
      @methods[class_name].length
    end

    def class_names
      @methods.keys
    end

    private

    def visit(sexp)
      if Symbol === sexp[0]
        type = sexp[0]
        args = sexp.drop(1)

        case type
          when :def
            name, params, body = *args

            class_name = @scope.join '::'
            method_name = extract_name(name)
            @methods[class_name] << method_name

            visit params
            visit body

          when :class
            name, parents, body = *args

            @scope.push extract_name(name)
            visit parents if parents
            visit body
            @scope.pop

          when :module
            name, body = *args

            @scope.push extract_name(name)
            visit body
            @scope.pop

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
  end
end
