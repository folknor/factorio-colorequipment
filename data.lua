
do
	local function trim(s)
		local from = s:match"^%s*()"
		return from > #s and "" or s:match(".*%S", from)
	end
	local p = require("parse")
	local defaults = "#1abc9c,#2ecc71,#3498db,#9b59b6,#34495e,#f1c40f,#e67e22,#e74c3c,#ecf0f1,#95a5a6"
	local data = _G.data
	local colors = trim(settings.startup["folk-colorequipment-colors"].value)
	if type(colors) ~= "string" or colors:len() == 0 then
		colors = defaults
	end
	local colorTables = p.readString(colors)
	if #colorTables == 0 then colorTables = p.readString(defaults) end

	for _, c in next, colorTables do
		local name = c.name
		local color = c.color
		color.a = 0.75
		if not data.raw["solar-panel-equipment"][name] then
			local it = {
				type = "item",
				name = name,
				localised_name = {"color-equipment.color-item", name},
				localised_description = {"color-equipment.color-description"},
				icons = {
					{
						icon = "__folk-colorequipment__/base.png",
					},
					{
						icon = "__folk-colorequipment__/color.png",
						tint = color,
					}
				},
				placed_as_equipment_result = name,
				flags = { "goes-to-main-inventory" },
				subgroup = "equipment",
				order = "z[colors]-color[#" .. name .. "]",
				stack_size = 100,
				enabled = false,
			}

			local eq = table.deepcopy(data.raw["solar-panel-equipment"]["solar-panel-equipment"])
			-- This doesn't travel over to the game scope, but allows us to determine which
			-- equipment items to modify in data-final-fixes
			eq.folk_color = true
			eq.name = name
			eq.localised_name = {"color-equipment.color-item", name}
			eq.localised_description = {"color-equipment.color-description"}
			eq.take_result = name
			eq.sprite.filename = "__folk-colorequipment__/palette.png"
			eq.shape.width = 1
			eq.shape.height = 1
			eq.order = "color_" .. name
			eq.power = "0W"

			data:extend({it, eq})
		end
	end
	-- for the icon sprite
	data:extend({{
		type = "item",
		name = "folk-color-equipment",
		icon = "__folk-colorequipment__/palette.png",
		flags = { "goes-to-main-inventory", "hidden" },
		subgroup = "equipment",
		order = "z",
		stack_size = 1,
		enabled = false,
	}})
end
