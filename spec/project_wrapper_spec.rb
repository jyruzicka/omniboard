require_relative "spec_helper"

describe Omniboard::ProjectWrapper do
  describe "#initialize" do
    it "should accept a project in initialize" do
      expect(Omniboard::ProjectWrapper.new(3).project).to eq(3)
    end

    it "should be able to take a column argument" do
      expect(Omniboard::ProjectWrapper.new(3, column: 4).column).to eq(4)
      expect(Omniboard::ProjectWrapper.new(3).column).to eq(nil)
    end
  end

  describe "#method_missing" do
    it "should route straight to the project" do
      project = double("Project")
      expect(project).to receive(:foo)
      pw = Omniboard::ProjectWrapper.new(project)
      pw.foo
    end

    it "should still raise an error if the project can't do anything" do
      pw = Omniboard::ProjectWrapper.new(3)
      expect{ pw.foo}.to raise_exception(NoMethodError)
    end
  end

  describe "#task_list" do
    it "should deal with a pretty simple list of tasks" do
      tasks = [double(name: "Foo task", has_subtasks?: false, completed?: false, rank: 2), double(name: "Bar task", has_subtasks?: false, completed?: true, rank: 1)]
      project = double(tasks: tasks)
      pw = Omniboard::ProjectWrapper.new(project)
      expect(pw.task_list).to eq(%|<ul><li class="complete">Bar task</li><li class="incomplete">Foo task</li></ul>|)
    end

    it "should deal with a more complex list of tasks" do
      tasks = [double(name: "Foo task", has_subtasks?: false, completed?: false, rank: 1)]
      tasks << double(name: "Bar task", has_subtasks?: true, completed?: false, rank: 2, tasks: [double(name: "Bar subtask 1", has_subtasks?: false, rank: 1, completed?: true), double(name: "Bar subtask 2", has_subtasks?: false, rank: 2, completed?: true)])
      project = double(tasks: tasks)
      pw = Omniboard::ProjectWrapper.new(project)
      expect(pw.task_list).to eq(%|<ul><li class="incomplete">Foo task</li><li class="incomplete">Bar task<ul><li class="complete">Bar subtask 1</li><li class="complete">Bar subtask 2</li></ul></li></ul>|)
    end
  end

  describe "#colour" do
    let(:coloured_column){ double("column", colour: "column colour") }
    let(:uncoloured_column){ double("column", colour: nil) }

    let(:coloured_group){ double("group", colour: "group colour") }

    it "should return the column colour when @column has a colour" do
      expect(Omniboard::ProjectWrapper.new(nil, column:coloured_column).colour).to eq("column colour")
    end

    it "should return the group colour when @column is colourless, @group exists" do
      pw = Omniboard::ProjectWrapper.new(nil, column: uncoloured_column) 
      pw.group = coloured_group
      expect(pw.colour).to eq("group colour")
    end

    it "should return basic colour when @column is colourless and @group doesn't exist" do
      expect(Omniboard::ProjectWrapper.new(nil, column:uncoloured_column).colour).to eq(Omniboard::Group.colour)
    end
  end
end