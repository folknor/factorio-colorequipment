require("mod-gui")
local modGui = _G.mod_gui

local getColorItems
do
	local items
	getColorItems = function()
		if not items then
			items = {}
			for name, item in pairs(game.item_prototypes) do
				if type(item.order) == "string" then
					local color = item.order:match("z%[colors%]%-color%[#(" .. name .. ")%]")
					if type(color) == "string" and color == name then
						table.insert(items, name)
					end
				end
			end
			table.sort(items)
		end
		return items
	end
end

do
	local parse = require("parse")
	local function built(event)
		if not event or not event.created_entity then return end
		local e = event.created_entity
		if type(e.grid) ~= "nil" then
			for _, eq in next, e.grid.equipment do
				local o = eq.prototype.order:match("^color_(%w+)$")
				if type(o) == "string" then
					local c = parse.stringToFactorio(o)
					if c then
						e.color = c
						return
					end
				end
			end
		end
	end
	script.on_event(defines.events.on_built_entity, built)

	-- I'm not sure how robust this is, because there's no way to tell
	-- from the actual event which entity got the item in it.
	-- We just check what the player has .opened, and apply it to that.
	local function putEquipment(event)
		local eq = event.equipment
		local p = game.players[event.player_index]
		if not eq then return end

		local applyon
		if p.opened and p.opened.grid then applyon = p.opened
		else applyon = p end
		if not applyon then return end

		local o = eq.prototype.order:match("^color_(%w+)$")
		if type(o) == "string" then
			local c = parse.stringToFactorio(o)
			if c then
				applyon.color = c
				return
			end
		end
	end
	script.on_event(defines.events.on_player_placed_equipment, putEquipment)
end

do
	local colorButtons = setmetatable({}, {
		__index = function(self, k)
			local v = {
				type = "sprite-button",
				sprite = "item/" .. k,
				style = modGui.button_style,
				tooltip = {"color-equipment.button-color", k},
				name = k,
			}
			rawset(self, k, v)
			return v
		end
	})

	-- Create the button for every player
	local function initGui(player)
		local buttons = modGui.get_button_flow(player)
		if not buttons.color_equipment then
			buttons.add({
				type = "sprite-button",
				name = "color_equipment",
				sprite = "item/folk-color-equipment",
				style = modGui.button_style,
				tooltip = {"color-equipment.main-button"}
			})
		end

		local frames = modGui.get_frame_flow(player)
		local frame = frames.color_equipment_frame
		if not frame then
			frame = frames.add({
				type = "frame",
				name = "color_equipment_frame",
				direction = "vertical",
				style = modGui.frame_style
			})
		end
		if not frame.grid then
			frame.add({
				type = "flow",
				name = "grid",
				direction = "horizontal"
			})
			--grid.style.max_on_row = 4
			--grid.style.resize_row_to_width = true
			--grid.style.resize_to_row_height = true
		end

		-- Remove all children of frame.grid
		frame.grid.clear()
		local items = getColorItems()
		for _, name in next, items do
			frame.grid.add(colorButtons[name])
		end

		frame.style.visible = false
	end
	script.on_init(function()
		for _, p in pairs(game.players) do
			initGui(p)
		end
	end)
	script.on_event(defines.events.on_player_created, function(event)
		initGui(game.players[event.player_index])
	end)
end

do
	local handle = {}
	handle["color_equipment"] = function(p)
		local frame = modGui.get_frame_flow(p).color_equipment_frame
		if not frame then return end
		frame.style.visible = not frame.style.visible
	end

	local function colorClick(event)
		local p = game.players[event.player_index]
		local item = {name=event.element.name, count=1}
		local inv = p.get_inventory(defines.inventory.player_main)
		if not inv or not inv.can_insert(item) then return end
		inv.insert(item)
	end

	script.on_event(defines.events.on_gui_click, function(event)
		if not event or not event.element then return end
		if handle[event.element.name] then
			handle[event.element.name](game.players[event.player_index])
		elseif event.element.parent and event.element.parent.parent and event.element.parent.parent.name == "color_equipment_frame" then
			colorClick(event)
		end
	end)
end

