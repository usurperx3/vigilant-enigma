-- LocalScript: StarterGui>ScreenGui>LoadoutFrame>LoadoutDisplay
-- LoadoutDisplay.lua [LocalScript] - CORRECT VERSION
-- Displays currently equipped primary weapon and secondary cosmetic
-- Place in StarterGui > ScreenGui > LoadoutFrame

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- GUI References
local screenGui = script.Parent.Parent -- ScreenGui
local loadoutFrame = script.Parent -- LoadoutFrame

-- Ensure parent frame is fullscreen and transparent
loadoutFrame.Size = UDim2.new(1, 0, 1, 0) -- Fullscreen
loadoutFrame.Position = UDim2.new(0, 0, 0, 0) -- Top-left
loadoutFrame.BackgroundTransparency = 1 -- Invisible

-- Create primary weapon display (large square) - More compact
local primaryWeaponDisplay = Instance.new("Frame")
primaryWeaponDisplay.Name = "PrimaryWeaponDisplay"
primaryWeaponDisplay.Size = UDim2.new(0, 60, 0, 60) -- Reduced from 80x80
primaryWeaponDisplay.Position = UDim2.new(1, -20, 1, -20) -- Bottom right with margin
primaryWeaponDisplay.AnchorPoint = Vector2.new(1, 1) -- Anchor to bottom-right corner
primaryWeaponDisplay.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
primaryWeaponDisplay.BorderSizePixel = 0
primaryWeaponDisplay.Parent = loadoutFrame

local primaryCorner = Instance.new("UICorner")
primaryCorner.CornerRadius = UDim.new(0, 6)
primaryCorner.Parent = primaryWeaponDisplay

-- Primary weapon icon (placeholder)
local primaryIcon = Instance.new("ImageLabel")
primaryIcon.Name = "PrimaryIcon"
primaryIcon.Size = UDim2.new(0.8, 0, 0.8, 0)
primaryIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
primaryIcon.AnchorPoint = Vector2.new(0.5, 0.5)
primaryIcon.BackgroundTransparency = 1
primaryIcon.Image = "" -- Will be set by weapon system
primaryIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)
primaryIcon.Parent = primaryWeaponDisplay

-- Primary weapon label
local primaryLabel = Instance.new("TextLabel")
primaryLabel.Name = "PrimaryLabel"
primaryLabel.Size = UDim2.new(1, 0, 0, 15)
primaryLabel.Position = UDim2.new(0, 0, 1, 2)
primaryLabel.BackgroundTransparency = 1
primaryLabel.Text = "PRIMARY"
primaryLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
primaryLabel.TextSize = 9
primaryLabel.Font = Enum.Font.Gotham
primaryLabel.TextStrokeTransparency = 0.7
primaryLabel.Parent = primaryWeaponDisplay

-- Keybind indicator (T key)
local primaryKeybind = Instance.new("TextLabel")
primaryKeybind.Name = "PrimaryKeybind"
primaryKeybind.Size = UDim2.new(0, 20, 0, 20)
primaryKeybind.Position = UDim2.new(0, 5, 0, 5)
primaryKeybind.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
primaryKeybind.BorderSizePixel = 0
primaryKeybind.Text = "T"
primaryKeybind.TextColor3 = Color3.fromRGB(220, 220, 220)
primaryKeybind.TextSize = 12
primaryKeybind.Font = Enum.Font.GothamBold
primaryKeybind.Parent = primaryWeaponDisplay

local keybindCorner = Instance.new("UICorner")
keybindCorner.CornerRadius = UDim.new(0, 4)
keybindCorner.Parent = primaryKeybind

-- Create secondary cosmetic display (small square) - More compact
local secondaryDisplay = Instance.new("Frame")
secondaryDisplay.Name = "SecondaryDisplay"
secondaryDisplay.Size = UDim2.new(0, 50, 0, 50) -- Slightly smaller
secondaryDisplay.Position = UDim2.new(0, -10, 0.5, 0) -- Closer to primary (was -60)
secondaryDisplay.AnchorPoint = Vector2.new(1, 0.5) -- Anchor to right-center
secondaryDisplay.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
secondaryDisplay.BorderSizePixel = 0
secondaryDisplay.Parent = primaryWeaponDisplay

local secondaryCorner = Instance.new("UICorner")
secondaryCorner.CornerRadius = UDim.new(0, 6)
secondaryCorner.Parent = secondaryDisplay

-- Secondary cosmetic icon (placeholder)
local secondaryIcon = Instance.new("ImageLabel")
secondaryIcon.Name = "SecondaryIcon"
secondaryIcon.Size = UDim2.new(0.8, 0, 0.8, 0)
secondaryIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
secondaryIcon.AnchorPoint = Vector2.new(0.5, 0.5)
secondaryIcon.BackgroundTransparency = 1
secondaryIcon.Image = "" -- Will be set by cosmetic system
secondaryIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)
secondaryIcon.Parent = secondaryDisplay

-- Secondary label
local secondaryLabel = Instance.new("TextLabel")
secondaryLabel.Name = "SecondaryLabel"
secondaryLabel.Size = UDim2.new(1, 0, 0, 12)
secondaryLabel.Position = UDim2.new(0, 0, 1, 2)
secondaryLabel.BackgroundTransparency = 1
secondaryLabel.Text = "COSMETIC"
secondaryLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
secondaryLabel.TextSize = 8
secondaryLabel.Font = Enum.Font.Gotham
secondaryLabel.TextStrokeTransparency = 0.7
secondaryLabel.Parent = secondaryDisplay

-- Placeholder text when no weapon equipped
local noWeaponText = Instance.new("TextLabel")
noWeaponText.Name = "NoWeaponText"
noWeaponText.Size = UDim2.new(1, 0, 1, 0)
noWeaponText.Position = UDim2.new(0, 0, 0, 0)
noWeaponText.BackgroundTransparency = 1
noWeaponText.Text = "?"
noWeaponText.TextColor3 = Color3.fromRGB(100, 100, 100)
noWeaponText.TextSize = 36
noWeaponText.Font = Enum.Font.GothamBold
noWeaponText.Parent = primaryIcon

-- Active weapon indicator (border highlight)
local activeIndicator = Instance.new("UIStroke")
activeIndicator.Name = "ActiveIndicator"
activeIndicator.Thickness = 3
activeIndicator.Color = Color3.fromRGB(100, 255, 100) -- Green
activeIndicator.Transparency = 1 -- Hidden by default
activeIndicator.Parent = primaryWeaponDisplay

-- Secondary active indicator
local secondaryActiveIndicator = Instance.new("UIStroke")
secondaryActiveIndicator.Name = "ActiveIndicator"
secondaryActiveIndicator.Thickness = 3
secondaryActiveIndicator.Color = Color3.fromRGB(100, 255, 100)
secondaryActiveIndicator.Transparency = 1
secondaryActiveIndicator.Parent = secondaryDisplay

-- Update loadout display based on equipped items
local function updateLoadout()
	-- Check for equipped weapon data in character
	local equippedWeapon = character:FindFirstChild("EquippedWeapon")
	local equippedCosmetic = character:FindFirstChild("EquippedCosmetic")

	-- Check which slot is active
	local currentSlot = character:FindFirstChild("CurrentSlot")
	if currentSlot then
		if currentSlot.Value == "Primary" then
			activeIndicator.Transparency = 0 -- Show primary border
			secondaryActiveIndicator.Transparency = 1 -- Hide secondary border
		elseif currentSlot.Value == "Secondary" then
			activeIndicator.Transparency = 1 -- Hide primary border
			secondaryActiveIndicator.Transparency = 0 -- Show secondary border
		end
	end

	if equippedWeapon and equippedWeapon.Value ~= "" then
		primaryIcon.Image = equippedWeapon.Value
		noWeaponText.Visible = false
	else
		primaryIcon.Image = ""
		noWeaponText.Visible = true
	end

	if equippedCosmetic and equippedCosmetic.Value ~= "" then
		secondaryIcon.Image = equippedCosmetic.Value
	else
		secondaryIcon.Image = ""
	end
end

-- Create placeholder values for weapon/cosmetic
local equippedWeapon = character:FindFirstChild("EquippedWeapon")
if not equippedWeapon then
	equippedWeapon = Instance.new("StringValue")
	equippedWeapon.Name = "EquippedWeapon"
	equippedWeapon.Value = ""
	equippedWeapon.Parent = character
end

local equippedCosmetic = character:FindFirstChild("EquippedCosmetic")
if not equippedCosmetic then
	equippedCosmetic = Instance.new("StringValue")
	equippedCosmetic.Name = "EquippedCosmetic"
	equippedCosmetic.Value = ""
	equippedCosmetic.Parent = character
end

-- Track current slot (Primary/Secondary)
local currentSlot = character:FindFirstChild("CurrentSlot")
if not currentSlot then
	currentSlot = Instance.new("StringValue")
	currentSlot.Name = "CurrentSlot"
	currentSlot.Value = "Primary"
	currentSlot.Parent = character
end

-- Connect to changes
equippedWeapon.Changed:Connect(updateLoadout)
equippedCosmetic.Changed:Connect(updateLoadout)
currentSlot.Changed:Connect(updateLoadout)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter

	-- Wait for values
	equippedWeapon = character:WaitForChild("EquippedWeapon", 10)
	equippedCosmetic = character:WaitForChild("EquippedCosmetic", 10)
	currentSlot = character:WaitForChild("CurrentSlot", 10)

	if equippedWeapon then
		equippedWeapon.Changed:Connect(updateLoadout)
	end
	if equippedCosmetic then
		equippedCosmetic.Changed:Connect(updateLoadout)
	end
	if currentSlot then
		currentSlot.Changed:Connect(updateLoadout)
	end

	updateLoadout()
end)

-- Initial update
updateLoadout()

print("LoadoutDisplay initialized for:", player.Name)
print("Note: Weapon/cosmetic system is placeholder - will integrate with weapon system later")
