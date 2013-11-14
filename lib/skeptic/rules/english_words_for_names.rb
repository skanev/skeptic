require 'ffi/aspell'
require 'set'

module Skeptic
  module Rules
    class EnglishWordsForNames
      DESCRIPTION = 'Detect if names contain non-English words'

      include SexpVisitor

      PERMANENT_WORD_WHITELIST = Set.new ['args', 'kwargs']

      def initialize(whitelist = '')
        @word_whitelist = PERMANENT_WORD_WHITELIST.merge whitelist.split
        @violations = []
        @aspell_speller = FFI::Aspell::Speller.new 'en_US'
      end

      def apply_to(code, tokens, sexp)
        visit sexp
        self
      end

      def violations
        @violations.map do |name, line|
          "#{name} on line #{line} is not in english"
        end
      end

      def name
        'English words for names'
      end

      private

      on :class, :module do |name, *, body|
        check_ident name
        visit body
      end

      on :def, :defs do |*, name, params, body|
        check_ident name
        visit params
        visit body
      end

      on :lambda do |params, body|
        visit params if params
        visit body
      end

      on :do_block, :brace_block do |(_, params, _), body|
        visit params if params
        visit body
      end

      on :assign do |target, value|
        check_ident target
        visit value
      end

      on :params do |*params|
        extract_param_idents(params).each do |param_ident|
          check_ident param_ident
        end
      end

      def check_ident(ident)
        check_name(extract_name(ident), extract_line_number(ident))
      end

      def check_name(name, line_number)
        words = split_name_to_words(name)

        unless words.all? { |word| english_word? word }
          @violations << [name, line_number]
        end
      end

      def split_name_to_words(text)
        if text.include? '_'
          text.split '_'
        else
          text.scan(/((\A[^A-Z]+)|[A-Z][^A-Z]*)/).map &:first
        end.map do |word|
          strip_word_punctuation(word)
        end.map(&:downcase).reject(&:empty?)
      end

      def strip_word_punctuation(word)
        word.gsub(/[^[^[:ascii:]]a-zA-Z0-9_]/, '')
      end

      def english_word?(word)
        @word_whitelist.include? word or @aspell_speller.correct? word
      end
    end
  end
end
