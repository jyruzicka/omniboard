require_relative "../spec_helper"

# Ensure that setting +display_project_counts+ on a column will show the number of projects in it
describe "Column#display_project_counts" do

  before(:all) do
    d = Rubyfocus::Document.new
    @c = Omniboard::Column.new("Default") do
      dim_when{ |p| p.name == "Dim me" }
      mark_when{ |p| p.name == "Mark me" }
    end

    @c << Rubyfocus::Project.new(d, name: "Dim me", id: "dim")
    @c << Rubyfocus::Project.new(d, name: "Do nothing", id: "nil")
    @c << Rubyfocus::Project.new(d, name: "Mark me", id: "mark")
  end

  describe "when set to 'all'" do
    it "should show the count of all projects in a column" do
      @c.display_project_counts :all

      doc = render_xml(@c)
      expect(doc.elements.to_a("//div[@class='column-total']").first.text).to eq("3")
    end
  end

  describe "when set to 'active'" do
    it "should show the count of all active (i.e. non-dimmed) projects in a column" do
      @c.display_project_counts :active

      doc = render_xml(@c)
      expect(doc.elements.to_a("//div[@class='column-total']").first.text).to eq("2")
    end
  end

  describe "when set to 'marked'" do
    it "should show the count of all marked projects in a column" do
      @c.display_project_counts :marked

      doc = render_xml(@c)
      expect(doc.elements.to_a("//div[@class='column-total']").first.text).to eq("1")
    end
  end

  describe "when set to an invalid value" do
    it "should throw an error" do
      expect{ @c.display_project_counts "foobar" }.to raise_exception(ArgumentError)
      expect{ Omniboard::Column.display_project_counts "foobar" }.to raise_exception(ArgumentError)
    end
  end
end