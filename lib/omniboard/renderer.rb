class Omniboard::Renderer
	attr_accessor :columns

	def initialize()
	  @columns = []
	  @current_column = nil
	  @current_group = nil
	end

	def add_column(col)
		@columns << col
	end

	def to_s
		preamble + @columns.map{ |c| render_column(c) }.join("\n") + postamble
	end

	def preamble
		ERB.new(template "preamble").result(binding)
	end

	def postamble
		ERB.new(template "postamble").result(binding)
	end

	def render_column(column)
		ERB.new(template("column")).result(binding)
	end

	def render_project(project)
		ERB.new(template("project")).result(binding)
	end

	# Fetch a template from the templates folder
	def template(template_name)
		@templates ||= {}

		if !@templates.has_key?(template_name)
			template_file = template_name + ".erb"
			template_path = File.join(__dir__, "templates", template_file)
			raise(ArgumentError, "Attempting to find template #{template_file}, which does not exist.") unless File.exists?(template_path)

			@templates[template_name] = File.read(template_path)
		end
		@templates[template_name]
	end
end