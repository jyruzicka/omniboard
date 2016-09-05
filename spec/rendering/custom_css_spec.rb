require_relative "../spec_helper"

# Ensure that if we set a custom CSS file, that custom CSS ends up in the output file.
describe "Colum.custom_css" do
  before(:all) do
    Omniboard.document = Rubyfocus::Document.new
  end

  it "should not show custom CSS when no custom.css file exists" do
    expect(render nil).not_to include(".foobar")    
  end

  it "should show custom CSS when custom.css exists" do
    Omniboard.config_location = File.join(__dir__, "../config/custom_css")
    expect(render nil).to include(".foobar")  
  end
end
