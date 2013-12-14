# encoding: utf-8
require 'spec_helper'

module Skeptic
  module Rules
    describe EnglishWordsForNames do
      it_behaves_like 'Rule' do
        subject { EnglishWordsForNames.new }
      end

      def expect_classy_english(code, ignore_words = [])
        analyze(code, ignore_words.join(' ')).violations.should be_empty
      end

      def expect_vogon_mumble(code, ignore_words = [])
        analyze(code, ignore_words.join(' ')).violations.should_not be_empty
      end

      def analyze(code, ignore = '')
        apply_rule EnglishWordsForNames, ignore, code
      end
    end
  end
end
