-- ==========================================================================
--  SimplUI (embedded)  -  Windows 7 Aero UI library, by you
--  Everything below the second banner is the MM2 Coin Farm.
-- ==========================================================================
local SimplUI = (function()
--[[
	Simpl UI  —  a Windows 7 "Aero" styled UI library for Roblox script hubs.
	Built for Simpl Hub.

	Load:
		local SimplUI = loadstring(game:HttpGet("<raw url to this file>"))()

	Quick start:
		local Window = SimplUI:CreateWindow({ Title = "Simpl Hub", SubTitle = "v1.0" })
		local Tab    = Window:CreateTab("Main")
		Tab:CreateButton({ Text = "Click me", Callback = function() end })

	Full API is documented at the bottom of this file.

	Aesthetic notes: the Win7 look is faked with vertical UIGradients (bright top,
	darker bottom) plus a thin translucent "shine" strip on the upper half of glossy
	surfaces, 6px rounded corners, and the classic light-blue hover glow on controls.
]]

--// Services
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")

--// Themes. Two palettes sharing the same role keys, so the UI can be repainted
--// live. DARK = smoky glass (see-through). LIGHT = classic clean Windows 7 Aero.
local Palettes = {}

Palettes.Dark = {
	Accent = Color3.fromRGB(78, 156, 224), AccentDark = Color3.fromRGB(46, 108, 164),
	WindowBg = Color3.fromRGB(26, 30, 37), ContentBg = Color3.fromRGB(28, 33, 41),
	ContentTint = Color3.fromRGB(28, 33, 41),
	Sidebar = Color3.fromRGB(22, 26, 33), SidebarLine = Color3.fromRGB(58, 66, 78),
	TitleTop = Color3.fromRGB(58, 74, 98), TitleBottom = Color3.fromRGB(34, 45, 62),
	WindowBorder = Color3.fromRGB(70, 86, 106),
	Text = Color3.fromRGB(228, 233, 240), SubText = Color3.fromRGB(150, 160, 174),
	TitleText = Color3.fromRGB(226, 236, 248),
	CtrlTop = Color3.fromRGB(66, 74, 88), CtrlBottom = Color3.fromRGB(44, 51, 63),
	CtrlBorder = Color3.fromRGB(92, 102, 118),
	CtrlHoverTop = Color3.fromRGB(74, 100, 132), CtrlHoverBottom = Color3.fromRGB(50, 72, 100),
	CtrlHoverBorder = Color3.fromRGB(90, 160, 224),
	CtrlPressTop = Color3.fromRGB(40, 58, 82), CtrlPressBottom = Color3.fromRGB(32, 46, 66),
	Field = Color3.fromRGB(20, 24, 30), FieldBorder = Color3.fromRGB(80, 90, 104),
	FieldFocus = Color3.fromRGB(90, 160, 224),
	Track = Color3.fromRGB(40, 46, 56), TrackBorder = Color3.fromRGB(66, 76, 90),
	AddrBg = Color3.fromRGB(34, 40, 50), AddrTop = Color3.fromRGB(44, 52, 64), AddrBottom = Color3.fromRGB(30, 36, 46),
	NotifTop = Color3.fromRGB(44, 52, 64), NotifBottom = Color3.fromRGB(28, 34, 44),
	GearHole = Color3.fromRGB(30, 35, 43),
	CloseTop = Color3.fromRGB(232, 122, 122), CloseBottom = Color3.fromRGB(197, 63, 63),
	CloseHoverTop = Color3.fromRGB(240, 105, 105), CloseHoverBottom = Color3.fromRGB(206, 45, 45),
	FrameT = 0.34, ContentT = 0.30,
	Font = Enum.Font.SourceSans, FontBold = Enum.Font.SourceSansBold,
}

Palettes.Light = {
	Accent = Color3.fromRGB(60, 127, 177), AccentDark = Color3.fromRGB(40, 96, 140),
	WindowBg = Color3.fromRGB(240, 240, 240), ContentBg = Color3.fromRGB(255, 255, 255),
	ContentTint = Color3.fromRGB(255, 255, 255),
	Sidebar = Color3.fromRGB(235, 241, 248), SidebarLine = Color3.fromRGB(213, 224, 237),
	TitleTop = Color3.fromRGB(233, 244, 253), TitleBottom = Color3.fromRGB(198, 224, 245),
	WindowBorder = Color3.fromRGB(120, 156, 196),
	Text = Color3.fromRGB(28, 28, 28), SubText = Color3.fromRGB(96, 104, 112),
	TitleText = Color3.fromRGB(30, 57, 91),
	CtrlTop = Color3.fromRGB(244, 244, 244), CtrlBottom = Color3.fromRGB(223, 223, 223),
	CtrlBorder = Color3.fromRGB(172, 172, 172),
	CtrlHoverTop = Color3.fromRGB(234, 246, 253), CtrlHoverBottom = Color3.fromRGB(206, 231, 248),
	CtrlHoverBorder = Color3.fromRGB(60, 127, 177),
	CtrlPressTop = Color3.fromRGB(197, 226, 246), CtrlPressBottom = Color3.fromRGB(180, 213, 240),
	Field = Color3.fromRGB(255, 255, 255), FieldBorder = Color3.fromRGB(171, 173, 179),
	FieldFocus = Color3.fromRGB(60, 127, 177),
	Track = Color3.fromRGB(231, 234, 234), TrackBorder = Color3.fromRGB(188, 188, 188),
	AddrBg = Color3.fromRGB(233, 239, 247), AddrTop = Color3.fromRGB(241, 246, 252), AddrBottom = Color3.fromRGB(221, 230, 242),
	NotifTop = Color3.fromRGB(248, 250, 253), NotifBottom = Color3.fromRGB(226, 234, 244),
	GearHole = Color3.fromRGB(245, 247, 250),
	CloseTop = Color3.fromRGB(232, 122, 122), CloseBottom = Color3.fromRGB(197, 63, 63),
	CloseHoverTop = Color3.fromRGB(240, 105, 105), CloseHoverBottom = Color3.fromRGB(206, 45, 45),
	FrameT = 0.42, ContentT = 0.30,   -- translucent Aero glass (see-through like Dark)
	Font = Enum.Font.SourceSans, FontBold = Enum.Font.SourceSansBold,
}

local activeTheme = "Dark"
-- Theme is a live proxy: Theme.X always returns the active palette's value, so
-- any element built after a switch is correct, and helpers read current colors.
local Theme = setmetatable({}, { __index = function(_, k) return Palettes[activeTheme][k] end })

--// GUI parent resolution (executor-safe)
local function getGuiParent()
	local ok, hui = pcall(function() return gethui and gethui() end)
	if ok and hui then return hui end
	local cg = game:GetService("CoreGui")
	return cg
end

--// Instance builder.
-- Supports a `Meta` sub-table used by the theme system:
--   Meta = { bg="WindowBg", txt="Text", glass="frame"|"content"|"sidebar", keepText=true }
-- These are written as attributes so Window:SetTheme can repaint the instance later.
local function New(class, props, children)
	local inst = Instance.new(class)
	local meta = props and props.Meta
	for k, v in pairs(props or {}) do
		if k ~= "Parent" and k ~= "Meta" then
			inst[k] = v
		end
	end
	if meta then
		for a, val in pairs(meta) do
			inst:SetAttribute("t_" .. a, val)
		end
	end
	for _, c in ipairs(children or {}) do
		c.Parent = inst
	end
	if props and props.Parent then
		inst.Parent = props.Parent
	end
	return inst
end

local function corner(radius, parent)
	return New("UICorner", { CornerRadius = UDim.new(0, radius or 6), Parent = parent })
end

-- stroke(color, thickness, transparency, parent[, role]) — role tags it for theming
local function stroke(color, thickness, transparency, parent, role)
	local s = New("UIStroke", {
		Color = color,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
	if role then s:SetAttribute("t_st", role) end
	return s
end

local function gradSeq(topColor, bottomColor)
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, topColor),
		ColorSequenceKeypoint.new(0.48, topColor),
		ColorSequenceKeypoint.new(0.52, bottomColor),
		ColorSequenceKeypoint.new(1.00, bottomColor),
	})
end

-- verticalGradient(top, bottom, parent[, roleTop, roleBot]) — roles tag it for theming
local function verticalGradient(topColor, bottomColor, parent, roleTop, roleBot)
	local g = New("UIGradient", {
		Rotation = 90,
		Color = gradSeq(topColor, bottomColor),
		Parent = parent,
	})
	if roleTop then g:SetAttribute("t_gt", roleTop); g:SetAttribute("t_gb", roleBot) end
	return g
end

-- Thin translucent shine over the top half — the Aero gloss
local function glossShine(parent, zindex)
	return New("Frame", {
		Name = "Gloss",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0.45, 0),
		Position = UDim2.new(0, 0, 0, 0),
		ZIndex = (zindex or 1) + 1,
		Parent = parent,
	}, {
		New("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.35),
				NumberSequenceKeypoint.new(1, 1),
			}),
		}),
		corner(5),
	})
end

local function tween(inst, time, props, style, dir)
	local ti = TweenInfo.new(time or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
	local t = TweenService:Create(inst, ti, props)
	t:Play()
	return t
end

-- Vector icon set — everything drawn with frames so it renders on any executor
-- (no font glyphs, no external image assets). Matches the flat Win7 nav-pane look.
local function drawIcon(parent, kind, px)
	px = px or 16
	local h = New("Frame", {
		Name = "Icon", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, px, 0, px),
		ZIndex = (parent.ZIndex or 1) + 1, Parent = parent,
	})
	local z = h.ZIndex
	kind = tostring(kind or "folder"):lower()

	if kind == "folder" or kind == "main" or kind == "home" then
		-- classic yellow manila folder: back flap + glossy body
		New("Frame", { BackgroundColor3 = Color3.fromRGB(238, 184, 66), BorderSizePixel = 0,
			Size = UDim2.new(0, 7, 0, 3), Position = UDim2.new(0, 1, 0, 3), ZIndex = z, Parent = h }, { corner(1) })
		local body = New("Frame", { BackgroundColor3 = Color3.fromRGB(255, 206, 84), BorderSizePixel = 0,
			Size = UDim2.new(0, 14, 0, 9), Position = UDim2.new(0, 1, 0, 5), ZIndex = z + 1, Parent = h },
			{ corner(2), stroke(Color3.fromRGB(201, 146, 28), 1, 0) })
		verticalGradient(Color3.fromRGB(255, 224, 150), Color3.fromRGB(246, 179, 40), body)
		glossShine(body, z + 1)

	elseif kind == "user" or kind == "player" or kind == "account" then
		-- head + shoulders silhouette in Aero blue
		local head = New("Frame", { BackgroundColor3 = Color3.fromRGB(96, 146, 196), BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.new(0, 7, 0, 7), Position = UDim2.new(0.5, 0, 0, 1),
			ZIndex = z + 1, Parent = h }, { corner(4), stroke(Color3.fromRGB(48, 92, 148), 1, 0) })
		verticalGradient(Color3.fromRGB(126, 172, 216), Color3.fromRGB(66, 114, 170), head)
		local body = New("Frame", { BackgroundColor3 = Color3.fromRGB(96, 146, 196), BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 1), Size = UDim2.new(0, 13, 0, 8), Position = UDim2.new(0.5, 0, 1, 3),
			ZIndex = z, Parent = h }, { corner(6), stroke(Color3.fromRGB(48, 92, 148), 1, 0) })
		verticalGradient(Color3.fromRGB(126, 172, 216), Color3.fromRGB(66, 114, 170), body)

	elseif kind == "gear" or kind == "settings" or kind == "config" then
		-- cog: two rounded squares crossed to make 8 teeth, hollow centre
		for _, rot in ipairs({ 0, 45 }) do
			local sq = New("Frame", { BackgroundColor3 = Color3.fromRGB(150, 154, 160), BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5), Rotation = rot, Size = UDim2.new(0, 13, 0, 13),
				Position = UDim2.new(0.5, 0, 0.5, 0), ZIndex = z, Parent = h }, { corner(3) })
			verticalGradient(Color3.fromRGB(180, 184, 190), Color3.fromRGB(118, 122, 130), sq)
		end
		New("Frame", { BackgroundColor3 = Color3.fromRGB(30, 35, 43), BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 5, 0, 5), Position = UDim2.new(0.5, 0, 0.5, 0),
			ZIndex = z + 2, Parent = h }, { corner(3) })

	elseif kind == "disk" or kind == "drive" then
		-- hard-drive / local disk box
		local box = New("Frame", { BackgroundColor3 = Color3.fromRGB(206, 212, 220), BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 14, 0, 10), Position = UDim2.new(0.5, 0, 0.5, 1),
			ZIndex = z, Parent = h }, { corner(2), stroke(Color3.fromRGB(120, 130, 142), 1, 0) })
		verticalGradient(Color3.fromRGB(232, 236, 242), Color3.fromRGB(188, 196, 206), box)
		New("Frame", { BackgroundColor3 = Color3.fromRGB(120, 200, 120), BorderSizePixel = 0,
			Size = UDim2.new(0, 2, 0, 2), Position = UDim2.new(1, -4, 1, -4), ZIndex = z + 1, Parent = box }, { corner(1) })

	elseif kind == "coins" or kind == "coin" or kind == "money" or kind == "farm" then
		-- stack of glossy gold coins (Vista/7 "currency" look)
		local layers = {
			{ y = 10, top = Color3.fromRGB(255, 220, 140), bot = Color3.fromRGB(226, 162, 36) },
			{ y = 6,  top = Color3.fromRGB(255, 228, 156), bot = Color3.fromRGB(234, 174, 48) },
			{ y = 2,  top = Color3.fromRGB(255, 236, 174), bot = Color3.fromRGB(242, 186, 62) },
		}
		for i, spec in ipairs(layers) do
			local coin = New("Frame", { BackgroundColor3 = spec.bot, BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.new(0, 13, 0, 5),
				Position = UDim2.new(0.5, 0, 0, spec.y), ZIndex = z + i, Parent = h },
				{ corner(3), stroke(Color3.fromRGB(178, 126, 22), 1, 0) })
			verticalGradient(spec.top, spec.bot, coin)
		end

	elseif kind == "chart" or kind == "stats" or kind == "graph" then
		-- little bar chart with a baseline
		local bars = { { x = 1, hh = 5 }, { x = 6, hh = 9 }, { x = 11, hh = 13 } }
		for i, b in ipairs(bars) do
			local bar = New("Frame", { BackgroundColor3 = Color3.fromRGB(96, 176, 96), BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0, 1), Size = UDim2.new(0, 3, 0, b.hh),
				Position = UDim2.new(0, b.x, 1, -1), ZIndex = z + 1, Parent = h },
				{ corner(1), stroke(Color3.fromRGB(52, 116, 52), 1, 0) })
			verticalGradient(Color3.fromRGB(150, 214, 150), Color3.fromRGB(72, 150, 72), bar)
		end
		New("Frame", { BackgroundColor3 = Color3.fromRGB(120, 130, 142), BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), ZIndex = z, Parent = h })

	elseif kind == "monitor" or kind == "network" or kind == "clients" or kind == "computer" then
		-- LCD monitor on a stand (Win7 "Computer"/network-pane feel)
		local screen = New("Frame", { BackgroundColor3 = Color3.fromRGB(210, 216, 224), BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.new(0, 15, 0, 11), Position = UDim2.new(0.5, 0, 0, 0),
			ZIndex = z, Parent = h }, { corner(2), stroke(Color3.fromRGB(110, 120, 132), 1, 0) })
		verticalGradient(Color3.fromRGB(228, 234, 242), Color3.fromRGB(184, 192, 204), screen)
		local disp = New("Frame", { BackgroundColor3 = Color3.fromRGB(86, 140, 196), BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 12, 0, 8), Position = UDim2.new(0.5, 0, 0.5, 0),
			ZIndex = z + 1, Parent = screen }, { corner(1) })
		verticalGradient(Color3.fromRGB(126, 180, 226), Color3.fromRGB(58, 108, 168), disp)
		glossShine(disp, z + 1)
		-- stand + base
		New("Frame", { BackgroundColor3 = Color3.fromRGB(150, 160, 172), BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.new(0, 3, 0, 2), Position = UDim2.new(0.5, 0, 0, 11),
			ZIndex = z, Parent = h })
		New("Frame", { BackgroundColor3 = Color3.fromRGB(150, 160, 172), BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.new(0, 9, 0, 2), Position = UDim2.new(0.5, 0, 0, 13),
			ZIndex = z, Parent = h }, { corner(1) })

	elseif kind == "cpu" or kind == "performance" or kind == "gauge" or kind == "chip" then
		-- CPU chip with pins (hardware/performance)
		for i = 0, 2 do
			local off = 3 + i * 4
			New("Frame", { BackgroundColor3 = Color3.fromRGB(150, 154, 160), BorderSizePixel = 0,
				Size = UDim2.new(0, 2, 0, 3), Position = UDim2.new(0, off, 0, 0), ZIndex = z, Parent = h })
			New("Frame", { BackgroundColor3 = Color3.fromRGB(150, 154, 160), BorderSizePixel = 0,
				Size = UDim2.new(0, 2, 0, 3), Position = UDim2.new(0, off, 1, -3), ZIndex = z, Parent = h })
			New("Frame", { BackgroundColor3 = Color3.fromRGB(150, 154, 160), BorderSizePixel = 0,
				Size = UDim2.new(0, 3, 0, 2), Position = UDim2.new(0, 0, 0, off), ZIndex = z, Parent = h })
			New("Frame", { BackgroundColor3 = Color3.fromRGB(150, 154, 160), BorderSizePixel = 0,
				Size = UDim2.new(0, 3, 0, 2), Position = UDim2.new(1, -3, 0, off), ZIndex = z, Parent = h })
		end
		local body = New("Frame", { BackgroundColor3 = Color3.fromRGB(70, 110, 150), BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 11, 0, 11), Position = UDim2.new(0.5, 0, 0.5, 0),
			ZIndex = z + 1, Parent = h }, { corner(2), stroke(Color3.fromRGB(40, 74, 110), 1, 0) })
		verticalGradient(Color3.fromRGB(110, 158, 206), Color3.fromRGB(58, 100, 146), body)
		glossShine(body, z + 1)
		New("Frame", { BackgroundColor3 = Color3.fromRGB(36, 60, 92), BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 5, 0, 5), Position = UDim2.new(0.5, 0, 0.5, 0),
			ZIndex = z + 2, Parent = h }, { corner(1) })

	else
		return drawIcon(parent, "folder", px)
	end
	return h
end

--============================================================================--
--// Library root
--============================================================================--
local SimplUI = {}
SimplUI.__index = SimplUI

SimplUI.Theme  = Theme
SimplUI._windows = {}

-- Root ScreenGui (one per session, high display order)
local function ensureRoot()
	if SimplUI._root and SimplUI._root.Parent then
		return SimplUI._root
	end
	local gui = New("ScreenGui", {
		Name = "SimplUI_" .. tostring(math.random(1000, 9999)),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 9999,
		IgnoreGuiInset = true,
	})
	-- executor protection
	pcall(function()
		if syn and syn.protect_gui then syn.protect_gui(gui) end
	end)
	gui.Parent = getGuiParent()
	SimplUI._root = gui
	return gui
end

--============================================================================--
--// Notifications (Win7 balloon toast, bottom-right stack)
--============================================================================--
function SimplUI:Notify(opts)
	opts = opts or {}
	local root = ensureRoot()

	local holder = root:FindFirstChild("NotifyHolder")
	if not holder then
		holder = New("Frame", {
			Name = "NotifyHolder",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -14, 1, -14),
			Size = UDim2.new(0, 210, 1, -28),
			ZIndex = 5000,
			Parent = root,
		}, {
			New("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 6),
			}),
		})
	end

	-- Compact Win7 "balloon" toast. Colors come from the active theme (NotifTop/
	-- NotifBottom, glass transparency, text roles) so it matches Dark/Light live.
	-- The card auto-sizes to a single inner Content frame. Decorative layers (gloss,
	-- accent strip) live directly on the card and are kept OUT of the list flow — if
	-- they were laid out, their Scale heights (0.45 + 1.0) would feed back into the
	-- card's AutomaticSize and blow it up to hundreds of px tall.
	local card = New("Frame", {
		BackgroundColor3 = Theme.NotifBottom,
		BackgroundTransparency = Theme.FrameT,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 5001,
		ClipsDescendants = true,
		Parent = holder,
	}, {
		corner(5),
		stroke(Theme.WindowBorder, 1, 0.2),
	})
	verticalGradient(Theme.NotifTop, Theme.NotifBottom, card)
	glossShine(card, 5001)
	-- Aero accent strip down the left edge (the Win7 balloon look)
	New("Frame", {
		BackgroundColor3 = Theme.Accent, BorderSizePixel = 0,
		Size = UDim2.new(0, 3, 1, 0), Position = UDim2.new(0, 0, 0, 0),
		ZIndex = 5003, Parent = card,
	})
	-- Content holds the only laid-out children; it alone drives the card's height.
	New("Frame", {
		Name = "Content", BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 5002, Parent = card,
	}, {
		New("UIPadding", {
			PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 5),
			PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 9),  -- 12 left clears the accent strip
		}),
		New("UIListLayout", { Padding = UDim.new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder }),
		New("TextLabel", {
			Name = "Title", LayoutOrder = 1,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 14),
			Font = Theme.FontBold, TextSize = 13,
			TextColor3 = Theme.TitleText, TextXAlignment = Enum.TextXAlignment.Left,
			Text = opts.Title or "Simpl Hub",
			ZIndex = 5002,
		}),
		New("TextLabel", {
			Name = "Body", LayoutOrder = 2,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			Font = Theme.Font, TextSize = 12, TextWrapped = true,
			TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left,
			Text = opts.Content or opts.Text or "",
			ZIndex = 5002,
		}),
	})

	card.Position = UDim2.new(1, 40, 0, 0)
	tween(card, 0.22, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back)

	task.delay(opts.Duration or 3, function()
		if card and card.Parent then
			tween(card, 0.22, { BackgroundTransparency = 1 })
			for _, d in ipairs(card:GetDescendants()) do
				pcall(function()
					if d:IsA("TextLabel") then tween(d, 0.22, { TextTransparency = 1 }) end
					if d:IsA("UIStroke") then tween(d, 0.22, { Transparency = 1 }) end
					if d:IsA("Frame") then tween(d, 0.22, { BackgroundTransparency = 1 }) end
				end)
			end
			task.wait(0.26)
			card:Destroy()
		end
	end)
end

--============================================================================--
--// Window
--============================================================================--
local Window = {}
Window.__index = Window

function SimplUI:CreateWindow(opts)
	opts = opts or {}
	local root = ensureRoot()

	if opts.Theme and Palettes[opts.Theme] then activeTheme = opts.Theme end

	local size = opts.Size or UDim2.fromOffset(820, 520)   -- wide Win7-explorer rectangle

	-- Aero glass translucency. Frame chrome (title/address/sidebar) is heavily
	-- frosted so the world shows through; the content pane stays readable.
	-- Glass amounts come from the active theme (Dark = see-through, Light = solid).
	local frameGlass   = opts.Translucency ~= nil and opts.Translucency or Theme.FrameT
	local contentGlass = opts.Translucency ~= nil and math.clamp(opts.Translucency * 0.85, 0, 0.32) or Theme.ContentT
	local contentTint  = opts.ContentTint or Theme.ContentTint
	local self = setmetatable({}, Window)
	self._tabs = {}
	self._activeTab = nil
	self._toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
	self._minimized = false
	self._userName = opts.UserName or (Players.LocalPlayer and Players.LocalPlayer.Name) or "User"
	self._rootPath = opts.RootPath or { "C:", "Users", self._userName }  -- breadcrumb prefix
	self._history = {}
	self._histIndex = 0

	-- Outer window
	local win = New("Frame", {
		Name = "Window",
		BackgroundColor3 = Theme.WindowBg,
		BackgroundTransparency = frameGlass,
		BorderSizePixel = 0,
		Size = size,
		Position = opts.Position or UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
		ClipsDescendants = true,
		Active = true,
		Parent = root,
		Meta = { bg = "WindowBg", glass = "frame" },
	}, {
		corner(6),
		stroke(Theme.WindowBorder, 1, 0, nil, "WindowBorder"),
	})
	-- soft outer glow
	New("UIStroke", { Color = Color3.fromRGB(255,255,255), Thickness = 1, Transparency = 0.4, Parent = win })
	self.Instance = win

	-- Title bar (glossy glass)
	local titleBar = New("Frame", {
		Name = "TitleBar",
		BackgroundColor3 = Theme.TitleBottom,
		BackgroundTransparency = frameGlass,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 32),
		ZIndex = 3,
		Parent = win,
		Meta = { bg = "TitleBottom", glass = "frame" },
	}, {
		corner(6),
	})
	verticalGradient(Theme.TitleTop, Theme.TitleBottom, titleBar, "TitleTop", "TitleBottom")
	glossShine(titleBar, 3)
	-- bright specular highlight along the very top edge (Aero shine)
	New("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.25, BorderSizePixel = 0,
		Size = UDim2.new(1, -12, 0, 1), Position = UDim2.new(0, 6, 0, 2), ZIndex = 5, Parent = titleBar,
	})
	-- cover the rounded bottom of the titlebar so it meets the body flush
	New("Frame", {
		BackgroundColor3 = Theme.TitleBottom, BackgroundTransparency = frameGlass, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 8), Position = UDim2.new(0, 0, 1, -8), ZIndex = 3, Parent = titleBar,
		Meta = { bg = "TitleBottom", glass = "frame" },
	})
	-- bottom edge line under title
	New("Frame", {
		BackgroundColor3 = Theme.WindowBorder, BackgroundTransparency = 0.4, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, 0), ZIndex = 4, Parent = titleBar,
	})

	-- Simpl Hub logo: a bold multicolour "S" at the very left of the title bar. Drawn
	-- as a gradient-filled text glyph so it always renders (no image asset needed) and
	-- matches the red→green→blue→gold brand mark. Set opts.Logo=false to hide it.
	local titleX = 12
	if opts.Logo ~= false then
		New("TextLabel", {
			Name = "Logo", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 9, 0.5, 0), Size = UDim2.new(0, 20, 0, 22),
			Font = Enum.Font.GothamBold, TextSize = 22, TextColor3 = Color3.fromRGB(255, 255, 255),
			Text = "S", ZIndex = 5, Parent = titleBar, Meta = { keepText = true },
		}, {
			New("UIGradient", {
				Rotation = 90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0.00, Color3.fromRGB(230, 72, 42)),
					ColorSequenceKeypoint.new(0.34, Color3.fromRGB(122, 190, 38)),
					ColorSequenceKeypoint.new(0.63, Color3.fromRGB(30, 160, 222)),
					ColorSequenceKeypoint.new(1.00, Color3.fromRGB(222, 162, 30)),
				}),
			}),
		})
		titleX = 34   -- shove the title text right so it clears the logo
	end

	New("TextLabel", {
		Name = "Title", BackgroundTransparency = 1,
		Position = UDim2.new(0, titleX, 0, 0), Size = UDim2.new(1, -(titleX + 108), 1, 0),
		Font = Theme.FontBold, TextSize = 15, TextColor3 = Theme.TitleText,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
		Text = opts.Title or "Simpl Hub",
	}, { }).Parent = titleBar

	if opts.SubTitle then
		local titleLbl = titleBar.Title
		local sub = New("TextLabel", {
			Name = "SubTitle", BackgroundTransparency = 1,
			Position = UDim2.new(0, titleX, 0, 0), Size = UDim2.new(1, -120, 1, 0),
			Font = Theme.Font, TextSize = 13, TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5,
			Text = "     " .. string.rep(" ", #(opts.Title or "Simpl Hub") * 1) .. opts.SubTitle,
			Parent = titleBar,
		})
		-- position subtitle just after title using TextBounds
		local titlePx = titleLbl.TextBounds.X
		sub.Position = UDim2.new(0, titleX + titlePx + 8, 0, 1)
	end

	-- Window controls — the classic Aero pill: minimize | maximize | close,
	-- three glossy cells fused into one rounded, bordered group.
	local minW, maxW, closeW = 30, 31, 39
	local groupW = minW + maxW + closeW

	local controls = New("Frame", {
		Name = "Controls", BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0, ClipsDescendants = true,
		AnchorPoint = Vector2.new(1, 0),
		Size = UDim2.new(0, groupW, 0, 22), Position = UDim2.new(1, -6, 0, 5),
		ZIndex = 6, Parent = titleBar,
	}, {
		corner(5),
		stroke(Color3.fromRGB(112, 133, 158), 1, 0),
		New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	-- inner white bevel highlight so the pill reads as glass
	New("UIStroke", { Color = Color3.fromRGB(255,255,255), Thickness = 1, Transparency = 0.45, Parent = controls })

	-- normal / hover face colors
	local GlassTop,    GlassBottom    = Color3.fromRGB(240, 248, 254), Color3.fromRGB(198, 222, 244)
	local GlassHovTop, GlassHovBottom = Color3.fromRGB(216, 240, 253), Color3.fromRGB(168, 205, 240)
	local GlassPrsTop, GlassPrsBottom = Color3.fromRGB(170, 205, 238), Color3.fromRGB(140, 182, 224)

	local iconColor = Color3.fromRGB(36, 60, 92)
	-- draws the min/max/restore glyphs with frames so they always render crisply
	local function drawGlyph(cell, kind)
		local holder = cell:FindFirstChild("Glyph")
		if holder then holder:Destroy() end
		holder = New("Frame", { Name = "Glyph", BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0), ZIndex = 8, Parent = cell })
		if kind == "min" then
			New("Frame", { BackgroundColor3 = iconColor, BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 9, 0, 2),
				Position = UDim2.new(0.5, 0, 0.5, 4), ZIndex = 9, Parent = holder })
		elseif kind == "max" then
			New("Frame", { BackgroundColor3 = iconColor, BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 11, 0, 9),
				Position = UDim2.new(0.5, 0, 0.5, 0), ZIndex = 9, Parent = holder }, {
				New("Frame", { BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel = 0,
					Position = UDim2.new(0, 1, 0, 2), Size = UDim2.new(1, -2, 1, -3), ZIndex = 10 }),
				-- thicker top edge, like a title bar
			})
		elseif kind == "close" then
			-- two crossed bars → a crisp X that never depends on font glyphs
			for _, rot in ipairs({ 45, -45 }) do
				New("Frame", { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0,
					AnchorPoint = Vector2.new(0.5, 0.5), Rotation = rot,
					Size = UDim2.new(0, 12, 0, 2), Position = UDim2.new(0.5, 0, 0.5, 0),
					ZIndex = 9, Parent = holder }, { corner(1) })
			end
		elseif kind == "restore" then
			-- back square
			New("Frame", { BackgroundColor3 = iconColor, BorderSizePixel = 0,
				Size = UDim2.new(0, 9, 0, 8), Position = UDim2.new(0.5, -2, 0.5, -5), ZIndex = 9, Parent = holder }, {
				New("Frame", { BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel = 0,
					Position = UDim2.new(0, 1, 0, 2), Size = UDim2.new(1, -2, 1, -3), ZIndex = 10 }),
			})
			-- front square
			New("Frame", { BackgroundColor3 = iconColor, BorderSizePixel = 0,
				Size = UDim2.new(0, 9, 0, 8), Position = UDim2.new(0.5, -5, 0.5, -1), ZIndex = 11, Parent = holder }, {
				New("Frame", { BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel = 0,
					Position = UDim2.new(0, 1, 0, 2), Size = UDim2.new(1, -2, 1, -3), ZIndex = 12 }),
			})
		end
	end

	local function controlCell(name, order, width, kind, isClose)
		local cell = New("TextButton", {
			Name = name, AutoButtonColor = false, Text = "",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0,
			LayoutOrder = order, Size = UDim2.new(0, width, 1, 0), ZIndex = 6,
			Parent = controls,
		})
		verticalGradient(
			isClose and Theme.CloseTop or GlassTop,
			isClose and Theme.CloseBottom or GlassBottom, cell)
		glossShine(cell, 6)
		drawGlyph(cell, kind)
		-- 1px separator on the cell's left edge (skip the first cell)
		if order > 1 then
			New("Frame", {
				BackgroundColor3 = Color3.fromRGB(120, 140, 165), BorderSizePixel = 0,
				Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(0, 0, 0, 0), ZIndex = 8, Parent = cell,
			})
			New("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.5,
				BorderSizePixel = 0, Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(0, 1, 0, 0), ZIndex = 8, Parent = cell,
			})
		end

		local function setFace(top, bottom)
			for _, g in ipairs(cell:GetChildren()) do
				if g:IsA("UIGradient") then g:Destroy() end
			end
			verticalGradient(top, bottom, cell)
		end
		cell.MouseEnter:Connect(function()
			setFace(isClose and Theme.CloseHoverTop or GlassHovTop,
				isClose and Theme.CloseHoverBottom or GlassHovBottom)
		end)
		cell.MouseLeave:Connect(function()
			setFace(isClose and Theme.CloseTop or GlassTop,
				isClose and Theme.CloseBottom or GlassBottom)
		end)
		cell.MouseButton1Down:Connect(function()
			setFace(isClose and Theme.CloseHoverBottom or GlassPrsTop,
				isClose and Color3.fromRGB(150, 20, 20) or GlassPrsBottom)
		end)
		cell.MouseButton1Up:Connect(function()
			setFace(isClose and Theme.CloseHoverTop or GlassHovTop,
				isClose and Theme.CloseHoverBottom or GlassHovBottom)
		end)
		return cell
	end

	local minBtn   = controlCell("Minimize", 1, minW,   "min", false)
	local maxBtn   = controlCell("Maximize", 2, maxW,   "max", false)
	local closeBtn = controlCell("Close",    3, closeW, "close", true)
	-- lets ToggleMaximize swap the square <-> restore glyph
	self._setMaxGlyph = function(maximized) drawGlyph(maxBtn, maximized and "restore" or "max") end

	minBtn.MouseButton1Click:Connect(function() self:ToggleMinimize() end)
	maxBtn.MouseButton1Click:Connect(function() self:ToggleMaximize() end)
	closeBtn.MouseButton1Click:Connect(function() self:Destroy() end)

	--------------------------------------------------------------------------
	-- Address / navigation bar (Win7 Explorer breadcrumb)
	--------------------------------------------------------------------------
	local AB = 34
	local addr = New("Frame", {
		Name = "AddressBar", BorderSizePixel = 0, BackgroundColor3 = Theme.AddrBg,
		BackgroundTransparency = frameGlass,
		Position = UDim2.new(0, 0, 0, 32), Size = UDim2.new(1, 0, 0, AB), ZIndex = 2, Parent = win,
		Meta = { bg = "AddrBg", glass = "frame" },
	})
	verticalGradient(Theme.AddrTop, Theme.AddrBottom, addr, "AddrTop", "AddrBottom")
	New("Frame", { BackgroundColor3 = Theme.WindowBorder, BackgroundTransparency = 0.5, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), ZIndex = 2, Parent = addr })

	-- back / forward circular nav buttons
	local function navCircle(name, x, glyph)
		local b = New("TextButton", { Name = name, AutoButtonColor = false, Text = "", BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(84, 150, 214), AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, x, 0.5, 0), Size = UDim2.new(0, 22, 0, 22), ZIndex = 3, Parent = addr },
			{ corner(11), stroke(Color3.fromRGB(40, 92, 150), 1, 0) })
		verticalGradient(Color3.fromRGB(126, 184, 234), Color3.fromRGB(56, 118, 184), b)
		glossShine(b, 3)
		local g = New("TextLabel", { Name = "G", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 5, Font = Theme.FontBold, TextSize = 17, TextColor3 = Color3.fromRGB(255, 255, 255),
			Text = glyph, Parent = b, Meta = { keepText = true } })
		return b, g
	end
	local backBtn, backG = navCircle("Back", 8, "<")
	local fwdBtn,  fwdG  = navCircle("Forward", 33, ">")

	-- breadcrumb address field
	local field = New("Frame", { Name = "Path", BackgroundColor3 = Theme.Field, BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 62, 0.5, 0),
		Size = UDim2.new(1, -74, 0, 22), ZIndex = 3, Parent = addr,
		Meta = { bg = "Field" } },
		{ corner(3), stroke(Color3.fromRGB(150, 170, 195), 1, 0, nil, "FieldBorder") })
	local fico = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(0, 5, 0.5, -8), ZIndex = 4, Parent = field })
	drawIcon(fico, "folder", 14)
	local dropArrow = New("TextLabel", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.new(0, 10, 1, 0), ZIndex = 4,
		Font = Theme.FontBold, TextSize = 11, TextColor3 = Color3.fromRGB(150, 160, 174), Text = "v", Parent = field })
	local crumbs = New("Frame", { Name = "Crumbs", BackgroundTransparency = 1, ClipsDescendants = true,
		Position = UDim2.new(0, 26, 0, 0), Size = UDim2.new(1, -44, 1, 0), ZIndex = 4, Parent = field },
		{ New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 1) }) })

	-- rebuilds the breadcrumb: C: > Users > <username> > <Tab>
	self._setPathTab = function(tabName)
		for _, c in ipairs(crumbs:GetChildren()) do
			if c:IsA("TextLabel") then c:Destroy() end
		end
		local segs = {}
		for _, s in ipairs(self._rootPath) do segs[#segs + 1] = s end
		if tabName then segs[#segs + 1] = tabName end
		local order = 0
		for i, s in ipairs(segs) do
			order += 1
			New("TextLabel", { LayoutOrder = order, BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0),
				Font = (i == #segs) and Theme.FontBold or Theme.Font, TextSize = 14,
				TextColor3 = (i == #segs) and Theme.TitleText or Theme.Text,
				Text = " " .. s .. " ", ZIndex = 4, Parent = crumbs })
			if i < #segs then
				order += 1
				New("TextLabel", { LayoutOrder = order, BackgroundTransparency = 1,
					Size = UDim2.new(0, 9, 1, 0), Font = Theme.FontBold, TextSize = 12,
					TextColor3 = Color3.fromRGB(120, 130, 142), Text = ">", ZIndex = 4, Parent = crumbs })
			end
		end
	end

	-- enable/disable nav buttons based on history position
	self._refreshNav = function()
		local canBack = self._histIndex > 1
		local canFwd  = self._histIndex < #self._history
		backBtn.BackgroundTransparency = canBack and 0 or 0.55
		backG.TextTransparency = canBack and 0 or 0.5
		fwdBtn.BackgroundTransparency = canFwd and 0 or 0.55
		fwdG.TextTransparency = canFwd and 0 or 0.5
	end
	backBtn.MouseButton1Click:Connect(function()
		if self._histIndex > 1 then
			self._histIndex -= 1
			self:SelectTab(self._history[self._histIndex], true)
		end
	end)
	fwdBtn.MouseButton1Click:Connect(function()
		if self._histIndex < #self._history then
			self._histIndex += 1
			self:SelectTab(self._history[self._histIndex], true)
		end
	end)

	-- Body container (below title + address bar)
	local body = New("Frame", {
		Name = "Body", BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 32 + AB), Size = UDim2.new(1, 0, 1, -(32 + AB)),
		Parent = win,
	})
	self._body = body

	-- Sidebar (explorer nav pane)
	local sidebarW = opts.SidebarWidth or 148
	local sidebar = New("Frame", {
		Name = "Sidebar", BackgroundColor3 = Theme.Sidebar, BackgroundTransparency = frameGlass * 0.85,
		BorderSizePixel = 0, Size = UDim2.new(0, sidebarW, 1, 0), Parent = body,
		Meta = { bg = "Sidebar", glass = "sidebar" },
	}, {
		New("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
		New("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }),
	})
	-- vertical divider line
	New("Frame", {
		BackgroundColor3 = Theme.SidebarLine, BorderSizePixel = 0,
		Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(0, sidebarW, 0, 0), Parent = body,
		Meta = { bg = "SidebarLine" },
	})
	self._sidebar = sidebar

	-- Content area
	local content = New("Frame", {
		Name = "Content", BackgroundColor3 = contentTint, BackgroundTransparency = contentGlass,
		BorderSizePixel = 0,
		Position = UDim2.new(0, sidebarW + 1, 0, 0), Size = UDim2.new(1, -(sidebarW + 1), 1, 0),
		Parent = body,
		Meta = { bg = "ContentTint", glass = "content" },
	})
	self._content = content

	-- Dragging (title bar)
	do
		local dragging, dragStart, startPos
		titleBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = win.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - dragStart
				win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
					startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	end

	-- Resize grip (bottom-right)
	do
		local grip = New("TextButton", {
			Name = "Resize", Text = "", AutoButtonColor = false,
			BackgroundTransparency = 1, ZIndex = 10,
			Size = UDim2.new(0, 16, 0, 16), AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -2, 1, -2), Parent = win,
		})
		New("TextLabel", {
			BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0),
			Font = Theme.FontBold, TextSize = 14, TextColor3 = Theme.SubText,
			Text = "◢", ZIndex = 10, Parent = grip,
		})
		local resizing, startPos, startSize
		local minSize = opts.MinSize or Vector2.new(560, 380)
		grip.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
				resizing = true
				startPos = input.Position
				startSize = win.AbsoluteSize
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then resizing = false end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - startPos
				local nx = math.max(minSize.X, startSize.X + delta.X)
				local ny = math.max(minSize.Y, startSize.Y + delta.Y)
				win.Size = UDim2.fromOffset(nx, ny)
			end
		end)
	end

	-- Global show/hide toggle
	self._toggleConn = UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == self._toggleKey then
			win.Visible = not win.Visible
		end
	end)

	-- open animation
	win.Size = UDim2.fromOffset(size.X.Offset, 0)
	tween(win, 0.22, { Size = size }, Enum.EasingStyle.Quart)

	self._currentTheme = activeTheme
	table.insert(SimplUI._windows, self)
	return self
end

-- Live theme switch: repaints every tagged instance from the chosen palette.
function Window:SetTheme(name)
	if not Palettes[name] then return end
	activeTheme = name
	self._currentTheme = name
	local pal = Palettes[name]
	local win = self.Instance

	local function transFor(kind)
		if kind == "content" then return pal.ContentT
		elseif kind == "sidebar" then return pal.FrameT * 0.85
		else return pal.FrameT end
	end

	local function repaint(d)
		local bg = d:GetAttribute("t_bg");   if bg  and pal[bg]  then d.BackgroundColor3 = pal[bg] end
		local gl = d:GetAttribute("t_glass"); if gl then d.BackgroundTransparency = transFor(gl) end
		local st = d:GetAttribute("t_st");   if st  and pal[st]  and d:IsA("UIStroke") then d.Color = pal[st] end
		if d:IsA("UIGradient") then
			local gt, gb = d:GetAttribute("t_gt"), d:GetAttribute("t_gb")
			if gt and gb and pal[gt] and pal[gb] then d.Color = gradSeq(pal[gt], pal[gb]) end
		end
		if (d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox")) and not d:GetAttribute("t_keepText") then
			local role = d:GetAttribute("t_txt")
			d.TextColor3 = (role and pal[role]) or pal.Text
		end
	end

	repaint(win)
	for _, d in ipairs(win:GetDescendants()) do repaint(d) end

	-- refresh the selected tab's highlight (its gradient is generated dynamically)
	if self._activeTab and self._activeTab._setSelected then
		for _, t in ipairs(self._tabs) do t._setSelected(t == self._activeTab) end
	end
	if self._setPathTab and self._activeTab then self._setPathTab(self._activeTab._name) end
end

function Window:ToggleMinimize()
	self._minimized = not self._minimized
	if self._minimized then
		self._restoreSize = self.Instance.Size
		tween(self.Instance, 0.18, { Size = UDim2.new(self.Instance.Size.X.Scale, self.Instance.Size.X.Offset, 0, 32) })
		self._body.Visible = false
	else
		self._body.Visible = true
		tween(self.Instance, 0.18, { Size = self._restoreSize or UDim2.fromOffset(580, 430) })
	end
end

function Window:ToggleMaximize()
	self._maximized = not self._maximized
	local win = self.Instance
	if self._maximized then
		-- un-minimize first if needed so the body is visible when maximized
		if self._minimized then self:ToggleMinimize() end
		self._restorePos  = win.Position
		self._restoreSizeM = win.Size
		tween(win, 0.2, { Size = UDim2.new(1, -12, 1, -12), Position = UDim2.new(0, 6, 0, 6) }, Enum.EasingStyle.Quart)
	else
		tween(win, 0.2, { Size = self._restoreSizeM or UDim2.fromOffset(820, 520),
			Position = self._restorePos or UDim2.new(0.5, -410, 0.5, -260) }, Enum.EasingStyle.Quart)
	end
	if self._setMaxGlyph then self._setMaxGlyph(self._maximized) end
end

function Window:Destroy()
	if self._toggleConn then self._toggleConn:Disconnect() end
	local win = self.Instance
	tween(win, 0.18, { Size = UDim2.fromOffset(win.AbsoluteSize.X, 0), BackgroundTransparency = 1 })
	task.wait(0.2)
	win:Destroy()
end

function Window:Notify(opts) return SimplUI:Notify(opts) end

--============================================================================--
--// Tabs
--============================================================================--
local Tab = {}
Tab.__index = Tab

function Window:CreateTab(name, icon)
	local self_win = self
	local tab = setmetatable({}, Tab)
	tab._window = self_win

	-- Sidebar button (nav-pane entry)
	local btn = New("TextButton", {
		Name = "Tab_" .. name, AutoButtonColor = false, Text = "",
		BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 28),
		Parent = self_win._sidebar,
	}, { corner(4) })

	-- drawn Win7 nav-pane icon (folder / user / gear / disk ...)
	local iconBox = New("Frame", {
		Name = "IconBox", BackgroundTransparency = 1,
		Position = UDim2.new(0, 7, 0.5, -8), Size = UDim2.new(0, 16, 0, 16),
		ZIndex = 2, Parent = btn,
	})
	drawIcon(iconBox, icon or "folder", 16)

	local lbl = New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 29, 0, 0), Size = UDim2.new(1, -33, 1, 0),
		Font = Theme.Font, TextSize = 15, TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2,
		Text = name, Parent = btn,
	})

	-- Content page (scrolling)
	local page = New("ScrollingFrame", {
		Name = "Page_" .. name, Active = true, Visible = false,
		BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 8,
		ScrollBarImageColor3 = Color3.fromRGB(190, 190, 190),
		Parent = self_win._content,
	}, {
		New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
		New("UIPadding", {
			PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
		}),
	})
	tab._page = page
	tab._btn  = btn
	tab._lbl  = lbl
	tab._name = name
	tab._order = 0

	local function setSelected(on)
		if on then
			btn.BackgroundTransparency = 0
			verticalGradient(Theme.CtrlHoverTop, Theme.CtrlHoverBottom, btn)
			stroke(Theme.CtrlHoverBorder, 1, 0.3, btn)
			lbl.TextColor3 = Theme.TitleText
		else
			btn.BackgroundTransparency = 1
			for _, c in ipairs(btn:GetChildren()) do
				if c:IsA("UIGradient") or c:IsA("UIStroke") then c:Destroy() end
			end
			lbl.TextColor3 = Theme.Text
		end
	end
	tab._setSelected = setSelected

	btn.MouseEnter:Connect(function()
		if self_win._activeTab ~= tab then btn.BackgroundTransparency = 0.85 end
	end)
	btn.MouseLeave:Connect(function()
		if self_win._activeTab ~= tab then btn.BackgroundTransparency = 1 end
	end)
	btn.MouseButton1Click:Connect(function()
		self_win:SelectTab(tab)
	end)

	table.insert(self_win._tabs, tab)
	if not self_win._activeTab then
		self_win:SelectTab(tab)
	end
	return tab
end

function Window:SelectTab(tab, isNav)
	for _, t in ipairs(self._tabs) do
		t._page.Visible = false
		t._setSelected(false)
	end
	tab._page.Visible = true
	tab._setSelected(true)
	self._activeTab = tab

	-- update the breadcrumb path (C: > Users > user > <Tab>)
	if self._setPathTab then self._setPathTab(tab._name) end

	-- record navigation history unless we got here via the back/forward buttons
	if not isNav then
		for i = #self._history, self._histIndex + 1, -1 do self._history[i] = nil end
		self._history[#self._history + 1] = tab
		self._histIndex = #self._history
	end
	if self._refreshNav then self._refreshNav() end
end

--============================================================================--
--// Elements
--============================================================================--

-- shared: next LayoutOrder for a tab's page (preserves insertion order)
local function nextOrder(tab)
	tab._order = (tab._order or 0) + 1
	return tab._order
end

-- shared: a full-width row container
local function makeRow(tab, height)
	return New("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = nextOrder(tab),
		Size = UDim2.new(1, 0, 0, height or 30),
		Parent = tab._page,
	})
end

-- shared: apply glossy Win7 button styling + hover states to a TextButton
local function styleGlossyButton(b)
	verticalGradient(Theme.CtrlTop, Theme.CtrlBottom, b, "CtrlTop", "CtrlBottom")
	glossShine(b, b.ZIndex)
	local strk = stroke(Theme.CtrlBorder, 1, 0, b, "CtrlBorder")

	local function grad(roleTop, roleBot)
		for _, c in ipairs(b:GetChildren()) do
			if c:IsA("UIGradient") then c:Destroy() end
		end
		verticalGradient(Theme[roleTop], Theme[roleBot], b, roleTop, roleBot)
	end
	b.MouseEnter:Connect(function()
		grad("CtrlHoverTop", "CtrlHoverBottom")
		strk.Color = Theme.CtrlHoverBorder
	end)
	b.MouseLeave:Connect(function()
		grad("CtrlTop", "CtrlBottom")
		strk.Color = Theme.CtrlBorder
	end)
	b.MouseButton1Down:Connect(function()
		grad("CtrlPressTop", "CtrlPressBottom")
	end)
	b.MouseButton1Up:Connect(function()
		grad("CtrlHoverTop", "CtrlHoverBottom")
	end)
	return strk
end

function Tab:CreateButton(opts)
	opts = opts or {}
	local row = makeRow(self, 30)
	local b = New("TextButton", {
		AutoButtonColor = false, Text = "", BorderSizePixel = 0,
		BackgroundColor3 = Theme.CtrlBottom,
		Size = UDim2.new(1, 0, 1, 0), Parent = row,
		Meta = { bg = "CtrlBottom" },
	}, { corner(5) })
	New("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ZIndex = 5,
		Font = Theme.Font, TextSize = 15, TextColor3 = Theme.Text,
		Text = opts.Text or "Button", Parent = b,
	})
	styleGlossyButton(b)
	b.MouseButton1Click:Connect(function()
		if opts.Callback then task.spawn(opts.Callback) end
	end)
	return { Instance = b }
end

function Tab:CreateLabel(opts)
	opts = opts or {}
	local text = type(opts) == "string" and opts or (opts.Text or "Label")
	local row = makeRow(self, 20)
	local lbl = New("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
		Font = Theme.Font, TextSize = 15, TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
		Text = text, Parent = row,
	})
	row.AutomaticSize = Enum.AutomaticSize.Y
	lbl.AutomaticSize = Enum.AutomaticSize.Y
	return {
		Instance = lbl,
		Set = function(_, t) lbl.Text = t end,
	}
end

function Tab:CreateSection(opts)
	opts = opts or {}
	local text = type(opts) == "string" and opts or (opts.Text or "Section")
	local row = makeRow(self, 24)
	New("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
		Font = Theme.FontBold, TextSize = 15, TextColor3 = Theme.TitleText,
		TextXAlignment = Enum.TextXAlignment.Left, Text = text, Parent = row,
		Meta = { txt = "TitleText" },
	})
	-- underline that fills remaining width
	local line = New("Frame", {
		BackgroundColor3 = Theme.SidebarLine, BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 1, -2), Size = UDim2.new(1, 0, 0, 1), Parent = row,
		Meta = { bg = "SidebarLine" },
	})
	return { Instance = row }
end

function Tab:CreateToggle(opts)
	opts = opts or {}
	local state = opts.Default or false
	local row = makeRow(self, 26)

	local check = New("TextButton", {
		AutoButtonColor = false, Text = "", BorderSizePixel = 0,
		BackgroundColor3 = Theme.Field,
		Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 0, 0.5, -9),
		Parent = row, Meta = { bg = "Field" },
	}, { corner(3), stroke(Theme.FieldBorder, 1, 0) })
	local tick = New("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
		Font = Theme.FontBold, TextSize = 16, TextColor3 = Theme.Accent,
		Text = "✔", TextTransparency = state and 0 or 1, Parent = check,
	})
	New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 26, 0, 0), Size = UDim2.new(1, -26, 1, 0),
		Font = Theme.Font, TextSize = 15, TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left, Text = opts.Text or "Toggle", Parent = row,
	})

	local api = {}
	local function apply(fire)
		tick.TextTransparency = state and 0 or 1
		check:FindFirstChildOfClass("UIStroke").Color = state and Theme.Accent or Theme.FieldBorder
		if fire and opts.Callback then task.spawn(opts.Callback, state) end
	end
	check.MouseButton1Click:Connect(function()
		state = not state
		apply(true)
	end)
	apply(false)
	function api:Set(v) state = v and true or false; apply(true) end
	function api:Get() return state end
	return api
end

function Tab:CreateSlider(opts)
	opts = opts or {}
	local min = opts.Min or 0
	local max = opts.Max or 100
	local decimals = opts.Decimals or 0
	local value = math.clamp(opts.Default or min, min, max)

	local row = makeRow(self, 42)
	New("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, -60, 0, 18), Font = Theme.Font, TextSize = 15,
		TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
		Text = opts.Text or "Slider", Parent = row,
	})
	local valLbl = New("TextLabel", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 60, 0, 18),
		Font = Theme.Font, TextSize = 15, TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Right, Text = tostring(value), Parent = row,
	})

	local track = New("Frame", {
		BackgroundColor3 = Theme.Track, BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -14), Size = UDim2.new(1, 0, 0, 6),
		Parent = row, Meta = { bg = "Track" },
	}, { corner(3), stroke(Theme.TrackBorder, 1, 0, nil, "TrackBorder") })
	local fill = New("Frame", {
		BackgroundColor3 = Theme.Accent, BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0), Parent = track,
	}, { corner(3) })
	verticalGradient(Color3.fromRGB(120, 178, 220), Theme.Accent, fill)
	local thumb = New("Frame", {
		BackgroundColor3 = Theme.CtrlTop, BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(0, 12, 0, 16),
		ZIndex = 3, Parent = track, Meta = { bg = "CtrlTop" },
	}, { corner(3), stroke(Theme.CtrlHoverBorder, 1, 0) })
	verticalGradient(Theme.CtrlTop, Theme.CtrlBottom, thumb, "CtrlTop", "CtrlBottom")

	local function round(n)
		local m = 10 ^ decimals
		return math.floor(n * m + 0.5) / m
	end
	local api = {}
	local function setFromScalar(alpha, fire)
		alpha = math.clamp(alpha, 0, 1)
		value = round(min + (max - min) * alpha)
		local a = (value - min) / (max - min)
		fill.Size = UDim2.new(a, 0, 1, 0)
		thumb.Position = UDim2.new(a, 0, 0.5, 0)
		valLbl.Text = tostring(value)
		if fire and opts.Callback then task.spawn(opts.Callback, value) end
	end

	local dragging = false
	local function updateFromInput(input)
		local rel = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
		setFromScalar(rel, true)
	end
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true; updateFromInput(input)
		end
	end)
	thumb.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
			updateFromInput(input)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	setFromScalar((value - min) / (max - min), false)
	function api:Set(v) setFromScalar((math.clamp(v, min, max) - min) / (max - min), true) end
	function api:Get() return value end
	return api
end

function Tab:CreateTextbox(opts)
	opts = opts or {}
	local row = makeRow(self, 46)
	New("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 18), Font = Theme.Font, TextSize = 15,
		TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
		Text = opts.Text or "Input", Parent = row,
	})
	local box = New("Frame", {
		BackgroundColor3 = Theme.Field, BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 0, 22),
		Parent = row, Meta = { bg = "Field" },
	}, { corner(3) })
	local strk = stroke(Theme.FieldBorder, 1, 0, box, "FieldBorder")
	local input = New("TextBox", {
		BackgroundTransparency = 1, ClearTextOnFocus = false,
		Position = UDim2.new(0, 8, 0, 0), Size = UDim2.new(1, -14, 1, 0),
		Font = Theme.Font, TextSize = 15, TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		PlaceholderText = opts.Placeholder or "",
		PlaceholderColor3 = Theme.SubText,
		Text = opts.Default or "", Parent = box,
	})
	input.Focused:Connect(function() strk.Color = Theme.FieldFocus end)
	input.FocusLost:Connect(function(enter)
		strk.Color = Theme.FieldBorder
		if opts.Callback then task.spawn(opts.Callback, input.Text, enter) end
	end)
	return {
		Instance = input,
		Get = function() return input.Text end,
		Set = function(_, t) input.Text = t end,
	}
end

function Tab:CreateKeybind(opts)
	opts = opts or {}
	local current = opts.Default
	local row = makeRow(self, 30)
	New("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, -110, 1, 0), Font = Theme.Font, TextSize = 15,
		TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
		Text = opts.Text or "Keybind", Parent = row,
	})
	local b = New("TextButton", {
		AutoButtonColor = false, Text = "", BorderSizePixel = 0,
		BackgroundColor3 = Theme.CtrlBottom, AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0, 100, 0, 24),
		Parent = row, Meta = { bg = "CtrlBottom" },
	}, { corner(5) })
	local keyLbl = New("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ZIndex = 5,
		Font = Theme.Font, TextSize = 14, TextColor3 = Theme.Text,
		Text = current and current.Name or "None", Parent = b,
	})
	styleGlossyButton(b)

	local listening = false
	b.MouseButton1Click:Connect(function()
		listening = true
		keyLbl.Text = "..."
	end)
	UserInputService.InputBegan:Connect(function(input, gpe)
		if listening and input.UserInputType == Enum.UserInputType.Keyboard then
			listening = false
			current = input.KeyCode
			keyLbl.Text = current.Name
		elseif not listening and current and not gpe
		and input.KeyCode == current then
			if opts.Callback then task.spawn(opts.Callback, current) end
		end
	end)
	return {
		Get = function() return current end,
		Set = function(_, k) current = k; keyLbl.Text = k and k.Name or "None" end,
	}
end

function Tab:CreateDropdown(opts)
	opts = opts or {}
	local options = opts.Options or {}
	local multi = opts.Multi or false
	local icons = opts.Icons   -- optional map: { [optionName] = "rbxassetid://..." }; adds a thumbnail per row
	local labels = opts.Labels -- optional map: { [optionValue] = "Display Name" }; value stays the key
	local ROW_H = icons and 30 or 24
	local selected = multi and {} or opts.Default
	if multi and opts.Default then
		for _, v in ipairs(opts.Default) do selected[v] = true end
	end

	local row = New("Frame", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 46),
		LayoutOrder = nextOrder(self),
		ClipsDescendants = false, Parent = self._page,
	})
	New("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 18), Font = Theme.Font, TextSize = 15,
		TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
		Text = opts.Text or "Dropdown", Parent = row,
	})

	local box = New("TextButton", {
		AutoButtonColor = false, Text = "", BorderSizePixel = 0,
		BackgroundColor3 = Theme.Field,
		Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 0, 22),
		Parent = row, Meta = { bg = "Field" },
	}, { corner(3) })
	local boxStroke = stroke(Theme.FieldBorder, 1, 0, box, "FieldBorder")
	local selLbl = New("TextLabel", {
		BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 0),
		Size = UDim2.new(1, -34, 1, 0), Font = Theme.Font, TextSize = 15,
		TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
		Text = "", Parent = box,
	})
	-- combobox arrow button
	local arrowBtn = New("Frame", {
		BackgroundColor3 = Theme.CtrlBottom, BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -1, 0.5, 0),
		Size = UDim2.new(0, 20, 1, -2), Parent = box, Meta = { bg = "CtrlBottom" },
	}, { corner(3) })
	verticalGradient(Theme.CtrlTop, Theme.CtrlBottom, arrowBtn, "CtrlTop", "CtrlBottom")
	New("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
		Font = Theme.FontBold, TextSize = 12, TextColor3 = Theme.Text,
		Text = "▼", Parent = arrowBtn,
	})

	-- expandable list (inline, pushes content down). ScrollingFrame so long option
	-- lists (e.g. all 11 crates) are reachable instead of being clipped at 6 rows.
	local list = New("ScrollingFrame", {
		BackgroundColor3 = Theme.Field, BorderSizePixel = 0, Visible = false,
		Position = UDim2.new(0, 0, 0, 46), Size = UDim2.new(1, 0, 0, 0),
		ClipsDescendants = true, ZIndex = 20, Parent = row, Meta = { bg = "Field" },
		CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 5, ScrollBarImageColor3 = Color3.fromRGB(150, 160, 174),
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, {
		corner(3), stroke(Theme.FieldBorder, 1, 0, nil, "FieldBorder"),
		New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
	})

	local function refreshLabel()
		if multi then
			local names = {}
			for _, v in ipairs(options) do if selected[v] then table.insert(names, (labels and labels[v]) or v) end end
			selLbl.Text = #names > 0 and table.concat(names, ", ") or (opts.Placeholder or "None")
		else
			selLbl.Text = selected ~= nil and tostring((labels and labels[selected]) or selected) or (opts.Placeholder or "Select...")
		end
	end

	local open = false
	local markFns = {}   -- parallel to option buttons; can't store fns on Instances
	local function rebuild()
		for _, c in ipairs(list:GetChildren()) do
			if c:IsA("TextButton") then c:Destroy() end
		end
		markFns = {}
		for i, opt in ipairs(options) do
			local hasIcon = icons and icons[opt]
			local disp = (labels and labels[opt]) or opt
			local ob = New("TextButton", {
				AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = i,
				BackgroundColor3 = Theme.Field, BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, ROW_H), ZIndex = 21,
				Font = Theme.Font, TextSize = 15, TextColor3 = Theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = (hasIcon and "           " or "   ") .. tostring(disp),
				Parent = list,
			})
			if hasIcon then
				New("ImageLabel", {
					BackgroundTransparency = 1, Image = icons[opt], ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 6, 0.5, -10),
					ZIndex = 22, Parent = ob,
				})
			end
			local function markSelected()
				local isSel = multi and selected[opt] or (not multi and selected == opt)
				ob.BackgroundColor3 = Theme.CtrlHoverBottom
				ob.BackgroundTransparency = isSel and 0 or 1
				ob.TextColor3 = isSel and Theme.TitleText or Theme.Text
			end
			markSelected()
			ob.MouseEnter:Connect(function()
				if not (multi and selected[opt]) and selected ~= opt then
					ob.BackgroundTransparency = 0.6
					ob.BackgroundColor3 = Theme.CtrlHoverBottom
				end
			end)
			ob.MouseLeave:Connect(markSelected)
			ob.MouseButton1Click:Connect(function()
				if multi then
					selected[opt] = not selected[opt] or nil
				else
					selected = opt
				end
				refreshLabel()
				for _, m in ipairs(markFns) do m() end
				if opts.Callback then
					task.spawn(opts.Callback, multi and selected or selected)
				end
				if not multi then
					open = false
					list.Visible = false
					tween(list, 0.12, { Size = UDim2.new(1, 0, 0, 0) })
					row.Size = UDim2.new(1, 0, 0, 46)
				end
			end)
			table.insert(markFns, markSelected)
		end
	end
	rebuild()

	local function toggleOpen()
		open = not open
		if open then
			list.Visible = true
			local h = math.min(#options * ROW_H, ROW_H * 6)
			list.Size = UDim2.new(1, 0, 0, 0)
			tween(list, 0.12, { Size = UDim2.new(1, 0, 0, h) })
			row.Size = UDim2.new(1, 0, 0, 46 + h + 2)
			boxStroke.Color = Theme.FieldFocus
		else
			tween(list, 0.12, { Size = UDim2.new(1, 0, 0, 0) })
			row.Size = UDim2.new(1, 0, 0, 46)
			boxStroke.Color = Theme.FieldBorder
			task.delay(0.12, function() if not open then list.Visible = false end end)
		end
	end
	box.MouseButton1Click:Connect(toggleOpen)

	refreshLabel()
	local api = {}
	function api:Get() return selected end
	function api:Set(v)
		if multi then
			selected = {}
			for _, x in ipairs(v) do selected[x] = true end
		else
			selected = v
		end
		refreshLabel()
		for _, m in ipairs(markFns) do m() end
	end
	function api:Refresh(newOptions)
		options = newOptions or options
		rebuild(); refreshLabel()
	end
	return api
end

--============================================================================--
--// API reference
--============================================================================--
--[[
	SimplUI:CreateWindow{
		Title       = "Simpl Hub",
		SubTitle    = "v1.0",              -- optional, shown after title
		Size        = UDim2.fromOffset(580, 430),
		MinSize     = Vector2.new(420, 300),
		SidebarWidth= 148,
		ToggleKey   = Enum.KeyCode.RightShift,   -- show/hide the whole UI
	} -> Window

	Window:CreateTab(name, icon?)  -> Tab   (icon is any string/emoji prefix)
	Window:SelectTab(tab)
	Window:ToggleMinimize()
	Window:Destroy()
	Window:Notify{ Title, Content, Duration }
	SimplUI:Notify{ Title, Content, Duration }

	Tab:CreateSection("Name")
	Tab:CreateLabel("text")                     -> { Set(text) }
	Tab:CreateButton{ Text, Callback }
	Tab:CreateToggle{ Text, Default, Callback(state) }        -> { Set(bool), Get() }
	Tab:CreateSlider{ Text, Min, Max, Default, Decimals, Callback(value) } -> { Set(n), Get() }
	Tab:CreateTextbox{ Text, Placeholder, Default, Callback(text, enterPressed) } -> { Get, Set }
	Tab:CreateKeybind{ Text, Default = Enum.KeyCode.X, Callback(key) }  -> { Get, Set }
	Tab:CreateDropdown{ Text, Options = {"a","b"}, Default, Multi=false, Placeholder, Callback(sel) } -> { Get, Set, Refresh(opts) }
]]

return SimplUI

end)()

-- ==========================================================================
--  License gate  (HWID-locked).  Runs BEFORE anything below loads — if it
--  returns false we `return` out of the whole chunk and nothing else executes.
--
--  How the sharing block works: the first machine to activate a key BINDS its
--  hwid on the server. Any later run of that key from a different machine is
--  rejected ("locked to another PC"). A remembered key is re-checked online on
--  every launch, so revokes/expiries take effect immediately; only a genuine
--  network failure falls back to a short offline grace so a server blip can't
--  lock out paying users.
-- ==========================================================================
local function __LicenseGate()
    local HttpService = game:GetService("HttpService")
    local Players     = game:GetService("Players")
    local LP          = Players.LocalPlayer

    -- Your license server. Same box as the bot; change the port if you merge the
    -- /key routes into the bot itself (then use the bot's port).
    local KEY_ENDPOINT = "http://37.27.54.248:25386/key"
    local PRODUCT      = "Simpl Hub"
    local KEY_FILE     = "SimplHub_MM2/key.txt"
    local STAMP_FILE   = "SimplHub_MM2/key_ok.txt"   -- unix time of last good online check
    local GRACE_SECS   = 72 * 3600                      -- offline grace after a good check

    -- executor HTTP request fn (name differs per executor)
    local function reqFn()
        return (syn and syn.request) or (http and http.request) or http_request or request
            or (fluxus and fluxus.request)
    end

    -- Stable per-machine identity. gethwid() is a true hardware id where the
    -- executor exposes it; RbxAnalyticsService:GetClientId() is a stable
    -- per-install fallback that exists everywhere. We join both so a binding
    -- survives one of them being unavailable on a given executor.
    local function getHWID()
        local a, b
        pcall(function() if gethwid then a = gethwid() end end)
        pcall(function() b = game:GetService("RbxAnalyticsService"):GetClientId() end)
        local raw = tostring(a or "") .. "|" .. tostring(b or "")
        if raw == "|" then raw = "UID-" .. tostring(LP.UserId) end   -- last resort
        return raw
    end
    local HWID = getHWID()

    -- file helpers (all guarded — executors without a file API just won't remember)
    local function readSaved(p)
        local v; pcall(function() if isfile and isfile(p) then v = readfile(p) end end); return v
    end
    local function write(p, s)
        pcall(function()
            if not (isfolder and isfolder("SimplHub_MM2")) then pcall(makefolder, "SimplHub_MM2") end
            writefile(p, s)
        end)
    end
    local function stampOk() write(STAMP_FILE, tostring(os.time())) end
    local function withinGrace()
        local s = readSaved(STAMP_FILE)
        local t = s and tonumber(s)
        return t ~= nil and (os.time() - t) < GRACE_SECS
    end

    -- POST {key,hwid} -> ok, reason.  reason "unreachable"/"no_http" = ambiguous
    -- (network fault); everything else is an explicit server decision.
    local function verify(key)
        local fn = reqFn()
        if not fn then return false, "no_http" end
        local ok, res = pcall(function()
            return fn({
                Url = KEY_ENDPOINT .. "/verify",
                Method = "POST",
                Headers = {
                    ["Content-Type"]           = "application/json",
                    ["User-Agent"]             = "MM2CoinFarm",
                    ["bypass-tunnel-reminder"] = "true",
                },
                Body = HttpService:JSONEncode({ key = key, hwid = HWID, product = PRODUCT }),
            })
        end)
        if not ok or not res then return false, "unreachable" end
        local code = res.StatusCode or res.status_code or 0
        local body = {}
        pcall(function() body = HttpService:JSONDecode(res.Body or "{}") end)
        if code >= 200 and code < 300 and body.ok == true then return true, "ok" end
        if code == 0 then return false, "unreachable" end
        return false, (body and body.reason) or ("http_" .. tostring(code))
    end

    -- human-readable line for each reason
    local function reasonText(r)
        if r == "hwid_mismatch" then return "This key is locked to another PC."
        elseif r == "invalid"    then return "Invalid key."
        elseif r == "expired"    then return "This key has expired."
        elseif r == "revoked"    then return "This key was revoked."
        elseif r == "unreachable" or r == "no_http" then return "Can't reach the license server."
        else return "Activation failed (" .. tostring(r) .. ")." end
    end

    -- Which reasons mean the SERVER explicitly rejected the key (vs. a network
    -- blip). Only these ever kick a user / block the load — timeouts and server
    -- errors are treated as "can't tell" and covered by the offline grace.
    local function isHardReject(reason)
        return reason == "hwid_mismatch" or reason == "invalid"
            or reason == "expired" or reason == "revoked"
    end

    -- ── one-paste loader flow: a loader may set script_key before loadstring()
    --    ran us. Executors scatter loader globals across _G / getgenv() / the
    --    fenv, so we check all of them. ──
    local loaderKey = rawget(_G, "script_key")
    if not loaderKey then pcall(function() loaderKey = getgenv and getgenv().script_key end) end
    if not loaderKey then pcall(function() loaderKey = rawget(getfenv(0), "script_key") end) end
    if not loaderKey then pcall(function() loaderKey = script_key end) end   -- bare global
    if type(loaderKey) ~= "string" or #loaderKey == 0 then loaderKey = nil end

    local saved = readSaved(KEY_FILE)   -- the last key that verified OK on THIS machine
    -- Prefer a loader-supplied key; otherwise the remembered one.
    local knownKey = loaderKey or (saved and #saved > 0 and saved) or nil

    -- ── FAST PATH: instant load, verify in the background. ──
    -- Only when the key we're about to use is the SAME one already validated on
    -- this machine AND that validation is recent (within grace). This is the 99%
    -- case (a returning user re-executing), and it never blocks on the bot — so a
    -- slow/stalling host no longer delays startup. A background re-check still runs;
    -- if the server explicitly rejects the key (revoked / shared to another PC /
    -- expired), we boot them. Network blips are ignored (grace already covers them).
    if knownKey and saved and knownKey == saved and withinGrace() then
        task.spawn(function()
            local ok, reason = verify(knownKey)
            if ok then stampOk()
            elseif isHardReject(reason) then
                pcall(function() LocalPlayer:Kick("\nSimpl Hub — license check failed: " .. reasonText(reason)) end)
            end
        end)
        return true
    end

    -- ── SLOW PATH: first activation on this machine, or a new/changed key. ──
    -- Here we must confirm with the server before loading anything.
    if knownKey then
        local ok, reason = verify(knownKey)
        if ok then write(KEY_FILE, knownKey); stampOk(); return true end
        -- ambiguous (server down/slow) but we passed recently → grace
        if not isHardReject(reason) and withinGrace() then return true end
        -- explicit reject / no grace → fall through to the activation window
    end

    -- ── activation window (raw instances, Win7-ish, self-contained) ──
    local function guiParent()
        local ok, h = pcall(function() return gethui and gethui() end)
        if ok and h then return h end
        return game:GetService("CoreGui")
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "SH_Activation"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999999
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    gui.Parent = guiParent()

    local shade = Instance.new("Frame", gui)   -- dim backdrop
    shade.Size = UDim2.fromScale(1, 1)
    shade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shade.BackgroundTransparency = 0.4
    shade.BorderSizePixel = 0

    local card = Instance.new("Frame", shade)
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.fromScale(0.5, 0.5)
    card.Size = UDim2.fromOffset(400, 250)
    card.BackgroundColor3 = Color3.fromRGB(238, 242, 247)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
    local cs = Instance.new("UIStroke", card); cs.Color = Color3.fromRGB(120, 156, 196); cs.Thickness = 1

    local title = Instance.new("Frame", card)
    title.Size = UDim2.new(1, 0, 0, 34); title.BorderSizePixel = 0
    title.BackgroundColor3 = Color3.fromRGB(74, 112, 156)
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 6)
    local tg = Instance.new("UIGradient", title); tg.Rotation = 90
    tg.Color = ColorSequence.new(Color3.fromRGB(84, 122, 166), Color3.fromRGB(46, 82, 122))
    local tCover = Instance.new("Frame", title); tCover.BorderSizePixel = 0
    tCover.BackgroundColor3 = Color3.fromRGB(46, 82, 122)
    tCover.Size = UDim2.new(1, 0, 0, 8); tCover.Position = UDim2.new(0, 0, 1, -8)
    local tTxt = Instance.new("TextLabel", title)
    tTxt.BackgroundTransparency = 1; tTxt.Position = UDim2.new(0, 12, 0, 0); tTxt.Size = UDim2.new(1, -44, 1, 0)
    tTxt.Font = Enum.Font.SourceSansBold; tTxt.TextSize = 16; tTxt.TextColor3 = Color3.fromRGB(236, 244, 252)
    tTxt.TextXAlignment = Enum.TextXAlignment.Left; tTxt.ZIndex = 2; tTxt.Text = PRODUCT .. " — Activation"

    local closeBtn = Instance.new("TextButton", title)
    closeBtn.Text = "X"; closeBtn.Font = Enum.Font.SourceSansBold; closeBtn.TextSize = 15
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255); closeBtn.AutoButtonColor = true
    closeBtn.BackgroundColor3 = Color3.fromRGB(197, 63, 63); closeBtn.BorderSizePixel = 0
    closeBtn.AnchorPoint = Vector2.new(1, 0.5); closeBtn.Position = UDim2.new(1, -6, 0.5, 0)
    closeBtn.Size = UDim2.fromOffset(26, 20); closeBtn.ZIndex = 2
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

    local function mkLabel(y, text, size, color)
        local l = Instance.new("TextLabel", card)
        l.BackgroundTransparency = 1; l.Position = UDim2.new(0, 18, 0, y); l.Size = UDim2.new(1, -36, 0, size + 6)
        l.Font = Enum.Font.SourceSans; l.TextSize = size; l.TextColor3 = color or Color3.fromRGB(40, 44, 50)
        l.TextXAlignment = Enum.TextXAlignment.Left; l.Text = text; l.TextWrapped = true
        return l
    end

    mkLabel(46, "Enter your license key to activate this copy.", 15)

    local box = Instance.new("TextBox", card)
    box.Position = UDim2.new(0, 18, 0, 78); box.Size = UDim2.new(1, -36, 0, 30)
    box.BackgroundColor3 = Color3.fromRGB(255, 255, 255); box.BorderSizePixel = 0
    box.Font = Enum.Font.Code; box.TextSize = 15; box.TextColor3 = Color3.fromRGB(30, 34, 40)
    box.PlaceholderText = "SH-XXXX-XXXX-XXXX"; box.ClearTextOnFocus = false
    box.Text = ""; box.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    local bs = Instance.new("UIStroke", box); bs.Color = Color3.fromRGB(160, 172, 188)
    local bpad = Instance.new("UIPadding", box); bpad.PaddingLeft = UDim.new(0, 8); bpad.PaddingRight = UDim.new(0, 8)

    local function mkButton(x, w, y, text, bg)
        local b = Instance.new("TextButton", card)
        b.Position = UDim2.new(0, x, 0, y); b.Size = UDim2.fromOffset(w, 30)
        b.Font = Enum.Font.SourceSansBold; b.TextSize = 15; b.AutoButtonColor = true
        b.TextColor3 = Color3.fromRGB(255, 255, 255); b.BackgroundColor3 = bg; b.BorderSizePixel = 0
        b.Text = text
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        return b
    end

    local pasteBtn    = mkButton(18, 110, 118, "Paste", Color3.fromRGB(96, 108, 124))
    local activateBtn = mkButton(140, 242, 118, "Activate", Color3.fromRGB(60, 127, 177))

    local status = mkLabel(158, "", 14, Color3.fromRGB(150, 60, 60))
    status.Size = UDim2.new(1, -36, 0, 34)

    local hwidLbl = mkLabel(202, "HWID: " .. HWID:sub(1, 40), 12, Color3.fromRGB(120, 128, 138))
    local copyHwid = mkButton(18, 364, 224, "Copy HWID", Color3.fromRGB(120, 130, 142))
    copyHwid.TextSize = 13

    -- clipboard paste (name differs per executor)
    pasteBtn.MouseButton1Click:Connect(function()
        local clip
        pcall(function() clip = (getclipboard and getclipboard()) or (get_clipboard and get_clipboard()) end)
        if clip and #clip > 0 then box.Text = clip end
    end)
    copyHwid.MouseButton1Click:Connect(function()
        pcall(function() if setclipboard then setclipboard(HWID) end end)
        copyHwid.Text = "Copied!"
        task.delay(1.2, function() if copyHwid then copyHwid.Text = "Copy HWID" end end)
    end)

    local result = nil   -- "ok" | "cancel"
    local checking = false

    local function doActivate()
        if checking then return end
        local key = (box.Text or ""):gsub("%s+", "")
        if #key == 0 then status.TextColor3 = Color3.fromRGB(170, 50, 50); status.Text = "Paste your key first."; return end
        checking = true
        activateBtn.Text = "Checking..."; activateBtn.AutoButtonColor = false
        status.TextColor3 = Color3.fromRGB(120, 128, 138); status.Text = "Contacting license server..."
        local ok, reason = verify(key)
        if ok then
            write(KEY_FILE, key); stampOk()
            status.TextColor3 = Color3.fromRGB(40, 130, 60); status.Text = "Activated. Loading..."
            task.wait(0.4)
            result = "ok"
        else
            checking = false
            activateBtn.Text = "Activate"; activateBtn.AutoButtonColor = true
            status.TextColor3 = Color3.fromRGB(170, 50, 50); status.Text = reasonText(reason)
        end
    end

    activateBtn.MouseButton1Click:Connect(doActivate)
    closeBtn.MouseButton1Click:Connect(function() result = "cancel" end)
    box.FocusLost:Connect(function(enter) if enter then doActivate() end end)   -- Enter = activate

    repeat task.wait(0.05) until result ~= nil
    pcall(function() gui:Destroy() end)
    return result == "ok"
end

if not __LicenseGate() then return end

--[[
    Simpl Hub  —  Murder Mystery 2
    ---------------------------------------------------------------
    Features:
      * Coin Farm toggle: tweens the character to every round coin,
        with noclip always enabled while farming so walls/floors never block the path.
      * Constant-velocity tweening (duration = distance / speed) so the
        character never has a velocity spike — this is what keeps it
        under MM2's radar, not the raw number. Speed is slider-tunable.
      * Auto Reset when the coin bag is full (default limit 40).
      * Auto Fling Murderer: piledrive-flings the murderer (found by their Knife tool)
        until they're dead. Fires in two situations — (1) once your coin bag is FULL
        during a round (so you farm first), and (2) while you're in the lobby /
        "waiting for your turn", to auto-end the current round. NOTE: cannot fling
        while YOU are dead. Requires Enable Farm to be on.
      * Anti-AFK: spoofed inputs prevent the 20-minute idle kick (Toggleable).

    UI: SimplUI (Windows 7 Aero, custom lib).
]]

-- ── Services ────────────────────────────────────────────────────────────
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace    = game:GetService("Workspace")

local TeleportService   = game:GetService("TeleportService")
local GuiService        = game:GetService("GuiService")
local VirtualUser       = game:GetService("VirtualUser")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer  = Players.LocalPlayer
local PLACE_ID     = game.PlaceId

-- Undo a NaN FallenPartsDestroyHeight left behind by a previously crashed fling
-- (NaN ~= NaN is the reliable way to detect it). Restores normal part cleanup.
if Workspace.FallenPartsDestroyHeight ~= Workspace.FallenPartsDestroyHeight then
    pcall(function() Workspace.FallenPartsDestroyHeight = -500 end)
end

-- Re-enable 3D rendering and clear any render-disable overlay left by a previous run
pcall(function() RunService:Set3dRenderingEnabled(true) end)
pcall(function()
    local hui = (gethui and gethui()) or game:GetService("CoreGui")
    local old = hui:FindFirstChild("SH_RenderOverlay")
    if old then old:Destroy() end
end)

-- ── Config (mutated by UI) ──────────────────────────────────────────────
local Config = {
    Enabled       = false,   -- coin farm master toggle
    Noclip        = true,    -- hardcoded noclip while farming
    Speed         = 22.5,    -- studs/s — HARD-CAPPED, not user-adjustable (anti-cheat)
    MinHopTime    = 0.05,
    MaxHopTime    = 6.0,
    ReachDist     = 6,
    CollectWait   = 0.30,
    AutoReset     = true,
    BagLimit      = 40,
    FlingMurderer   = false,
    FlingDuration   = 5,
    AntiAFK         = true,
    AntiFling       = false, -- clamp abnormal velocity so others can't fling US
    LowFps          = false, -- cap FPS to 15 for extra CPU savings
    AutoHop         = false, -- server-hop when a match can't start
    HopStuck        = 60,    -- seconds stuck out-of-round before hopping
    SinkDepth       = 4,     -- always-on under-map farming: studs below the coin to sit at.
                             -- Kept shallow (< collection range) so coins still register.
}

-- ── Discord stats sync ───────────────────────────────────────────────────
-- Fill STATS_ENDPOINT with YOUR bot's ingest URL before selling. Each instance
-- POSTs its stats (keyed by the player's link code) so your bot can answer
-- /stats and /inventory. Until it's a real https URL, uploads are skipped.
local STATS_ENDPOINT     = "http://37.27.54.248:25386/ingest"   -- TEST tunnel; swap for your Railway URL when live
local DISCORD_TOKEN_FILE = "SimplHub_MM2/discord_token.txt"

-- ── Anti-AFK ────────────────────────────────────────────────────────────
-- (VirtualUser CaptureController + ClickButton2 — no loader notification)
LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- ── Auto-rejoin on kick ─────────────────────────────────────────────────
local AUTOSTART_FLAG = "SimplHub_MM2/autostart.flag"
local function setAutostart(on)
    pcall(function()
        if not isfolder("SimplHub_MM2") then makefolder("SimplHub_MM2") end
        if on then writefile(AUTOSTART_FLAG, "1")
        elseif isfile(AUTOSTART_FLAG) then delfile(AUTOSTART_FLAG) end
    end)
end

local rejoining = false
local function rejoin()
    if rejoining then return end
    rejoining = true
    setAutostart(true)
    for _ = 1, 20 do
        pcall(function() TeleportService:Teleport(PLACE_ID, LocalPlayer) end)
        task.wait(3)
    end
end

GuiService.ErrorMessageChanged:Connect(function()
    local msg = GuiService:GetErrorMessage()
    if msg and #msg > 0 then
        task.wait(0.15)
        rejoin()
    end
end)

-- ── State ───────────────────────────────────────────────────────────────
local farmThread   = nil
local noclipConn   = nil
local StatusText   = "Idle."
local flinging     = false
local hopping      = false

-- Session stats (per instance; aggregated across instances in the Stats tab)
local Stats = {
    startClock     = os.clock(),
    startCoins     = nil,   -- set lazily on first balance read
    bagsFilled     = 0,
    murderersFlung = 0,
    serverHops     = 0,
}

-- ── Character helpers ───────────────────────────────────────────────────
local function getChar()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if hrp and hum and hum.Health > 0 then
        return char, hrp, hum
    end
    return nil
end

-- ── Round / alive detection ─────────────────────────────────────────────
-- MM2 sets a boolean `Alive` attribute on the LocalPlayer: true only while you're
-- a live, playing participant in the current round; false when you're dead /
-- spectating ("WAITING FOR YOUR TURN"). This is the authoritative signal — the
-- coin-bag HUD lags behind it (it can stay visible while you're dead), which used
-- to make the farm tween a dead/spectator body off into the void and reset.
local function playerAlive()
    local a = LocalPlayer:GetAttribute("Alive")
    if a ~= nil then return a == true end     -- trust the attribute when present
    -- fallback (attribute missing on some game versions): use humanoid health
    local _, _, hum = getChar()
    return hum ~= nil and hum.Health > 0
end

-- ── Coin-bag HUD detection ──────────────────────────────────────────────
local function coinBagFrame()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local f = pg:FindFirstChild("MainGUI")
    f = f and f:FindFirstChild("Game")
    f = f and f:FindFirstChild("CoinBags")
    f = f and f:FindFirstChild("Container")
    f = f and f:FindFirstChild("Coin")
    return f
end

-- We're farmable only when BOTH are true: the round HUD is showing (so we're in a
-- round, not the lobby) AND the player is actually alive (not spectating).
local function isInGame()
    if not playerAlive() then return false end
    local frame = coinBagFrame()
    if not frame or not frame.Visible then return false end
    local cam = Workspace.CurrentCamera
    if not cam then return false end
    local vp = cam.ViewportSize
    local p, s = frame.AbsolutePosition, frame.AbsoluteSize
    if s.X <= 0 or s.Y <= 0 then return false end
    local cx, cy = p.X + s.X / 2, p.Y + s.Y / 2
    return cx >= 0 and cx <= vp.X and cy >= 0 and cy <= vp.Y
end

local function bagCount()
    local frame = coinBagFrame()
    if not frame then return 0 end
    local lbl = frame:FindFirstChild("CurrencyFrame")
    lbl = lbl and lbl:FindFirstChild("Icon")
    lbl = lbl and lbl:FindFirstChild("Coins")
    return (lbl and tonumber(lbl.Text)) or 0
end

local function bagFull()
    local frame = coinBagFrame()
    if not frame then return false end
    local fi = frame:FindFirstChild("FullBagIcon")
    if fi and fi.Visible then return true end
    local full = frame:FindFirstChild("Full")
    if full and full.Visible then return true end
    return false
end

-- ── Total coin balance ──────────────────────────────────────────────────
-- The game keeps the player's spendable coins in the shared ProfileData module
-- (ProfileData.Materials.Owned.Coins). We read that live rather than scraping
-- the shop UI (whose responsive layouts hold stale values).
local ProfileData
pcall(function()
    ProfileData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ProfileData"))
end)

-- Weapon database (id -> { Name, Rarity, ... }); used for inventory upload + trading.
local SyncWeapons
pcall(function()
    SyncWeapons = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync")).Weapons
end)

-- Snapshot of owned weapons for the Discord bot: id, display name, rarity, count.
local function buildInventory()
    local inv = {}
    local owned = (type(ProfileData) == "table" and type(ProfileData.Weapons) == "table") and ProfileData.Weapons.Owned or nil
    if type(owned) == "table" then
        for id, count in pairs(owned) do
            local n = tonumber(count) or 0
            if n > 0 and id ~= "DefaultKnife" and id ~= "DefaultGun" then
                local w = SyncWeapons and SyncWeapons[id]
                local imgId
                if w and w.Image then imgId = tostring(w.Image):match("assetId=(%d+)") end
                if not imgId and w and w.ItemID then imgId = tostring(w.ItemID) end
                inv[#inv + 1] = {
                    id = id,
                    name = (w and w.Name) or id,
                    rarity = (w and w.Rarity) or "Unknown",
                    count = n,
                    image = imgId,
                }
            end
        end
    end
    return inv
end

local function getCoinBalance()
    if type(ProfileData) ~= "table" then return nil end
    local owned = type(ProfileData.Materials) == "table" and ProfileData.Materials.Owned or nil
    local coins = type(owned) == "table" and owned.Coins or nil
    return type(coins) == "number" and coins or nil
end

local function commafy(n)
    local s = tostring(math.floor(n))
    return (s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

-- ── Noclip + anti-gravity hover ─────────────────────────────────────────
local ZERO = Vector3.zero
local function startNoclip()
    if noclipConn then return end
    noclipConn = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if hrp.Anchored then hrp.Anchored = false end
            hrp.AssemblyLinearVelocity  = ZERO
            hrp.AssemblyAngularVelocity = ZERO
        end
    end)
end

local function stopNoclip()
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
end

-- ── Anti-fling ──────────────────────────────────────────────────────────
-- Flings work by injecting huge velocity / angular velocity into your HRP. We clamp
-- anything abnormal every frame so other players' (or the game's) flings can't launch
-- you. Skips while WE are flinging so it doesn't fight our own attack.
local antiFlingConn
local function setAntiFling(on)
    Config.AntiFling = on
    if on then
        if antiFlingConn then return end
        antiFlingConn = RunService.Stepped:Connect(function()
            if flinging then return end
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            -- spin is the giveaway of a fling; normal movement has ~0 angular velocity
            if hrp.AssemblyAngularVelocity.Magnitude > 20 then
                hrp.AssemblyAngularVelocity = ZERO
            end
            -- only kill truly extreme linear velocity so normal walking/falling is fine
            if hrp.AssemblyLinearVelocity.Magnitude > 400 then
                hrp.AssemblyLinearVelocity = ZERO
            end
        end)
    else
        if antiFlingConn then antiFlingConn:Disconnect() antiFlingConn = nil end
    end
end

-- ── Client presence (multi-instance) ────────────────────────────────────
-- Every instance running this script on this PC heartbeats a small file into a
-- shared folder; the Clients tab reads them so you can see all your attached /
-- executed instances at once (handy when multi-boxing alts). Requires the
-- executor's file API (writefile/readfile/listfiles).
-- Stable per-account id: one Roblox account == one client file. It used to carry a
-- random/time suffix, so every RE-EXECUTE registered as a brand-new instance and the
-- same alt piled up (10+ ghost "instances") because the old run's heartbeat loop kept
-- refreshing its now-orphaned file. Keying on UserId means a re-exec just overwrites
-- the same file, and the generation token below stops the previous run's loops.
local INSTANCE_ID = tostring(LocalPlayer.UserId)
local CLIENTS_DIR = "SimplHub_MM2/clients"
local CLIENT_FILE = CLIENTS_DIR .. "/" .. INSTANCE_ID .. ".txt"

-- Bumped every execution. The prior run's forever-loops (heartbeat / stats write /
-- Discord upload) check this and exit when a newer run takes over, so they don't keep
-- writing files or double-posting to Discord after a re-exec.
_G.__SH_HB_GEN = (_G.__SH_HB_GEN or 0) + 1
local HB_GEN = _G.__SH_HB_GEN
local function hbCurrent() return _G.__SH_HB_GEN == HB_GEN end

-- Stats sync plumbing (shared across instances via the executor filesystem)
local STATS_DIR  = "SimplHub_MM2/stats"
local STATS_FILE = STATS_DIR .. "/" .. INSTANCE_ID .. ".json"
local HttpService = game:GetService("HttpService")

local discordToken = nil
pcall(function() if isfile(DISCORD_TOKEN_FILE) then discordToken = readfile(DISCORD_TOKEN_FILE) end end)

-- executor HTTP POST (the global's name differs per executor)
local function getRequestFn()
    return (syn and syn.request) or (http and http.request) or http_request or request
        or (fluxus and fluxus.request)
end

local function writeHeartbeat()
    pcall(function()
        if not isfolder("SimplHub_MM2") then makefolder("SimplHub_MM2") end
        if not isfolder(CLIENTS_DIR) then makefolder(CLIENTS_DIR) end
        local jobId = (game.JobId ~= "" and game.JobId) or "local"
        local state = isInGame() and "in-round" or "lobby"
        local line  = table.concat({
            LocalPlayer.Name, jobId, state, tostring(bagCount()),
            (StatusText:gsub("|", "/")), tostring(os.time()),
        }, "|")
        writefile(CLIENT_FILE, line)
    end)
end

local function readClients()
    -- Collapse duplicate heartbeats for the same account into one entry (an account can
    -- only be in one server at a time, so same name == same instance). This hides ghost
    -- files left behind by earlier executions whose loops are still writing.
    local byName = {}
    pcall(function()
        if not isfolder(CLIENTS_DIR) then return end
        for _, path in ipairs(listfiles(CLIENTS_DIR)) do
            local ok, data = pcall(readfile, path)
            if ok and type(data) == "string" then
                local name, jobId, state, bag, status, ts =
                    data:match("^(.-)|(.-)|(.-)|(.-)|(.-)|(%d+)$")
                if name and ts and (os.time() - tonumber(ts)) <= 10 then
                    local tsn = tonumber(ts)
                    local cur = byName[name]
                    if not cur or tsn > cur._ts then
                        byName[name] = { name = name, jobId = jobId, state = state, bag = bag, status = status, _ts = tsn }
                    end
                end
            end
        end
    end)
    local out = {}
    for _, v in pairs(byName) do out[#out + 1] = v end
    table.sort(out, function(a, b) return a.name:lower() < b.name:lower() end)
    return out
end

-- ── Stats: compute / persist / aggregate / upload ───────────────────────
local function currentStats()
    local bal = getCoinBalance()
    if bal and not Stats.startCoins then Stats.startCoins = bal end
    local runtime = math.max(0, os.clock() - Stats.startClock)
    local gained  = (bal and Stats.startCoins) and math.max(0, bal - Stats.startCoins) or 0
    local cph     = runtime > 0 and math.floor(gained / (runtime / 3600)) or 0
    return {
        instanceId     = INSTANCE_ID,
        name           = LocalPlayer.Name,
        displayName    = LocalPlayer.DisplayName,
        userId         = LocalPlayer.UserId,
        jobId          = (game.JobId ~= "" and game.JobId) or "local",
        state          = isInGame() and "in-round" or "lobby",
        runtime        = math.floor(runtime),
        coins          = bal or 0,
        gained         = gained,
        coinsPerHour   = cph,
        bag            = bagCount(),
        bagsFilled     = Stats.bagsFilled,
        murderersFlung = Stats.murderersFlung,
        serverHops     = Stats.serverHops,
        inventory      = buildInventory(),
        ts             = os.time(),
    }
end

local function writeStatsFile()
    pcall(function()
        if not isfolder("SimplHub_MM2") then makefolder("SimplHub_MM2") end
        if not isfolder(STATS_DIR) then makefolder(STATS_DIR) end
        writefile(STATS_FILE, HttpService:JSONEncode(currentStats()))
    end)
end

local function readAllStats()
    -- Dedupe by account (keep the freshest) so ghost stat files from earlier executions
    -- don't multiply the aggregated totals in the Stats tab.
    local byName = {}
    pcall(function()
        if not isfolder(STATS_DIR) then return end
        for _, path in ipairs(listfiles(STATS_DIR)) do
            local ok, data = pcall(readfile, path)
            if ok and type(data) == "string" then
                local ok2, s = pcall(function() return HttpService:JSONDecode(data) end)
                if ok2 and type(s) == "table" and s.ts and (os.time() - s.ts) <= 10 then
                    local key = s.name or s.instanceId or tostring(path)
                    local cur = byName[key]
                    if not cur or (s.ts > cur.ts) then byName[key] = s end
                end
            end
        end
    end)
    local out = {}
    for _, v in pairs(byName) do out[#out + 1] = v end
    table.sort(out, function(a, b) return (a.name or ""):lower() < (b.name or ""):lower() end)
    return out
end

-- POST this instance's stats to your bot, keyed by the player's link code.
-- Returns (ok, detail) so the UI can show exactly what happened.
local function uploadStatsOnce()
    if not (discordToken and #discordToken > 0) then return false, "no link code entered" end
    if not STATS_ENDPOINT:match("^https?://") or STATS_ENDPOINT:find("your%-bot") then
        return false, "STATS_ENDPOINT not set in the script"
    end
    local fn = getRequestFn()
    if not fn then return false, "your executor has no HTTP request function" end

    local ok, detail = false, "request failed (executor blocked it?)"
    pcall(function()
        local payload = currentStats()
        payload.token = discordToken
        local res = fn({
            Url     = STATS_ENDPOINT,
            Method  = "POST",
            Headers = {
                ["Content-Type"]           = "application/json",
                ["User-Agent"]             = "MM2CoinFarm",
                ["bypass-tunnel-reminder"] = "true",  -- lets localtunnel forward POSTs
            },
            Body    = HttpService:JSONEncode(payload),
        })
        if res then
            local code = res.StatusCode or res.status_code or res.Status or res.status or 0
            if code >= 200 and code < 300 then
                ok, detail = true, "ok (" .. tostring(code) .. ")"
            elseif code == 401 then
                detail = "bot rejected the code (401) — run /link again for a fresh code"
            elseif code == 0 then
                ok, detail = true, "sent (no status returned)"  -- some executors don't expose status
            else
                detail = "server returned HTTP " .. tostring(code)
            end
        end
    end)
    return ok, detail
end

-- One-time cleanup: delete client/stats files that haven't been refreshed in >15s.
-- Live instances rewrite theirs every 2s, so anything this old is a dead ghost from a
-- previous execution (this is what used to accumulate). Safe — never touches a live alt.
local function sweepDeadClientFiles()
    pcall(function()
        for _, dir in ipairs({ CLIENTS_DIR, STATS_DIR }) do
            if isfolder(dir) then
                for _, path in ipairs(listfiles(dir)) do
                    local ok, data = pcall(readfile, path)
                    if ok and type(data) == "string" then
                        local ts = data:match("|(%d+)%s*$") or data:match('"ts"%s*:%s*(%d+)')
                        if ts and (os.time() - tonumber(ts)) > 15 then
                            pcall(delfile, path)
                        end
                    end
                end
            end
        end
    end)
end

task.spawn(function()
    sweepDeadClientFiles()
    while hbCurrent() do
        writeHeartbeat()
        writeStatsFile()
        task.wait(2)
    end
end)

task.spawn(function()
    while hbCurrent() do
        task.wait(30)
        if not hbCurrent() then break end
        pcall(uploadStatsOnce)
    end
end)

-- Validate a REMEMBERED link code on startup. The code persists in discord_token.txt
-- so you don't re-paste it every execute — but if the bot no longer knows it (e.g. you
-- switched bots or its data reset), we clear it so the UI won't falsely show "Linked".
-- Only an explicit 401 clears it; timeouts/blips are ignored so a hiccup never unlinks.
task.spawn(function()
    task.wait(6)
    if not (discordToken and #discordToken > 0) then return end
    if not (STATS_ENDPOINT:match("^https?://") and not STATS_ENDPOINT:find("your%-bot")) then return end
    local fn = getRequestFn()
    if not fn then return end
    local url = (STATS_ENDPOINT:gsub("/ingest%s*$", "/pull")) .. "?token=" .. discordToken .. "&account=probe"
    local ok, res = pcall(function()
        return fn({ Url = url, Method = "GET",
            Headers = { ["User-Agent"] = "MM2CoinFarm", ["bypass-tunnel-reminder"] = "true" } })
    end)
    if ok and res then
        local code = res.StatusCode or res.status_code or res.Status or res.status
        if code == 401 then          -- the bot doesn't recognise this code → it's stale
            discordToken = nil
            pcall(function() if isfile(DISCORD_TOKEN_FILE) then delfile(DISCORD_TOKEN_FILE) end end)
        end
    end
end)

-- ── Coin discovery ──────────────────────────────────────────────────────
local COIN_PART_NAME = "Coin_Server"

local coinRootCache = nil
local function coinRoot()
    if coinRootCache and coinRootCache.Parent then return coinRootCache end
    coinRootCache = nil
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d.Name == "CoinContainer" then
            coinRootCache = d
            break
        end
    end
    return coinRootCache
end

local function isFarmableCoin(part)
    return part:IsA("BasePart") and part.Name == COIN_PART_NAME
end

local blacklist = {}
local function isBlacklisted(coin)
    local exp = blacklist[coin]
    if not exp then return false end
    if os.clock() > exp then blacklist[coin] = nil return false end
    return true
end

-- Safety guards (kept loose so they never exclude legit coins on oddly-placed maps;
-- they only catch genuine garbage). Coins that truly fall get destroyed at the
-- FallenPartsDestroyHeight (~-500) anyway, so -400 only skips ones mid-fall.
local VOID_FLOOR_Y  = -400
local MAX_COIN_DIST  = 2500
-- Murderer avoidance: coins within this radius of the murderer are treated as "risky"
-- and only farmed as a last resort (when no safer coin exists). This keeps the farm
-- from pathing into the murderer — important on the moments it has to surface above the
-- floor (e.g. going up to floor 2 for coins), where the under-map cover doesn't protect us.
local DANGER_RADIUS = 55

-- avoidPos = the murderer's current position (or nil). We pick the nearest coin that is
-- NOT close to the murderer; only if every reachable coin is near them do we fall back to
-- the plain nearest, so the farm never stalls when the murderer is camping the coins.
local function nearestCoin(fromPos, avoidPos)
    local root = coinRoot()
    if not root then return nil end
    local safeBest, safeDist = nil, math.huge
    local anyBest,  anyDist  = nil, math.huge
    for _, d in ipairs(root:GetChildren()) do
        if isFarmableCoin(d) and not isBlacklisted(d)
           and d.Position.Y > VOID_FLOOR_Y then         -- skip coins that fell into the void
            local dist = (d.Position - fromPos).Magnitude
            if dist <= MAX_COIN_DIST then                -- and unreachable/garbage-far ones
                if dist < anyDist then anyBest, anyDist = d, dist end
                local risky = avoidPos ~= nil and (d.Position - avoidPos).Magnitude < DANGER_RADIUS
                if not risky and dist < safeDist then safeBest, safeDist = d, dist end
            end
        end
    end
    local pick = safeBest or anyBest
    return pick, (pick == safeBest) and safeDist or anyDist
end

-- ── Movement (constant-velocity tween) + forced touch ───────────────────
local function fireTouch(hrp, coin)
    pcall(function()
        firetouchinterest(hrp, coin, 0)
        firetouchinterest(hrp, coin, 1)
    end)
end

local function tweenToCoin(coin)
    local _, hrp = getChar()
    if not hrp then return false end

    local collected = false
    local ancConn = coin.AncestryChanged:Connect(function(_, parent)
        if parent == nil then collected = true end
    end)

    local dist = (hrp.Position - coin.Position).Magnitude
    local dur  = math.clamp(dist / Config.Speed, Config.MinHopTime, Config.MaxHopTime)
    -- Always farm from just UNDER the floor: aim below the coin so the body drops under
    -- the map (noclip is on, so it sinks through) with the head at floor level — hard to
    -- see or hit from above. Kept shallow (SinkDepth) so the coin stays in collection
    -- range; reachTrig widens with the depth so the touch still fires once we're below.
    local yOff      = -Config.SinkDepth
    local reachTrig = math.max(Config.ReachDist, Config.SinkDepth + 2)
    local goal = CFrame.new(coin.Position + Vector3.new(0, yOff, 0))
    local tween = TweenService:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), { CFrame = goal })

    tween:Play()
    local elapsed = 0
    while tween.PlaybackState == Enum.PlaybackState.Playing do
        -- bail if farming stopped, coin taken, left the round, or a fling started
        if not Config.Enabled or collected or coin.Parent == nil or not isInGame() or flinging then tween:Cancel() break end
        local _, curHrp = getChar()
        if not curHrp then tween:Cancel() break end

        if (curHrp.Position - coin.Position).Magnitude <= reachTrig then
            fireTouch(curHrp, coin)
            tween:Cancel()
            break
        end
        elapsed += RunService.Heartbeat:Wait()
        if elapsed > Config.MaxHopTime + 1 then tween:Cancel() break end
    end

    local t0 = os.clock()
    while not collected and (os.clock() - t0) < Config.CollectWait do
        if coin.Parent == nil then collected = true break end
        local _, curHrp = getChar()
        if curHrp and (curHrp.Position - coin.Position).Magnitude <= reachTrig + 4 then
            fireTouch(curHrp, coin)
        end
        RunService.Heartbeat:Wait()
    end

    ancConn:Disconnect()
    if not collected then
        blacklist[coin] = os.clock() + 2
    end
    return collected
end

-- ── Murderer detection ──────────────────────────────────────────────────
local function playerHasTool(player, toolName)
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item.Name == toolName then return true end
        end
    end
    local character = player.Character
    if character then
        for _, item in ipairs(character:GetChildren()) do
            if item:IsA("Tool") and item.Name == toolName then return true end
        end
        for _, child in ipairs(character:GetDescendants()) do
            if child:IsA("Tool") then
                local n = child.Name:lower()
                if n == "knife" or n:find("knife") then return true end
            end
        end
    end
    return false
end

local function findMurderer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and playerHasTool(player, "Knife") then
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and hum.RootPart then
                    return player
                end
            end
        end
    end
    return nil
end

-- ── Fling (piledriver — pure downward kill) ─────────────────────────────
local FLING_FPDH_DEFAULT   = -500  -- sane fallback if the stored height was lost/NaN
local FLING_HARD_CAP       = 10    -- absolute max seconds to spend on one fling
local FLING_PROGRESS_CHECK = 4     -- if the target still isn't dead after this many seconds it's
                                   -- likely an anti-fling autofarmer — give up (don't waste the round)
local LOBBY_FLING_DELAY    = 5     -- wait this long out-of-round before lobby-flinging, so we
                                   -- don't fling a round that's just starting for us

-- murderers the fling couldn't kill (AFK autofarmers) get parked here for a bit so we
-- back off instead of endlessly re-flinging them
local murdererFlingBlacklist = {}
local function murdererBlacklisted(p)
    local exp = murdererFlingBlacklist[p]
    if not exp then return false end
    if os.clock() > exp then murdererFlingBlacklist[p] = nil return false end
    return true
end

local function flingPlayer(targetPlayer)
    if flinging then return false end   -- re-entrancy guard: one fling at a time
    local char, hrp, hum = getChar()
    if not char or not hrp or not hum then return false end

    local tChar = targetPlayer.Character
    if not tChar then return false end
    local tHum  = tChar:FindFirstChildOfClass("Humanoid")
    local tRoot = tHum and tHum.RootPart
    local tHead = tChar:FindFirstChild("Head")
    local tHandle
    local acc = tChar:FindFirstChildOfClass("Accessory")
    if acc then tHandle = acc:FindFirstChild("Handle") end

    if not tRoot and not tHead and not tHandle then return false end
    if tHum and tHum.Sit then return false end

    flinging = true
    StatusText = "Flinging murderer: " .. targetPlayer.Name .. "..."

    local oldCFrame = hrp.CFrame
    local oldFPDH   = workspace.FallenPartsDestroyHeight
    if oldFPDH ~= oldFPDH then oldFPDH = FLING_FPDH_DEFAULT end  -- NaN guard (prev crashed fling)
    local bv

    -- guaranteed cleanup — runs no matter how the fling ends (success, our death, or error)
    local function cleanup()
        pcall(function() if bv then bv:Destroy() end end)
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end)
        pcall(function()
            local _, _, myHum = getChar()
            if myHum then workspace.CurrentCamera.CameraSubject = myHum end
        end)
        pcall(function() workspace.FallenPartsDestroyHeight = oldFPDH end)
        flinging = false
    end

    local function localAlive()
        local c = LocalPlayer.Character
        if not c then return false end
        local h = c:FindFirstChildOfClass("Humanoid")
        local r = c:FindFirstChild("HumanoidRootPart")
        return (h and r and h.Health > 0) and true or false
    end

    local killed = false
    pcall(function()
        -- NaN via a runtime expression (inf - inf), NOT the literal 0/0. Obfuscators
        -- constant-fold 0/0 and can't store the NaN result, which silently corrupts
        -- this line and breaks the fling. math.huge is a runtime lookup they can't fold.
        workspace.FallenPartsDestroyHeight = math.huge - math.huge

        bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent   = hrp

        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        workspace.CurrentCamera.CameraSubject = tHead or tHum or tHandle

        -- Lead a MOVING target by its own velocity. Without this, a running murderer
        -- slips out from under the piledrive: by the time our teleport reaches the server
        -- (one ping later) they've already moved, so on the server we land where they WERE
        -- and never overlap them → no launch. Leading puts us where they're GOING, so the
        -- server's physics solver actually catches them. ~0.09s ≈ a step of network lead.
        local FLING_LEAD = 0.09
        local function positionOn(basePart, yOff)
            if not basePart or not basePart.Parent then return end
            local p = basePart.Position
            local ok, vel = pcall(function() return basePart.AssemblyLinearVelocity end)
            if ok and vel then
                -- lead horizontally only (their vertical velocity is noise here)
                p = p + Vector3.new(vel.X * FLING_LEAD, 0, vel.Z * FLING_LEAD)
            end
            local cf = CFrame.new(p.X, p.Y + yOff, p.Z)
            hrp.CFrame = cf
            pcall(function() char:SetPrimaryPartCFrame(cf) end)
            hrp.Velocity    = Vector3.new(0, -math.huge, 0)
            hrp.RotVelocity = Vector3.new(9e15, 9e15, 9e15)
        end

        -- Purely server-side kill detection: the target dies when the SERVER launches
        -- them out of the world (piledriver knockback → fall damage / void). Health and
        -- parent are authoritative; we never touch their position (that would only be a
        -- client-side illusion that snaps back).
        local function targetDead()
            if not tChar or not tChar.Parent then return true end
            if tHum and tHum.Health <= 0 then return true end
            local r = tHum and tHum.RootPart
            if r and r.Position.Y < -400 then return true end
            return false
        end

        -- Piledrive: ram our high-velocity root into the target so the SERVER'S physics
        -- solver launches them into the void. This is a legit server-side fling (we only
        -- move OUR own character). If the target still isn't dead after the progress check
        -- it's likely an anti-fling autofarmer — bail so we don't waste the round.
        local t0 = tick()
        repeat
            if not localAlive() then break end      -- we got stabbed — can't fling while dead
            if targetDead() then killed = true break end
            local bp = (tHum and tHum.RootPart) or tChar:FindFirstChild("Head") or tHandle
            if not bp then break end
            for _ = 1, 16 do
                positionOn(bp,  2)
                positionOn(bp,  0.1)
                positionOn(bp,  3)
                positionOn(bp, -0.1)
            end
            if (tick() - t0) >= FLING_PROGRESS_CHECK and not targetDead() then break end
            task.wait()
        until not Config.FlingMurderer or (tick() - t0 >= FLING_HARD_CAP)
        if targetDead() then killed = true end

        -- return to start, but only if we're still alive, and with a timeout so it can't hang
        if localAlive() and oldCFrame then
            local rt0 = tick()
            repeat
                hrp.CFrame = oldCFrame * CFrame.new(0, 0.5, 0)
                pcall(function() char:SetPrimaryPartCFrame(oldCFrame * CFrame.new(0, 0.5, 0)) end)
                pcall(function() hum:ChangeState("GettingUp") end)
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Velocity    = Vector3.new()
                        part.RotVelocity = Vector3.new()
                    end
                end
                task.wait()
            until (hrp.Position - oldCFrame.Position).Magnitude < 25 or (tick() - rt0 > 3)
        end
    end)

    if killed then Stats.murderersFlung = Stats.murderersFlung + 1 end
    cleanup()
    return killed
end

-- ── Server hop ───────────────────────────────────────────────────────────
-- Hops to a fresh public server when a match can't start (too few players /
-- stuck in the lobby). Needs the executor's auto-execute so the farm resumes
-- after landing — we set the autostart flag before teleporting.
local function serverHop()
    if hopping then return end
    hopping = true
    Stats.serverHops = Stats.serverHops + 1
    setAutostart(true)
    StatusText = "Server hopping — no match could start..."

    local function httpGet(u)
        local body
        pcall(function() body = game:HttpGet(u) end)
        if not body then pcall(function() body = game:HttpGetAsync(u) end) end
        return body
    end

    local hopped = false
    pcall(function()
        local cursor = ""
        for _ = 1, 5 do
            local url = string.format(
                "https://games.roblox.com/v1/games/%d/servers/Public?limit=100&cursor=%s",
                PLACE_ID, cursor)
            local body = httpGet(url)
            if not body then break end
            local data = HttpService:JSONDecode(body)
            local servers = data and data.data
            if servers then
                -- shuffle so instances don't all pile into the same server
                for i = #servers, 2, -1 do
                    local j = math.random(i)
                    servers[i], servers[j] = servers[j], servers[i]
                end
                for _, s in ipairs(servers) do
                    if s.id and s.id ~= game.JobId and s.playing and s.maxPlayers
                       and s.playing < s.maxPlayers then
                        TeleportService:TeleportToPlaceInstance(PLACE_ID, s.id, LocalPlayer)
                        hopped = true
                        return
                    end
                end
            end
            if data and data.nextPageCursor then cursor = data.nextPageCursor else break end
        end
    end)

    if not hopped then
        pcall(function() TeleportService:Teleport(PLACE_ID, LocalPlayer) end)
    end
    task.wait(6)   -- give the teleport time to fire before the loop retries
    hopping = false
end

-- ── Reset ───────────────────────────────────────────────────────────────
local function resetCharacter()
    -- the persistent guard handles murderer flinging; here we just reset.
    StatusText = "Bag full — resetting..."
    stopNoclip()
    local _, _, hum = getChar()
    if hum then
        hum.Health = 0
    else
        pcall(function() LocalPlayer.Character:BreakJoints() end)
    end
    LocalPlayer.CharacterAdded:Wait()
    task.wait(1.5)
end

-- Auto Fling is triggered from the farm loop when the bag fills — so you farm
-- your coins first, THEN the murderer gets flung. No always-on guard.
local function setFling(on)
    Config.FlingMurderer = on
end

-- ── Farm loop ───────────────────────────────────────────────────────────
local function farmLoop()
    -- The game doesn't reset FullBagIcon / the count label the instant a new round
    -- starts, so at round start they can still read "full" from last round and cause
    -- an instant fling. We only ARM the full-trigger after we've actually observed a
    -- genuinely non-full, low bag this round. `bagReady` resets between rounds.
    local bagReady = false
    local outSince = nil   -- os.clock() when we became out-of-round
    local aliveWas = false   -- tracks alive->respawn transitions
    local deadSince = nil    -- os.clock() when we became a spectator (Alive=false)
    local spectateFlung = false -- one lobby fling per spectate period (reset on respawn)
    while Config.Enabled do
        -- Track alive transitions. On (re)spawn, restart the out-of-round clock so the
        -- auto-hop timer doesn't count spectate time against a round that just started,
        -- and re-arm the lobby fling. deadSince tracks spectate duration for the settle.
        local aliveNow = playerAlive()
        if aliveNow then
            if not aliveWas then outSince = os.clock() end
            deadSince = nil
            spectateFlung = false
        else
            deadSince = deadSince or os.clock()
        end
        aliveWas = aliveNow

        if not isInGame() then
            stopNoclip()
            bagReady = false
            outSince = outSince or os.clock()
            -- Auto server-hop: stuck out-of-round too long (match can't start).
            if Config.AutoHop and not flinging and (os.clock() - outSince) >= Config.HopStuck then
                serverHop()
                outSince = os.clock()
            -- Lobby fling: end a round we're SPECTATING (Alive=false) so we don't wait it
            -- out. Gated on `not playerAlive()` so it can NEVER fire once our own round has
            -- started (that was the round-start self-fling bug). Small settle after we start
            -- spectating so we don't fling during a brief between-rounds intermission.
            elseif Config.FlingMurderer and not flinging and not aliveNow and not spectateFlung
               and getChar() and deadSince and (os.clock() - deadSince) >= LOBBY_FLING_DELAY then
                local murderer = findMurderer()
                if murderer and not murdererBlacklisted(murderer) then
                    StatusText = "Spectating — flinging murderer to end the round..."
                    spectateFlung = true   -- only one attempt per spectate period
                    local killed = flingPlayer(murderer)
                    if not killed then
                        murdererFlingBlacklist[murderer] = os.clock() + 12
                        StatusText = "Murderer resists fling — backing off..."
                    end
                    task.wait(0.5)
                else
                    StatusText = "Spectating — waiting for a murderer to fling..."
                    task.wait(0.5)
                end
            else
                StatusText = "Not in a round — waiting for coin bag UI..."
                task.wait(0.4)
            end
        else
            outSince = nil
            local _, hrp = getChar()
            if not hrp then
                StatusText = "In round, waiting to spawn..."
                task.wait(0.3)
            elseif flinging then
                -- pause farming while a fling is happening so we don't fight the HRP
                StatusText = "Murderer fling in progress..."
                task.wait(0.2)
            else
                if Config.Noclip then startNoclip() end
                local count = bagCount()
                local full  = bagFull()

                -- arm only once the bag is confirmed genuinely empty/low this round
                if not bagReady and not full and count < Config.BagLimit then
                    bagReady = true
                end

                if bagReady and (full or count >= Config.BagLimit) then
                    Stats.bagsFilled = Stats.bagsFilled + 1
                    -- bag is genuinely full (coins collected) — NOW deal with the murderer, then reset
                    if Config.FlingMurderer then
                        local murderer = findMurderer()
                        if murderer and not murdererBlacklisted(murderer) then
                            stopNoclip()
                            StatusText = "Bag full — flinging murderer..."
                            local killed = flingPlayer(murderer)
                            if not killed then murdererFlingBlacklist[murderer] = os.clock() + 12 end
                        end
                    end
                    if Config.AutoReset then
                        resetCharacter()
                        bagReady = false            -- re-arm freshly after the reset
                    else
                        StatusText = string.format("Bag full (%d/%d) — idle", count, Config.BagLimit)
                        task.wait(0.5)
                    end
                else
                    -- murderer avoidance: find where the killer is so we can prefer coins
                    -- away from them (cheap: one scan per coin pick, only ~players * tools)
                    local avoidPos
                    do
                        local m = findMurderer()
                        local mc = m and m.Character
                        local mhrp = mc and mc:FindFirstChild("HumanoidRootPart")
                        if mhrp then avoidPos = mhrp.Position end
                    end
                    local coin = nearestCoin(hrp.Position, avoidPos)
                    if coin then
                        StatusText = string.format("Farming%s — bag %d/%d",
                            bagReady and "" or " (arming)", count, Config.BagLimit)
                        tweenToCoin(coin)
                    else
                        StatusText = string.format("No coins in reach — bag %d/%d", count, Config.BagLimit)
                        task.wait(0.4)
                    end
                end
            end
        end
    end
    stopNoclip()
    StatusText = "Idle."
end

local function setFarm(on)
    Config.Enabled = on
    if on then
        if Config.Noclip then startNoclip() end
        if not farmThread then
            farmThread = task.spawn(function()
                farmLoop()
                farmThread = nil
            end)
        end
    else
        stopNoclip()
    end
end

-- ── Performance: disable 3D rendering + custom acrylic overlay ───────────
-- Set3dRenderingEnabled(false) stops the 3D viewport (big CPU saving) but 2D
-- GUIs still draw — so instead of a black screen we paint a frosted-glass
-- translucent acrylic card with live stats. Press K anytime to turn it back on.
local scriptStart   = os.clock()
local renderDisabled = false
local overlayGui    = nil
local RenderToggle   -- forward-declared; assigned in the Performance tab below
local doSaveConfig   -- forward-declared; assigned once the config manager is ready (below)

local function fmtRuntime()
    local t = math.max(0, math.floor(os.clock() - scriptStart))
    return string.format("%02d:%02d:%02d", math.floor(t / 3600), math.floor((t % 3600) / 60), t % 60)
end

local function destroyOverlay()
    if overlayGui then pcall(function() overlayGui:Destroy() end) overlayGui = nil end
end

-- Chunky retro coin drawn from Frames (flat colours, hard edges — that low-quality
-- Mario-coin look that fits the Win7 vibe). Drawn, not an image asset, so it always
-- renders. Used by BOTH the Farming tab and the 3D-render-off screen.
local function drawCoin(parent, px)
    px = px or 16
    local holder = Instance.new("Frame")
    holder.Name = "CoinIcon"
    holder.BackgroundTransparency = 1
    holder.Size = UDim2.fromOffset(px, px)
    holder.ZIndex = (parent.ZIndex or 1) + 1   -- sit above whatever we're placed on
    holder.Parent = parent

    local disc = Instance.new("Frame")           -- gold body
    disc.Size = UDim2.fromScale(1, 1)
    disc.BackgroundColor3 = Color3.fromRGB(240, 185, 40)
    disc.BorderSizePixel = 0
    disc.ZIndex = holder.ZIndex
    disc.Parent = holder
    Instance.new("UICorner", disc).CornerRadius = UDim.new(1, 0)
    local rim = Instance.new("UIStroke", disc)   -- dark outline
    rim.Color = Color3.fromRGB(146, 96, 8)
    rim.Thickness = 1

    local inner = Instance.new("Frame")          -- lighter inner face
    inner.AnchorPoint = Vector2.new(0.5, 0.5)
    inner.Position = UDim2.fromScale(0.5, 0.5)
    inner.Size = UDim2.fromScale(0.56, 0.72)
    inner.BackgroundColor3 = Color3.fromRGB(255, 226, 120)
    inner.BorderSizePixel = 0
    inner.ZIndex = holder.ZIndex + 1
    inner.Parent = disc
    Instance.new("UICorner", inner).CornerRadius = UDim.new(1, 0)

    return holder
end

local function buildOverlay()
    destroyOverlay()
    local gui = Instance.new("ScreenGui")
    gui.Name = "SH_RenderOverlay"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 100000
    local usedGethui = false
    pcall(function() gui.Parent = gethui() end)
    if gui.Parent then usedGethui = true end
    if not gui.Parent then pcall(function() gui.Parent = game:GetService("CoreGui") end) end
    if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- simple dark backdrop (hides the 3D world — that's the whole point)
    local bg = Instance.new("Frame")
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundColor3 = Color3.fromRGB(24, 27, 33)
    bg.BorderSizePixel = 0
    bg.Parent = gui
    local bgGrad = Instance.new("UIGradient", bg)
    bgGrad.Rotation = 90
    bgGrad.Color = ColorSequence.new(Color3.fromRGB(36, 41, 51), Color3.fromRGB(17, 19, 24))

    -- a clean Windows 7 window in the middle
    local card = Instance.new("Frame")
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.fromScale(0.5, 0.5)
    card.Size = UDim2.fromOffset(440, 248)
    card.BackgroundColor3 = Color3.fromRGB(32, 36, 44)
    card.BorderSizePixel = 0
    card.Parent = bg
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
    local cStroke = Instance.new("UIStroke", card)
    cStroke.Color = Color3.fromRGB(90, 120, 155); cStroke.Thickness = 1
    local cGlow = Instance.new("UIStroke", card)
    cGlow.Color = Color3.fromRGB(255, 255, 255); cGlow.Thickness = 1; cGlow.Transparency = 0.6

    -- Aero glass title bar
    local title = Instance.new("Frame")
    title.Size = UDim2.new(1, 0, 0, 34)
    title.BackgroundColor3 = Color3.fromRGB(52, 84, 124)
    title.BorderSizePixel = 0
    title.Parent = card
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 6)
    local tGrad = Instance.new("UIGradient", title)
    tGrad.Rotation = 90
    tGrad.Color = ColorSequence.new(Color3.fromRGB(74, 112, 156), Color3.fromRGB(40, 72, 112))
    local tCover = Instance.new("Frame")   -- square off the title's rounded bottom
    tCover.BackgroundColor3 = Color3.fromRGB(40, 72, 112); tCover.BorderSizePixel = 0
    tCover.Size = UDim2.new(1, 0, 0, 8); tCover.Position = UDim2.new(0, 0, 1, -8); tCover.Parent = title
    local tGloss = Instance.new("Frame")   -- upper Aero gloss
    tGloss.BackgroundColor3 = Color3.fromRGB(255, 255, 255); tGloss.BackgroundTransparency = 0.82
    tGloss.BorderSizePixel = 0; tGloss.Size = UDim2.new(1, 0, 0.5, 0); tGloss.Parent = title
    local tShine = Instance.new("Frame")   -- top specular line
    tShine.BackgroundColor3 = Color3.fromRGB(255, 255, 255); tShine.BackgroundTransparency = 0.35
    tShine.BorderSizePixel = 0; tShine.Size = UDim2.new(1, -12, 0, 1); tShine.Position = UDim2.new(0, 6, 0, 2)
    tShine.ZIndex = 2; tShine.Parent = title
    local titleTxt = Instance.new("TextLabel")
    titleTxt.BackgroundTransparency = 1
    titleTxt.Position = UDim2.new(0, 12, 0, 0); titleTxt.Size = UDim2.new(1, -20, 1, 0)
    titleTxt.Font = Enum.Font.SourceSansBold; titleTxt.TextSize = 16
    titleTxt.TextColor3 = Color3.fromRGB(236, 244, 252)
    titleTxt.TextXAlignment = Enum.TextXAlignment.Left; titleTxt.ZIndex = 3
    titleTxt.Text = "Coin Farm"; titleTxt.Parent = title

    -- body
    local pad = Instance.new("Frame")
    pad.BackgroundTransparency = 1
    pad.Position = UDim2.new(0, 20, 0, 46); pad.Size = UDim2.new(1, -40, 1, -58)
    pad.Parent = card
    local list = Instance.new("UIListLayout", pad)
    list.SortOrder = Enum.SortOrder.LayoutOrder; list.Padding = UDim.new(0, 7)

    local function mk(text, size, color, order, font)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Size = UDim2.new(1, 0, 0, size + 6)
        l.Font = font or Enum.Font.SourceSans
        l.TextSize = size
        l.TextColor3 = color or Color3.fromRGB(220, 226, 234)
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Text = text; l.LayoutOrder = order; l.Parent = pad
        return l
    end

    mk("3D rendering is off - farming in the background", 14, Color3.fromRGB(150, 168, 190), 1)
    local coinRow = Instance.new("Frame")
    coinRow.BackgroundTransparency = 1; coinRow.Size = UDim2.new(1, 0, 0, 26)
    coinRow.LayoutOrder = 2; coinRow.Parent = pad
    local coinImg = drawCoin(coinRow, 22)
    coinImg.AnchorPoint = Vector2.new(0, 0.5)
    coinImg.Position = UDim2.new(0, 0, 0.5, 0)
    local coinsL = Instance.new("TextLabel")
    coinsL.BackgroundTransparency = 1; coinsL.Position = UDim2.new(0, 30, 0, 0); coinsL.Size = UDim2.new(1, -30, 1, 0)
    coinsL.Font = Enum.Font.SourceSansBold; coinsL.TextSize = 18; coinsL.TextColor3 = Color3.fromRGB(255, 214, 90)
    coinsL.TextXAlignment = Enum.TextXAlignment.Left; coinsL.Text = "Coins: -"; coinsL.Parent = coinRow

    local bagL    = mk("Bag: -",             15, nil,                          3)
    local statusL = mk("Status: -",          14, Color3.fromRGB(190, 198, 208), 4)
    local runL    = mk("Runtime: 00:00:00",  14, Color3.fromRGB(190, 198, 208), 5)
    mk("Press Ctrl + K to restore rendering", 13, Color3.fromRGB(120, 165, 220), 6)

    overlayGui = gui

    task.spawn(function()
        while gui.Parent and renderDisabled do
            -- Float the SimplUI window (and other exploit GUIs in the same hidden
            -- container) ABOVE the overlay, so you can still open Settings → Save
            -- Config while 3D is disabled. Only done when we're in gethui, so we
            -- never touch Roblox's core UI.
            if usedGethui and gui.Parent then
                pcall(function()
                    for _, sg in ipairs(gui.Parent:GetChildren()) do
                        if sg:IsA("ScreenGui") and sg ~= gui and sg.DisplayOrder <= gui.DisplayOrder then
                            sg.DisplayOrder = gui.DisplayOrder + 5
                        end
                    end
                end)
            end
            local bal = getCoinBalance()
            coinsL.Text  = "Coins: " .. (bal and commafy(bal) or "-")
            bagL.Text    = string.format("Bag: %d / %d", bagCount(), Config.BagLimit)
            statusL.Text = "Status: " .. StatusText
            runL.Text    = "Runtime: " .. fmtRuntime()
            task.wait(0.5)
        end
    end)
end

local function setRender(disable)
    renderDisabled = disable
    pcall(function() RunService:Set3dRenderingEnabled(not disable) end)
    if disable then buildOverlay() else destroyOverlay() end
end

-- Low FPS cap (extra CPU savings) — uses the executor's setfpscap
local function setLowFps(on)
    Config.LowFps = on
    pcall(function()
        if setfpscap then setfpscap(on and 15 or 0) end  -- 0 = uncapped/back to normal
    end)
end

-- ── Godly drop alerts (via the Discord bot) ──────────────────────────────
-- When you unbox a Godly, we POST a small event to the bot (keyed by your link code);
-- the bot then DMs YOU (or posts to a channel you chose with /alerts) with the weapon's
-- image — chroma godlies get a rainbow embed. No webhook to paste: just link your
-- account in the Stats tab. The bot resolves the image, so we only send the asset id.
local godlyAlertsEnabled = true

local function sendGodlyEvent(reward, isTest)
    if not (discordToken and #discordToken > 0) then return false end
    if not (STATS_ENDPOINT:match("^https?://") and not STATS_ENDPOINT:find("your%-bot")) then return false end
    local fn = getRequestFn()
    if not fn then return false end
    local w = SyncWeapons and SyncWeapons[reward]
    local imgId
    if w and w.Image then imgId = tostring(w.Image):match("assetId=(%d+)") end
    if not imgId and w and w.ItemID then imgId = tostring(w.ItemID) end
    local isChroma = w and ((w.Chroma == true) or (tostring(reward):find("Chroma") ~= nil))
    local url = (STATS_ENDPOINT:gsub("/ingest%s*$", "/godly"))
    local ok = pcall(function()
        fn({ Url = url, Method = "POST",
            Headers = { ["Content-Type"] = "application/json", ["User-Agent"] = "MM2CoinFarm", ["bypass-tunnel-reminder"] = "true" },
            Body = HttpService:JSONEncode({
                token = discordToken, name = (w and w.Name) or reward, rarity = "Godly",
                chroma = isChroma and true or false, imageId = imgId, account = LocalPlayer.Name, test = isTest and true or false,
            }) })
    end)
    return ok
end

-- Called for every unbox reward; no-ops unless it's a godly and alerts are on.
local function sendGodlyAlert(reward)
    if not godlyAlertsEnabled then return end
    local w = SyncWeapons and SyncWeapons[reward]
    if not (w and w.Rarity == "Godly") then return end
    task.spawn(function() sendGodlyEvent(reward, false) end)
end

-- ── Auto Unbox (weapon crates) ───────────────────────────────────────────
-- MM2 opens a crate via ReplicatedStorage.Remotes.Shop.OpenCrate (a RemoteFunction):
--   OpenCrate:InvokeServer(crateName, "MysteryBox", payWith)  ->  reward item name (string)
-- The server deducts the currency and grants the item on the invoke itself; the
-- normal client BoxController:Fire() call is only the reveal animation, so we skip
-- it and just collect the returned reward. A falsy return means the server rejected
-- it (can't afford / restricted), which is how we detect "out of currency".
local WEAPON_CRATES = {
    "MysteryBox1", "MysteryBox2",
    "GunBox1", "GunBox2", "GunBox3",
    "KnifeBox1", "KnifeBox2", "KnifeBox3", "KnifeBox4", "KnifeBox5",
    "MLG Box",
}
-- Shop thumbnail asset IDs (pulled live from the game's shop item frames).
local CRATE_ICONS = {
    MysteryBox1 = "rbxassetid://3060009986", MysteryBox2 = "rbxassetid://4659688870",
    GunBox1 = "rbxassetid://3180973254", GunBox2 = "rbxassetid://3180973441", GunBox3 = "rbxassetid://3180973740",
    KnifeBox1 = "rbxassetid://3180967400", KnifeBox2 = "rbxassetid://3180968681", KnifeBox3 = "rbxassetid://3180969927",
    KnifeBox4 = "rbxassetid://3180970565", KnifeBox5 = "rbxassetid://3180971059",
    ["MLG Box"] = "rbxassetid://3180972343",
}
-- Display names (the crate id stays what the remote needs; only the label changes).
local CRATE_LABELS = { ["MLG Box"] = "Rainbow Box" }
local function crateLabel(id) return CRATE_LABELS[id] or id end
local UNBOX_PAY_OPTIONS = { "Coins", "Gems", "Key" }
local UNBOX_DELAY = 0.15   -- pace between opens when the animation is hidden
local UNBOX_ANIM_WAIT = 4.2  -- pace between opens when the reveal animation is shown (its length)

local UnboxCfg = {
    Crates   = {},        -- set: { [crateName] = true }
    PayWith  = "Coins",   -- "Coins" | "Gems" | "Key"
    Amount   = 10,        -- target boxes to open per run; 0 = unlimited (until stopped / broke)
    HideAnim = true,      -- skip the reveal animation (fast); false = play it like a normal open
}

-- Replays the reveal animation for one opened crate by firing the game's own
-- BoxController exactly like the shop does (MysteryBoxService consumes it).
local function fireBoxAnimation(crateName, reward)
    pcall(function()
        local rem = ReplicatedStorage:FindFirstChild("Remotes")
        rem = rem and rem:FindFirstChild("Shop")
        rem = rem and rem:FindFirstChild("BoxController")
        if rem then
            rem:Fire({ { MysteryBoxId = crateName, RewardedItemId = reward } })
        end
    end)
end

local unboxing      = false
local unboxStop     = false
local UnboxStatus   = "Idle."
local unboxOpened   = 0            -- opened this run
local unboxLast     = nil          -- last reward name
local unboxSession  = 0            -- total opened this session
local UnboxToggle              -- forward-declared; assigned in the Unboxing tab
local FarmToggle              -- forward-declared; assigned in the Farming tab (so Discord /farm can sync it)
local handleUnboxedReward     -- forward-declared; set by the Trading backend (auto-mule)

local function openCrateRemote()
    local rem = ReplicatedStorage:FindFirstChild("Remotes")
    rem = rem and rem:FindFirstChild("Shop")
    rem = rem and rem:FindFirstChild("OpenCrate")
    if rem and rem:IsA("RemoteFunction") then return rem end
    return nil
end

-- Opens one crate. Returns the reward item name, or nil on failure.
local function openOneCrate(crateName, payWith)
    local remote = openCrateRemote()
    if not remote then return nil end
    local ok, reward = pcall(function()
        return remote:InvokeServer(crateName, "MysteryBox", payWith)
    end)
    if ok and reward and reward ~= false then return reward end
    return nil
end

local function selectedCrateList()
    local list = {}
    for _, name in ipairs(WEAPON_CRATES) do
        if UnboxCfg.Crates[name] then list[#list + 1] = name end
    end
    return list
end

-- Round-robins through the selected crates, opening until the target Amount is hit,
-- the user stops it, or the server rejects several in a row (out of currency).
local function unboxLoop()
    local crates = selectedCrateList()
    if #crates == 0 then
        UnboxStatus = "No crates selected."
        unboxing = false
        return
    end
    local target = math.max(0, math.floor(tonumber(UnboxCfg.Amount) or 0))
    unboxOpened = 0
    local fails, idx = 0, 1
    while unboxing and not unboxStop and (target == 0 or unboxOpened < target) do
        local crate = crates[idx]
        idx = (idx % #crates) + 1
        local reward = openOneCrate(crate, UnboxCfg.PayWith)
        if reward then
            fails = 0
            unboxOpened  += 1
            unboxSession += 1
            unboxLast = tostring(reward)
            UnboxStatus = string.format("Unboxing %d%s — %s: %s",
                unboxOpened, target > 0 and ("/" .. target) or "", crateLabel(crate), unboxLast)
            sendGodlyAlert(reward)                                       -- Discord DM on godly
            if handleUnboxedReward then handleUnboxedReward(reward) end  -- auto-mule on godly
            if not UnboxCfg.HideAnim then
                fireBoxAnimation(crate, reward)
                task.wait(UNBOX_ANIM_WAIT)   -- let the reveal play before the next open
            else
                task.wait(UNBOX_DELAY)
            end
        else
            fails += 1
            UnboxStatus = string.format("%s rejected (can't afford / restricted)...", crateLabel(crate))
            if fails >= 3 then
                UnboxStatus = string.format("Stopped — out of %s (opened %d). Last: %s",
                    UnboxCfg.PayWith, unboxOpened, unboxLast or "-")
                break
            end
            task.wait(UNBOX_DELAY)
        end
    end
    if unboxOpened > 0 and fails < 3 then
        UnboxStatus = string.format("Done — opened %d box%s. Last: %s",
            unboxOpened, unboxOpened == 1 and "" or "es", unboxLast or "-")
    end
    unboxing  = false
    unboxStop = false
    -- flip the UI toggle back off so it reflects the finished run
    if UnboxToggle then pcall(function() UnboxToggle:Set(false) end) end
end

-- Returns false (and sets a status) if it couldn't start, so the toggle can revert.
local function setUnbox(on)
    if on then
        if unboxing then return true end
        if not openCrateRemote() then
            UnboxStatus = "Unbox remote not found (wrong game?)."
            return false
        end
        if #selectedCrateList() == 0 then
            UnboxStatus = "Select at least one crate first."
            return false
        end
        unboxing, unboxStop = true, false
        task.spawn(unboxLoop)
        return true
    else
        unboxStop = true
        unboxing  = false
        return true
    end
end

-- ── Trading (auto-mule + manual trades) ──────────────────────────────────
-- MM2 trade flow (from the game's own TradeModule):
--   Trade.SendRequest:InvokeServer(player)        -> ask to trade
--   Trade.AcceptRequest:FireServer()              -> accept an incoming request
--   Trade.StartTrade.OnClientEvent(offer, name)   -> the trade window opened
--   Trade.OfferItem:FireServer(itemId,"Weapons")  -> put an item in your offer
--   Trade.UpdateTrade.OnClientEvent(state)        -> offer changed; state.LastOffer is
--                                                    the token AcceptTrade needs
--   Trade.AcceptTrade:FireServer(PlaceId*3, tok)  -> confirm (both sides must, same tok)
--   Trade.AcceptTrade.OnClientEvent(done, items)  -> done=false: other side accepted;
--                                                    done=true: trade completed
-- Caps: 4 items per trade, ~6s cooldown before you can confirm after the last offer.
local TradeRemotes = ReplicatedStorage:FindFirstChild("Trade")
-- SyncWeapons is required once up top (shared with the inventory upload).

local TRADE_CMD_DIR      = "SimplHub_MM2/tradecmds"
local TRADE_PENDING_FLAG = "SimplHub_MM2/pending_trade.txt"  -- holds a target name across a teleport
local TRADE_ITEMS_MAX    = 4
local TRADE_ACCEPT_WAIT  = 6.6   -- game enforces a 6s cooldown after the last offer change

local TradeCfg = {
    AutoMule       = false,   -- giver: when THIS acc unboxes a godly, mule it away
    MuleName       = "",      -- the receiving account's username
    GodliesOnly    = true,    -- trade only Godly weapons (off = every non-default weapon)
    AcceptFromAlts = false,   -- receiver/mule: auto-accept + confirm trades from your own alts
}

local TradeStatus = "Idle."
local tradeBusy   = false

local function isMuleRole()
    return TradeCfg.MuleName ~= "" and LocalPlayer.Name:lower() == TradeCfg.MuleName:lower()
end
local function isReceiverRole()
    return isMuleRole() or TradeCfg.AcceptFromAlts
end

local function isGodly(itemId)
    local w = SyncWeapons and SyncWeapons[itemId]
    return w ~= nil and w.Rarity == "Godly"
end

-- Flat list of weapon ids to trade (godlies only, or every non-default weapon),
-- expanded by how many of each you own. Never includes the default knife/gun.
local function itemsToTrade()
    local list, owned = {}, nil
    pcall(function() owned = require(ReplicatedStorage.Modules.ProfileData).Weapons.Owned end)
    if type(owned) ~= "table" then return list end
    for id, count in pairs(owned) do
        local n = tonumber(count) or 0
        if n > 0 and id ~= "DefaultKnife" and id ~= "DefaultGun"
           and (not TradeCfg.GodliesOnly or isGodly(id)) then
            for _ = 1, n do list[#list + 1] = id end
        end
    end
    return list
end

local function ownedGodlyCount()
    local owned, n = nil, 0
    pcall(function() owned = require(ReplicatedStorage.Modules.ProfileData).Weapons.Owned end)
    if type(owned) == "table" then
        for id, c in pairs(owned) do if isGodly(id) then n += (tonumber(c) or 0) end end
    end
    return n
end

local function playerByName(name)
    if not name or name == "" then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower() == name:lower() then return p end
    end
    return nil
end

local function findClientJob(name)
    for _, c in ipairs(readClients()) do
        if c.name and c.name:lower() == name:lower() then return c.jobId end
    end
    return nil
end

-- Live trade session state, driven by the game's own remotes.
local latestLastOffer   = nil
local inTradeWith       = nil
local tradeCompleted    = false

if TradeRemotes then
    pcall(function()
        TradeRemotes.UpdateTrade.OnClientEvent:Connect(function(p)
            if type(p) == "table" then latestLastOffer = p.LastOffer end
        end)
        TradeRemotes.StartTrade.OnClientEvent:Connect(function(_, otherName)
            inTradeWith, tradeCompleted = otherName, false
        end)
        TradeRemotes.AcceptTrade.OnClientEvent:Connect(function(done)
            if done then
                tradeCompleted, inTradeWith = true, nil
            elseif isReceiverRole() and inTradeWith and latestLastOffer ~= nil then
                -- the other side (our alt) accepted; as the mule, confirm to finish
                pcall(function() TradeRemotes.AcceptTrade:FireServer(game.PlaceId * 3, latestLastOffer) end)
            end
        end)
        TradeRemotes.DeclineTrade.OnClientEvent:Connect(function() inTradeWith = nil end)
        TradeRemotes.EndTrade.OnClientEvent:Connect(function() inTradeWith = nil end)
        -- receiver: auto-accept trade requests, but ONLY from your own alts (the accounts
        -- heartbeating into the shared clients folder), never from random players.
        TradeRemotes.RequestSent.OnClientEvent:Connect(function(sender)
            if not isReceiverRole() then return end
            local sName = (type(sender) == "table" and sender.Name) or tostring(sender)
            for _, c in ipairs(readClients()) do
                if c.name == sName then
                    pcall(function() TradeRemotes.AcceptRequest:FireServer() end)
                    break
                end
            end
        end)
    end)
end

-- Offer up to 4 items into an already-open trade, wait out the cooldown, then confirm.
local function offerAndConfirm(chunk)
    for _, id in ipairs(chunk) do
        pcall(function() TradeRemotes.OfferItem:FireServer(id, "Weapons") end)
        task.wait(0.35)
    end
    task.wait(TRADE_ACCEPT_WAIT)
    tradeCompleted = false
    pcall(function() TradeRemotes.AcceptTrade:FireServer(game.PlaceId * 3, latestLastOffer) end)
    local t0 = os.clock()
    while not tradeCompleted and (os.clock() - t0) < 15 do task.wait(0.2) end
    return tradeCompleted
end

local function ownedCounts()
    local owned
    pcall(function() owned = require(ReplicatedStorage.Modules.ProfileData).Weapons.Owned end)
    return type(owned) == "table" and owned or {}
end

-- Giver flow: request → offer up to 4 → confirm, looped until everything's sent.
-- itemIds = a specific list of weapon ids to send (from Discord /trade); nil = every
-- godly / whole inventory per the GodliesOnly setting. Ownership is re-checked each round.
local function tradeItemsTo(targetPlayer, itemIds)
    if tradeBusy then return false, "already trading" end
    if not TradeRemotes then return false, "trade remotes missing (wrong game?)" end
    if not targetPlayer then return false, "target player not in this server" end
    tradeBusy = true
    local remaining = itemIds and { table.unpack(itemIds) } or nil
    local ok, err = pcall(function()
        for _ = 1, 60 do                     -- hard cap on rounds
            local queue = {}
            if remaining then
                local avail = {}
                for id, c in pairs(ownedCounts()) do avail[id] = tonumber(c) or 0 end
                for _, id in ipairs(remaining) do
                    if id ~= "DefaultKnife" and id ~= "DefaultGun" and (avail[id] or 0) > 0 then
                        queue[#queue + 1] = id
                        avail[id] = avail[id] - 1
                        if #queue >= TRADE_ITEMS_MAX then break end
                    end
                end
            else
                for _, id in ipairs(itemsToTrade()) do
                    queue[#queue + 1] = id
                    if #queue >= TRADE_ITEMS_MAX then break end
                end
            end
            if #queue == 0 then break end
            TradeStatus = "Requesting trade with " .. targetPlayer.Name .. "..."
            inTradeWith, tradeCompleted = nil, false
            pcall(function() TradeRemotes.SendRequest:InvokeServer(targetPlayer) end)
            local t0 = os.clock()
            while not inTradeWith and (os.clock() - t0) < 12 do task.wait(0.2) end
            if not inTradeWith then error("they didn't accept / not in your server") end
            TradeStatus = string.format("Sending %d item(s) to %s...", #queue, targetPlayer.Name)
            if not offerAndConfirm(queue) then error("trade didn't complete") end
            -- for a fixed list, drop the ids we just sent so we don't re-send them
            if remaining then
                local sent = {}
                for _, id in ipairs(queue) do sent[id] = (sent[id] or 0) + 1 end
                local rest = {}
                for _, id in ipairs(remaining) do
                    if sent[id] and sent[id] > 0 then sent[id] = sent[id] - 1
                    else rest[#rest + 1] = id end
                end
                remaining = rest
                if #remaining == 0 then break end
            end
            task.wait(1.5)   -- let inventory replicate before the next round
        end
    end)
    tradeBusy = false
    TradeStatus = ok and ("Done — sent to " .. targetPlayer.Name .. ".")
                      or ("Stopped: " .. tostring(err))
    return ok, err
end

local function tradeAllTo(targetPlayer) return tradeItemsTo(targetPlayer, nil) end

-- Trade to a target name: directly if they're here, otherwise hop to their server
-- (found via the shared client heartbeat) and resume after landing. itemIds optional.
local function tradeToName(name, itemIds)
    if isMuleRole() then return end          -- the mule never trades to itself
    if not name or name == "" then TradeStatus = "No target set."; return end
    local target = playerByName(name)
    if target then
        tradeItemsTo(target, itemIds)
        return
    end
    local job = findClientJob(name)
    if job and job ~= "local" and job ~= game.JobId then
        TradeStatus = "Joining " .. name .. "'s server to trade..."
        pcall(function()
            if not isfolder("SimplHub_MM2") then makefolder("SimplHub_MM2") end
            writefile(TRADE_PENDING_FLAG, HttpService:JSONEncode({ target = name, items = itemIds }))
        end)
        pcall(function() TeleportService:TeleportToPlaceInstance(PLACE_ID, job, LocalPlayer) end)
    else
        TradeStatus = name .. " isn't in your server and isn't a running instance."
    end
end

local function tradeToMuleNow()
    if TradeCfg.MuleName == "" then TradeStatus = "Enter the mule's username first."; return end
    task.spawn(function() tradeToName(TradeCfg.MuleName) end)
end

-- Auto-mule: fires from the unbox loop when a godly drops.
handleUnboxedReward = function(reward)
    if TradeCfg.AutoMule and not isMuleRole() and isGodly(reward) then
        TradeStatus = "Godly unboxed (" .. tostring(reward) .. ") — muling to " .. TradeCfg.MuleName .. "..."
        setUnbox(false)
        setFarm(false)
        task.spawn(function() tradeToName(TradeCfg.MuleName) end)
    end
end

-- Resume a pending trade after a teleport-to-server (auto-mule / trade-to-player).
task.spawn(function()
    task.wait(4)
    local raw
    pcall(function() if isfile(TRADE_PENDING_FLAG) then raw = readfile(TRADE_PENDING_FLAG) end end)
    if raw and #raw > 0 then
        pcall(function() delfile(TRADE_PENDING_FLAG) end)
        local targetName, itemIds = raw, nil
        local okj, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
        if okj and type(decoded) == "table" and decoded.target then
            targetName, itemIds = decoded.target, decoded.items
        end
        if targetName and #targetName > 0 and LocalPlayer.Name:lower() ~= targetName:lower() then
            local target, t0 = playerByName(targetName), os.clock()
            while not target and (os.clock() - t0) < 20 do task.wait(1); target = playerByName(targetName) end
            if target then tradeItemsTo(target, itemIds) end
        end
    end
end)

-- Cross-instance command channel: one instance tells selected clients to trade their
-- godlies to a player (the "Trade to Player" feature). Commands are small json files in
-- a shared folder; every instance polls and runs the ones addressed to its own name.
local processedTradeCmds = {}
local function writeTradeCommand(targetName, clientNames)
    pcall(function()
        if not isfolder("SimplHub_MM2") then makefolder("SimplHub_MM2") end
        if not isfolder(TRADE_CMD_DIR) then makefolder(TRADE_CMD_DIR) end
        local id = tostring(os.time()) .. "-" .. tostring(math.random(10000, 99999))
        writefile(TRADE_CMD_DIR .. "/" .. id .. ".json",
            HttpService:JSONEncode({ id = id, action = "tradeAllTo", target = targetName, clients = clientNames, ts = os.time() }))
    end)
end

task.spawn(function()
    while hbCurrent() do
        pcall(function()
            if isfolder(TRADE_CMD_DIR) then
                for _, path in ipairs(listfiles(TRADE_CMD_DIR)) do
                    local ok, data = pcall(readfile, path)
                    if ok and type(data) == "string" then
                        local ok2, cmd = pcall(function() return HttpService:JSONDecode(data) end)
                        if ok2 and type(cmd) == "table" and cmd.id and not processedTradeCmds[cmd.id]
                           and cmd.ts and (os.time() - cmd.ts) <= 90 then
                            local mine = false
                            for _, n in ipairs(cmd.clients or {}) do
                                if tostring(n):lower() == LocalPlayer.Name:lower() then mine = true break end
                            end
                            if mine and cmd.action == "tradeAllTo" and cmd.target then
                                processedTradeCmds[cmd.id] = true
                                task.spawn(function()
                                    setUnbox(false); setFarm(false)
                                    tradeToName(cmd.target)
                                end)
                            end
                        end
                    end
                end
            end
        end)
        task.wait(2)
    end
end)

-- ── Discord bot command channel (pull) ───────────────────────────────────
-- Polls the bot for commands queued by slash commands (/serverhop, /trade, /join,
-- /farm, /unbox). Same link code + endpoint as the stats upload; /ingest -> /pull.
local processedRemoteCmds = {}

local function runRemoteCommand(cmd)
    if type(cmd) ~= "table" or not cmd.id or processedRemoteCmds[cmd.id] then return end
    -- only run commands addressed to this account (blank/"*" = broadcast to all)
    local acct = cmd.account
    if acct and acct ~= "" and acct ~= "*" and acct:lower() ~= LocalPlayer.Name:lower() then return end
    processedRemoteCmds[cmd.id] = true
    local a = cmd.action
    if a == "serverhop" then
        task.spawn(function() serverHop() end)
    elseif a == "farm" then
        -- drive the UI toggle so the on-screen checkbox stays in sync with the phone
        local on = cmd.on and true or false
        if FarmToggle then pcall(function() FarmToggle:Set(on) end)
        else setFarm(on); setAutostart(on) end
    elseif a == "unbox" then
        task.spawn(function()
            if cmd.amount ~= nil then UnboxCfg.Amount = tonumber(cmd.amount) or UnboxCfg.Amount end
            if type(cmd.crates) == "table" then
                UnboxCfg.Crates = {}
                for _, c in ipairs(cmd.crates) do UnboxCfg.Crates[c] = true end
            end
            if UnboxToggle then pcall(function() UnboxToggle:Set(true) end) else setUnbox(true) end
        end)
    elseif a == "join" then
        local job = cmd.jobId
        if (not job or job == "") and cmd.account2 then job = findClientJob(cmd.account2) end
        if job and job ~= "local" and job ~= game.JobId then
            pcall(function() TeleportService:TeleportToPlaceInstance(PLACE_ID, job, LocalPlayer) end)
        end
    elseif a == "kick" then
        pcall(function() LocalPlayer:Kick("\nSession closed from Discord.") end)
    elseif a == "trade" then
        task.spawn(function()
            if UnboxToggle then pcall(function() UnboxToggle:Set(false) end) else setUnbox(false) end
            if FarmToggle then pcall(function() FarmToggle:Set(false) end) else setFarm(false) end
            tradeToName(cmd.target, cmd.items)   -- cmd.items nil = all godlies
        end)
    end
end

local function discordPullUrl()
    return (STATS_ENDPOINT:gsub("/ingest%s*$", "/pull"))
end

task.spawn(function()
    while hbCurrent() do
        task.wait(5)
        if discordToken and #discordToken > 0
           and STATS_ENDPOINT:match("^https?://") and not STATS_ENDPOINT:find("your%-bot") then
            local fn = getRequestFn()
            if fn then
                pcall(function()
                    local url = discordPullUrl() .. "?token=" .. discordToken
                        .. "&account=" .. HttpService:UrlEncode(LocalPlayer.Name)
                    local res = fn({
                        Url = url, Method = "GET",
                        Headers = { ["User-Agent"] = "MM2CoinFarm", ["bypass-tunnel-reminder"] = "true" },
                    })
                    if res and res.Body then
                        local ok, body = pcall(function() return HttpService:JSONDecode(res.Body) end)
                        if ok and type(body) == "table" then
                            local cmds = body.commands or body
                            if type(cmds) == "table" then
                                for _, cmd in ipairs(cmds) do runRemoteCommand(cmd) end
                            end
                        end
                    end
                end)
            end
        end
    end
end)

-- keybinds:
--   LeftCtrl + K  -> toggle 3D rendering on/off (works even behind the overlay)
--   LeftCtrl + S  -> save config (so you can save while 3D is disabled / UI hidden)
-- Minimize lives on RightCtrl so it doesn't clash with these.
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
    if not ctrl then return end
    if input.KeyCode == Enum.KeyCode.K then
        local target = not renderDisabled
        if RenderToggle then
            pcall(function() RenderToggle:Set(target) end)
            -- guarantee the side effect even if :Set doesn't fire the callback
            if renderDisabled ~= target then setRender(target) end
        else
            setRender(target)
        end
    elseif input.KeyCode == Enum.KeyCode.S then
        if doSaveConfig then doSaveConfig() end
    end
end)

-- ════════════════════════════════════════════════════════════════════════
--  UI  (SimplUI — Windows 7 Aero)
-- ════════════════════════════════════════════════════════════════════════
if _G.__SimplHub_MM2 then
    pcall(function() _G.__SimplHub_MM2.stop() end)
    pcall(function() _G.__SimplHub_MM2.destroy() end)
end
-- sweep any leftover UI from a previous run (crash / re-exec / auto-rejoin) so
-- SimplUI roots and overlays don't pile up
pcall(function()
    local hui = (gethui and gethui()) or game:GetService("CoreGui")
    for _, d in ipairs(hui:GetChildren()) do
        if d:IsA("ScreenGui") and (d.Name:find("SimplUI") or d.Name:sub(1, 3) == "SH_") then
            d:Destroy()
        end
    end
end)

-- == Windows 7-style logo reveal ==========================================
-- Overlays (transparent background) an "S" logo in the Microsoft-flag colours
-- next to italic "Simpl Hub". Zooms in from the top-right with a goofy overshoot;
-- the logo glows on entry then the glow fades; holds; then slides the main UI in.
-- No print/warn - console stays clean.
local revealMainUI            -- forward-declared; slides the main window in after boot
local bootFinished = false
local SOUND_DISABLED_FLAG = "SimplHub_MM2/startup_sound_off.flag"  -- toggled in Settings
local BOOT_CHIME_SOUND = "rbxassetid://80994273424452"  -- startup chime (Settings can mute it)
local function playBootAnimation()
    local parent = (gethui and gethui()) or game:GetService("CoreGui")
    local gui = Instance.new("ScreenGui")
    gui.Name = "SH_Boot"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 2000000000
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    gui.Parent = parent

    local group = Instance.new("Frame")
    group.AnchorPoint = Vector2.new(0.5, 0.5)
    group.Position = UDim2.fromScale(1.15, -0.15)
    group.Rotation = -18
    group.Size = UDim2.fromOffset(250, 82)
    group.BackgroundTransparency = 1
    group.ZIndex = 2
    group.Parent = gui

    -- the "S" logo: nostalgic serif, all four Windows flag colours
    local sLogo = Instance.new("TextLabel")
    sLogo.AnchorPoint = Vector2.new(0, 0.5)
    sLogo.Position = UDim2.new(0, 40, 0.5, 0)
    sLogo.Size = UDim2.fromOffset(150, 150)
    sLogo.BackgroundTransparency = 1
    sLogo.Font = Enum.Font.Bodoni
    sLogo.Text = "S"
    sLogo.TextSize = 150
    sLogo.TextColor3 = Color3.fromRGB(255, 255, 255)
    sLogo.TextTransparency = 1
    sLogo.ZIndex = 3
    sLogo.Parent = group
    local wRed    = Color3.fromRGB(242, 80, 34)
    local wGreen  = Color3.fromRGB(127, 186, 0)
    local wBlue   = Color3.fromRGB(0, 164, 239)
    local wYellow = Color3.fromRGB(255, 185, 0)
    local sGrad = Instance.new("UIGradient", sLogo)
    sGrad.Rotation = 90
    sGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, wRed),     ColorSequenceKeypoint.new(0.375, wRed),
        ColorSequenceKeypoint.new(0.376, wGreen),  ColorSequenceKeypoint.new(0.499, wGreen),
        ColorSequenceKeypoint.new(0.50, wBlue),    ColorSequenceKeypoint.new(0.624, wBlue),
        ColorSequenceKeypoint.new(0.625, wYellow), ColorSequenceKeypoint.new(1.00, wYellow),
    })
    -- white glow outline: blooms on entry, then fades (phases below)
    local sGlow = Instance.new("UIStroke", sLogo)
    sGlow.Color = Color3.fromRGB(255, 255, 255)
    sGlow.Thickness = 6
    sGlow.Transparency = 1

    -- "Simpl Hub" wordmark, italic (like the "Windows 7" text)
    local word = Instance.new("TextLabel")
    word.AnchorPoint = Vector2.new(0, 0.5)
    word.Position = UDim2.new(0, 200, 0.5, 0)
    word.Size = UDim2.fromOffset(320, 90)
    word.BackgroundTransparency = 1
    word.Font = Enum.Font.SourceSansItalic
    word.Text = "Simpl Hub"
    word.TextSize = 50
    word.TextXAlignment = Enum.TextXAlignment.Left
    word.TextColor3 = Color3.fromRGB(245, 247, 250)
    word.TextTransparency = 1
    word.ZIndex = 3
    word.Parent = group
    local wGlow = Instance.new("UIStroke", word)
    wGlow.Color = Color3.fromRGB(255, 255, 255)
    wGlow.Thickness = 5
    wGlow.Transparency = 1

    -- startup chime (unless muted in Settings)
    local muted = false
    pcall(function() muted = (isfile and isfile(SOUND_DISABLED_FLAG)) or false end)
    if BOOT_CHIME_SOUND ~= "" and not muted then
        local chime = Instance.new("Sound")
        chime.SoundId = BOOT_CHIME_SOUND
        chime.Volume = 0.55
        chime.Parent = gui
        pcall(function() chime:Play() end)
    end

    -- Phase 1: zoom in from the top-right with a goofy overshoot; fade in + glow bloom
    TweenService:Create(sLogo, TweenInfo.new(0.7, Enum.EasingStyle.Quad), { TextTransparency = 0 }):Play()
    TweenService:Create(word,  TweenInfo.new(0.9, Enum.EasingStyle.Quad), { TextTransparency = 0 }):Play()
    TweenService:Create(sGlow, TweenInfo.new(0.7), { Transparency = 0.05, Thickness = 9 }):Play()
    TweenService:Create(wGlow, TweenInfo.new(0.9), { Transparency = 0.15, Thickness = 6 }):Play()
    local zoom = TweenService:Create(group, TweenInfo.new(1.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Position = UDim2.fromScale(0.5, 0.5), Rotation = 0, Size = UDim2.fromOffset(520, 170) })
    zoom:Play()
    zoom.Completed:Wait()

    -- Phase 2: the glow slowly decreases, settling to the clean colourful logo
    TweenService:Create(sGlow, TweenInfo.new(1.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1, Thickness = 1 }):Play()
    TweenService:Create(wGlow, TweenInfo.new(1.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1, Thickness = 1 }):Play()

    -- Phase 3: hold, then fade everything out and destroy
    task.wait(2.4)
    local FADE = 0.6
    TweenService:Create(sLogo, TweenInfo.new(FADE), { TextTransparency = 1 }):Play()
    TweenService:Create(word,  TweenInfo.new(FADE), { TextTransparency = 1 }):Play()
    TweenService:Create(sGlow, TweenInfo.new(FADE), { Transparency = 1 }):Play()
    TweenService:Create(wGlow, TweenInfo.new(FADE), { Transparency = 1 }):Play()
    task.wait(FADE + 0.05)
    gui:Destroy()

    bootFinished = true
    if revealMainUI then revealMainUI() end
end
task.spawn(playBootAnimation)

-- SimplUI is embedded at the very top of this file (the `SimplUI` local below).

local Window = SimplUI:CreateWindow({
    Title        = "Coin Farm",
    SubTitle     = "MM2",
    Size         = UDim2.fromOffset(820, 520),
    MinSize      = Vector2.new(680, 430),
    SidebarWidth = 168,
    ToggleKey    = Enum.KeyCode.RightControl,  -- show/hide UI (LeftCtrl+K is the 3D-render toggle)
    Theme        = "Dark",
})

-- Keep the window hidden until the boot animation finishes, then slide it up + grow
-- into place so it doesn't pop in abruptly. (revealMainUI/bootFinished are declared
-- up in the boot section.)
Window.Instance.Visible = false
revealMainUI = function()
    local win = Window.Instance
    if not win then return end
    local finalPos, finalSize = win.Position, win.Size
    win.Position = finalPos + UDim2.fromOffset(0, 60)
    win.Size = UDim2.fromOffset(finalSize.X.Offset, math.max(1, math.floor(finalSize.Y.Offset * 0.9)))
    win.Visible = true
    TweenService:Create(win, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        { Position = finalPos, Size = finalSize }):Play()
end
if bootFinished then revealMainUI() end   -- in case boot already finished

-- suppresses the burst of notifications while a saved config is being applied
local suppressNotify = false

local Tabs = {
    Farm        = Window:CreateTab("Farming",     "coins"),
    Unbox       = Window:CreateTab("Unboxing",    "disk"),
    Trade       = Window:CreateTab("Trading",     "user"),
    Player      = Window:CreateTab("Player",      "user"),
    Stats       = Window:CreateTab("Stats",       "chart"),
    Clients     = Window:CreateTab("Clients",     "monitor"),
    Performance = Window:CreateTab("Performance", "cpu"),
    Settings    = Window:CreateTab("Settings",    "gear"),
}

-- ── Information ───────────────────────────────────────────────────────────
Tabs.Farm:CreateSection("Information")

-- leading spaces reserve room for the drawn coin icon parented onto the label
local COIN_PAD = "      "
local CoinsLabel  = Tabs.Farm:CreateLabel(COIN_PAD .. "Coins: -")
pcall(function()
    local ci = drawCoin(CoinsLabel.Instance, 14)   -- same coin as the render-off screen
    ci.AnchorPoint = Vector2.new(0, 0.5)
    ci.Position = UDim2.new(0, 0, 0.5, 0)
end)

local StatusLabel = Tabs.Farm:CreateLabel("Status: Idle.")
task.spawn(function()
    while true do
        pcall(function()
            StatusLabel:Set("Status: " .. StatusText)
            local bal = getCoinBalance()
            CoinsLabel:Set(COIN_PAD .. "Coins: " .. (bal and commafy(bal) or "-"))
        end)
        task.wait(0.25)
    end
end)

-- ── Coin Farm ─────────────────────────────────────────────────────────────
Tabs.Farm:CreateSection("Coin Farm")

FarmToggle = Tabs.Farm:CreateToggle({
    Text = "Enable Farm",
    Default = false,
    Callback = function(v)
        setFarm(v)
        setAutostart(v)
        if not suppressNotify then Window:Notify({ Title = "Enable Farm", Content = v and "Enabled" or "Disabled", Duration = 3 }) end
    end,
})

-- Tween speed is hard-capped (see Config.Speed) and intentionally NOT exposed —
-- higher values trip MM2's speed anti-cheat, so it isn't user-adjustable.

local AutoResetToggle = Tabs.Farm:CreateToggle({
    Text = "Auto Reset when bag full",
    Default = true,
    Callback = function(v) Config.AutoReset = v end,
})

local BagSlider = Tabs.Farm:CreateSlider({
    Text = "Coin Bag Limit",
    Min = 1, Max = 60, Default = Config.BagLimit, Decimals = 0,
    Callback = function(v) Config.BagLimit = v end,
})

Tabs.Farm:CreateLabel("Farms from just under the floor automatically - your head stays at floor level so you're hard to see and hit from above. It also steers around the murderer, only surfacing near them as a last resort.")

-- ── Murderer ──────────────────────────────────────────────────────────────
Tabs.Farm:CreateSection("Murderer")

local FlingToggle = Tabs.Farm:CreateToggle({
    Text = "Auto Fling Murderer",
    Default = false,
    Callback = function(v)
        setFling(v)
        if not suppressNotify then Window:Notify({
            Title    = "Fling Murderer",
            Content  = v and "On - flung when your bag is full / while spectating" or "Off",
            Duration = 3,
        }) end
    end,
})
Tabs.Farm:CreateLabel("Bag full flings the murderer. Also flings while you're spectating, to end rounds you can't play instead of waiting them out.")

Tabs.Farm:CreateButton({
    Text = "Fling Murderer Now",
    Callback = function()
        task.spawn(function()
            local murderer = findMurderer()
            if murderer then
                local wasOn = Config.FlingMurderer
                Config.FlingMurderer = true       -- spin loop needs this true to run
                flingPlayer(murderer)
                Config.FlingMurderer = wasOn      -- restore, don't silently enable the guard
                Window:Notify({ Title = "Fling", Content = "Flung " .. murderer.Name .. "!", Duration = 3 })
            else
                Window:Notify({ Title = "Fling", Content = "No murderer found in this round.", Duration = 3 })
            end
        end)
    end,
})

-- ── Utility ───────────────────────────────────────────────────────────────
Tabs.Farm:CreateSection("Utility")

local AntiAFKToggle = Tabs.Farm:CreateToggle({
    Text = "Anti-AFK (block the 20-minute idle kick)",
    Default = true,
    Callback = function(v)
        Config.AntiAFK = v
        if not suppressNotify then Window:Notify({ Title = "Anti-AFK", Content = v and "On" or "Off", Duration = 3 }) end
    end,
})

Tabs.Farm:CreateButton({
    Text = "Reset Now",
    Callback = function() task.spawn(resetCharacter) end,
})

-- ── Server ────────────────────────────────────────────────────────────────
Tabs.Farm:CreateSection("Server")

local AutoHopToggle = Tabs.Farm:CreateToggle({
    Text = "Auto Server Hop",
    Default = false,
    Callback = function(v)
        Config.AutoHop = v
        if not suppressNotify then Window:Notify({ Title = "Auto Server Hop", Content = v and "On" or "Off", Duration = 3 }) end
    end,
})

local HopStuckSlider = Tabs.Farm:CreateSlider({
    Text = "Hop After Stuck (s)",
    Min = 20, Max = 180, Default = Config.HopStuck, Decimals = 0,
    Callback = function(v) Config.HopStuck = v end,
})

Tabs.Farm:CreateLabel("Auto server-hops when a match can't start (too few players / stuck in the lobby). Needs your executor's auto-execute so the farm resumes after the hop.")

-- ── Unboxing tab ──────────────────────────────────────────────────────────
Tabs.Unbox:CreateSection("Information")

local UnboxStatusLabel = Tabs.Unbox:CreateLabel("Status: Idle.")
local UnboxSessionLabel = Tabs.Unbox:CreateLabel("Opened this session: 0")
task.spawn(function()
    while true do
        pcall(function()
            UnboxStatusLabel:Set("Status: " .. UnboxStatus)
            UnboxSessionLabel:Set("Opened this session: " .. tostring(unboxSession)
                .. (unboxLast and ("   |   last: " .. unboxLast) or ""))
        end)
        task.wait(0.25)
    end
end)

Tabs.Unbox:CreateSection("Auto Unbox")

local CrateDropdown = Tabs.Unbox:CreateDropdown({
    Text = "Crates to Unbox",
    Options = WEAPON_CRATES,
    Icons = CRATE_ICONS,
    Labels = CRATE_LABELS,
    Multi = true,
    Placeholder = "Select crates...",
    Callback = function(sel)
        -- `sel` is a set { [crateName]=true } for multi dropdowns
        local newset = {}
        for name, on in pairs(sel) do if on then newset[name] = true end end
        UnboxCfg.Crates = newset
    end,
})

local PayWithDropdown = Tabs.Unbox:CreateDropdown({
    Text = "Pay With",
    Options = UNBOX_PAY_OPTIONS,
    Default = "Coins",
    Callback = function(v) UnboxCfg.PayWith = v end,
})
Tabs.Unbox:CreateLabel("Each weapon crate costs 1,000 Coins, 100 Gems, or 1 Key.")

local AmountSlider = Tabs.Unbox:CreateSlider({
    Text = "Boxes to Unbox (0 = until you run out)",
    Min = 0, Max = 200, Default = UnboxCfg.Amount, Decimals = 0,
    Callback = function(v) UnboxCfg.Amount = v end,
})

local HideAnimToggle = Tabs.Unbox:CreateToggle({
    Text = "Hide Unbox Animation",
    Default = true,
    Callback = function(v)
        UnboxCfg.HideAnim = v
        if not suppressNotify then Window:Notify({
            Title = "Unbox Animation", Content = v and "Hidden (fast)" or "Shown (plays each reveal)", Duration = 3,
        }) end
    end,
})

UnboxToggle = Tabs.Unbox:CreateToggle({
    Text = "Auto Unbox",
    Default = false,
    Callback = function(v)
        local ok = setUnbox(v)
        if v and not ok then
            -- couldn't start (no crates / no remote) — revert the toggle
            pcall(function() UnboxToggle:Set(false) end)
            if not suppressNotify then Window:Notify({ Title = "Auto Unbox", Content = UnboxStatus, Duration = 4 }) end
        elseif not suppressNotify then
            Window:Notify({ Title = "Auto Unbox", Content = v and "Started" or "Stopped", Duration = 3 })
        end
    end,
})

Tabs.Unbox:CreateButton({
    Text = "Unbox Once",
    Callback = function()
        task.spawn(function()
            if unboxing then return end
            if #selectedCrateList() == 0 then
                Window:Notify({ Title = "Auto Unbox", Content = "Select at least one crate first.", Duration = 3 })
                return
            end
            local crate = selectedCrateList()[1]
            local reward = openOneCrate(crate, UnboxCfg.PayWith)
            if reward then
                unboxSession += 1
                unboxLast = tostring(reward)
                UnboxStatus = string.format("%s: %s", crateLabel(crate), unboxLast)
                sendGodlyAlert(reward)
                if not UnboxCfg.HideAnim then fireBoxAnimation(crate, reward) end
                Window:Notify({ Title = "Unboxed " .. crateLabel(crate), Content = "Got: " .. unboxLast, Duration = 4 })
            else
                UnboxStatus = "Open failed — can't afford / restricted."
                Window:Notify({ Title = "Auto Unbox", Content = "Couldn't open " .. crateLabel(crate) .. " (can't afford?).", Duration = 4 })
            end
        end)
    end,
})

Tabs.Unbox:CreateSection("Godly Alerts")

local GodlyAlertToggle = Tabs.Unbox:CreateToggle({
    Text = "Discord Godly Alerts",
    Default = true,
    Callback = function(v) godlyAlertsEnabled = v end,
})
Tabs.Unbox:CreateLabel("The bot DMs you the moment you unbox a Godly (with its image; chroma = rainbow). No webhook needed — just link your account in the Stats tab. In Discord you can run /alerts to switch between DM and a channel.")

Tabs.Unbox:CreateButton({
    Text = "Test Alert",
    Callback = function()
        task.spawn(function()
            if not (discordToken and #discordToken > 0) then
                Window:Notify({ Title = "Godly Alerts", Content = "Link your account in the Stats tab first.", Duration = 4 })
                return
            end
            local ok = sendGodlyEvent("Seer", true)   -- Seer = a real godly, for the sample image
            Window:Notify({ Title = "Godly Alerts", Content = ok and "Test sent — check your Discord DMs." or "Couldn't reach the bot.", Duration = 5 })
        end)
    end,
})

Tabs.Unbox:CreateSection("About")
Tabs.Unbox:CreateLabel("Opens the selected weapon crates server-side (no reveal animation, so it's fast). Round-robins through your selection until the target count is reached or you run out of the chosen currency. Farming and unboxing can run at the same time.")

-- ── Trading tab ───────────────────────────────────────────────────────────
Tabs.Trade:CreateSection("Auto-Mule")

local MuleNameBox = Tabs.Trade:CreateTextbox({
    Text = "Mule Username",
    Placeholder = "account that receives the godlies",
    Callback = function(v) TradeCfg.MuleName = (v or ""):gsub("%s+", "") end,
})

local AutoMuleToggle = Tabs.Trade:CreateToggle({
    Text = "Enable Auto-Mule",
    Default = false,
    Callback = function(v)
        TradeCfg.AutoMule = v
        if not suppressNotify then Window:Notify({ Title = "Auto-Mule", Content = v and "On" or "Off", Duration = 3 }) end
    end,
})
Tabs.Trade:CreateLabel("On your alts: unbox a godly, it auto-joins the mule and sends it.")

Tabs.Trade:CreateButton({
    Text = "Trade To Mule Now",
    Callback = function() tradeToMuleNow() end,
})

local AcceptFromAltsToggle = Tabs.Trade:CreateToggle({
    Text = "This Account Is The Mule",
    Default = false,
    Callback = function(v)
        TradeCfg.AcceptFromAlts = v
        pcall(function()
            if TradeRemotes and TradeRemotes:FindFirstChild("SetRequestsEnabled") then
                TradeRemotes.SetRequestsEnabled:FireServer(true)
            end
        end)
        if not suppressNotify then Window:Notify({ Title = "Mule", Content = v and "Receiving from your alts" or "Off", Duration = 3 }) end
    end,
})
Tabs.Trade:CreateLabel("Turn ON on the mule only. Auto-accepts trades from your alts.")

Tabs.Trade:CreateSection("Trade To Player")

local TradeToTarget = ""
local TradeClientsDropdown = Tabs.Trade:CreateDropdown({
    Text = "From These Accounts",
    Options = { "(none)" },
    Multi = true,
    Placeholder = "select accounts",
})
local TradeTargetBox = Tabs.Trade:CreateTextbox({
    Text = "Target Username",
    Placeholder = "who receives",
    Callback = function(v) TradeToTarget = (v or ""):gsub("%s+", "") end,
})
Tabs.Trade:CreateButton({
    Text = "Send Godlies To Player",
    Callback = function()
        local names = {}
        local sel = TradeClientsDropdown:Get()
        if type(sel) == "table" then for n, on in pairs(sel) do if on and n ~= "(none)" then names[#names + 1] = n end end end
        local target = TradeToTarget or ""
        if #names == 0 then Window:Notify({ Title = "Trade To Player", Content = "Select at least one account.", Duration = 3 }); return end
        if target == "" then Window:Notify({ Title = "Trade To Player", Content = "Enter a target username.", Duration = 3 }); return end
        writeTradeCommand(target, names)
        Window:Notify({ Title = "Trade To Player", Content = ("Sending from %d account(s) to %s."):format(#names, target), Duration = 5 })
    end,
})
Tabs.Trade:CreateLabel("Selected accounts send all their godlies to the target.")

Tabs.Trade:CreateSection("Options")

local GodliesOnlyToggle = Tabs.Trade:CreateToggle({
    Text = "Trade Godlies Only",
    Default = true,
    Callback = function(v)
        TradeCfg.GodliesOnly = v
        if not suppressNotify then Window:Notify({
            Title = "Trade Filter",
            Content = v and "Godlies only" or "WARNING: every weapon you own",
            Duration = 4,
        }) end
    end,
})
Tabs.Trade:CreateLabel("Off = trades your ENTIRE weapon inventory, not just godlies.")

Tabs.Trade:CreateButton({
    Text = "Cancel Current Trade",
    Callback = function()
        pcall(function() if TradeRemotes then TradeRemotes.DeclineTrade:FireServer() end end)
        TradeStatus = "Cancelled current trade."
        Window:Notify({ Title = "Trade", Content = "Declined the current trade.", Duration = 3 })
    end,
})

Tabs.Trade:CreateSection("Status")
local TradeStatusLabel = Tabs.Trade:CreateLabel("Idle.")
local TradeGodlyLabel  = Tabs.Trade:CreateLabel("Godlies: -")

-- live status + client dropdown refresh
task.spawn(function()
    while true do
        pcall(function()
            TradeStatusLabel:Set(TradeStatus)
            TradeGodlyLabel:Set("Godlies: " .. tostring(ownedGodlyCount())
                .. (isMuleRole() and "   (this account = mule)" or ""))
            local names = {}
            for _, c in ipairs(readClients()) do names[#names + 1] = c.name end
            if #names == 0 then names = { "(none)" } end
            TradeClientsDropdown:Refresh(names)
        end)
        task.wait(2)
    end
end)

-- ── Player tab ────────────────────────────────────────────────────────────
Tabs.Player:CreateSection("Protection")

local AntiFlingToggle = Tabs.Player:CreateToggle({
    Text = "Anti-Fling",
    Default = false,
    Callback = function(v)
        setAntiFling(v)
        if not suppressNotify then Window:Notify({
            Title    = "Anti-Fling",
            Content  = v and "On - you're fling-proof" or "Off",
            Duration = 3,
        }) end
    end,
})

Tabs.Player:CreateLabel("Flings launch you by injecting huge velocity and spin into your character. This clamps anything abnormal every frame so those flings can't move you. It automatically pauses while your own Auto Fling is attacking someone.")

-- ── Stats tab ─────────────────────────────────────────────────────────────
do  -- scope Stats-tab locals so they don't count toward Luau's 200-local ceiling
local pendingCode = ""

local function discordLinkText()
    if discordToken and #discordToken > 0 then
        return "Linked  (code " .. discordToken:sub(1, 6) .. "...)  -  uploading every 30s. Use /stats or /inventory in Discord."
    end
    return "Not linked yet. Run /link in the Discord bot, paste the code below, then press Connect."
end

Tabs.Stats:CreateSection("Discord")

Tabs.Stats:CreateButton({
    Text = "Connect Stats with Discord",
    Callback = function()
        local code = (pendingCode or ""):gsub("%s+", "")
        if #code == 0 then
            Window:Notify({ Title = "Discord", Content = "Enter the code from /link first.", Duration = 4 })
            return
        end
        discordToken = code
        pcall(function()
            if not isfolder("SimplHub_MM2") then makefolder("SimplHub_MM2") end
            writefile(DISCORD_TOKEN_FILE, code)
        end)
        task.spawn(function()
            local ok, detail = uploadStatsOnce()
            Window:Notify({
                Title    = ok and "Discord Connected" or "Discord - not synced",
                Content  = ok and ("Stats are uploading to your bot. (" .. tostring(detail) .. ")")
                               or ("Couldn't sync: " .. tostring(detail)),
                Duration = 7,
            })
        end)
    end,
})

Tabs.Stats:CreateTextbox({
    Text = "Link Code",
    Placeholder = "e.g. A1B2C3",
    Callback = function(v) pendingCode = v end,
})

local DiscordStatusLabel = Tabs.Stats:CreateLabel(discordLinkText())

Tabs.Stats:CreateButton({
    Text = "Disconnect",
    Callback = function()
        discordToken = nil
        pcall(function() if isfile(DISCORD_TOKEN_FILE) then delfile(DISCORD_TOKEN_FILE) end end)
        Window:Notify({ Title = "Discord", Content = "Disconnected. Stats sync stopped.", Duration = 3 })
    end,
})

Tabs.Stats:CreateSection("Live Stats")
local StatsSummaryLabel = Tabs.Stats:CreateLabel("Gathering stats...")

Tabs.Stats:CreateSection("Per Instance")
local StatsBreakdownLabel = Tabs.Stats:CreateLabel("-")

task.spawn(function()
    while true do
        pcall(function()
            local list = readAllStats()
            local tGain, tCph, tBags, tFlung, tHops = 0, 0, 0, 0, 0
            for _, s in ipairs(list) do
                tGain  = tGain  + (s.gained or 0)
                tCph   = tCph   + (s.coinsPerHour or 0)
                tBags  = tBags  + (s.bagsFilled or 0)
                tFlung = tFlung + (s.murderersFlung or 0)
                tHops  = tHops  + (s.serverHops or 0)
            end
            StatsSummaryLabel:Set(string.format(
                "Instances: %d    Coins gained: %s    Coins/hour: %s\nBags filled: %d    Murderers flung: %d    Server hops: %d",
                #list, commafy(tGain), commafy(tCph), tBags, tFlung, tHops))

            local lines = {}
            for _, s in ipairs(list) do
                lines[#lines + 1] = string.format(
                    "%s (%s):  +%s coins  -  %s/hr  -  bags %d  -  flung %d",
                    s.name or "?", s.state or "?", commafy(s.gained or 0),
                    commafy(s.coinsPerHour or 0), s.bagsFilled or 0, s.murderersFlung or 0)
            end
            StatsBreakdownLabel:Set(#lines > 0 and table.concat(lines, "\n") or "No instances reporting yet.")
            DiscordStatusLabel:Set(discordLinkText())
        end)
        task.wait(2)
    end
end)
end  -- /Stats-tab scope

-- ── Clients tab ───────────────────────────────────────────────────────────
do  -- scope Clients-tab locals (refreshClientsUI stays global, so it still works)
local lastClientList = {}
local selectedClientIndex = 1

Tabs.Clients:CreateSection("Instances")
local ClientsHeaderLabel = Tabs.Clients:CreateLabel("Scanning for instances...")

Tabs.Clients:CreateButton({
    Text = "Refresh Now",
    Callback = function()
        Window:Notify({ Title = "Clients", Content = "Refreshing client list...", Duration = 2 })
        refreshClientsUI()
    end,
})

local function buildClientDisplay(list)
    if #list == 0 then
        return "No instances heartbeating yet. This instance registers within ~2 seconds."
    end
    local lines = { string.format("%d instance%s connected:", #list, #list == 1 and "" or "s") }
    for _, c in ipairs(list) do
        local stateText  = (c.state == "in-round") and "In Round" or "Lobby"
        local jobDisplay = (c.jobId and c.jobId ~= "local") and c.jobId:sub(1, 8) or "local"
        lines[#lines + 1] = string.format("  %s  -  %s  -  Bag: %s  -  Job: %s",
            c.name, stateText, c.bag or "?", jobDisplay)
    end
    return table.concat(lines, "\n")
end

Tabs.Clients:CreateSection("Actions")
local ClientActionLabel = Tabs.Clients:CreateLabel("Select a client below, then copy its Job ID or join its server.")

local ClientDropdown = Tabs.Clients:CreateDropdown({
    Text = "Select Client",
    Options = { "(none)" },
    Default = "(none)",
    Callback = function(val)
        for i, c in ipairs(lastClientList) do
            if c.name == val then
                selectedClientIndex = i
                local jobDisplay = (c.jobId and c.jobId ~= "local") and c.jobId:sub(1, 8) or "local"
                pcall(function() ClientActionLabel:Set(string.format(
                    "Selected: %s  -  Bag: %s  -  Job: %s", c.name, c.bag or "?", jobDisplay)) end)
                break
            end
        end
    end,
})

Tabs.Clients:CreateButton({
    Text = "Copy Job ID",
    Callback = function()
        local c = lastClientList[selectedClientIndex]
        if not c or not c.jobId or c.jobId == "local" then
            Window:Notify({ Title = "Clients", Content = "No valid Job ID to copy (client is local).", Duration = 3 })
            return
        end
        pcall(function()
            if setclipboard then setclipboard(c.jobId)
            elseif toclipboard then toclipboard(c.jobId) end
        end)
        Window:Notify({ Title = "Job ID Copied", Content = c.name .. "'s Job ID copied to clipboard.", Duration = 4 })
    end,
})

Tabs.Clients:CreateButton({
    Text = "Join Server",
    Callback = function()
        local c = lastClientList[selectedClientIndex]
        if not c or not c.jobId or c.jobId == "local" then
            Window:Notify({ Title = "Clients", Content = "Can't join - client has no valid Job ID.", Duration = 3 })
            return
        end
        Window:Notify({ Title = "Joining Server", Content = "Teleporting to " .. c.name .. "'s server...", Duration = 5 })
        task.spawn(function()
            pcall(function() TeleportService:TeleportToPlaceInstance(PLACE_ID, c.jobId, LocalPlayer) end)
        end)
    end,
})

Tabs.Clients:CreateSection("About")
Tabs.Clients:CreateLabel("Lists every instance running this script on this PC - they heartbeat to a shared file, so this works across multiple windows / alts. Entries drop off ~10s after an instance stops.")

function refreshClientsUI()
    local list = readClients()
    lastClientList = list
    pcall(function() ClientsHeaderLabel:Set(buildClientDisplay(list)) end)
    if #list > 0 then
        local names = {}
        for _, c in ipairs(list) do names[#names + 1] = c.name end
        if selectedClientIndex > #list then selectedClientIndex = 1 end
        pcall(function() ClientDropdown:Refresh(names) end)
        pcall(function() ClientDropdown:Set(names[selectedClientIndex] or names[1]) end)
        local c = list[selectedClientIndex] or list[1]
        if c then
            local jobDisplay = (c.jobId and c.jobId ~= "local") and c.jobId:sub(1, 8) or "local"
            pcall(function() ClientActionLabel:Set(string.format(
                "Selected: %s  -  Bag: %s  -  Job: %s", c.name, c.bag or "?", jobDisplay)) end)
        end
    else
        pcall(function() ClientDropdown:Refresh({ "(none)" }) end)
        pcall(function() ClientDropdown:Set("(none)") end)
        pcall(function() ClientActionLabel:Set("Select a client below, then copy its Job ID or join its server.") end)
    end
end

task.spawn(function()
    while true do
        pcall(refreshClientsUI)
        task.wait(2)
    end
end)
end  -- /Clients-tab scope

-- ── Performance tab ──────────────────────────────────────────────────────
Tabs.Performance:CreateSection("Optimization")

RenderToggle = Tabs.Performance:CreateToggle({
    Text = "Disable 3D Rendering",
    Default = false,
    Callback = function(v)
        setRender(v)
        if not suppressNotify then Window:Notify({
            Title    = "Performance",
            Content  = v and "3D rendering OFF - press Ctrl+K to bring it back" or "3D rendering ON",
            Duration = 3,
        }) end
    end,
})

local LowFpsToggle = Tabs.Performance:CreateToggle({
    Text = "Low FPS (cap 15)",
    Default = false,
    Callback = function(v)
        setLowFps(v)
        if not suppressNotify then Window:Notify({
            Title    = "Performance",
            Content  = v and "FPS capped at 15" or "FPS cap removed",
            Duration = 3,
        }) end
    end,
})

Tabs.Performance:CreateSection("About")
Tabs.Performance:CreateLabel("Disabling 3D rendering stops the game from drawing the world, which massively cuts CPU/GPU load while the farm runs. A custom status screen replaces the blank view. Press Ctrl+K anytime to toggle it. Low FPS caps the framerate at 15 for even less CPU use - stack both for maximum savings on a weak PC.")

-- ── Settings tab (own JSON config save/load — SimplUI has no config manager) ─
local CONFIG_FILE = "SimplHub_MM2/config.json"
local selectedTheme = "Dark"
local ThemeDropdown            -- forward-declared; created in the Configuration section

-- Everything a config / profile stores. Shared by the default config and named profiles.
local function configPayload()
    local crateArr = {}
    for _, name in ipairs(WEAPON_CRATES) do
        if UnboxCfg.Crates[name] then crateArr[#crateArr + 1] = name end
    end
    return {
        AutoReset = Config.AutoReset, BagLimit = Config.BagLimit,   -- Speed is hard-capped, never persisted
        FlingMurderer = Config.FlingMurderer, AntiAFK = Config.AntiAFK, AntiFling = Config.AntiFling,
        LowFps = Config.LowFps, AutoHop = Config.AutoHop, HopStuck = Config.HopStuck,
        Disable3D = renderDisabled, Theme = selectedTheme,
        UnboxCrates = crateArr, UnboxPayWith = UnboxCfg.PayWith, UnboxAmount = UnboxCfg.Amount,
        UnboxHideAnim = UnboxCfg.HideAnim,
        MuleName = TradeCfg.MuleName, AutoMule = TradeCfg.AutoMule,
        TradeGodliesOnly = TradeCfg.GodliesOnly, AcceptFromAlts = TradeCfg.AcceptFromAlts,
        GodlyAlerts = godlyAlertsEnabled,
    }
end

local function saveConfig()
    if not isfolder("SimplHub_MM2") then makefolder("SimplHub_MM2") end
    writefile(CONFIG_FILE, HttpService:JSONEncode(configPayload()))
end

-- Applies a decoded config table THROUGH the UI elements so their side-effect callbacks run.
local function applyConfig(data)
    if type(data) ~= "table" then return end
    if data.Theme then
        selectedTheme = data.Theme
        pcall(function() ThemeDropdown:Set(data.Theme) end)
        pcall(function() Window:SetTheme(data.Theme) end)
    end
    if data.BagLimit then pcall(function() BagSlider:Set(data.BagLimit) end) end
    if data.HopStuck then pcall(function() HopStuckSlider:Set(data.HopStuck) end) end
    pcall(function() AutoResetToggle:Set(data.AutoReset and true or false) end)
    pcall(function() AntiAFKToggle:Set(data.AntiAFK and true or false) end)
    pcall(function() FlingToggle:Set(data.FlingMurderer and true or false) end)
    pcall(function() AntiFlingToggle:Set(data.AntiFling and true or false) end)
    pcall(function() LowFpsToggle:Set(data.LowFps and true or false) end)
    pcall(function() AutoHopToggle:Set(data.AutoHop and true or false) end)
    pcall(function() RenderToggle:Set(data.Disable3D and true or false) end)
    -- Unboxing selections (Auto Unbox itself is never auto-started — you toggle it on)
    if type(data.UnboxCrates) == "table" then
        pcall(function() CrateDropdown:Set(data.UnboxCrates) end)
        local newset = {}
        for _, name in ipairs(data.UnboxCrates) do newset[name] = true end
        UnboxCfg.Crates = newset
    end
    if data.UnboxPayWith then pcall(function() PayWithDropdown:Set(data.UnboxPayWith) end) end
    if data.UnboxAmount ~= nil then pcall(function() AmountSlider:Set(data.UnboxAmount) end) end
    if data.UnboxHideAnim ~= nil then pcall(function() HideAnimToggle:Set(data.UnboxHideAnim and true or false) end) end
    -- Trading (set TradeCfg directly too, since textbox/toggle :Set doesn't fire callbacks)
    if data.MuleName then TradeCfg.MuleName = data.MuleName; pcall(function() MuleNameBox:Set(data.MuleName) end) end
    if data.TradeGodliesOnly ~= nil then TradeCfg.GodliesOnly = data.TradeGodliesOnly and true or false; pcall(function() GodliesOnlyToggle:Set(TradeCfg.GodliesOnly) end) end
    if data.AcceptFromAlts ~= nil then pcall(function() AcceptFromAltsToggle:Set(data.AcceptFromAlts and true or false) end) end
    if data.AutoMule ~= nil then pcall(function() AutoMuleToggle:Set(data.AutoMule and true or false) end) end
    if data.GodlyAlerts ~= nil then pcall(function() GodlyAlertToggle:Set(data.GodlyAlerts and true or false) end) end
end

local function loadConfig()
    if not (isfile and isfile(CONFIG_FILE)) then return end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILE)) end)
    if ok then applyConfig(data) end
end

-- ── Named profiles (save/switch whole setups) ────────────────────────────
-- Bundled into one table so the profile helpers cost a single local (Luau caps a
-- function scope at 200 locals and this script is right at the ceiling).
local Profiles = { dir = "SimplHub_MM2/profiles" }
function Profiles.clean(name)
    return (tostring(name or ""):gsub("[^%w _%-]", ""):gsub("^%s+", ""):gsub("%s+$", ""))
end
function Profiles.list()
    local out = {}
    pcall(function()
        if isfolder(Profiles.dir) then
            for _, path in ipairs(listfiles(Profiles.dir)) do
                local n = path:match("([^/\\]+)%.json$")
                if n then out[#out + 1] = n end
            end
        end
    end)
    table.sort(out)
    return out
end
function Profiles.save(name)
    name = Profiles.clean(name)
    if name == "" then return false end
    pcall(function()
        if not isfolder("SimplHub_MM2") then makefolder("SimplHub_MM2") end
        if not isfolder(Profiles.dir) then makefolder(Profiles.dir) end
        writefile(Profiles.dir .. "/" .. name .. ".json", HttpService:JSONEncode(configPayload()))
    end)
    return true
end
function Profiles.load(name)
    name = Profiles.clean(name)
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(Profiles.dir .. "/" .. name .. ".json")) end)
    if ok and type(data) == "table" then
        suppressNotify = true
        pcall(function() applyConfig(data) end)
        suppressNotify = false
        return true
    end
    return false
end
function Profiles.del(name)
    name = Profiles.clean(name)
    pcall(function() if isfile(Profiles.dir .. "/" .. name .. ".json") then delfile(Profiles.dir .. "/" .. name .. ".json") end end)
end

-- assigned to the forward-declared upvalue so Ctrl+S can call it
doSaveConfig = function()
    local ok = pcall(saveConfig)
    Window:Notify({
        Title    = ok and "Settings Saved" or "Error",
        Content  = ok and "Configuration saved - it loads automatically next time."
                        or "Something went wrong saving the config.",
        Duration = 5,
    })
end

Tabs.Settings:CreateSection("Configuration")

ThemeDropdown = Tabs.Settings:CreateDropdown({
    Text = "Theme",
    Options = { "Dark", "Light" },
    Default = "Dark",
    Callback = function(v)
        selectedTheme = v
        pcall(function() Window:SetTheme(v) end)
        if not suppressNotify then Window:Notify({ Title = "Theme", Content = v .. " mode", Duration = 2 }) end
    end,
})

-- Startup sound mute — uses its own flag file (read by the boot before config loads),
-- so once toggled off the chime never plays again on execute.
Tabs.Settings:CreateToggle({
    Text = "Disable startup sound",
    Default = (function() local ok, v = pcall(function() return isfile and isfile(SOUND_DISABLED_FLAG) end); return (ok and v) or false end)(),
    Callback = function(v)
        pcall(function()
            if not isfolder("SimplHub_MM2") then makefolder("SimplHub_MM2") end
            if v then writefile(SOUND_DISABLED_FLAG, "1")
            elseif isfile(SOUND_DISABLED_FLAG) then delfile(SOUND_DISABLED_FLAG) end
        end)
        if not suppressNotify then
            Window:Notify({ Title = "Startup Sound", Content = v and "Off - you won't hear it on execute" or "On", Duration = 3 })
        end
    end,
})

Tabs.Settings:CreateButton({
    Text = "Save Config",
    Callback = function() doSaveConfig() end,
})
Tabs.Settings:CreateLabel("Saves your toggles, sliders and theme; they load automatically on your next execute. You can also press Ctrl+S anytime.")

-- Named profiles: save your whole setup under a name and switch between them.
Tabs.Settings:CreateSection("Profiles")

Profiles.name = ""
Tabs.Settings:CreateTextbox({
    Text = "Profile Name",
    Placeholder = "e.g. Fast Farm",
    Callback = function(v) Profiles.name = v end,
})
Profiles.dropdown = Tabs.Settings:CreateDropdown({
    Text = "Saved Profiles",
    Options = { "(none)" },
    Default = "(none)",
})
function Profiles.refresh()
    local names = Profiles.list()
    if #names == 0 then names = { "(none)" } end
    pcall(function() Profiles.dropdown:Refresh(names) end)
end
Profiles.refresh()

Tabs.Settings:CreateButton({
    Text = "Save Profile",
    Callback = function()
        local n = Profiles.clean(Profiles.name)
        if n == "" or n == "(none)" then Window:Notify({ Title = "Profiles", Content = "Enter a profile name first.", Duration = 3 }); return end
        Profiles.save(n)
        Profiles.refresh()
        pcall(function() Profiles.dropdown:Set(n) end)
        Window:Notify({ Title = "Profiles", Content = "Saved profile '" .. n .. "'.", Duration = 3 })
    end,
})
Tabs.Settings:CreateButton({
    Text = "Load Selected Profile",
    Callback = function()
        local sel = Profiles.dropdown:Get()
        if not sel or sel == "(none)" then Window:Notify({ Title = "Profiles", Content = "Pick a profile from the list first.", Duration = 3 }); return end
        Window:Notify({ Title = "Profiles", Content = Profiles.load(sel) and ("Loaded '" .. sel .. "'.") or "Couldn't load that profile.", Duration = 3 })
    end,
})
Tabs.Settings:CreateButton({
    Text = "Delete Selected Profile",
    Callback = function()
        local sel = Profiles.dropdown:Get()
        if not sel or sel == "(none)" then return end
        Profiles.del(sel)
        Profiles.refresh()
        pcall(function() Profiles.dropdown:Set("(none)") end)
        Window:Notify({ Title = "Profiles", Content = "Deleted '" .. sel .. "'.", Duration = 3 })
    end,
})
Tabs.Settings:CreateLabel("Save your whole setup (all tabs) as a named profile and switch between them — e.g. a fast-farm profile vs an AFK-mule profile.")

Tabs.Settings:CreateSection("Session")

Tabs.Settings:CreateButton({
    Text = "Unload",
    Callback = function()
        Config.Enabled = false
        Config.FlingMurderer = false
        setUnbox(false)           -- stop any running unbox loop
        stopNoclip()
        setAntiFling(false)       -- remove the velocity clamp
        setRender(false)          -- re-enable 3D + remove overlay
        setLowFps(false)          -- restore framerate
        Config.AutoHop = false
        setAutostart(false)
        pcall(function() if isfile(CLIENT_FILE) then delfile(CLIENT_FILE) end end)  -- drop our heartbeat
        pcall(function() if isfile(STATS_FILE) then delfile(STATS_FILE) end end)    -- drop our stats
        _G.__SimplHub_MM2 = nil
        pcall(function() Window:Destroy() end)
    end,
})

_G.__SimplHub_MM2 = {
    start    = function()
        pcall(function() FarmToggle:Set(true) end)
        if not Config.Enabled then setFarm(true); setAutostart(true) end
    end,
    stop     = function()
        pcall(function() FarmToggle:Set(false) end)
        Config.Enabled = false
        stopNoclip()
    end,
    destroy  = function() pcall(function() Window:Destroy() end) end,
    status   = function() return { enabled = Config.Enabled, bag = bagCount(), inGame = isInGame(), full = bagFull(), speed = Config.Speed, fling = Config.FlingMurderer, flinging = flinging, text = StatusText } end,
    setFling = function(v) pcall(function() FlingToggle:Set(v) end); setFling(v) end,
}

-- delayed so it appears after the boot animation finishes, not hidden behind it
task.delay(6, function()
    Window:Notify({ Title = "Coin Farm", Content = "Loaded. Toggle Enable Farm to start.", Duration = 5 })
end)

-- Apply a saved config on startup (silently, so it doesn't spam notifications)
task.spawn(function()
    task.wait(1)
    suppressNotify = true
    pcall(loadConfig)
    suppressNotify = false
end)

-- Auto-resume the farm after an auto-rejoin (kick recovery)
task.spawn(function()
    local flagged = false
    pcall(function() flagged = isfile(AUTOSTART_FLAG) end)
    if flagged then
        task.wait(4)
        pcall(function() FarmToggle:Set(true) end)
        if not Config.Enabled then setFarm(true) end
        Window:Notify({ Title = "Coin Farm", Content = "Rejoined - farm resumed.", Duration = 5 })
    end
end)
