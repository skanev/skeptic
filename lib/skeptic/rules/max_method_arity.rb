module Skeptic
  module Rules
    class MaxMethodArity
      DESCRIPTION = 'Limit the arguments count per method'
      MAX_METHOD_ARITY = 3

      include SexpVisitor

      def initialize(limit = nil)
        @violations = []
        @limit  = limit || MAX_METHOD_ARITY
      end

      def apply_to(code, tokens, sexp)
        visit sexp
        self
      end

      def violations
        @violations.map do |method, arity|
          "#{method} has #{arity} arguments (maximum method arity: #{@limit})"
        end
      end

      def name
        "Maximum method arity (#@limit)"
      end

      private

      on :class do |name, parents, body|
        env.push module: qualified_class_name(name)
        visit body

        env.pop
      end

      on :module do |name, body|
        env.push module: qualified_class_name(name)
        visit body

        env.pop
      end

      on :def do |name, params, _|
        qualified_method_name = (env[:module] || '') + '#' + extract_name(name)
        env.push method: qualified_method_name

        visit params

        env.pop
      end

      on :defs do |target, separator, name, params, body|
        method_name = extract_name(name)
        class_name  = extract_name(target)
        class_name  = (env[:module] || '') if class_name == 'self'

        qualified_method_name = class_name + '.' + method_name
        env.push method: qualified_method_name

        visit params

        env.pop
      end

      on :params do |*params|
        check_max_arity(params) if params
      end

      def check_max_arity(params)
        arguments_count = extract_param_idents(params).size
        if arguments_count > @limit
          @violations << [env[:method], arguments_count]
        end
      end

      def qualified_class_name(name)
        [env[:module], extract_name(name)].compact.join('::')
      end
    end
  end
end