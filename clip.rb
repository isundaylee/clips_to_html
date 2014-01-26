require_relative 'item'

class Clip < Item

  attr_accessor :text

  def initialize(datetime, text)
    super datetime, :clip
    @text = text
  end

end