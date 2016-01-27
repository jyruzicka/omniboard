class Omniboard::ProjectWrapper
	attr_accessor :project
	attr_accessor :column
	attr_accessor :group

	# Is this project marked to show up specially?
	attr_accessor :marked
	alias_method :marked?, :marked

	# Is this project dimmed (i.e. shown "faded out")
	attr_accessor :dimmed
	alias_method :dimmed?, :dimmed

	# Should this project display an icon in the kanban? If so, what's the filename of the icon?
	attr_accessor :icon

	# Create a new project wrapper, wrapping project
	def initialize(project, column: nil)
	  @project = project
	  @column = column
	  @marked = false
	end

	#---------------------------------------
	# Colour methods
	def colour
		(@group || Omniboard::Group).colour
	end

	def light_colour
		(@group || Omniboard::Group).light_colour
	end

	#---------------------------------------
	# Number of tasks
	def num_tasks
		@num_tasks ||= project.incomplete_tasks.count
	end

	#---------------------------------------
	# Runs on method missing. Allows project to step in and take
	# the method if it can.
	def method_missing(sym, *args, &blck)
		if @project.respond_to?(sym)
			@project.send(sym, *args, &blck)
		else
			raise NoMethodError, "undefined method #{sym} for #{self}"
		end
	end

	#---------------------------------------
	# Turn this project's tasks into a list
	def task_list
		tasks_to_list(@project.tasks)
	end

	# A list of CSS classes to apply to this project
	def css_classes
		classes = ["project", column.display]
		classes << "marked" if marked?
		classes << "dimmed" if dimmed?
		classes
	end

	# Are all the available tasks in this project deferred?
	def all_tasks_deferred?
		next_tasks.size > 0 && actionable_tasks.size == 0
	end

	# How many days until one of our tasks becomes available?
	def days_until_action
		earliest_start = next_tasks.map(&:start).sort.first
		if earliest_start.nil?
			0
		else
			earliest_start = earliest_start.to_date
			if earliest_start < Date.today
				0
			else
				(earliest_start - Date.today).to_i
			end
		end
	end

	def to_s
		self.project.to_s
	end

	private
	def tasks_to_list(arr)
		arr = arr.sort_by(&:rank)
		"<ul>" + arr.map { |task| %|<li class="#{task.completed? ? "complete" : "incomplete"}">#{task.name}| + (task.has_subtasks? ? tasks_to_list(task.tasks) : "") + "</li>" }.join("") + "</ul>"
	end
end