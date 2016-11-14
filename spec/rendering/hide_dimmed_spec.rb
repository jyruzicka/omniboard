require_relative "../spec_helper"

# Ensure that setting +hide_dimmed+ will auto-hide dimmed projects
describe "Column.hide_dimmed" do
  it "should hide dimmed projects when set" do
    d = Rubyfocus::Document.new
    c = Omniboard::Column.new("Dimmable column") do
      dim_when{  |p| p.name == "Dim me" }
      filter_button true
    end

    p = wrap Rubyfocus::Project.new(d, name: "Dim me", id: "dim")
    c << p

    doc = render_xml(c)
    project_node = doc.elements.to_a("//div[contains(@class, 'project') @data-name='Dim me']").first
    expect(project_node).not_to be_nil
    expect(project_node.attribute("class").to_s).not_to include("hidden")

    dim_svg = doc.elements.to_a("//svg[@class='filter-button']/use").first
    expect(dim_svg.attribute("xlink:href").to_s).to eq("#filter-apply")

    c1 = Omniboard::Column.new("Dimmable, hidden column") do
      dim_when{  |p| p.name == "Dim me" }
      hide_dimmed true
      filter_button true
    end
    c1 << p

    doc = render_xml(c1)
    project_node = doc.elements.to_a("//div[@data-name='Dim me' contains(@class, 'project')]").first
    expect(project_node).not_to be_nil
    expect(project_node.attribute("class").to_s).to include("hidden")
    
    dim_svg = doc.elements.to_a("//svg[@class='filter-button']/use").first
    expect(dim_svg.attribute("xlink:href").to_s).to eq("#filter-remove")

    c << p
    Omniboard::Column.hide_dimmed true

    doc = render_xml(c)
    project_node = doc.elements.to_a("//div[@data-name='Dim me' contains(@class, 'project')]").first
    expect(project_node).not_to be_nil
    expect(project_node.attribute("class").to_s).to include("hidden") 

    dim_svg = doc.elements.to_a("//svg[@class='filter-button']/use").first
    expect(dim_svg.attribute("xlink:href").to_s).to eq("#filter-remove")
  end
end