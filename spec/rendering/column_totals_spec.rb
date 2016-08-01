require_relative "../spec_helper"

# Ensure that setting +display_total_projects+ to true on a column will show the number of projects in it
describe "Column#display_total_projects" do
  it "should cause column project totals to be displayed" do
   
    # Set up 
    d = Rubyfocus::Document.new
    Omniboard::document = d

    c = Omniboard::Column.new("Default"){ display_total_projects true }
    c << Rubyfocus::Project.new(d, name: "Highlighted Project", note: "Highlighted", id: "1")

    expect(render c).to contain_one_xpath("//div[@class='column-total']")
  end
end