# frozen_string_literal: true

require_relative 'loaders/yardoc_loader'
require_relative 'loaders/markdown_loader'
require_relative 'loaders/ruby_doc_loader'
require_relative 'loaders/c_doc_loader'
require_relative 'loaders/file_loader'

class Reader
  attr_accessor :loader

  EXT_TO_PARSER_CLASS = {
    '.rb' => RubyDocLoader,
    '.c' => CDocLoader,
    '.cpp' => CDocLoader,
    '.cxx' => CDocLoader,
    '.md' => MarkdownLoader
  }.freeze

  def initialize; end

  def read
    loader.process.result
  end

  def parsing_errors
    loader.errors
  end

  def for(path)
    @loader = EXT_TO_PARSER_CLASS[File.extname(path)].new(file: path)
    self
  end
end
