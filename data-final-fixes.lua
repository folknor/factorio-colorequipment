do
	local cats = {}
	for cat in pairs(_G.data.raw["equipment-category"]) do
		table.insert(cats, cat)
	end
	for _, eq in pairs(_G.data.raw["solar-panel-equipment"]) do
		if eq.folk_color then
			eq.categories = cats
			eq.folk_color = nil
		end
	end
end
