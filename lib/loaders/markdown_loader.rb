require 'kramdown'

require_relative'./base_loader'
require_relative'../kramdown/converter/filtered_hash'

class MarkdownLoader < BaseLoader
  attr_reader :result

  def initialize input = nil, file: nil, parser: 'GFM'
    @custom_dictionary = []
    @input = input || IO.read(file)
    @result = {}
    @parser = parser
  end

  def process
    tree = Kramdown::Document.new(@input, input: @parser).to_filtered_hash
    extract_values(tree)
    self
  end

  private

  def extract_values tree
    tree[:children].grep(Hash).map do |child| 
      if child[:children]
        extract_values(child)
      else
        if @result[ child[:location] ].nil?
          @result[ child[:location] ] = sanitize_value(child[:value])
        else
          @result[ child[:location] ] += sanitize_value(child[:value])
        end
      end
    end
  end

  def sanitize_value value
    # TODO: delete raw URLs or something else
    filter_code_objects(value)
  end
end