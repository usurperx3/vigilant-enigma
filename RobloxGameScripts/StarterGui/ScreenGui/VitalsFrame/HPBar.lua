-- LocalScript: StarterGui>ScreenGui>VitalsFrame>HPBar
-- HPBar.lua [LocalScript]
-- Displays HP bar in Bottom Center of screen (above stamina bar)
-- Place in StarterGui > ScreenGui > VitalsFrame

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- GUI References
local screenGui = script.Parent.Parent -- ScreenGui
screenGui.IgnoreGuiInset = true

local vitalsFrame = script.Parent -- VitalsFrame
vitalsFrame.Size = UDim2.new(1, 0, 1, 0)
vitalsFrame.BackgroundTransparency = 1

-- Create HP bar elements if they don't exist
local hpBarBackground = vitalsFrame:FindFirstChild("HPBarBackground")
if not hpBarBackground then
	hpBarBackground = Instance.new("Frame")
	hpBarBackground.Name = "HPBarBackground"
	hpBarBackground.Size = UDim2.new(0, 320, 0, 20)
	hpBarBackground.Position = UDim2.new(0.5, 0, 1, -100)
	hpBarBackground.AnchorPoint = Vector2.new(0.5, 1)
	hpBarBackground.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Dark background
	hpBarBackground.BorderSizePixel = 0
	hpBarBackground.Parent = vitalsFrame

	-- Add rounded corners
	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = UDim.new(0, 6)
	bgCorner.Parent = hpBarBackground
end

local hpBar = hpBarBackground:FindFirstChild("HPBar")
if not hpBar then
	hpBar = Instance.new("Frame")
	hpBar.Name = "HPBar"
	hpBar.Size = UDim2.new(1, 0, 1, 0)
	hpBar.Position = UDim2.new(0, 0, 0, 0)
	hpBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- Red
	hpBar.BorderSizePixel = 0
	hpBar.Parent = hpBarBackground

	-- Add rounded corners
	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 6)
	barCorner.Parent = hpBar
end

local hpLabel = hpBarBackground:FindFirstChild("HPLabel")
if not hpLabel then
	hpLabel = Instance.new("TextLabel")
	hpLabel.Name = "HPLabel"
	hpLabel.Size = UDim2.new(1, -12, 1, 0)
	hpLabel.Position = UDim2.new(0, 6, 0, 0)
	hpLabel.BackgroundTransparency = 1
	hpLabel.Text = "HP: 100/100"
	hpLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	hpLabel.TextSize = 12
	hpLabel.Font = Enum.Font.Gotham
	hpLabel.TextStrokeTransparency = 0.7
	hpLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	hpLabel.TextXAlignment = Enum.TextXAlignment.Center
	hpLabel.ZIndex = 2
	hpLabel.Parent = hpBarBackground
end

-- Update HP bar
local function updateHPBar()
	local currentHP = humanoid.Health
	local maxHP = humanoid.MaxHealth
	local percentage = currentHP / math.max(maxHP, 1)

	-- Update bar size
	hpBar.Size = UDim2.new(percentage, 0, 1, 0)

	-- Update label text
	hpLabel.Text = string.format("HP: %d/%d", math.floor(currentHP), math.floor(maxHP))
end

-- Connect to health changes
humanoid.HealthChanged:Connect(updateHPBar)

-- Connect to RenderStepped for smooth updates
RunService.RenderStepped:Connect(updateHPBar)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")

	-- Reconnect health changed
	humanoid.HealthChanged:Connect(updateHPBar)
end)

-- Initial update
updateHPBar()

print("HPBar initialized for:", player.Name)
