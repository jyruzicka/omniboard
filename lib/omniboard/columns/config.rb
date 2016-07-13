# Place global config variables here. See the README for config variables
Omniboard::Column.config do
	# Group projects by their containing folders
	group_by{ |p| p.container }
		# p.ancestry == [] ? "Top level" : p.ancestry.map(&:name).reverse.join("→")

	# Sort by rank, with top level projects at the top
	sort_groups{ |c| c.nil? ? 0 : c.rank }

	# Name based on ancestry
	group_name{ |c| c.ancestry == [] ? "Top level" : c.ancestry.map(&:name).reverse.join("&rarr;")}
end