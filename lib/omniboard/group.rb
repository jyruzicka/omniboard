class Omniboard::Group
	include Comparable

	attr_accessor :name
	attr_accessor :colour

	@groups = []
	
	class << self
		attr_accessor :brightness, :saturation

		def [] str
			raise(ArgumentError, "Must search by string") if !str.is_a?(String)
			@groups.find{ |g| g.name == str } || new(str)
		end

		def index(g)
			@groups.index(g)
		end

		def size
			@groups.size
		end

		def add(g)
			@groups.each(&:reset_colour)
			@groups << g
		end

		def default_colour
			Omniboard::Colour.new(0).standard
		end
		alias_method :colour, :default_colour
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