module Omniboard::Property
	module PropertyClassMethods
		def property p
			define_method(p) do |*args|
				ivar = "@#{p}"
				if args.empty?
					instance_variable_get(ivar)
				elsif args.size == 1
					instance_variable_set(ivar, args.first)
				else
					raise ArgumentError, "wrong number of arguments (#{args.size} for 0,1)"
				end
			end
		end

		def block_property p
			define_method(p) do |&blck|
				ivar = "@#{p}"
				if blck
					instance_variable_set(ivar, blck)
				else
					instance_variable_get(ivar)
				end
			end
		end
	end
	
	def self.included mod
		mod.extend PropertyClassMethods
	end
end