require_relative "spec_helper"

def render_column(column)
  column_file = File.join(__dir__, "../lib/omniboard/templates/column.erb")
  ERB.new(File.read column_file).result(binding)
end

def make_projects *names
  names.map{ |n| double(name: n, id: nil, note: nil) }
end

describe Omniboard::Column do
  #---------------------------------------
  # Basics

	describe "properties" do
    it "should have all the various properties" do
      c = Omniboard::Column.new("Sample Column")
      expect(c.name).to eq("Sample Column")
      expect(c.order).to eq(0)
      expect(c.display).to eq(:full)
      expect(c.sort).to eq(:inherit)
    end
  end

  describe "#add" do
    it "should only accept projects that fulfil its criteria" do
      c = Omniboard::Column.new("Sample column")
      c.conditions{ |p| p.name == 2 }
      c.add make_projects(1,2,3)
      expect(c.projects.size).to eq(1)
      expect(c.projects.first.name).to eq(2)
    end

    it "should create ProjectWrappers for all its items" do
      c = Omniboard::Column.new("Sample column")
      c.add(1)
      expect(c.projects.first.column).to eq(c)
    end

    it "should avoid wrapping ProjectWrappers in more ProjectWrappers" do
      c = Omniboard::Column.new("Sample column")
      pw = Omniboard::ProjectWrapper.new(1)
      c.add(pw)
      expect(c.projects.first.project).to eq(1)
    end
  end

  describe "#projects" do
  	let(:c){ Omniboard::Column.new("Sample column"){ self.projects = [1,2,5,3,4] } }
    it "should be fine with no sort block" do
      expect(c.projects).to be_a(Array)
    end

    it "should sort using sort_by() with 1 argument" do
      c.sort{ |p| p }
      expect(c.projects).to eq([1,2,3,4,5])
    end

    it "should sort using sort() with 2 arguments" do
      c.sort do |a,b|
      	# Evens first, descending
      	if (a%2 == 0) && (b%2 != 0)
      		-1
      	elsif (a%2 != 0) && (b%2 == 0)
      		1
      	else
      		b <=> a
      	end
      end
      expect(c.projects).to eq([4,2,5,3,1])
    end

    it "should complain about a sort() using >2 arguments" do
      c.sort{ |a,b,c| true }
      expect{ c.projects }.to raise_error(ArgumentError)
    end

    it "should only let out projects fitting a given group" do
      c = Omniboard::Column.new("Sample column")
      c.group_by{ |p| p[:group] }
      c.add({name: "foo", group: "red"})
      c.add({name: "bar", group: "blue"})
      c.add({name: "baz", group: "red"})

      expect(c.projects("red").size).to eq(2)
      expect(c.projects(Omniboard::Group["blue"]).size).to eq(1)
    end
  end

  #---------------------------------------
  # Block properties

  describe "#property" do
    it "should fetch an instance property when provided" do
      c = Omniboard::Column.new("Sample column")

      c.sort{ 3 }
      expect(c.property(:sort)[]).to eq(3)
    end

    it "should fall back to the Column property if :inherit is set" do
      Omniboard::Column.sort{ 4 }
      c = Omniboard::Column.new("No sort")
      expect(c.property(:sort)[]).to eq(4)
    end

    it "should return nil if the property is set to nil, regardless of Column property" do
      Omniboard::Column.sort{ 4 }
      c = Omniboard::Column.new("No sort")
      c.sort nil
      expect(c.property(:sort)).to eq(nil)

      c.sort :inherit
      expect(c.property(:sort)[]).to eq(4)
    end

    it "should raise an error if we call property on an unknown property" do
      c = Omniboard::Column.new("Sample")
      expect{c.property(:foo)}.to raise_error(ArgumentError)
    end

    after(:each){ Omniboard::Column.clear_config :sort}
  end

  describe "#mark_when" do
    it "should mark a project if it obeys the marked block" do
      c = Omniboard::Column.new("Sample column"){ mark_when{ |p| p.project == 2} }
      projects = [1,2,3]
      c.add projects

      project_named_two = c.projects.find{ |p| p.project == 2 }
      expect(project_named_two.marked).to eq(true)
      project_named_one = c.projects.find{ |p| p.project == 1 }
      expect(project_named_one.marked).to eq(false)
    end

    it "should revert to the default column marked block" do
      Omniboard::Column.mark_when { |p| p.project == 2}
      c = Omniboard::Column.new("No mark")
      projects = [1,2,3]
      c.add projects

      project_named_two = c.projects.find{ |p| p.project == 2 }
      expect(project_named_two.marked).to eq(true)
      project_named_one = c.projects.find{ |p| p.project == 1 }
      expect(project_named_one.marked).to eq(false)
      
      Omniboard::Column.clear_config :mark_when
    end
  end

   describe "#dim_when" do
    it "should dim a project if it obeys the dimmed block" do
      c = Omniboard::Column.new("Sample column"){ dim_when{ |p| p.project == 2} }
      projects = [1,2,3]
      c.add projects

      project_named_two = c.projects.find{ |p| p.project == 2 }
      expect(project_named_two.dimmed).to eq(true)
      project_named_one = c.projects.find{ |p| p.project == 1 }
      expect(project_named_one.dimmed).to eq(false)
    end

    it "should revert to the default column dimmed block" do
      Omniboard::Column.dim_when { |p| p.project == 2}
      c = Omniboard::Column.new("No dim")
      projects = [1,2,3]
      c.add projects

      project_named_two = c.projects.find{ |p| p.project == 2 }
      expect(project_named_two.dimmed).to eq(true)
      project_named_one = c.projects.find{ |p| p.project == 1 }
      expect(project_named_one.dimmed).to eq(false)
      
      Omniboard::Column.clear_config :dim_when
    end
  end

  describe "#icon" do
    it "should assign an icon to a project if it obeys the icon block" do
      c = Omniboard::Column.new("Sample column"){ icon{ "foo"} }
      c.add(1)

      expect(c.projects.first.icon).to eq("foo")
    end

    it "should revert to the default icon block if required" do
      Omniboard::Column.icon { "bar" }
      c = Omniboard::Column.new("No icon block")
      c.add(1)

      expect(c.projects.first.icon).to eq("bar")
      
      Omniboard::Column.clear_config :icon
    end
  end

  #---------------------------------------
  # Grouping-related methods
  describe "#group_by" do
    it "should allow us to group projects when supplied" do
      c = Omniboard::Column.new("Group by foo"){ group_by{ |p| "Foo: #{p[:foo]}" } }
      projects = [{foo: 1}, {foo: 2}, {foo: 1}]
      c.add(projects)

      gp = c.grouped_projects
      expect(gp[Omniboard::Group["Foo: 1"]].size).to eq(2)
      expect(gp[Omniboard::Group["Foo: 2"]].size).to eq(1)
    end

    it "should throw an error if we try to group and there is no group_by defined" do
      c = Omniboard::Column.new("No grouping")
      projects = [{foo: 1}, {foo: 2}, {foo: 1}]
      c.add(projects)

      expect{c.grouped_projects}.to raise_error RuntimeError
    end
  end

  describe "#can_be_grouped?" do
    it "should return true if a column has a group_by? block" do
      c = Omniboard::Column.new("Sample column")
      expect(c.can_be_grouped?).to eq(false)
      c.group_by{ true }
      expect(c.can_be_grouped?).to eq(true)
    end

    it "should return true if the class-based group_by is set" do
      c = Omniboard::Column.new("Another sample column")
      expect(c.can_be_grouped?).to eq(false)
      Omniboard::Column.group_by{ true } 
      expect(c.can_be_grouped?).to eq(true)

      Omniboard::Column.clear_config :group_by
    end
  end

  describe "#groups" do
    it "should return the groups it will split the columns into, alphabetically ordered" do
      c = Omniboard::Column.new("Sample column")
      c.group_by{ |h| h[:group] }

      c.add({name: "foo", group: "red"})
      c.add({name: "bar", group: "red"})
      c.add({name: "baz", group: "blue"})
      expect(c.groups).to eq(%w|blue red|)
    end
  end

  describe "#sort_groups" do
    it "should let us sort sort_groups" do
      c = Omniboard::Column.new("Sample column")
      c.group_by{ |h| h[:group] }
      c.sort_groups do |x,y|
        if x == "zzz"
          -1
        elsif y == "zzz"
          1
        else
          x <=> y
        end
      end

      c.add({name: "foo", group: "red"})
      c.add({name: "bar", group: "zzz"})
      c.add({name: "baz", group: "blue"})
      expect(c.groups).to eq(%w|zzz blue red|)
    end

    it "should default to Column.sort_groups" do
      Omniboard::Column.sort_groups{ |x,y| y <=> x } #reverse alpha

      c = Omniboard::Column.new("Sample column")
      c.group_by{ |h| h[:group] }

      c.add({name: "foo", group: "red"})
      c.add({name: "bar", group: "zzz"})
      c.add({name: "baz", group: "blue"})

      expect(c.groups).to eq(%w|zzz red blue|)

      Omniboard::Column.clear_config :sort_groups
    end
  end

  describe "#filter_button" do
    it "should produce a filter button" do
      c = Omniboard::Column.new("Hide"){ filter_button true }
      expect(render_column c).to include(%|<svg class="filter-button"|)
    end
  end

  #---------------------------------------
  # Class methods

  describe ".columns" do
    it "should record all columns" do
      c = Omniboard::Column.new("Foo column")
      expect(Omniboard::Column.columns).to include(c)
    end
  end

  #---------------------------------------
  # Config methods

  describe ".config" do
    it "should open a block in the context of the Column" do
      expect(Omniboard::Column.config{ self }).to eq(Omniboard::Column)
    end
  end

  describe ".clear_config" do
    it "should clear a given configuration variables" do
      Omniboard::Column.conditions{ true }
      Omniboard::Column.clear_config :conditions

      expect(Omniboard::Column.conditions).to eq(nil)
    end

    it "should silently fail if the config is nil" do
      expect(Omniboard::Column.conditions).to eq(nil)
      Omniboard::Column.clear_config :conditions
      expect(Omniboard::Column.conditions).to eq(nil)
    end

    it "should raise an error if you try to clear a nonexistant config" do
      expect{Omniboard::Column.clear_config :does_not_exist}.to raise_error(ArgumentError)
    end
  end

  describe ".conditions" do
    it "should create a conditions block that runs on all columns" do
      Omniboard::Column.conditions{ |p| p.name % 3 == 0 } # Only multiples of three
      c = Omniboard::Column.new("Sample column"){ conditions{ |p| p.name % 2 == 0 } } # Only even numbers
      c.add make_projects(1,2,3,4,5,6)
      expect(c.projects.first.name).to eq(6)
      
      Omniboard::Column.clear_config :conditions
    end
  end

  describe ".group_by" do
    it "should provide a default grouping for when no other grouping method is supplied" do
      Omniboard::Column.group_by{ |p| "Foo: " + p[:foo].to_s }
      c = Omniboard::Column.new("Sample column") # No grouping condition!
      projects = [{foo: 1}, {foo: 2}, {foo: 1}]
      c.add(projects)

      expect(c.grouped_projects[Omniboard::Group["Foo: 1"]].size).to eq(2)
      expect(c.grouped_projects[Omniboard::Group["Foo: 2"]].size).to eq(1)

      Omniboard::Column.clear_config :group_by
    end
  end

  describe ".heading_font" do
    it "should default to Helvetica, Arial, sans-serif" do
      expect(Omniboard::Column.heading_font).to eq("Helvetica, Arial, sans-serif")

      Omniboard::Column.heading_font "Open Sans"
      expect(Omniboard::Column.heading_font).to eq("Open Sans")
    end
  end
end