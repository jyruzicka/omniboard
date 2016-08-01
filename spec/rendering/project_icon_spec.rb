require_relative "../spec_helper"

# Ensure that projects show the right icon, and alt, where required
describe "config.rb icon:" do
  it "should give a project an svg icon if required" do
   
    Omniboard::Column.icon{ |p| p.name == "Icon project" ? "svg:icon" : nil }

    d = Rubyfocus::Document.new
    p = wrap Rubyfocus::Project.new(d, name: "Standard project", id: "1")
    
    expect(render p).to_not contain_xpath("//svg")
    expect(render p).to_not contain_xpath("//img")

    c = Omniboard::Column.new("Default")

    # We need to wrap this! ProjectWrapper needs to know it's in a column
    p2 = wrap Rubyfocus::Project.new(d, name: "Icon project", id: "2")
    c << p2

    expect(render p2).to contain_xpath("//svg")
    expect(render p2).to contain_xpath("//use[@xlink:href='#icon']")
  end

  it "should give a project an img icon if required" do
    Omniboard::Column.icon{ |p| p.name == "Icon project" ? "icon.png" : nil }

    d = Rubyfocus::Document.new
    

    p = wrap Rubyfocus::Project.new(d, name: "Standard project", id: "1")
    expect(render p).to_not contain_xpath("//svg")
    expect(render p).to_not contain_xpath("//img")

    c = Omniboard::Column.new("Default")
    p2 = wrap Rubyfocus::Project.new(d, name: "Icon project", id: "2")
    c << p2

    expect(render p2).to contain_xpath("//img[@src='icon.png']")
  end

  it "should supply an alt text if required" do
    Omniboard::Column.icon{ |p| p.name == "Icon project" ? ["icon.png", "This is an icon"] : nil }

    d = Rubyfocus::Document.new


    p = wrap Rubyfocus::Project.new(d, name: "Standard project", id: "1")
    expect(render p).to_not contain_xpath("//svg")
    expect(render p).to_not contain_xpath("//img")

    c = Omniboard::Column.new("Default")
    p2 = wrap Rubyfocus::Project.new(d, name: "Icon project", id: "2")
    c << p2

    expect(render p2).to contain_xpath("//div[@class='project-icon' @alt='This is an icon' @title='This is an icon']")
  end
end