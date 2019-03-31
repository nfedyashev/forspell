# frozen_string_literal: true

require 'ffi/hunspell'

module Forspell
  class Speller
    attr_reader :dictionary

    SUGGESTIONS_SIZE = 3
    HUNSPELL_DIRS = [File.join(__dir__, 'dictionaries')]
    RUBY_DICT = File.join(__dir__, 'ruby.dict')

    def initialize(main_dictionary, *custom_dictionaries)
      FFI::Hunspell.directories = HUNSPELL_DIRS << File.dirname(main_dictionary)
      @dictionary = FFI::Hunspell.dict(File.basename(main_dictionary))

      [RUBY_DICT, *custom_dictionaries].flat_map { |path| File.read(path).split("\n") }
                                       .compact
                                       .map { |line| line.gsub(/\s*\#.*$/, '') }
                                       .reject(&:empty?)
                                       .map { |line| line.split(/\s*:\s*/, 2) }
                                       .each do |word, example|
        example ? @dictionary.add_with_affix(word, example) : @dictionary.add(word)
      end
    rescue ArgumentError
      puts "Unable to find dictionary #{main_dictionary}"
      exit(2)
    end

    def correct?(word)
      dictionary.check?(word)
    end

    def suggest(word)
      dictionary.suggest(word).first(SUGGESTIONS_SIZE)
    end
  end
end
