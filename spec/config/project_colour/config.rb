Omniboard::Column.config do
  colour_group(0){ |g| g.name == "Highlighted" }
  colour_group(120){ |g| g.name == "Cool off" }
end

Omniboard::Column.new("Default") do
  group_by{ |p| p.note }
end