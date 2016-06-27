require_relative "spec_helper"

describe Omniboard::StyledText do
  describe "#<<" do
    it "should add stuff?" do
      e = Omniboard::StyledText.new
      e << "foo"
      e << "bar"
      expect(e.elements).to eq(["foo", "bar"])
    end
  end

  describe "#to_html" do
    it "should allow string literals through" do
      e = Omniboard::StyledText.new
      e << "foo"
      e << "bar"
      expect(e.to_html).to eq("foobar")
    end

    it "should call to_html on non-strings" do
      text_element = double("StyledTextElement")
      expect(text_element).to receive(:to_html).and_return("bar.")
      e = Omniboard::StyledText.new
      e << "Foo "
      e << text_element
      expect(e.to_html).to eq("Foo bar.")
    end
  end

  describe ".parse" do
    def parse(str)
      Omniboard::StyledText.parse(str)
    end

    it "should parse just a string" do
      st = parse("Foobar!")
      expect(st.elements).to eq(["Foobar!"])
    end

    it "should parse just styled text (one run)" do
      st = parse("<run><lit>foooo</lit></run>")
      expect(st.elements.size).to eq(1)
    end

    it "should parse two things" do
      expect(parse("aaaa<run><lit>foooo</lit></run>").elements.size).to eq(2)
      expect(parse("<run><lit>foooo</lit></run>aaaaa").elements.size).to eq(2)
      expect(parse("aaaa <run><lit>foooo</lit></run>aaaaa").elements.size).to eq(3)
    end

    it "should parse two runs!" do
      expect(parse("<run><lit>foooo</lit></run><run><lit>barrrr</lit></run>").elements.size).to eq(2)
    end
  end  
end