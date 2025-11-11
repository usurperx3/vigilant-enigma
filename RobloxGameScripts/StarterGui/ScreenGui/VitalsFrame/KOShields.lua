-- LocalScript: StarterGui>ScreenGui>VitalsFrame>KOShields
-- KOShields.lua [LocalScript]
-- Displays KO shields indicator in Bottom Center
-- Place in StarterGui > ScreenGui > VitalsFrame

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- GUI References
local screenGui = script.Parent.Parent -- ScreenGui
screenGui.IgnoreGuiInset = true

local vitalsFrame = script.Parent -- VitalsFrame
vitalsFrame.Size = UDim2.new(1, 0, 1, 0)
vitalsFrame.BackgroundTransparency = 1

-- KO Shields configuration
local maxShields = 3 -- Default number of KO shields

-- Create KO shields container
local shieldsContainer = vitalsFrame:FindFirstChild("KOShieldsContainer")
if not shieldsContainer then
	shieldsContainer = Instance.new("Frame")
	shieldsContainer.Name = "KOShieldsContainer"
	shieldsContainer.Size = UDim2.new(0, 320, 0, 24)
	shieldsContainer.Position = UDim2.new(0.5, 0, 1, -20)
	shieldsContainer.AnchorPoint = Vector2.new(0.5, 1)
	shieldsContainer.BackgroundTransparency = 1
	shieldsContainer.Parent = vitalsFrame
end

-- Create label
local shieldsLabel = shieldsContainer:FindFirstChild("ShieldsLabel")
if not shieldsLabel then
	shieldsLabel = Instance.new("TextLabel")
	shieldsLabel.Name = "ShieldsLabel"
	shieldsLabel.Size = UDim2.new(0, 120, 1, 0)
	shieldsLabel.Position = UDim2.new(0, 0, 0, 0)
	shieldsLabel.BackgroundTransparency = 1
	shieldsLabel.Text = "KO SHIELDS"
	shieldsLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	shieldsLabel.TextSize = 12
	shieldsLabel.Font = Enum.Font.Gotham
	shieldsLabel.TextXAlignment = Enum.TextXAlignment.Left
	shieldsLabel.TextStrokeTransparency = 0.7
	shieldsLabel.Parent = shieldsContainer
end

-- Create shield indicators container
local shieldIconsFrame = shieldsContainer:FindFirstChild("ShieldIconsFrame")
if not shieldIconsFrame then
	shieldIconsFrame = Instance.new("Frame")
	shieldIconsFrame.Name = "ShieldIconsFrame"
	shieldIconsFrame.Size = UDim2.new(0, 120, 1, 0)
	shieldIconsFrame.Position = UDim2.new(0, 130, 0, 0)
	shieldIconsFrame.BackgroundTransparency = 1
	shieldIconsFrame.Parent = shieldsContainer
end

-- Create shield icons
local shieldIcons = {}
for i = 1, maxShields do
	local shieldIcon = shieldIconsFrame:FindFirstChild("Shield" .. i)
	if not shieldIcon then
		shieldIcon = Instance.new("Frame")
		shieldIcon.Name = "Shield" .. i
		shieldIcon.Size = UDim2.new(0, 18, 0, 18)
		shieldIcon.Position = UDim2.new(0, (i - 1) * 30, 0.5, 0)
		shieldIcon.AnchorPoint = Vector2.new(0, 0.5)
		shieldIcon.BackgroundColor3 = Color3.fromRGB(100, 200, 255) -- Blue shield color
		shieldIcon.BorderSizePixel = 0
		shieldIcon.Parent = shieldIconsFrame

		local shieldCorner = Instance.new("UICorner")
		shieldCorner.CornerRadius = UDim.new(1, 0) -- Fully round
		shieldCorner.Parent = shieldIcon

		-- Inner circle for visual effect
		local innerCircle = Instance.new("Frame")
		innerCircle.Name = "InnerCircle"
		innerCircle.Size = UDim2.new(0.6, 0, 0.6, 0)
		innerCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
		innerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
		innerCircle.BackgroundColor3 = Color3.fromRGB(150, 220, 255)
		innerCircle.BorderSizePixel = 0
		innerCircle.Parent = shieldIcon

		local innerCorner = Instance.new("UICorner")
		innerCorner.CornerRadius = UDim.new(1, 0)
		innerCorner.Parent = innerCircle
	end

	table.insert(shieldIcons, shieldIcon)
end

-- Update shield display
local function updateShields()
	-- Get current shield count from character
	local shieldValue = character:FindFirstChild("KOShieldsValue")
	local currentShields = shieldValue and shieldValue.Value or maxShields

	for i = 1, maxShields do
		local icon = shieldIcons[i]
		if icon then
			local innerCircle = icon:FindFirstChild("InnerCircle")
			if i <= currentShields then
				-- Shield is active
				icon.BackgroundTransparency = 0
				icon.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
				if innerCircle then
					innerCircle.BackgroundTransparency = 0
				end
			else
				-- Shield is depleted
				icon.BackgroundTransparency = 0.7
				icon.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				if innerCircle then
					innerCircle.BackgroundTransparency = 0.9
				end
			end
		end
	end
end

-- Create KO shields value in character
local shieldValue = character:FindFirstChild("KOShieldsValue")
if not shieldValue then
	shieldValue = Instance.new("IntValue")
	shieldValue.Name = "KOShieldsValue"
	shieldValue.Value = maxShields
	shieldValue.Parent = character
end

-- Connect to shield changes
shieldValue.Changed:Connect(updateShields)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter

	-- Wait for shield value
	shieldValue = character:WaitForChild("KOShieldsValue", 10)
	if not shieldValue then
		shieldValue = Instance.new("IntValue")
		shieldValue.Name = "KOShieldsValue"
		shieldValue.Value = maxShields
		shieldValue.Parent = character
	end

	shieldValue.Changed:Connect(updateShields)
	updateShields()
end)

-- Initial update
updateShields()

print("KOShields initialized for:", player.Name)
print("Note: KO shield system is placeholder - will integrate with combat system later")
