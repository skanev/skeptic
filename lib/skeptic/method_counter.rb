module Skeptic
  class MethodCounter < SexpVisitor
    def initialize
      super
      @methods = Hash.new { |hash, key| hash[key] = [] }
    end

    def analyze(tree)
      visit tree
    end

    def methods_in(class_name)
      @methods[class_name].length
    end

    def method_names_in(class_name)
      @methods[class_name]
    end

    def class_names
      @methods.keys
    end

    private

    on :def do |name, params, body|
      method_name = extract_name(name)
      class_name  = env[:class]

      @methods[class_name] << method_name

      visit params
      visit body
    end

    on :class do |name, parents, body|
      env.push :class => qualified_class_name(name)

      visit parents if parents
      visit body

      env.pop
    end

    on :module do |name, body|
      env.push :class => qualified_class_name(name)

      visit body

      env.pop
    end

    def qualified_class_name(name)
      [env[:class], extract_name(name)].compact.join('::')
    end
  end
end
