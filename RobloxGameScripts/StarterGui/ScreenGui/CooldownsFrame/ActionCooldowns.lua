-- LocalScript: StarterGui>ScreenGui>CooldownsFrame>ActionCooldowns
-- ActionCooldowns.lua [LocalScript] — FINALIZED
-- StarterGui > ScreenGui > CooldownsFrame
-- Style matches Loadout HUD, sits directly to the left of Loadout cluster.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- === Screen / Root Frame ==================================
local screenGui = script.Parent.Parent -- ScreenGui
screenGui.IgnoreGuiInset = true

local cooldownsFrame = script.Parent -- CooldownsFrame
cooldownsFrame.Size = UDim2.new(1, 0, 1, 0)
cooldownsFrame.Position = UDim2.new(0, 0, 0, 0)
cooldownsFrame.BackgroundTransparency = 1

-- === Layout constants (mirror your Loadout cluster exactly) =
local EDGE_MARGIN = 20

-- Loadout sizes (from your LoadoutDisplay)
local PRIMARY_W   = 90
local SECONDARY_W = 60
local GAP_P_S     = 6   -- UIListLayout padding inside Loadout

-- Gap between Loadout cluster and cooldowns row
local GAP_CLUSTER_TO_COOLDOWNS = 12

-- Cooldown chip style (square, like your ability tiles in Loadout)
local CHIP_W = 58
local CHIP_H = 58
local CHIP_CORNER = 6
local CHIP_PAD = 8

-- Right offset so our container's RIGHT edge sits just to the left of the Loadout cluster:
-- [primary 90] + [gap 6] + [secondary 60] + [gutter 12] + [edge 20]
local RIGHT_OFFSET = EDGE_MARGIN + PRIMARY_W + GAP_P_S + SECONDARY_W + GAP_CLUSTER_TO_COOLDOWNS
local BOTTOM_OFFSET = EDGE_MARGIN

-- === Abilities / cooldown config ===========================
-- Neutral (black) icon look; no color tints. Durations are same as before.
local order = { "Deflect", "Grapple", "Dodge" } -- left -> right (we align right, so Dodge ends up at the far right)
local cooldownConfigs = {
	Deflect = { KeyBind = "Q", Cooldown = 2.0 },
	Grapple = { KeyBind = "E", Cooldown = 3.0 },
	Dodge   = { KeyBind = "V", Cooldown = 1.0 },
}

-- (Optional) if you have images later, fill these:
local iconImages = {
	Deflect = "", -- e.g., "rbxassetid://<id>"
	Grapple = "",
	Dodge   = "",
}

-- === Build container =======================================
local CONTAINER_W = (#order * CHIP_W) + ((#order - 1) * CHIP_PAD)
local CONTAINER_H = CHIP_H

local container = Instance.new("Frame")
container.Name = "CooldownsContainer"
container.Size = UDim2.new(0, CONTAINER_W, 0, CONTAINER_H)
container.Position = UDim2.new(1, -RIGHT_OFFSET, 1, -BOTTOM_OFFSET)
container.AnchorPoint = Vector2.new(1, 1)
container.BackgroundTransparency = 1
container.Parent = cooldownsFrame

local list = Instance.new("UIListLayout")
list.FillDirection = Enum.FillDirection.Horizontal
list.HorizontalAlignment = Enum.HorizontalAlignment.Right
list.VerticalAlignment = Enum.VerticalAlignment.Bottom
list.Padding = UDim.new(0, CHIP_PAD)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = container

-- === Helpers ===============================================
local function mkKeyBadge(parent, text)
	local badge = Instance.new("TextLabel")
	badge.Name = "KeyBadge"
	badge.Size = UDim2.new(0, 22, 0, 22)
	badge.Position = UDim2.new(0, 6, 0, 6)
	badge.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	badge.BorderSizePixel = 0
	badge.Text = text
	badge.TextColor3 = Color3.fromRGB(220, 220, 220)
	badge.TextSize = 12
	badge.Font = Enum.Font.GothamBold
	badge.ZIndex = 3
	badge.Parent = parent
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 4)
	c.Parent = badge
	return badge
end

local function mkBlink(parent)
	local blink = Instance.new("Frame")
	blink.Name = "Blink"
	blink.Size = UDim2.new(0, 10, 0, 10)
	blink.AnchorPoint = Vector2.new(0.5, 0.5)
	blink.Position = UDim2.new(0.5, 0, 0.5, 0)
	blink.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	blink.BorderSizePixel = 0
	blink.Visible = false
	blink.ZIndex = 5
	blink.Parent = parent
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 2)
	c.Parent = blink
	return blink
end

-- === Chip factory (black icon, keybadge at TL, cooldown overlay, blink) ==
local function createChip(name, layoutOrder)
	local chip = Instance.new("Frame")
	chip.Name = name .. "Chip"
	chip.LayoutOrder = layoutOrder
	chip.Size = UDim2.new(0, CHIP_W, 0, CHIP_H)
	chip.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	chip.BorderSizePixel = 0
	chip.Parent = container
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, CHIP_CORNER)
	corner.Parent = chip

	-- Black HUD icon (like weapon HUD). Provide your image later via iconImages[].
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.BackgroundTransparency = 1
	icon.Size = UDim2.new(0.7, 0, 0.7, 0)
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Position = UDim2.new(0.5, 0, 0.45, 0)
	icon.Image = iconImages[name] or ""
	icon.ImageColor3 = Color3.fromRGB(0, 0, 0) -- black HUD icon
	icon.ZIndex = 2
	icon.Parent = chip

	-- Hotkey badge (top-left), same style as Weapon HUD.
	local key = mkKeyBadge(chip, cooldownConfigs[name].KeyBind)

	-- Dark overlay (used to "gray out" on cooldown).
	local overlay = Instance.new("Frame")
	overlay.Name = "Overlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 0.6
	overlay.Visible = false
	overlay.BorderSizePixel = 0
	overlay.ZIndex = 3
	overlay.Parent = chip
	local oCorner = Instance.new("UICorner")
	oCorner.CornerRadius = UDim.new(0, CHIP_CORNER)
	oCorner.Parent = overlay

	-- Small cooldown number under chip.
	local cd = Instance.new("TextLabel")
	cd.Name = "CooldownText"
	cd.BackgroundTransparency = 1
	cd.Size = UDim2.new(1, 0, 0, 14)
	cd.Position = UDim2.new(0, 0, 1, 2)
	cd.Text = ""
	cd.TextColor3 = Color3.fromRGB(200, 200, 200)
	cd.TextSize = 10
	cd.Font = Enum.Font.Gotham
	cd.TextStrokeTransparency = 0.7
	cd.Visible = false
	cd.ZIndex = 3
	cd.Parent = chip

	-- A tiny white square that blinks once when the ability becomes ready.
	local blink = mkBlink(chip)

	return {
		Chip = chip,
		Icon = icon,
		KeyBadge = key,
		Overlay = overlay,
		CooldownText = cd,
		Blink = blink,
	}
end

-- === Build chips in fixed order ============================
local indicators = {}
for i, name in ipairs(order) do
	indicators[name] = createChip(name, i) -- 1..N left->right, container is right-aligned
end

-- === Cooldown runtime ======================================
local cooldownTimers = { Deflect = 0, Grapple = 0, Dodge = 0 }
local justOffCooldown = { Deflect = false, Grapple = false, Dodge = false }

local function use(name)
	if cooldownTimers[name] <= 0 then
		cooldownTimers[name] = cooldownConfigs[name].Cooldown
	end
end

-- Simple input hooks (placeholder until wired to actual ability events)
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Q then use("Deflect") end
	if input.KeyCode == Enum.KeyCode.E then use("Grapple") end
	if input.KeyCode == Enum.KeyCode.V then use("Dodge") end
end)

local function flashReady(ui)
	-- one quick blink of a small white square
	ui.Blink.Visible = true
	task.wait(0.11)
	ui.Blink.Visible = false
end

local function setCooldownVisual(ui, pct, active)
	if active then
		-- Gray out: dim overlay + lighten icon from black to gray + dim key badge
		ui.Overlay.Visible = true
		ui.Overlay.BackgroundTransparency = 0.45 + 0.35 * (1 - pct) -- stronger dim early, fades as it nears ready
		ui.Icon.ImageColor3 = Color3.fromRGB(90, 90, 90)
		ui.KeyBadge.TextTransparency = 0.45
		ui.CooldownText.Visible = true
	else
		-- Ready: full black icon, no overlay
		ui.Overlay.Visible = false
		ui.Icon.ImageColor3 = Color3.fromRGB(0, 0, 0)
		ui.KeyBadge.TextTransparency = 0
		ui.CooldownText.Visible = false
	end
end

local function update(dt)
	for _, name in ipairs(order) do
		local t = cooldownTimers[name]
		local ui = indicators[name]

		if t > 0 then
			t = math.max(0, t - dt)
			cooldownTimers[name] = t
			local pct = t / cooldownConfigs[name].Cooldown
			setCooldownVisual(ui, pct, true)
			ui.CooldownText.Text = string.format("%.1f", t)
			justOffCooldown[name] = true
		else
			if justOffCooldown[name] then
				justOffCooldown[name] = false
				-- Blink once when becoming ready
				task.spawn(flashReady, ui)
			end
			setCooldownVisual(ui, 0, false)
		end
	end
end

RunService.RenderStepped:Connect(update)

-- Reset on respawn
player.CharacterAdded:Connect(function()
	for k in pairs(cooldownTimers) do
		cooldownTimers[k] = 0
		justOffCooldown[k] = false
	end
end)
