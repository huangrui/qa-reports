class ParseError < StandardError
  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end
end