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

	# Order in the kanban board. Lower numbers are further left. Default 0
	property :order

	# Relative width of the column. Defaults to 1.
	property :width

	# Display - compact or full? Full includes task info.
	property :display

	# Do we show a button allowing us to filter our dimmed projects?
	property :filter_button

	# How many projects to show per line? Defaults to 1.
	property :columns

	# Intializer. Provide name and block for instance evaluation (optional)
	def initialize(name, &blck)
		self.name = name
		self.projects = []
		self.order(0)
		self.width(1)
		self.columns(1)
		self.display(:full)
		self.filter_button(false)
		
		instance_exec(&blck) if blck
		Omniboard::Column.add(self)
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
		arr = arr.map{ |p| Omniboard::ProjectWrapper.new(p, column: self) }

		# Tasks performed upon adding project to column. Add to group, mark & dim appropriately
		arr.each do |pw|
			pw.group = self.group_for(pw)

			pw.marked = self.should_mark(pw)
			pw.dimmed = self.should_dim(pw)
			pw.icon = self.icon_for(pw)
		end

		@projects += arr
	end


	# Return an array of projects, sorted according to the sort block (or not, if no sort block supplied).
	# If group string is provided, only fetched projects for that group
	def projects(group=nil)
		p = if group
			group = Omniboard::Group[group] if group.is_a?(String)
			grouped_projects[group]
		else
			@projects
		end

		sort_block = self.sort || Omniboard::Column.sort
		
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
		!!(self.group_by || self.class.group_by)
	end

	# Returns a sorted array of groups. Returned as strings
	def groups
		keys = grouped_projects.keys.map(&:name)

		group_sort_block = self.sort_groups || Omniboard::Column.sort_groups
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
		gby = self.group_by || self.class.group_by
		if gby
			Omniboard::Group[gby[project]]
		else
			nil
		end
	end

	# Return the marked status of a given project, based on mark_when blocks
	def should_mark(project)
		mark = self.mark_when || self.class.mark_when
		if mark
			mark[project]
		else
			false
		end
	end

	# Return the dimmed status of a given project, based on mark_when blocks
	def should_dim(project)
		dim = self.dim_when || self.class.dim_when
		if dim
			dim[project]
		else
			false
		end
	end	

	# Return the icon for a given project, based on icon blocks
	def icon_for(project)
		ic = self.icon || self.class.icon
		if ic
			ic[project]
		else
			nil
		end
	end

	#---------------------------------------
	# Class-level methods

	# Columns
	@columns = []

	class << self
		include Omniboard::Property

		attr_reader :columns

		def add(c)
			@columns << c
			@columns = @columns.sort_by(&:order)
		end

		# Configuration

		#---------------------------------------
		# Font config values
		property :heading_font
		property :body_font

		# Global conditions, apply to all columns
		block_property :conditions

		# Fallback sort method
		block_property :sort

		# Fallback mark method, apply only if individual mark method is blank
		block_property :mark_when

		# Fallback mark method, apply only if individual dim method is blank
		block_property :dim_when

		# Fallback group method, apply only if individual column group is blank
		block_property :group_by

		# Fallback group sort method
		block_property :sort_groups

		# Fallback icon method
		block_property :icon

		# Condfig method
		def config &blck
			self.instance_exec(&blck)
		end

		# Clear configuration option
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