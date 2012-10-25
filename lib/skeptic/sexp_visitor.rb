module Skeptic
  module SexpVisitor
    def self.included(receiver)
      receiver.send :include, InstanceMethods
      receiver.extend ClassMethods
    end

    module ClassMethods
      def handlers
        @handlers ||= {}
      end

      def on(*types, &block)
        types.each do |type|
          handlers[type] = block
        end
      end
    end

    module InstanceMethods
      private

      def visit(sexp)
        if Symbol === sexp[0] and self.class.handlers.has_key? sexp[0]
          type, *args = *sexp
          handler = self.class.handlers[type]

          with_sexp_type(type) { instance_exec(*args, &handler) }
        else
          range = sexp[0].kind_of?(Symbol) ? 1..-1 : 0..-1

          sexp[range].each do |subtree|
            visit subtree if subtree.kind_of?(Array) and not subtree[0].kind_of?(Fixnum)
          end
        end
      end

      def env
        @env ||= Environment.new
      end

      def with_sexp_type(type)
        @current_sexp_type, old_sexp_type = type, @current_sexp_type
        yield
        @current_sexp_type = old_sexp_type
      end

      def sexp_type
        @current_sexp_type
      end

      def extract_name(tree)
        type, first, second = *tree
        case type
          when :const_path_ref then "#{extract_name(first)}::#{extract_name(second)}"
          when :const_ref then extract_name(first)
          when :var_ref then extract_name(first)
          when :@const then first
          when :@ident then first
          when :@kw then first
          when :@op then first
          else '<unknown>'
        end
      end
    end
  end
end
