require 'open3'

module Skeptic
  module Rules
    class CheckSyntax
      DESCRIPTION = 'Check the syntax'

      def initialize(enabled = false)
        @errors = []
      end

      def apply_to(code, tokens, sexp)
        output, error, status = Open3.capture3 'ruby -c', stdin_data: code
        @errors << "Invalid syntax:\n#{error.gsub(/^/m, '  ')}" unless output.chomp == 'Syntax OK'
        self
      end

      def violations
        @errors
      end

      def name
        'Syntax check'
      end
    end
  end
end
