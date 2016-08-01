require_relative "../spec_helper"

# Ensure that setting +project_limit+ will show columns totals as red, if column totals are enabled
describe "Column#project_limit" do
  it "should not change anything if no display" do

    # Set up 
    d = Rubyfocus::Document.new
    c = Omniboard::Column.new("Default"){ project_limit 1 }
    c << Rubyfocus::Project.new(d, name: "Highlighted Project", note: "Highlighted", id: "1")

    expect(render c).not_to contain_xpath("//div[contains(@class, 'limit-breached')]")
  end

  it "should not change anything if less or equal projects than limit" do

    # Set up 
    d = Rubyfocus::Document.new
    Omniboard::document = d

    c = Omniboard::Column.new("Default") do
      display_total_projects true
      project_limit 1
    end

    c << Rubyfocus::Project.new(d, name: "Highlighted Project", note: "Highlighted", id: "1")
    expect(render c).not_to contain_xpath("//div[contains(@class, 'limit-breached')]")
  end

  it "should be red if greater projects than limit" do
    # Set up 
    d = Rubyfocus::Document.new
    Omniboard::document = d

    c = Omniboard::Column.new("Default") do
      display_total_projects true
      project_limit 0
    end

    c << Rubyfocus::Project.new(d, name: "Highlighted Project", note: "Highlighted", id: "1")

    expect(render c).to contain_xpath("//div[contains(@class, 'limit-breached')]")
  end
end