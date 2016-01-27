Omniboard::Column.new "Active" do
	order 1
	conditions{ |p| p.active? }

	width 2
	columns 4

	display :full

	icon do |p|
		if p.incomplete_tasks.size == 0
			"svg:hanging"
		elsif p.actionable_tasks.all?{ |t| t.context && t.context.name == "Waiting for..." }
			"svg:waiting-on"
		end
	end
end
