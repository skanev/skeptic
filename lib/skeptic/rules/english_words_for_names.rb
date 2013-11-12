require 'ffi/aspell'

module Skeptic
  module Rules
    class EnglishWordsForNames
      DESCRIPTION = 'Detect if names contain non-English words'

      include SexpVisitor

      def initialize(ignore = '')
        @ignore_words = ignore.split(' ')
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

      on :class, :module do |name, *args, body|
        check_ident name
        visit body
      end

      on :def, :defs do |*args, name, params, body|
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

      on :params do |unary_params, default_params , rest_params, *args, block_param|
        unary_param_idents = extract_unary_param_idents unary_params

        param_idents = unary_param_idents +
                       default_params.to_a.map(&:first) +
                       rest_params.to_a[1..-1].to_a +
                       [block_param].compact

        param_idents.each { |param_ident| check_ident param_ident }
      end

      on :assign do |target, value|
        check_ident target
        visit value
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
        @ignore_words.include? word or @aspell_speller.correct? word
      end
    end
  end
end
