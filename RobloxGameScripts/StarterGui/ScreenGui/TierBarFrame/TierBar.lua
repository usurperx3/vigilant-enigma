-- LocalScript: StarterGui>ScreenGui>TierBarFrame>TierBar
-- TierBar.lua [LocalScript]
-- Displays Sol Dust progression and weapon tier unlocks
-- Place in StarterGui > ScreenGui > TierBarFrame

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- GUI References
local screenGui = script.Parent.Parent -- ScreenGui
local tierBarFrame = script.Parent -- TierBarFrame

-- Ensure parent frame is fullscreen and transparent
tierBarFrame.Size = UDim2.new(1, 0, 1, 0) -- Fullscreen
tierBarFrame.Position = UDim2.new(0, 0, 0, 0) -- Top-left
tierBarFrame.BackgroundTransparency = 1 -- Invisible

-- Tier configuration (from GameConfig)
local tierThresholds = {
	[1] = 0,   -- Passive (always unlocked)
	[2] = 100, -- Ability
	[3] = 250  -- Ultimate
}

local tierNames = {
	[1] = "PASSIVE",
	[2] = "ABILITY",
	[3] = "ULTIMATE"
}

local tierKeys = {
	[1] = "1",
	[2] = "2",
	[3] = "3"
}

-- Track Sol Dust (placeholder until weapon system is implemented)
local currentSolDust = 0

-- Create tier bar container
local tierBarContainer = Instance.new("Frame")
tierBarContainer.Name = "TierBarContainer"
tierBarContainer.Size = UDim2.new(0, 360, 0, 70)
tierBarContainer.Position = UDim2.new(0, 20, 1, -20) -- Bottom left with margin
tierBarContainer.AnchorPoint = Vector2.new(0, 1) -- Anchor to bottom-left corner
tierBarContainer.BackgroundTransparency = 1
tierBarContainer.Parent = tierBarFrame

-- Create individual tier slots
local tierSlots = {}

for i = 1, 3 do
	-- Slot background
	local slot = Instance.new("Frame")
	slot.Name = "TierSlot" .. i
	slot.Size = UDim2.new(0, 110, 0, 70)
	slot.Position = UDim2.new(0, (i-1) * 120, 0, 0)
	slot.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	slot.BorderSizePixel = 0
	slot.Parent = tierBarContainer

	local slotCorner = Instance.new("UICorner")
	slotCorner.CornerRadius = UDim.new(0, 6)
	slotCorner.Parent = slot

	-- Tier name label
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, 0, 0, 15)
	nameLabel.Position = UDim2.new(0, 0, 0, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = tierNames[i]
	nameLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	nameLabel.TextSize = 10
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = slot

	-- Progress bar background
	local progressBg = Instance.new("Frame")
	progressBg.Name = "ProgressBackground"
	progressBg.Size = UDim2.new(0.9, 0, 0, 8)
	progressBg.Position = UDim2.new(0.05, 0, 0, 25)
	progressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	progressBg.BorderSizePixel = 0
	progressBg.Parent = slot

	local progressBgCorner = Instance.new("UICorner")
	progressBgCorner.CornerRadius = UDim.new(0, 4)
	progressBgCorner.Parent = progressBg

	-- Progress bar fill
	local progressFill = Instance.new("Frame")
	progressFill.Name = "ProgressFill"
	progressFill.Size = UDim2.new(0, 0, 1, 0)
	progressFill.Position = UDim2.new(0, 0, 0, 0)
	progressFill.BackgroundColor3 = Color3.fromRGB(255, 200, 50) -- Gold color for Sol Dust
	progressFill.BorderSizePixel = 0
	progressFill.Parent = progressBg

	local progressFillCorner = Instance.new("UICorner")
	progressFillCorner.CornerRadius = UDim.new(0, 4)
	progressFillCorner.Parent = progressFill

	-- Keybind indicator
	local keybindLabel = Instance.new("TextLabel")
	keybindLabel.Name = "KeybindLabel"
	keybindLabel.Size = UDim2.new(0, 30, 0, 30)
	keybindLabel.Position = UDim2.new(0.5, 0, 1, -35)
	keybindLabel.AnchorPoint = Vector2.new(0.5, 0)
	keybindLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	keybindLabel.BorderSizePixel = 0
	keybindLabel.Text = tierKeys[i]
	keybindLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	keybindLabel.TextSize = 16
	keybindLabel.Font = Enum.Font.GothamBold
	keybindLabel.Parent = slot

	local keybindCorner = Instance.new("UICorner")
	keybindCorner.CornerRadius = UDim.new(0, 4)
	keybindCorner.Parent = keybindLabel

	-- Status label (LOCKED/UNLOCKED)
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(1, 0, 0, 12)
	statusLabel.Position = UDim2.new(0, 0, 0, 38)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = "LOCKED"
	statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	statusLabel.TextSize = 9
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.Parent = slot

	tierSlots[i] = {
		Slot = slot,
		ProgressFill = progressFill,
		StatusLabel = statusLabel,
		KeybindLabel = keybindLabel
	}
end

-- Update tier bar based on Sol Dust
local function updateTierBar()
	for i = 1, 3 do
		local slot = tierSlots[i]
		local threshold = tierThresholds[i]
		local nextThreshold = tierThresholds[i + 1] or 999999

		if currentSolDust >= threshold then
			-- Tier is unlocked
			slot.StatusLabel.Text = "UNLOCKED"
			slot.StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)

			-- Calculate progress to next tier
			if i < 3 then
				local progress = (currentSolDust - threshold) / (nextThreshold - threshold)
				progress = math.clamp(progress, 0, 1)
				slot.ProgressFill.Size = UDim2.new(progress, 0, 1, 0)
			else
				-- Max tier
				slot.ProgressFill.Size = UDim2.new(1, 0, 1, 0)
			end
		else
			-- Tier is locked
			slot.StatusLabel.Text = "LOCKED"
			slot.StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)

			-- Show progress toward unlocking this tier
			if i > 1 then
				local prevThreshold = tierThresholds[i - 1]
				local progress = (currentSolDust - prevThreshold) / (threshold - prevThreshold)
				progress = math.clamp(progress, 0, 1)
				slot.ProgressFill.Size = UDim2.new(progress, 0, 1, 0)
			else
				slot.ProgressFill.Size = UDim2.new(1, 0, 1, 0) -- Passive always shown as full
			end
		end
	end
end

-- Listen for Sol Dust changes (placeholder - will connect to weapon system later)
local function onSolDustChanged(newAmount)
	currentSolDust = newAmount
	updateTierBar()
end

-- Create Sol Dust value in character for testing
local solDustValue = character:FindFirstChild("SolDustValue")
if not solDustValue then
	solDustValue = Instance.new("NumberValue")
	solDustValue.Name = "SolDustValue"
	solDustValue.Value = 0
	solDustValue.Parent = character
end

-- Connect to Sol Dust changes
solDustValue.Changed:Connect(function(value)
	onSolDustChanged(value)
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter

	-- Wait for Sol Dust value
	solDustValue = character:WaitForChild("SolDustValue", 10)
	if solDustValue then
		solDustValue.Changed:Connect(function(value)
			onSolDustChanged(value)
		end)
		currentSolDust = solDustValue.Value
		updateTierBar()
	end
end)

-- Initial update
updateTierBar()

print("TierBar initialized for:", player.Name)
print("Note: Sol Dust system is placeholder - will integrate with weapon system later")
