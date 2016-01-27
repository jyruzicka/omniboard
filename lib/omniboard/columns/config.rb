# Place global config variables here. See the README for config variables
Omniboard::Column.config do
	# Group projects by their containing folders
	group_by do |p|
		p.ancestry == [] ? "Top level" : p.ancestry.map(&:name).reverse.join("→")
	end

	# Sort alphabetically, with top level projects at the top
	sort_groups do |x,y|
		if x == "Top level"
			-1
		elsif y == "Top level"
			1
		else
			x <=> y
		end
	end
end