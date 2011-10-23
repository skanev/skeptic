module Skeptic
  class MethodCounter < SexpVisitor
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

    on :def do |name, params, body|
      class_name = @scope.join '::'
      method_name = extract_name(name)
      @methods[class_name] << method_name

      visit params
      visit body
    end

    on :class do |name, parents, body|
      @scope.push extract_name(name)
      visit parents if parents
      visit body
      @scope.pop
    end

    on :module do |name, body|
      @scope.push extract_name(name)
      visit body
      @scope.pop
    end
  end
end
