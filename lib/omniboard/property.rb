module Omniboard::Property
	module PropertyClassMethods
		def property p, allowed_values: nil, munge: nil
			define_method(p) do |*args|
				ivar = "@#{p}"
				if args.empty?
					instance_variable_get(ivar)
				elsif args.size == 1
					# Set values!
					new_value = args.first
					if allowed_values && !new_value.nil? && !allowed_values.include?(new_value)
						raise(ArgumentError, "attempted to set property #{p} to forbidden value #{new_value.inspect}")
					else
						if new_value # Only run munge for non-nil values
							case munge
							when Symbol
								new_value = new_value.send(munge)
							when Proc
								new_value = munge[new_value]
							when nil
							else
								raise ArgumentError, "Property munge must be a symbol or a block - you supplied a #{munge.class}."
							end
						end
						instance_variable_set(ivar, new_value)
					end
				else
					raise ArgumentError, "wrong number of arguments (#{args.size} for 0,1)"
				end
			end
		end

		# Block properties can also take non-block arguments
		def block_property p
			define_method(p) do |*args, &blck|
				ivar = "@#{p}"
				if blck
					instance_variable_set(ivar, blck)
				elsif args.size == 1
					instance_variable_set(ivar, args.first)
				elsif args.empty?
					instance_variable_get(ivar)
				else
					raise ArgumentError, "wrong number of arguments (#{args.size} for 0,1)"
				end
			end
		end
	end
	
	def self.included mod
		mod.extend PropertyClassMethods
	end
end