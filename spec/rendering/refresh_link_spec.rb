require_relative "../spec_helper"

# Ensure that setting +refresh_link+ will show a link allowing us to refesh the page.
describe "Column.config.refresh_link" do
  it "should not change anything if not set" do
    # Set up 
    expect(render nil).to_not include(%|refresh-link|)
  end

  it "should add a link when set" do
    # Set up
    Omniboard::Column.config{ refresh_link "/" }
    expect(render nil).to include(%|refresh-link|)
  end
end