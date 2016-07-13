# This class represents a "group" of Projects.
class Omniboard::Group
	include Comparable

	# The identifier for this group. Can be a string, object, whatever you like.
	attr_accessor :identifier

	# Deprecated methods
	def name
		$stderr.puts "Group#name is deprecated. Use Group#identifier instead."
		@identifier
	end

	def name= n
		$stderr.puts "Group#name= is deprecated. Use Group#identifier= instead."
		@identifier = n
	end

	# The colour representation of a group
	attr_accessor :colour

	# Array of all groups in the board
	@groups = []
	
	class << self
		# Global values for group colour brightness and saturation
		attr_accessor :brightness, :saturation

		# All groups in the board
		attr_accessor :groups

		# Find a group by identifier
		def [] identifier
			@groups.find{ |g| g.identifier == identifier } || new(identifier)
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

	def initialize(identifier)
	  @identifier = identifier
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

	def assigned_colour
		Omniboard::Column::colour_for_group(self.identifier)
	end

	def has_assigned_colour?
		assigned_colour != nil
	end

	def to_s
		@identifier
	end

	def <=> o
		self.identifier <=> o.identifier
	end

	private
	def colour_obj
		@colour_obj ||= begin
			my_hue = if has_assigned_colour?
				assigned_colour
			else
				unassigned_groups = Omniboard::Group.groups.select{ |g| !g.has_assigned_colour? }
				360.0 / unassigned_groups.size * unassigned_groups.index(self)
			end
			Omniboard::Colour.new(my_hue)
		end
	end	
end
