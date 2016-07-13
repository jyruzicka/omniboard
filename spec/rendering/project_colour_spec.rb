require_relative "../spec_helper"

# Ensure that putting a colour specification in the config file will cause that project to go a certain colour
describe "config.rb colour:" do
  it "should cause a project to be a certain colour" do
   
    # Set up 
    Omniboard::Column.config do
        colour_group(10){ |g| g == "Highlighted" }
        colour_group(120){ |g| g == "Cool off" }
    end

    d = Rubyfocus::Document.new
    Omniboard::document = d

    c = Omniboard::Column.new("Default"){ group_by{ |p| p.note } }
    c << Rubyfocus::Project.new(d, name: "Highlighted Project", note: "Highlighted", id: "1")
    expect(render c).to include_tag("div", data: {name: "Highlighted Project", colour: "hsl(10,100%,80%)"})
  end
end