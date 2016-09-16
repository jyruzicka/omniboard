# Place global config variables here. See the README for config variables
Omniboard::Column.config do
	# Group projects by their containing folders
	group_by{ |p| p.container || "" }

	# This somewhat-complex code sorts projects by their order within OmniFocus
  # Want to help? Find a more elegant way to write this :P
  sort_groups do |a,b|
    if a == ""
      -1
    elsif b == ""
      1
    else
      # Compare from outside in
      a_ancestry = [a] + a.ancestry
      b_ancestry = [b] + b.ancestry
      
      a_cursor = a_ancestry.size - 1
      b_cursor = b_ancestry.size - 1

      sort_value = 0
      until a_cursor < 0 || b_cursor < 0 || sort_value != 0
        sort_value = (a_ancestry[a_cursor].rank <=> b_ancestry[b_cursor].rank)
        if sort_value == 0
          a_cursor -= 1
          b_cursor -= 1
        end
      end

      if sort_value != 0
        sort_value
      else
        a_ancestry.size <=> b_ancestry.size
       end
    end
  end

	# Name based on ancestry
	group_name{ |c| (c == "") ? "Top level" : ([c] + c.ancestry.map(&:name)).reverse.join("→") }
end