# Represents some HTML-esque styled text
#
# The incredibly naive parser assumes all sorts of things about your notes, and
# faithfully turns them into a StyledText object.
#
# Will probably crash horridly if you try something nasty on it. Don't do that.
# Things it will choke on (off the top of my head):
#
# * Nested <run>s
# * <run>s with attributes
# * <text> or <note> tags within the body of this actual note
# * All kinds of other things?

class Omniboard::StyledText
  # All the elements that make up this styled text
  attr_accessor :elements

  # Parse some styled html
  def self.parse(styled_html)
    # Remove outlying HTML - surrounding <note> and <text> elements
    superfluous_tags = /<\/?(note|text)>/
    styled_html = styled_html.gsub(superfluous_tags, "")

    return_value = self.new

    # Run on all text
    until styled_html.empty?

      next_run_index = styled_html.index("<run>")

      if next_run_index.nil?
        return_value << styled_html
        styled_html = ""
      
      else
        # Get rid of any plain html!
        if next_run_index != 0
          return_value << styled_html[0...next_run_index]
          styled_html = styled_html[next_run_index..-1]
        end

        run_end = styled_html.index("</run>") + "</run>".length
        return_value << Omniboard::StyledTextElement.new(styled_html[0...run_end])
        styled_html = styled_html[run_end..-1]
      end
    end
    return_value
  end

  def initialize()
    @elements = []
  end

  # Add an element to the elements array
  def << element
    @elements << element
  end

  # Turn this styled text into html!
  def to_html
    @elements.map{ |e| e.is_a?(String) ? e : e.to_html }.join("")
  end
end
