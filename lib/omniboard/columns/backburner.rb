Omniboard::Column.new "Backburner" do
	order 0
	conditions{ |p| p.on_hold? || p.deferred? }
	display :compact
end
