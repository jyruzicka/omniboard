require_relative "../spec_helper"

# Ensure that projects show the right icon, and alt, where required
describe "config.rb icon:" do
  it "should give a project an svg icon if required" do
   
    Omniboard::Column.config do
        icon{ |p| p.name == "Icon project" ? "svg:icon" : nil }
    end

    d = Rubyfocus::Document.new
    Omniboard::document = d
    c = Omniboard::Column.new("Default")

    p = wrap Rubyfocus::Project.new(d, name: "Standard project", id: "1")
    expect(render p).to_not include_tag("svg")
    expect(render p).to_not include_tag("img")

    p2 = wrap Rubyfocus::Project.new(d, name: "Icon project", id: "2")
    c << p2
    expect(render p2).to include_tag("svg")
    expect(render p2).to include_tag("use", :"xlink:href" => "#icon")
  end

  it "should give a project an img icon if required" do
    Omniboard::Column.config do
        icon{ |p| p.name == "Icon project" ? "icon.png" : nil }
    end

    d = Rubyfocus::Document.new
    Omniboard::document = d
    c = Omniboard::Column.new("Default")

    p = wrap Rubyfocus::Project.new(d, name: "Standard project", id: "1")
    expect(render p).to_not include_tag("svg")
    expect(render p).to_not include_tag("img")

    p2 = wrap Rubyfocus::Project.new(d, name: "Icon project", id: "2")
    c << p2
    expect(render p2).to include_tag("img", src: "icon.png")
  end

  it "should supply an alt text if required" do
    Omniboard::Column.config do
        icon{ |p| p.name == "Icon project" ? ["icon.png", "This is an icon"] : nil }
    end

    d = Rubyfocus::Document.new
    Omniboard::document = d
    c = Omniboard::Column.new("Default")

    p = wrap Rubyfocus::Project.new(d, name: "Standard project", id: "1")
    expect(render p).to_not include_tag("svg")
    expect(render p).to_not include_tag("img")

    p2 = wrap Rubyfocus::Project.new(d, name: "Icon project", id: "2")
    c << p2
    expect(render p2).to include_tag("div", class: "project-icon", alt: "This is an icon", title: "This is an icon")
  end
end