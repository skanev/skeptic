module Skeptic
  class Scope
    attr_accessor :class_name, :method_name, :levels

    def initialize(class_name = nil, method_name = nil, levels = [])
      @class_name  = class_name
      @method_name = method_name
      @levels      = levels
    end

    def ==(other)
      other.kind_of?(Scope) and
        self.class_name == other.class_name and
        self.method_name == other.method_name and
        self.levels == other.levels
    end

    def depth
      levels.length
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

    def to_s
      location = if class_name and method_name then "#{class_name}##{method_name}"
        elsif class_name then "#{class_name}#[body]"
        elsif method_name then "Object##{method_name}"
        else "[top-level]"
      end

      "#{location} #{@levels.join(':')}".strip
    end

    def inspect
      "#<Scope: #{to_s}>"
    end

    private

    def copy(&block)
      Scope.new(class_name, method_name, levels.dup).tap(&block)
    end
  end
end
