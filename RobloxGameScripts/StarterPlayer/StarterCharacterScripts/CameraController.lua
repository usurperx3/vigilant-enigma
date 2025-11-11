-- LocalScript: StarterPlayer>StarterCharacterScripts>CameraController
-- CameraController.lua [LocalScript]
-- Third-person camera system for the RPG game
-- Place in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Camera Configuration
local Config = {
	-- Distance settings
	MinDistance = 8,
	MaxDistance = 20,
	DefaultDistance = 12,
	ZoomSpeed = 2,

	-- Angle settings
	MinPitch = -80, -- degrees (looking down)
	MaxPitch = 80,  -- degrees (looking up)

	-- Smoothing
	Smoothness = 0.15,
	RotationSpeed = 0.3,

	-- Offset from character (Over-the-shoulder style)
	OffsetY = 2, -- Height offset above character
	OffsetX = 4, -- Horizontal offset for RIGHT shoulder (left will be -3)
	OffsetXLeft = 3, -- Horizontal offset for LEFT shoulder (slightly less than right)
	OffsetZ = 0, -- Forward/backward offset

	-- Mouse sensitivity
	MouseSensitivity = 0.3,

	-- Lock on target settings (for future use)
	LockOnEnabled = false,
	LockOnDistance = 30
}

-- State variables
local currentDistance = Config.DefaultDistance
local currentRotationX = 0 -- Horizontal rotation (yaw)
local currentRotationY = 0 -- Vertical rotation (pitch)
local cameraLocked = false -- Toggle state for camera lock
local lastMousePosition = Vector2.new()
local isRightShoulder = true -- Track which shoulder camera is on (true = right, false = left)
local currentShoulderOffset = Config.OffsetX -- Smoothly transitions between shoulder positions
local targetShoulderOffset = Config.OffsetX -- Target offset for smooth transition

-- Camera shake variables (for future combat feel)
local shakeOffset = Vector3.new()
local shakeMagnitude = 0

-- Set camera to scriptable mode
camera.CameraType = Enum.CameraType.Scriptable

-- Input handling
local function onInputBegan(input, gameProcessed)
	if gameProcessed then return end

	-- Tab key to toggle camera lock
	if input.KeyCode == Enum.KeyCode.CapsLock then
		-- Toggle camera lock
		cameraLocked = not cameraLocked

		if cameraLocked then
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			UserInputService.MouseIconEnabled = false -- Hide cursor
			print("Camera locked - mouse controls camera")
		else
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true -- Show cursor
			print("Camera unlocked - character faces camera direction")
		end
	end

	-- Toggle camera shoulder (F key)
	if input.KeyCode == Enum.KeyCode.F then
		isRightShoulder = not isRightShoulder
		if isRightShoulder then
			targetShoulderOffset = Config.OffsetX -- Right shoulder (4 studs)
			print("Camera view: Right shoulder")
		else
			targetShoulderOffset = -Config.OffsetXLeft -- Left shoulder (-3 studs)
			print("Camera view: Left shoulder")
		end
	end
end

local function onInputEnded(input, gameProcessed)
	-- No longer needed for toggle, but keeping for future input handling
end

local function onInputChanged(input, gameProcessed)
	if gameProcessed then return end

	-- Handle mouse wheel zoom
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		currentDistance = math.clamp(
			currentDistance - input.Position.Z * Config.ZoomSpeed,
			Config.MinDistance,
			Config.MaxDistance
		)
	end

	-- Handle camera rotation (only when camera is locked)
	if input.UserInputType == Enum.UserInputType.MouseMovement and cameraLocked then
		local delta = input.Delta

		-- Update rotation with sensitivity
		currentRotationX = currentRotationX - delta.X * Config.MouseSensitivity
		-- Inverted Y: moving mouse up looks up (positive delta.Y increases pitch)
		currentRotationY = math.clamp(
			currentRotationY + delta.Y * Config.MouseSensitivity,
			Config.MinPitch,
			Config.MaxPitch
		)
	end
end

-- Calculate camera position
local function updateCamera()
	if not character or not character.Parent then
		character = player.Character
		if character then
			humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		end
		return
	end

	if not humanoidRootPart or not humanoidRootPart.Parent then
		return
	end

	-- Make character face camera direction (shift-lock style)
	-- Only rotate on Y axis (horizontal), not pitch
	local rotationXRad = math.rad(currentRotationX)
	local targetCFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, rotationXRad, 0)
	humanoidRootPart.CFrame = targetCFrame

	-- Get character position with vertical offset
	local characterPosition = humanoidRootPart.Position + Vector3.new(0, Config.OffsetY, 0)

	-- Calculate camera rotation
	local rotationYRad = math.rad(currentRotationY)

	-- Calculate camera offset based on rotation and distance
	local horizontalDistance = currentDistance * math.cos(rotationYRad)
	local verticalDistance = currentDistance * math.sin(rotationYRad)

	-- Base offset from rotation
	local offsetX = horizontalDistance * math.sin(rotationXRad)
	local offsetZ = horizontalDistance * math.cos(rotationXRad)

	-- Apply over-the-shoulder offset (shifts camera to the right or left based on toggle)
	-- We need to calculate the "right" vector based on camera rotation
	local rightVector = Vector3.new(math.cos(rotationXRad), 0, -math.sin(rotationXRad))
	local forwardVector = Vector3.new(math.sin(rotationXRad), 0, math.cos(rotationXRad))

	-- Smoothly interpolate shoulder offset for smooth transition (0.25 = quick but smooth)
	currentShoulderOffset = currentShoulderOffset + (targetShoulderOffset - currentShoulderOffset) * 0.25

	-- Apply shoulder offset in character-relative space
	local shoulderOffset = (rightVector * currentShoulderOffset) + (forwardVector * Config.OffsetZ)

	-- Calculate final camera position
	local targetPosition = characterPosition + Vector3.new(offsetX, verticalDistance, offsetZ) + shoulderOffset

	-- Apply camera shake (if any)
	targetPosition = targetPosition + shakeOffset

	-- Smooth camera movement
	local currentPosition = camera.CFrame.Position
	local smoothedPosition = currentPosition:Lerp(targetPosition, Config.Smoothness)

	-- Calculate look-at position (offset slightly based on current shoulder)
	local lookAtPosition = characterPosition + (rightVector * (currentShoulderOffset * 0.5))

	-- Set camera CFrame (look at offset character position)
	camera.CFrame = CFrame.new(smoothedPosition, lookAtPosition)

	-- Update shake (decay over time)
	if shakeMagnitude > 0 then
		shakeMagnitude = shakeMagnitude * 0.9
		if shakeMagnitude < 0.01 then
			shakeMagnitude = 0
			shakeOffset = Vector3.new()
		else
			-- Random shake offset
			shakeOffset = Vector3.new(
				(math.random() - 0.5) * shakeMagnitude,
				(math.random() - 0.5) * shakeMagnitude,
				(math.random() - 0.5) * shakeMagnitude
			)
		end
	end
end

-- Camera shake function (for hit feedback, explosions, etc.)
local function shakeCamera(magnitude, duration)
	shakeMagnitude = magnitude

	-- Optional: add duration-based decay
	if duration then
		task.delay(duration, function()
			shakeMagnitude = 0
			shakeOffset = Vector3.new()
		end)
	end
end

-- Reset camera to default
local function resetCamera()
	currentDistance = Config.DefaultDistance
	currentRotationX = 0
	currentRotationY = 0
end

-- Initialize camera system
local function setup()
	-- Connect input handlers
	UserInputService.InputBegan:Connect(onInputBegan)
	UserInputService.InputEnded:Connect(onInputEnded)
	UserInputService.InputChanged:Connect(onInputChanged)

	-- Connect camera update to render step for smooth motion
	RunService.RenderStepped:Connect(updateCamera)

	-- Handle character respawn
	player.CharacterAdded:Connect(function(newCharacter)
		character = newCharacter
		humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		resetCamera()
	end)

	print("CameraController initialized for:", player.Name)
	print("Controls: Tab = Toggle Camera Lock, F = Toggle Shoulder View")
end

-- Initialize
setup()

-- Export functions for other scripts
return {
	ShakeCamera = shakeCamera,
	ResetCamera = resetCamera,
	Config = Config
}
