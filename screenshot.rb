require_relative 'item'

class Screenshot < Item

  attr_accessor :path

  def initialize(datetime, path)
    super datetime, :screenshot
    @path = path
  end

end