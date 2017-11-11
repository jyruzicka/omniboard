[![Build Status](https://travis-ci.org/jyruzicka/omniboard.svg?branch=master)](https://travis-ci.org/jyruzicka/omniboard)

Omniboard is a static kanban webpage generator for OmniFocus. Use it to view your currently active projects as a kanban board, with custom sorting and grouping options.

# You will need

* Ruby 2.0 or later: type `ruby -v` at the terminal to see if you have it.
* It helps to know a little ruby if you want to customise your columns.
* Omniboard uses the `rubyfocus` gem, which requires Apple Developer Tools to install.

# Installing

Omniboard comes as a gem, although it's not currently hosted on rubygems or the like.

```
git clone https://github.com/jyruzicka/omniboard.git
cd omniboard
gem build omniboard.gemspec
gem install omniboard-1.2.1.gem
```

Alternatively, add it to your `Gemfile`:

```
gem "omniboard", git: "https://github.com/jyruzicka/omniboard.git"
```

# Running

Once installed, use the built-in binary:

```
omniboard
```

or try the following to see the kanban in your webbrowser:

```
omniboard -o kanban.html
open kanban.html 
```

To see the possible flags, run:

```
omniboard --help
```

## Flags

* **--configure**: By default, omniboard stores its configuration information in `~/.omniboard`. You can change this with the `configure` option, specifying a different folder.
* **--output**: `omniboard` normally outputs to STDOUT. Give a value here to direct its output to a file.
* **--reset**: If you pass this flag, `omniboard` will clear its cache and fetch a new copy of the OmniFocus database.

## Columns

Your omniboard is made up a number of *columns*, with each column made up of a number of different projects from OmniFocus.

The first time you run `omniboard`, you will generate a configuration folder at `~/.omniboard/`. You can find two types of files in your configuration folder: first, a database file (which stores the current cached state of OmniFocus), and second, a series of configuration and column files, all maintained within a folder named `columns`.

You can create a new column in your Kanban by creating a new file in the `columns` folder. Name it whatever you like, but make sure that it ends with `.rb`. Inside, you configure a column using the following syntax:

```ruby
Omniboard::Column.new "Column name" do
end
```

You should also find a file called `config.rb`. This is where you can place global configuration values.

### Customising columns

You can customise your columns in all manner of ways. These methods either govern how the column is displayed, or which projects will end up in there.

The following column properties are numeric or symbols. You can alter these inside the column block in the following manner:

```ruby
Omniboard::Column.new "Sample column" do
	order 1
	display :compact
end
```

* **order**: A number indicating where this column fits on the kanban board. The lower a column's order, the further to the left of the board it'll appear. This defaults to 0.
* **display**: A column whose display is `:compact` will only show a summary of each project contained within it. A column whose display is `:full` will show additional details for each project. By default, a column's display is `:full`.
* **width**: The relative width of this column as compared to other columns on the board. The column's default width is 0.
* **columns**: The number of sub-columns within this column. If `columns` is greater than 1, projects will be displayed side-by-side. By default, each column's width is 1.
* **filter_button**: Whether or not to show a small button which, when clicked, will hide all "dimmed" projects. By default, set to false.
* **hide_dimmed**: When set to true, dimmed projects will be automatically hidden on page load. By default, set to false.
* **display_project_counts**: Set this to `:all`, `:active`, or `:marked`. Will display the total number of projects in a column: the value you give it will determine if it counts all projects (`:all`), projects which are not dimmed (`:active`), or only marked projected (`:marked`).
* **project_limit**: If you're display project counts and you have more projects than this number, the project count will show up highlighted red. Useful if you're trying to keep down your total number of active projects!
* **colour**: If specified, all projects in this column will be coloured appropriately. Use it to keep your completed column greyed out, or your high-priority column bright red.

The following column properties take blocks of ruby code. You can alter these inside the column block in the following manner:

```ruby
Omniboard::Column.new "Active projects only" do

	conditions do |p|
		p.active?
	end
end
```

* **conditions**: This block is run on every project in OmniFocus, with the project being passed in as the first argument. If the block returns true, the project is included in this column. If it returns false, the project is not shown in this column.
* **sort**: This block determines the order in which projects appear within groups. `sort` may take one argument, in which case it acts much like ruby's [`sort_by`](http://ruby-doc.org/core-2.3.0/Enumerable.html#method-i-sort_by) method, or two arguments, in which case it acts like ruby's [`sort`](http://ruby-doc.org/core-2.3.0/Enumerable.html#method-i-sort) method. If no sort block is provided, the projects are sorted by name. The arguments passed to `sort` are the projects to be compared when sorting.
* **mark_when**: Marked projects are given a small red "bookmark" in the top-right-hand corner of their ticket. Marked projects are those which, when passed to the `marked_when` block, return true.
* **dim_when**: Dimmed projects are shown at partial opacity, and can be useful for providing information on less critical projects, or those that are currently deferred. Dimmed projects are those which, when passed to the `dim_when` block, return true.
* **icon**: This block is run on every project, and if it returns a non-`nil` value, omniboard will place a small icon in the bottom-right-hand corner of the project ticket with an image source set to the return value of the `icon` block. For example, if the `icon` block returns "waiting.png" for a project, omniboard will place a small icon in the bottom-right corner of the project ticket with the source equal to "waiting.png". Alternatively, you may use one of the two pre-defined SVG icons bundled into omniboard by setting the icon to either "svg:hanging" or "svg:waiting-on".

### Grouping projects

You may want to group your projects - for example, by parent folder, by flagged status, or by due date. Each column may group its projects in different ways, or you may assign one default grouping method to be used over the whole board.

Each group is associated with an *identifier* - this could be an object, a true/false value, a string, whatever you want. You can use the `group_by` method to set this identifier:

```ruby
Omniboard::Column.new "Due soon" do
	group_by{ |p| p.due.to_date - Date.today }
end
```

This will group each project by how many days in the future it's due. The identifier will be an integer.

You can sort groups as well, using the `sort_groups` method:

```ruby
Omniboard::Column.new "Due soon" do
	group_by{ |p| p.due.to_date - Date.today }
	sort_groups{ |i| i }
end
```

The `sort_groups` block takes arguments in the same way that `sort` does, although the arguments passed to the block are the identifiers of the relevant groups.

It's nice to have fancy names for your groups, and sometimes they'll be a little more involved than just the string representations of the group identifiers. You can set groups' names using the `group_name` block. Again, it gets passed the identifier for each group, and returns the string name of the group:

```ruby
Omniboard::Column.new "Due soon" do
	group_by{ |p| p.due.to_date - Date.today }
	sort_groups{ |i| i }

	group_name{ |i| "Due in " + (i == 1 ? "1 day" : "#{i} days") }
end
```

By default, each group is given an arbitrary colour. Sometimes you might want to override that. You can do this with the `colour_group` method. Note that you set this globally using the `Omniboard::Column.config` method (see next section for more on this):

```ruby
Omniboard::Column.config do
  group_by{ |p| p.container || "" }

	colour_group(50){ |identifier| identifier.respond_to?(:name) && identifier.name == "Home Projects" }
end
```

The `colour_group` method takes two arguments: first, a numerical value which represents the *hue* you want the group to be, and a block which takes the group identifier and returns `true` or `false`. In the above example, we're using the containing folder as the group identifier. If the containing folder's name is "Home Projects", we set the group's colour to `50`.

### Global configuration

You may apply global configuration properties by the following code:

```ruby
Omniboard::Column.config do
	# Config values here...
end
```

The majority of the column properties listed above can be applied inside of `Omniboard::Column.config` as well, giving a resulting **global value**. How omniboard uses this value depends on the property in question:

* A global `conditions` block will be run *in addition to* a column-specific `conditions` block on each project. The project must return `true` in **both cases** in order to be displayed in the given column. This way, a global `conditions` block effectively acts as a board-wide filter.
* A global `sort`, `group_by`, `sort_groups`, `group_name`, `mark_when`, `dim_when`, `hide_dimmed`, or `icon` block will be run *if no column-specific block is provided* on a given column. This way, a global block for any of these properties effectively acts as a "global default".

You can also set the following configuration options:

* `heading_font`: Tells omniboard to use a particular font for headings (`h1`, `h2`, etc.). This may be a CSS-style list of fonts. Defaults to "Helvetica, Arial, sans-serif".
* `body_font`: Tells omniboard to use a particular font for body text. Defaults to "Helvetica, Arial, sans-serif".
* `refresh_link`: If set, will put a refresh symbol in the title, which allows you to call a given URL. If you're running this in Sinatra + Pow, for example, you can call a path that will auto-refresh your database for you. Note that this usually requires a bit of complex setup - mess with this as you wish!

### Countering global configurations

You may find yourself in a situation where you want to have a default group block for every column except one, which you would prefer to leave ungrouped. In this case, you can specify "no value" (overriding the column default) by setting the property to nil:

```ruby
Omniboard::Column.new "Don't group me" do
	group_by nil
end
```

## Custom CSS

You can also change the look and feel of your kanban board by customising the CSS. All changes go into the file `custom.css`, stored in your Omniboard folder (by default, in `~/.omniboard`).

# Case studies

That's quite a lot to take in, so let's have a look at some of the ways I use this system.

## Leaving out folders
### Leaving out an entire single folder

I have a bunch of template projects for use in Chris Sauve's amazing [Templates.scpt](http://cmsauve.com/projects/templates/). There's no point in displaying these on my kanban board, so instead I'll block them using a global `conditions` block.

```ruby
Omniboard::Column.config do
	conditions do |p|
		!p.contained_within?(name: "Template")
	end
end
```

This block will return true only if the project is **not** contained within a folder that has the name "Template".

### Leaving out an entire folder including all subfolders

Sometimes you want to leave out an entire folder including all subfolders. For example, when your folder "Template" also has subfolders such as "Work Projects", "Private Things" or if you add additional subfolders or rename existing subfolders from time to time. The easiest way to block all subfolders as well:

```ruby
Omniboard::Column.config do
	conditions do |p|
		!p.ancestry.any?{ |c| c.name == "Template" }
	end
end
```

## Mark based on a note's contents

I use projects' note fields to highlight my important projects that I want to focus on right now. Using a global `mark_when` block, I can make sure that projects I've flagged in this way always show up marked.

```ruby
Omniboard::Column.config do
	mark_when do |p|
		p.note && p.note.include?("@flagged")
	end
end
```

## Group & sort based on folders

I like to see my projects grouped by their parent folders, but they're sometimes buried two or three folders deep. Since group names really need to be strings, I can format group names right inside the block.

```ruby
Omniboard::Column.config do
	group_by do |p|
		if p.ancestry == []
			"Top level"
		else
			p.ancestry.map(&:name).reverse.join("→")
		end
	end
end
```

Note that `Project#ancestry` is a method that returns an array of the project's containing folders, up to the Document level. If the project has no containing folder, we just give it the group "Top level". If we just wanted to group based on the top-most folder, we could do something like the following:

```ruby
Omniboard::Column.config do
	group_by do |p|
		if p.ancestry == []
			"Top level"
		else
			p.ancestry.last.name
		end
	end
end
```

If we want to sort these folders nicely, we could do something like the following:

```ruby
Omniboard::Column.config do
	sort_groups do |x,y|
			if x == "Top level"
				-1
			elsif y == "Top level"
				1
			else
				x <=> y
			end
		end
	end
end
```

This means that a group with the name "Top level" appears at the top of the column; after this groups are displayed in alphabetical order.

## Displaying a "backburner" column

I have a compacted column on the left of my Kanban board showing all the projects that are on hold or that have been deferred at the project level. The column's config looks like this:

```ruby
Omniboard::Column.new "Backburner" do

	conditions do |p|
		p.on_hold? || p.deferred?
	end

	order 0

	display :compact
end
```

## Displaying an "active projects" column

My main column is quite large, taking up twice as much space as regular columns. The projects are displayed as full tickets, with four projects per row:

```ruby
Omniboard::Column.new "In Progress" do
	order 1
	width 2
	columns 4
	display :full
```

Only projects which get through the global filter, and are marked "active" in OmniFocus, are shown:

```
	conditions do |p|
		p.active?
	end
```

## Dim a task when you can't do anything

I have a custom context "Waiting for..." which marks tasks I'm waiting to hear from others on. When all available tasks are "Waiting for..." tasks, I can't do anything, so I might as well dim the project.

```ruby
	dim_when do |p|
		p.next_tasks.all? { |t| t.context && t.context.name == "Waiting for..." }
	end
```

I'd also like to sort these tasks to the end of my projects in each group:

```ruby
	sort do |p|
		if p.next_tasks.all?{ |t| t.context && t.context.name == "Waiting for..." }
			1
		else
			0
		end
	end
```

## Show an icon for a given context

In fact, I could mark these "Waiting for..." projects with an icon, just so I know *why* they're dimmed.

```ruby
	icon do |p|
		if p.next_tasks.all?{ |t| t.context && t.context.name == "Waiting for..." }
			"waiting.png"
		end
	end
```

## Filter by date

What if you want to filter by defer, due, or completion date? For example:

* A "due soon" column containing only projects due within the next week.
* The "completed" column only shows projects you completed in the last two days.
* An "upcoming" column which shows projects which are currently deferred, but whose next action is deferred until tomorrow.

Before I start on this, I'd like to quickly talk about project vs. task due dates. OmniFocus treats each project as a sub-class of a task, with a couple of extra properties. This means that any property you can assign to a task, you can (in theory) assign to a project. This means that a project can be marked "deferred" for two reasons:

* The project itself is deferred, or
* Every available task in the project is deferred.

Similarly, it's a good idea to consider the due date on both tasks within a project, and the project itself.

For our first trick, let's consider a column containing projects whose due date is within the next week. Every task has a `due` property which returns a `Time` or `nil`:

```ruby
one_week_from_now = Time.now + (60 * 60 * 24 * 7)

Omniboard::Column.new "Due soon" do
	conditions do |p|
		p.active? && p.due && p.due <= one_week_from_now
	end
end
```

This checks the project's `due` property, and if it's not null (and is less than one week from now), includes it in the board. We also filter out on-hold, completed, or dropped projects.

The "completed" column is pretty similar:

```ruby
one_week_ago = Time.now - (60 * 60 * 24 * 7)

Omniboard::Column.new "Completed" do
	conditions do |p|
		p.completed? && p.completed >= one_week_ago
	end
end
```

Note that any completed task or project should always have a set completion time, so we don't need to check if the `completed` property is `nil`. You could, just to be double-sure.

Finally, let's look at our "upcoming" column. This is a bit trickier because we're delving into per-task dates, but it's still surprisingly easy to do. One thing I'm going to do here is say that the project's available tasks just need to be deferred to *any* time tomorrow, not within 24 hours of this exact moment.

```ruby
tomorrow = Date.today + 1

Omniboard::Column.new "Starting tomorrow" do
	conditions do |p|
		p.actionable_tasks.size == 0 && # No tasks we can do right now
			p.next_tasks.any?{ |t| t.start.to_date == tomorrow } # Incomplete, non-blocked task starting tomorrow
	end
end
```

# Feedback and further information

If you have any examples of particularly good examples of column configuration, or think I've missed something in the case studies or documentation, get in touch!
