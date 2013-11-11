# encoding: utf-8
require 'spec_helper'

module Skeptic
  module Rules
    describe EnglishWordsForNames do
      it_behaves_like 'Rule' do
        subject { EnglishWordsForNames.new }
      end

      describe 'recognizing english words in names' do
        it 'can recognize english words in snake case' do
          expect_classy_english('fancy = 2')
          expect_classy_english('sir_girl = 4')
          expect_classy_english('woman_label = //')
          expect_classy_english('zero_zombie_zebra = :a')
        end

        it 'can recognize english words in camel case' do
          expect_classy_english('Fancy = 0')
          expect_classy_english('class ApplyRule;end')
          expect_classy_english('module FunctionFunction;end')
          expect_vogon_mumble('DescribefReportCode = :baba')
        end

        it 'can recognize english words in screaming snake case' do
          expect_classy_english('FANCY = 2')
          expect_classy_english('I_MUST_BE_COOL = "w"')
          expect_classy_english('EXPECT_CLASSY_FRENCH = BLACK')
          expect_classy_english('SEXY_PEACE = 0')
          expect_vogon_mumble('@fearf = MIND')
        end

        it 'can recognize non-English words in names' do
          expect_vogon_mumble('meine_var = 0')
          expect_vogon_mumble('DlWsLx = A')
          expect_vogon_mumble('@wursty = good')
          expect_vogon_mumble('@@bueno = good')
        end

        it 'can recognize non-English words in definitions' do
          expect_vogon_mumble('class Ekc;end')
          expect_vogon_mumble('module Ej;end')
          expect_classy_english('class Animal;def !;true;end;end')
          expect_classy_english('class Animal;def |(other);end;end')
          expect_vogon_mumble('def beautifulJfghg; 2; end')
          expect_vogon_mumble('def function_with_default(hz = 2);end')
          expect_vogon_mumble('def horse.sayy;end')
        end

        it 'can recognize non-English words in params of def' do
          expect_vogon_mumble('def is(zeM);end')
          expect_vogon_mumble('def function(prm, parameter);end')
          expect_vogon_mumble('def function_with_rest(*rkf);end')
          expect_vogon_mumble('def function_with_block(&ane);2;end')
          expect_classy_english('is = -> queer { 4 }')
          expect_vogon_mumble('object = proc { |varh| varh }')
          expect_classy_english('zombie = -> { 2 }')
          expect_classy_english('zombie = proc { 2 }')
        end

        it "doesnt't check if outside names are in English" do
          expect_classy_english('zn')
          expect_classy_english('classy = diz_word_iz_stepif')
          expect_classy_english('0.upto(4)')
          expect_classy_english('sentence.downcase')
        end

        it 'checks different conjugations of verbs' do
          expect_classy_english('confused = 0')
          expect_classy_english('ran = 2')
        end

        it 'checks plurals of nouns' do
          expect_classy_english('criteria = 2')
          expect_classy_english('men = 4')
        end

        it 'ignores words in the ignore_words list' do
          expect_classy_english('zy = 0', ['zy'])
          expect_classy_english('@your_nice_wutwet = nil', ['wutwet', 'la'])
        end
      end

      describe 'reporting' do
        it 'shows the non-English names' do
          analyzer = analyze <<-RUBY
            weird = 0
            antwort
            computer = nil
            баница = pork
            hello = 4
            def grandme; 2; end
          RUBY

          analyzer.violations.should include 'grandme on line 6 is not in english'
          analyzer.violations.should include 'баница on line 4 is not in english'
        end
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
