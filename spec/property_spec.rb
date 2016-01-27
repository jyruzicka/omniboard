require_relative "spec_helper"

class SampleClass
	include Omniboard::Property

	property :foo
	block_property :bar
end

describe Omniboard::Property do
  describe "#property" do
    it "should allow us to set and retrieve properties" do
   		o = SampleClass.new
   		o.foo(3)
   		expect(o.foo).to eq(3)
   		expect{ o.foo(1,2) }.to raise_error(ArgumentError)
    end
  end

  describe "#block_property" do
    it "should allow us to set and retrieve blocks" do
      o = SampleClass.new
      o.bar{ |i| i * 2 }
      expect(o.bar[3]).to eq(6)
    end
  end
end