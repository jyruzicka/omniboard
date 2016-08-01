require_relative "spec_helper"

class SampleClass
	include Omniboard::Property

	property :foo
	block_property :bar

  property :restricted_property, allowed_values: [1,2,3]

  property :munged_property, munge: lambda{ |o| o / 2 }
  property :symbol_munged_property, munge: :to_i
end

describe Omniboard::Property do
  let(:o){ SampleClass.new}

  describe "#property" do
    it "should allow us to set and retrieve properties" do
   		o.foo(3)
   		expect(o.foo).to eq(3)
   		expect{ o.foo(1,2) }.to raise_error(ArgumentError)
    end

    it "should only allow allowed_values" do
      o.restricted_property(2)

      expect{ o.restricted_property(4) }.to raise_error(ArgumentError)
    end

    it "should munge values when munge is set" do
      o.munged_property(4)
      expect(o.munged_property).to eq(2)

      o.symbol_munged_property("4")
      expect(o.symbol_munged_property).to eq(4)
    end
  end

  describe "#block_property" do
    it "should allow us to set and retrieve blocks" do
      o.bar{ |i| i * 2 }
      expect(o.bar[3]).to eq(6)
    end

    it "should also take non-block arguments, but only if no block is supplied" do
      o.bar(3){ true }
      expect(o.bar).to be_a(Proc)

      o.bar(3)
      expect(o.bar).to eq(3)

      expect{o.bar(3,4).to raise_error(ArgumentError)}
    end
  end
end