require_relative 'clip'

class IbooksClip < Clip

  attr_accessor :author, :title

  REGEXP = /“(.*?)”\s*Excerpt From: (.*?). “(.*?).” iBooks./m

  def initialize(datetime, raw_content)
    match = raw_content.match(REGEXP)

    raise 'Not an iBooks clip entry. ' if match.nil?

    super datetime, match[1]
    @type = :ibooks_clip
    @author = match[2]
    @title = match[3]
  end

  def self.check(raw_content)
    raw_content =~ REGEXP
  end

end