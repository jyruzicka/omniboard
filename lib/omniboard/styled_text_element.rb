# Represents a little bit of styled text, complete with styling values and the like.
# Make me big, make me small, make me italic, just don't make me work weekends.
class Omniboard::StyledTextElement
  # The actual text
  attr_accessor :text

  # Applied values
  attr_accessor :styles

  # Initialize from a string
  def initialize(string)
    @text = string[/<lit>(.*?)<\/lit>/,1] || ""
    @styles = {}

    raw_styles = string[/<style>(.*?)<\/style>/,1]
    if raw_styles
      raw_styles.scan(/<value key="(.*?)">(.*?)<\/value>/).each do |match|
        @styles[match[0]] = match[1]
      end
    end
  end

  def [] k
    @styles[k]
  end

  def to_html
    surrounds = []
    surrounds << "i" if self["font-italic"] == "yes"
    surrounds << "b" if self["font-weight"].to_i > 7
    surrounds << "u" if self["underline-style"] == "single"

    tag(text, *surrounds)
  end

  private
  def tag(text, *tags)
    tags.map{|t| "<#{t}>"}.join("") + text + tags.reverse.map{|t| "</#{t}>"}.join("")
  end
end