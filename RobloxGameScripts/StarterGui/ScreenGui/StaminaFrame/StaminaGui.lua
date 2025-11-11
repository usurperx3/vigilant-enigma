-- LocalScript: StarterGui>ScreenGui>StaminaFrame>StaminaGui
-- StaminaGui.lua [LocalScript]
-- Displays stamina bar in Bottom Center of screen
-- Place in StarterGui > ScreenGui > StaminaFrame

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Stamina tracking variables (mirrored from CharacterController)
local currentStamina = 100
local maxStamina = 100

-- Create a NumberValue in the character to track stamina (set by CharacterController)
local staminaValue = character:FindFirstChild("StaminaValue")
if not staminaValue then
	staminaValue = Instance.new("NumberValue")
	staminaValue.Name = "StaminaValue"
	staminaValue.Value = maxStamina
	staminaValue.Parent = character
end

local maxStaminaValue = character:FindFirstChild("MaxStaminaValue")
if not maxStaminaValue then
	maxStaminaValue = Instance.new("NumberValue")
	maxStaminaValue.Name = "MaxStaminaValue"
	maxStaminaValue.Value = maxStamina
	maxStaminaValue.Parent = character
end

-- GUI References
local screenGui = script.Parent.Parent -- ScreenGui
screenGui.IgnoreGuiInset = true

local staminaFrame = script.Parent -- StaminaFrame
staminaFrame.Size = UDim2.new(1, 0, 1, 0)
staminaFrame.AnchorPoint = Vector2.new(0, 0)
staminaFrame.Position = UDim2.new(0, 0, 0, 0)
staminaFrame.BackgroundTransparency = 1

-- Create stamina bar elements if they don't exist
local staminaBarBackground = staminaFrame:FindFirstChild("StaminaBarBackground")
if not staminaBarBackground then
	staminaBarBackground = Instance.new("Frame")
	staminaBarBackground.Name = "StaminaBarBackground"
	staminaBarBackground.Size = UDim2.new(0, 320, 0, 20)
	staminaBarBackground.Position = UDim2.new(0.5, 0, 1, -60)
	staminaBarBackground.AnchorPoint = Vector2.new(0.5, 1)
	staminaBarBackground.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Darker background
	staminaBarBackground.BorderSizePixel = 0 -- No border for minimalist look
	staminaBarBackground.Parent = staminaFrame

	-- Add rounded corners
	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = UDim.new(0, 6) -- 6px rounded corners
	bgCorner.Parent = staminaBarBackground
end

local staminaBar = staminaBarBackground:FindFirstChild("StaminaBar")
if not staminaBar then
	staminaBar = Instance.new("Frame")
	staminaBar.Name = "StaminaBar"
	staminaBar.Size = UDim2.new(1, 0, 1, 0)
	staminaBar.Position = UDim2.new(0, 0, 0, 0)
	staminaBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Green by default
	staminaBar.BorderSizePixel = 0
	staminaBar.Parent = staminaBarBackground

	-- Add rounded corners to stamina bar
	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 6) -- 6px rounded corners
	barCorner.Parent = staminaBar
end

local staminaLabel = staminaBarBackground:FindFirstChild("StaminaLabel")
if not staminaLabel then
	staminaLabel = Instance.new("TextLabel")
	staminaLabel.Name = "StaminaLabel"
	staminaLabel.Size = UDim2.new(1, -12, 1, 0)
	staminaLabel.Position = UDim2.new(0, 6, 0, 0)
	staminaLabel.BackgroundTransparency = 1
	staminaLabel.Text = "STAMINA: 100/100"
	staminaLabel.TextColor3 = Color3.fromRGB(220, 220, 220) -- Slightly darker white
	staminaLabel.TextSize = 12 -- Smaller, more minimalist
	staminaLabel.Font = Enum.Font.Gotham -- Cleaner font
	staminaLabel.TextStrokeTransparency = 0.7 -- Subtle stroke
	staminaLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	staminaLabel.TextXAlignment = Enum.TextXAlignment.Center
	staminaLabel.ZIndex = 2
	staminaLabel.Parent = staminaBarBackground
end

-- Stamina color thresholds (from GameConfig)
local function getStaminaColor(percentage)
	if percentage > 0.6 then
		return Color3.fromRGB(0, 255, 0) -- Green
	elseif percentage > 0.3 then
		return Color3.fromRGB(255, 255, 0) -- Yellow
	else
		return Color3.fromRGB(255, 0, 0) -- Red
	end
end

-- Update stamina bar
local function updateStaminaBar()
	-- Read from character's stamina values
	currentStamina = staminaValue.Value
	maxStamina = maxStaminaValue.Value

	local percentage = currentStamina / maxStamina

	-- Update bar size
	staminaBar.Size = UDim2.new(percentage, 0, 1, 0)

	-- Update bar color based on percentage
	staminaBar.BackgroundColor3 = getStaminaColor(percentage)

	-- Update label text
	staminaLabel.Text = string.format("STAMINA: %d/%d", math.floor(currentStamina), maxStamina)
end

-- Connect to RenderStepped for smooth updates
RunService.RenderStepped:Connect(updateStaminaBar)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")

	-- Wait for stamina values to be created
	staminaValue = character:WaitForChild("StaminaValue", 10)
	maxStaminaValue = character:WaitForChild("MaxStaminaValue", 10)

	if not staminaValue then
		staminaValue = Instance.new("NumberValue")
		staminaValue.Name = "StaminaValue"
		staminaValue.Value = 100
		staminaValue.Parent = character
	end

	if not maxStaminaValue then
		maxStaminaValue = Instance.new("NumberValue")
		maxStaminaValue.Name = "MaxStaminaValue"
		maxStaminaValue.Value = 100
		maxStaminaValue.Parent = character
	end
end)

print("StaminaGui initialized for:", player.Name)
