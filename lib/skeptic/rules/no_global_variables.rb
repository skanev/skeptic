module Skeptic
  module Rules
    class NoGlobalVariables
      DESCRIPTION = 'Do not allow the use of global variables'

      include SexpVisitor

      def initialize(enabled = false)
        @enabled = enabled
        @violations = []
      end

      def apply_to(code, tokens, sexp)
        visit sexp
        self
      end

      def violations
        @violations.map do |variable, line|
          "You have a global variable #{variable} on line #{line}"
        end
      end

      def name
        'No global variables'
      end

      private

      on :@gvar do |variable, location|
        @violations << [variable, location.first]
      end
    end
  end
end
