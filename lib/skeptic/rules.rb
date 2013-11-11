module Skeptic
  module Rules
    def self.table
      @rule_table ||= RuleTable.new
    end

    table.register CheckSyntax, :boolean
    table.register EnglishWordsForNames, :string
    table.register LineLength, :int
    table.register LinesPerMethod, :int
    table.register MaxNestingDepth, :int
    table.register MethodsPerClass, :int
    table.register NoSemicolons, :boolean
    table.register NoTrailingWhitespace, :boolean
  end
end
