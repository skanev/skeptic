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

          with_sexp_type(type) { instance_exec *args, &handler }
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
          when :const_path_ref
            "#{extract_name(first)}::#{extract_name(second)}"
          when :const_ref, :var_ref, :var_field, :field, :aref_field, :blockarg
            extract_name(first)
          when :@const, :@ident, :@label, :@kw, :@op, :@ivar, :@cvar, :@gvar
            first
          else
            '<unknown>'
        end
      end

      def extract_line_number(tree)
        type, first, second = *tree
        case type
          when :const_path_ref, :const_ref, :var_ref, :var_field
            extract_line_number(first)
          when :@const, :@op, :@ident, :@ivar, :cvar, :@gvar, :@label
            second.first
          else
            0
        end
      end

      def extract_param_idents(tree)
        type, first, second = *tree
        case type
          when :params, :mlhs_add_star
            tree[1..-1].compact.map { |node| extract_param_idents node }.reduce [], :+
          when :mlhs_paren, :blockarg, :rest_param
            extract_param_idents first
          when :@ident, :@label
            [tree]
          when Symbol
            []
          when nil
            []
          else
            tree.compact.map { |node| extract_param_idents node }.reduce [], :+
        end
      end
    end
  end
end
