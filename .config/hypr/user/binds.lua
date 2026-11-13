local removed = {
	"SUPER + SHIFT + CTRL + left",
	"SUPER + SHIFT + CTRL + down",
	"SUPER + SHIFT + CTRL + up",
	"SUPER + SHIFT + CTRL + right",
	"SUPER + SHIFT + CTRL + H",
	"SUPER + SHIFT + CTRL + J",
	"SUPER + SHIFT + CTRL + K",
	"SUPER + SHIFT + CTRL + L",
	"SUPER + SHIFT + U",
	"SUPER + SHIFT + I",
	"SUPER + CTRL + U",
	"SUPER + CTRL + I",
	"SUPER + CTRL + down",
	"SUPER + CTRL + up",
	"SUPER + SHIFT + S",
	"SUPER + CTRL + S",
	"SUPER + minus",
	"SUPER + equal",
	"SUPER + SHIFT + minus",
	"SUPER + SHIFT + equal",
	"SUPER + R",
	"SUPER + bracketleft",
	"SUPER + bracketright",
	"SUPER + SHIFT + T",
	"SUPER + SHIFT + H",
	"SUPER + SHIFT + J",
	"SUPER + SHIFT + K",
	"SUPER + SHIFT + L",
}

for _, keys in ipairs(removed) do
	hl.unbind(keys)
end

hl.bind("SUPER + SHIFT + H", hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace" })
hl.bind("SUPER + SHIFT + L", hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace" })

local function center(window)
	local at, size = window.at, window.size
	return (at.x or at[1]) + (size.x or size[1]) / 2, (at.y or at[2]) + (size.y or size[2]) / 2
end

local direction_vectors = {
	l = { -1, 0 },
	r = { 1, 0 },
	u = { 0, -1 },
	d = { 0, 1 },
}

local function nearest_tiled(active, direction)
	local ax, ay = center(active)
	local vx, vy = table.unpack(direction_vectors[direction])
	local best, best_score
	local tiled = hl.get_windows({ workspace = active.workspace, floating = false, mapped = true })
	for _, candidate in ipairs(tiled) do
		local cx, cy = center(candidate)
		local dx, dy = cx - ax, cy - ay
		local along = dx * vx + dy * vy
		if along > 0 then
			local across = math.abs(dx * vy) + math.abs(dy * vx)
			local score = along + across * 2
			if not best_score or score < best_score then
				best, best_score = candidate, score
			end
		end
	end
	return best
end

local function focus_direction(direction)
	return function()
		local active = hl.get_active_window()
		if active and active.floating then
			local target = nearest_tiled(active, direction)
			if target then
				hl.dispatch(hl.dsp.focus({ window = "address:" .. target.address }))
			end
			return
		end
		hl.dispatch(hl.dsp.focus({ direction = direction }))
	end
end

hl.bind("CTRL + SHIFT + H", focus_direction("l"), { description = "Focus window left" })
hl.bind("CTRL + SHIFT + J", focus_direction("d"), { description = "Focus window down" })
hl.bind("CTRL + SHIFT + K", focus_direction("u"), { description = "Focus window up" })
hl.bind("CTRL + SHIFT + L", focus_direction("r"), { description = "Focus window right" })

local function horizontal_span(window)
	local x, width = window.at.x or window.at[1], window.size.x or window.size[1]
	return x, x + width
end

local function has_tiled_neighbor(active, direction)
	local _, ay = center(active)
	local left, right = horizontal_span(active)
	local tiled = hl.get_windows({ workspace = active.workspace, floating = false, mapped = true })
	for _, candidate in ipairs(tiled) do
		if candidate.address ~= active.address then
			local cleft, cright = horizontal_span(candidate)
			local _, cy = center(candidate)
			local overlaps = cleft < right and cright > left
			local beyond = (direction == "d" and cy > ay) or (direction == "u" and cy < ay)
			if overlaps and beyond then
				return true
			end
		end
	end
	return false
end

local function move_vertical(direction)
	return function()
		local active = hl.get_active_window()
		if not active or active.floating or has_tiled_neighbor(active, direction) then
			hl.dispatch(hl.dsp.window.move({ direction = direction }))
			return
		end

		local partner_side = nearest_tiled(active, "r") and "r" or "l"
		if partner_side == "l" and not nearest_tiled(active, "l") then
			return
		end

		hl.dispatch(hl.dsp.window.move({ direction = partner_side }))
		hl.dispatch(hl.dsp.layout("togglesplit"))

		local lands_on_top = partner_side == "l"
		if lands_on_top ~= (direction == "u") then
			hl.dispatch(hl.dsp.layout("swapsplit"))
		end
	end
end

hl.bind("CTRL + ALT + H", hl.dsp.window.move({ direction = "l" }), { description = "Move window left" })
hl.bind("CTRL + ALT + J", move_vertical("d"), { description = "Move window down" })
hl.bind("CTRL + ALT + K", move_vertical("u"), { description = "Move window up" })
hl.bind("CTRL + ALT + L", hl.dsp.window.move({ direction = "r" }), { description = "Move window right" })

hl.bind("CTRL + TAB", hl.dsp.window.cycle_next({ next = true, floating = true }), { description = "Cycle floating windows" })

local resize = { repeating = true }
hl.bind("ALT + SHIFT + H", hl.dsp.window.resize({ x = -100, y = 0, relative = true }), resize)
hl.bind("ALT + SHIFT + L", hl.dsp.window.resize({ x = 100, y = 0, relative = true }), resize)
hl.bind("ALT + SHIFT + K", hl.dsp.window.resize({ x = 0, y = -100, relative = true }), resize)
hl.bind("ALT + SHIFT + J", hl.dsp.window.resize({ x = 0, y = 100, relative = true }), resize)

hl.bind("CTRL + SHIFT + S", hl.dsp.exec_cmd("dms screenshot"), { description = "Screenshot" })

local function toggle_scratchpad_window()
	local active = hl.get_active_window()
	if not active then
		return
	end
	if active.workspace and active.workspace.special then
		hl.dispatch(hl.dsp.window.move({ workspace = "+0" }))
	else
		hl.dispatch(hl.dsp.window.move({ workspace = "special", follow = false }))
	end
end

hl.bind("SUPER + SHIFT + S", toggle_scratchpad_window, { description = "Move window to or from scratchpad" })
