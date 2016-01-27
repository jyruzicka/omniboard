class Omniboard::Colour
	attr_accessor :hue

	def initialize(hue)
	  @hue = hue
	end

	def standard
		"hsl(#{hue},100%,80%)"
	end

	def light
		"hsl(#{hue},50%,90%)"
	end
end