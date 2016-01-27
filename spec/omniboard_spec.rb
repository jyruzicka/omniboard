require_relative "spec_helper"

describe Omniboard do
  describe ".configuration=" do
    it "should take basic config and return it" do
      Omniboard.configuration = {foo: "bar"}
      expect(Omniboard.configuration(:foo)).to eq("bar")
    end
  end

  describe ".configure" do
    it "should take two arguments and set configuration appropriately" do
      Omniboard.configure(:foo, "baz")
      expect(Omniboard.configuration(:foo)).to eq("baz")
    end
  end

  describe ".config_exists?" do
    it "should return false when config doesn't exist" do
      Omniboard.config_location = "/does/not/exist"
      expect(Omniboard.config_exists?).to be false
    end

    it "should return true when config exists" do
      Omniboard.config_location = File.join(__dir__,"db")
      expect(Omniboard.config_exists?).to be true
    end
  end

  describe ".document_exists?" do
    it "should return true when database exists" do
      Omniboard.config_location = File.join(__dir__, "db")
      expect(Omniboard.document_exists?).to be true
    end

    it "should return false when database doesn't exist" do
      Omniboard.config_location = __dir__
      expect(Omniboard.document_exists?).to be false
    end
  end

  describe ".columns" do
    before(:each) do
      Omniboard::Column.instance_exec{ instance_variable_set("@columns", []) }
      Omniboard.instance_exec{ @columns = nil }
    end

    it "should load all the columns in a given folder, sorting by order" do
      Omniboard.config_location = File.join(__dir__, "db")
      expect(Omniboard.columns.size).to eq(2)
      expect(Omniboard.columns.first.name).to eq("Sample column")
      expect(Omniboard.columns.first.order).to eq(42)
    end

    it "should provide an empty array if folder does not exist" do
      Omniboard.config_location = __dir__
      expect(Omniboard.columns).to eq([])
    end
  end

end