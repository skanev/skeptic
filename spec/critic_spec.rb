require 'spec_helper'

module Skeptic
  describe Critic do
    let(:critic) { Critic.new }

    it "can locate semicolons in the code" do
      criticize 'foo; bar', complain_about_semicolons: true

      expect_criticism 'You have a semicolon at line 1, column 3', 'Semicolons'
    end

    it "can locate deep levels of nesting" do
      criticize <<-RUBY, max_nesting: 1
        class Foo
          def bar
            while true
              if false
                really?
              end
            end
          end
        end
      RUBY

      expect_criticism 'Foo#bar has 2 levels of nesting: while > if', 'Deep nesting'
    end

    it "can locate classes with too many methods" do
      criticize <<-RUBY, methods_per_class: 1
        class Foo
          def bar; end
          def baz; end
        end
      RUBY

      expect_criticism 'Foo has 2 methods: #bar, #baz', 'Number of methods per class'
    end

    it "can locate methods that are too long" do
      criticize <<-RUBY, method_length: 1
        class Foo
          def bar
            one
            two
            three
          end
        end
      RUBY

      expect_criticism 'Foo#bar is 3 lines long', 'Number of lines per method'
    end

    def criticize(code, options)
      options.each do |key, value|
        critic.send "#{key}=", value
      end

      critic.criticize code
    end

    def expect_criticism(message, type)
      critic.criticism.should include [message, type]
    end
  end
end