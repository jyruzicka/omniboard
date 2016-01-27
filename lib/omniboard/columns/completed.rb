Omniboard::Column.new "Completed" do
	order 2
	conditions{ |p| p.completed? }
	display :compact
end
