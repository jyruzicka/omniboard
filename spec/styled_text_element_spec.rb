require_relative "spec_helper"

describe Omniboard::StyledTextElement do
  def parse(text)
    Omniboard::StyledTextElement.new(text)
  end

  describe "#initialize" do
    it "should show blank string, no styles for plain text" do
      st = parse("foo")
      expect(st.styles).to eq({})
      expect(st.text).to eq("")
    end

    it "should deal with an absense of styles" do
      st = parse("<lit>foobar</lit>")
      expect(st.styles).to eq({})
      expect(st.text).to eq("foobar")
    end

    it "should apply styles when they appear" do
      st = parse(%|<run><style><value key="foo">bar</value></style><lit>foobar</lit></run>|)
      expect(st["foo"]).to eq("bar")
      expect(st.text).to eq("foobar")
    end
  end

  describe "#to_html" do
    it "should output the literal text, devoid of styles" do
      st = parse(%|<run><style><value key="foo">bar</value></style><lit>foobar</lit></run>|)
      expect(st.to_html).to eq("foobar")
    end

    it "should output italic text as italics" do
      st = parse(%|<run><style><value key="font-italic">yes</value></style><lit>foobar</lit></run>|)
      expect(st.to_html).to eq("<i>foobar</i>")
    end
  end
end