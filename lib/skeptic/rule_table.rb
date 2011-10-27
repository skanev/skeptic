module Skeptic
  class RuleTable
    def initialize
      @rules = {}
    end

    def rules
      @rules.keys
    end

    def register(klass, option_type)
      @rules[klass] = option_type
    end

    def slugs
      @rules.keys.map { |klass| slug_for klass }
    end

    def each_rule
      @rules.each do |klass, option_type|
        yield klass, slug_for(klass), option_type, description_for(klass)
      end
    end

    private

    def description_for(klass)
      klass.const_get(:DESCRIPTION)
    end

    def slug_for(klass)
      klass
        .name
        .gsub(/.*::/, '')
        .gsub(/([a-z])([A-Z])/, '\1_\2')
        .downcase
        .to_sym
    end
  end
end
