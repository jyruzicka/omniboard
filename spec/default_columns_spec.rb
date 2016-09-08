def load_default_columns
  Omniboard::Column.reset_columns
  default_columns_path = File.join(__dir__, "../lib/omniboard/columns/*")
  Dir[default_columns_path].each{ |f| require(f) }
end

describe "default columns" do
  before(:each){ load_default_columns }
  after(:each) do
    Omniboard::Column.reset_columns
    Omniboard::Column.clear_config :all
  end

  it "should accept a project with no parent group" do
    d = Rubyfocus::Document.new
    p = Rubyfocus::Project.new(d, name: "foo project", id: "Sample ID")
    Omniboard::Column.columns.each do |c|
      c.add p
    end
  end
end
