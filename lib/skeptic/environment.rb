module Skeptic
  class Environment
    def initialize
      @stack = [{}]
    end

    def []=(name, value)
      @stack.last[name] = value
    end

    def [](name)
      closure = @stack.reverse.detect { |closure| closure.has_key? name }
      closure[name] if closure
    end

    def push(closure = {})
      @stack.push closure
    end

    def pop
      raise "You went too far unextending env" if @stack.empty?
      @stack.pop
    end

    def scoped(closure = {})
      push closure
      yield
    ensure
      pop
    end
  end
end
