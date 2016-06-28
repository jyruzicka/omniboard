# This class represents a "group" of Projects.
class Omniboard::Group
	include Comparable

	# The name of the group
	attr_accessor :name

	# The colour representation of a group
	attr_accessor :colour

	# Array of all groups in the board
	@groups = []
	
	class << self
		# Global values for group colour brightness and saturation
		attr_accessor :brightness, :saturation

		# Find a group by name
		def [] str
			raise(ArgumentError, "Group[] called with non-string (#{str.klass}) argument: you must search groups by string.") if
				!str.is_a?(String)
			
			@groups.find{ |g| g.name == str } || new(str)
		end

		# Returns the index of a group in the group array
		def index(g)
			@groups.index(g)
		end

		# How many groups do we have in our array?
		def size
			@groups.size
		end

		# Add a new group to the groups array. Also resets all colour assignments for the group.
		# Note: usually called from initializer.
		def add(g)
			@groups.each(&:reset_colour)
			@groups << g
		end

		# If we don't have any groups on our board, this is our default
		# colour for ungrouped projects
		def default_colour
			Omniboard::Colour.new(0).standard
		end
		alias_method :colour, :default_colour

		# If we don't have any groups on our board, this is our default
		# light colour for ungrouped projects
		def light_colour
			Omniboard::Colour.new(0).light
		end
	end

	def initialize(name)
		raise(ArgumentError, "nil name not allowed") if name.nil?
	  @name = name
	  Omniboard::Group.add(self)
	end

	def colour
		colour_obj.standard
	end

	def light_colour
		colour_obj.light
	end

	def reset_colour
		@colour_obj = nil
	end

	def to_s
		@name
	end

	def <=> o
		self.name <=> o.name
	end

	private
	def colour_obj
		@colour_obj ||= Omniboard::Colour.new(360.0/Omniboard::Group.size*Omniboard::Group.index(self))
	end	
end
