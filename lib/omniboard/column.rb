# The column. Each column represents either:
# * A grouped column, if Column#group_by or Column.group_by are set
# * An ungrouped column, if they aren't 
class Omniboard::Column
	include Omniboard::Property

	# Column name, used to display
	attr_accessor :name
	def to_s; @name; end

	# All projects contained by the column
	attr_accessor :projects

	# Blocks governing which projects are let in and how they are displayed
	block_property :conditions
	block_property :sort
	block_property :mark_when
	block_property :dim_when
	block_property :icon

	# Blocks governing how to group and how groups are displayed
	block_property :group_by
	block_property :sort_groups
	block_property :group_name

	INHERITED_PROPERTIES = %i(sort mark_when dim_when icon group_by sort_groups group_name hide_dimmed display_project_counts)
	ALLOWED_PROJECT_COUNTS = %i(all active marked inherit)
	ALLOWED_PROJECT_DISPLAYS = %i(full compact)

	# Order in the kanban board. Lower numbers are further left. Default 0
	property :order

	# Relative width of the column. Defaults to 1.
	property :width

	# Display - compact or full? Full includes task info.
	property :display, allowed_values: ALLOWED_PROJECT_DISPLAYS

	# Display a heading with the total number of projects in this column?
	# Allowed values: "all", "active", "marked", nil
	property :display_project_counts, allowed_values: ALLOWED_PROJECT_COUNTS

	# Display total projects in red if this project limit is breached
	property :project_limit

	# Do we show a button allowing us to filter our dimmed projects?
	property :filter_button

	# Do we automatically hide dimmed projects?
	property :hide_dimmed

	# How many projects to show per line? Defaults to 1.
	property :columns

	# Column-wide colour setting. Overrides group colours
	property :colour

	# Intializer. Provide name and block for instance evaluation (optional)
	def initialize(name, &blck)
		# Set defaults
		self.name = name
		self.projects = []
		self.order(0)
		self.width(1)
		self.columns(1)
		self.display(:full)
		self.display_project_counts(nil)
		self.project_limit(nil)
		self.filter_button(false)

		INHERITED_PROPERTIES.each{ |s| self.send(s, :inherit) }

		instance_exec(&blck) if blck
		Omniboard::Column.add(self)
	end

	# Fetch the appropriate property value. If the value is :inherit, will fetch the appropriate value from Omniboard::Column
	def property(sym)
		raise(ArgumentError, "Unrecognised property #{sym}: allowed values are #{INHERITED_PROPERTIES.join(", ")}.") unless INHERITED_PROPERTIES.include?(sym)
		v = self.send(sym)
		v = Omniboard::Column.send(sym) if v == :inherit
		v
	end

	# Add an array of projects to the column. If +conditions+ is set, each project will be run through it.
	# Only projects that return +true+ will be allowed in.
	def add(arr)
		# Reset cache
		@grouped_projects = nil

		# Make sure it's an array
		arr = [arr] unless arr.is_a?(Array) || arr.is_a?(Rubyfocus::SearchableArray)

		# Run through individual conditions block
		arr = arr.select{ |p| self.conditions[p] } if self.conditions

		# Run through global conditions block
		arr = arr.select{ |p| self.class.conditions[p] } if self.class.conditions

		# Wrap in ProjectWrappers
		arr = arr.map{ |p| p.is_a?(Omniboard::ProjectWrapper) ? p : Omniboard::ProjectWrapper.new(p, column: self) }

		# Tasks performed upon adding project to column. Add to group, mark & dim appropriately
		arr.each do |pw|
			pw.column = self

			pw.group = self.group_for(pw)
			pw.marked = self.should_mark(pw)
			pw.dimmed = self.should_dim(pw)

			# Icon methods
			icon_attrs = self.icon_for(pw)
			if icon_attrs.is_a?(Array)
				pw.icon, pw.icon_alt = *icon_attrs
			else
				pw.icon = icon_attrs
			end
		end

		@projects += arr
	end
	alias_method :<<, :add


	# Return an array of projects, sorted according to the sort block (or not, if no sort block supplied).
	# If group string is provided, only fetched projects for that group
	def projects(group=nil)
		p = if group
			group = Omniboard::Group[group] unless group.is_a?(Omniboard::Group)
			grouped_projects[group]
		else
			@projects
		end

		sort_block = property(:sort)
		
		if sort_block.nil?
			p.sort_by(&:to_s)
		elsif sort_block.arity == 1
			p.sort_by(&self.sort)
		elsif sort_block.arity == 2
			p.sort(&self.sort)
		else
			raise ArgumentError, "Omniboard::Column.sort has an arity of #{sort.arity}, must take either 1 or 2 arguments."
		end
	end

	# Returns true if column or global group_by supplied
	def can_be_grouped?
		!!property(:group_by)
	end

	# Returns a sorted array of groups. Returned as strings
	def groups
		keys = grouped_projects.keys.map(&:identifier)

		group_sort_block = property(:sort_groups)
		if group_sort_block.nil?
			keys.sort
		elsif group_sort_block.arity == 1
			keys.sort_by(&group_sort_block)
		elsif group_sort_block.arity == 2
			keys.sort(&group_sort_block)
		else
			raise ArgumentError, "Omniboard::Column.group_sort has an arity of #{group_sort_block.arity}, must take either 1 or 2 arguments."
		end
	end

	# Return a hash of arrays of sorted projects, grouped using the group_by lambda.
	# Note: Unsorted
	def grouped_projects
		raise(RuntimeError, "Attempted to return grouped projects from column #{self.name}, but no group_by method defined.") unless can_be_grouped?
		@grouped_projects ||= self.projects.group_by(&:group)
	end

	# Return the group a project should fall into
	def group_for(project)
		gby = property(:group_by)
		if gby
			Omniboard::Group[gby[project]]
		else
			nil
		end
	end

	# Return the group name for a given group
	def group_name_for(group)
		gname = property(:group_name)
		gname ? gname[group] : group.to_s
	end

	# Return the marked status of a given project, based on mark_when blocks
	def should_mark(project)
		mark = property(:mark_when)
		if mark
			mark[project]
		else
			false
		end
	end

	# Return the dimmed status of a given project, based on mark_when blocks
	def should_dim(project)
		dim = property(:dim_when)
		if dim
			dim[project]
		else
			false
		end
	end	

	# Return the icon for a given project, based on icon blocks
	def icon_for(project)
		ic = property(:icon)
		if ic
			ic[project]
		else
			nil
		end
	end

	#---------------------------------------
	# Presentation methods
	def count_div
		total = case property(:display_project_counts)
		when :all
			self.projects.count
		when :active
			self.projects.select{ |p| !p.dimmed? }.count
		when :marked
			self.projects.select{ |p| p.marked? }.count
		else
			0
		end
		css_class = "column-total"
		css_class << " limit-breached" if project_limit && project_limit < total
		%|<div class="#{css_class}">#{total}</div>|
	end


	#---------------------------------------
	# Class-level methods

	# Columns
	@columns = []

	# Any group colour assignments
	@colour_groups = []

	# Default values for global config
	@hide_dimmed = false

	class << self
		include Omniboard::Property

		attr_reader :columns

		# Add a column to the global columns register
		def add(c)
			@columns << c
			@columns = @columns.sort_by(&:order)
		end

		# Wipe the global register of columns. Useful when resetting Omniboard to
		# a default state
		def reset_columns
			@columns = []
		end

		# Configuration

		#---------------------------------------
		# Font config values
		property :heading_font
		property :body_font

		# If set, will provide a link in the heading allowing you to refresh the page
		property :refresh_link

		# Fallback default for displaying project counts
		# Allowed values: "all", "active", "marked", nil
		property :display_project_counts, allowed_values: ALLOWED_PROJECT_COUNTS

		# Global conditions, apply to all columns
		block_property :conditions

		# Fallback sort method
		block_property :sort

		# Fallback mark method, apply only if individual mark method is blank
		block_property :mark_when

		# Fallback mark method, apply only if individual dim method is blank
		block_property :dim_when

		# Fallback property for hiding dimmed project
		property :hide_dimmed

		# Fallback group method, apply only if individual column group is blank
		block_property :group_by

		# Fallback group name method, apply only if individual column group name is blank
		block_property :group_name

		# Fallback group sort method
		block_property :sort_groups

		# Fallback icon method
		block_property :icon

		# Assign a colour to a group, given it fits a block
		def colour_group(hue, &blck)
			@colour_groups << {hue: hue, block: blck}
		end

		# Returns the appropriate hue for a given group, if it matches any of the colour groups provided by @colour_groups
		def colour_for_group(group)
			colour_group = @colour_groups.find{ |cgp| cgp[:block][group] }
			return colour_group && colour_group[:hue]
		end

		# Config method
		def config &blck
			self.instance_exec(&blck)
		end

		# Clear configuration option. You can always pass :all to clear all configuration options
		def clear_config config
			case config
			when :conditions
				@conditions = nil
			when :sort
				@sort = nil
			when :group_by
				@group_by = nil
			when :mark_when
				@mark_when = nil
			when :dim_when
				@dim_when = nil
			when :icon
				@icon = nil
			when :sort_groups
				@sort_groups = nil
			when :group_name
				@group_name = nil
			when :hide_dimmed
				@hide_dimmed = false
			when :display_project_counts
				@display_project_counts = nil
			when :all
				@conditions = nil
				@sort = nil
				@group_by = nil
				@mark_when = nil
				@dim_when = nil
				@icon = nil
				@sort_groups = nil
				@group_name = nil
				@hide_dimmed = false
				@display_project_counts = nil
			else
				raise ArgumentError, "Do not know how to clear config: #{config}"
			end
		end	
	end

	#---------------------------------------
	# Default values
	heading_font "Helvetica, Arial, sans-serif"
	body_font "Helvetica, Arial, sans-serif"
end