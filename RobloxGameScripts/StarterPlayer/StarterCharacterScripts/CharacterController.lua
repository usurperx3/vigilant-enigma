-- LocalScript: StarterPlayer>StarterCharacterScripts>CharacterController
-- CharacterController.lua [LocalScript]
-- Handles character movement, sprinting, and evading for the RPG game
-- Place in StarterPlayer > StarterCharacterScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Movement Configuration
local Config = {
	-- Base speeds
	WalkSpeed = 16,
	SprintSpeed = 24,

	-- Stamina settings
	MaxStamina = 100,
	SprintStaminaCost = 10, -- per second
	EvadeStaminaCost = 25,  -- per dodge roll
	StaminaRegenDelay = 5, -- seconds before regen starts
	StaminaRegenRate = 20, -- per second

	-- Jump settings
	JumpPower = 50,

	-- Evade/Dodge Roll settings
	DodgeDistance = 15, -- studs to move
	DodgeDuration = 0.4, -- seconds
	DodgeCooldown = 1.0, -- seconds between dodges (total time from start of one dodge to start of next)

	-- Animation settings
	AnimationBlendTime = 0.1
}

-- Keybind Configuration
local Keybinds = {
	-- Movement
	Sprint = Enum.KeyCode.LeftShift,
	Dodge = Enum.KeyCode.V,

	-- Combat (Future)
	Grapple = Enum.KeyCode.E,
	Deflect = Enum.KeyCode.Q,

	-- UI/System (Future)
	ToggleView = Enum.KeyCode.F,      -- Toggle camera view/spectate mode
	ToggleWeapon = Enum.KeyCode.T,    -- Switch between primary weapons

	-- Abilities (Future)
	Passive = Enum.KeyCode.One,       -- Activate passive (Tier 1)
	Ability1 = Enum.KeyCode.Two,      -- Activate ability (Tier 2)
	Ultimate = Enum.KeyCode.Three,    -- Activate ultimate (Tier 3)
}

-- State variables
local isSprinting = false
local isEvading = false
local canEvade = true
local currentStamina = Config.MaxStamina
local lastActionTime = 0
local lastEvadeTime = 0

-- Animation IDs (you'll replace these with your actual animation IDs)
local Animations = {
	Idle = nil, -- rbxassetid://YOUR_IDLE_ANIMATION_ID
	Walk = nil,
	Run = nil,
	Sprint = nil,
	Jump = nil,
	Fall = nil,
	DodgeRollForward = nil,  -- Add your forward dodge animation here
	DodgeRollBackward = nil, -- Add your backward dodge animation here
	DodgeRollLeft = nil,     -- Add your left dodge animation here
	DodgeRollRight = nil,    -- Add your right dodge animation here
}

-- Load animations
local loadedAnimations = {}
local animator = humanoid:WaitForChild("Animator")

local function loadAnimations()
	for name, animId in pairs(Animations) do
		if animId then
			local anim = Instance.new("Animation")
			anim.AnimationId = animId
			loadedAnimations[name] = animator:LoadAnimation(anim)
		end
	end
end

-- Initialize humanoid settings
local function initializeHumanoid()
	humanoid.WalkSpeed = Config.WalkSpeed
	humanoid.JumpPower = Config.JumpPower

	-- Configure humanoid state
	humanoid.AutoRotate = false -- Camera controls rotation (shift-lock style)
	humanoid.AutoJumpEnabled = false

	-- Create stamina values for GUI to read
	local staminaValue = character:FindFirstChild("StaminaValue")
	if not staminaValue then
		staminaValue = Instance.new("NumberValue")
		staminaValue.Name = "StaminaValue"
		staminaValue.Value = Config.MaxStamina
		staminaValue.Parent = character
	end

	local maxStaminaValue = character:FindFirstChild("MaxStaminaValue")
	if not maxStaminaValue then
		maxStaminaValue = Instance.new("NumberValue")
		maxStaminaValue.Name = "MaxStaminaValue"
		maxStaminaValue.Value = Config.MaxStamina
		maxStaminaValue.Parent = character
	end
end

-- Perform dodge roll
local function performDodge()
	-- Check if we can evade (stamina and cooldown)
	if not canEvade or isEvading or currentStamina < Config.EvadeStaminaCost then
		print("Cannot dodge - Not ready, already dodging, or insufficient stamina")
		return
	end

	-- Check cooldown
	local currentTime = tick()
	if currentTime - lastEvadeTime < Config.DodgeCooldown then
		print("Dodge on cooldown")
		return
	end

	-- IMMEDIATELY consume stamina (at the start of dodge)
	currentStamina = math.max(0, currentStamina - Config.EvadeStaminaCost)

	-- Update stamina value for GUI immediately
	local staminaValue = character:FindFirstChild("StaminaValue")
	if staminaValue then
		staminaValue.Value = currentStamina
	end

	lastActionTime = currentTime
	lastEvadeTime = currentTime

	-- Set evading state
	isEvading = true
	canEvade = false

	-- Get movement input direction
	local moveDirection = humanoid.MoveDirection

	-- If no movement input, dodge forward based on where character is facing
	local dodgeDirection
	if moveDirection.Magnitude > 0 then
		-- Use the actual movement direction (accounts for WASD input relative to camera)
		dodgeDirection = moveDirection.Unit
	else
		-- No input, dodge forward based on where character is facing
		dodgeDirection = rootPart.CFrame.LookVector
	end

	-- Keep dodge horizontal only (no vertical component)
	dodgeDirection = Vector3.new(dodgeDirection.X, 0, dodgeDirection.Z).Unit

	-- Determine which direction the dodge is relative to character facing
	-- This is used to select the correct animation
	local characterForward = rootPart.CFrame.LookVector
	local characterRight = rootPart.CFrame.RightVector

	-- Calculate dot products to determine direction
	local forwardDot = dodgeDirection:Dot(characterForward)
	local rightDot = dodgeDirection:Dot(characterRight)

	-- Determine primary dodge direction and select animation
	local dodgeAnimationName = "DodgeRollForward" -- Default

	if math.abs(forwardDot) > math.abs(rightDot) then
		-- Primarily forward or backward
		if forwardDot > 0 then
			dodgeAnimationName = "DodgeRollForward"
		else
			dodgeAnimationName = "DodgeRollBackward"
		end
	else
		-- Primarily left or right
		if rightDot > 0 then
			dodgeAnimationName = "DodgeRollRight"
		else
			dodgeAnimationName = "DodgeRollLeft"
		end
	end

	-- Calculate target position
	local targetPosition = rootPart.Position + (dodgeDirection * Config.DodgeDistance)

	-- Create dodge movement using BodyVelocity
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(50000, 0, 50000) -- Only horizontal movement
	bodyVelocity.Velocity = dodgeDirection * (Config.DodgeDistance / Config.DodgeDuration)
	bodyVelocity.Parent = rootPart

	-- Play dodge animation if available
	if loadedAnimations[dodgeAnimationName] then
		loadedAnimations[dodgeAnimationName]:Play()
		print("Playing animation:", dodgeAnimationName)
	else
		print("Animation not found:", dodgeAnimationName, "- Add animation ID to Animations table")
	end

	-- Optional: Add i-frames (invincibility frames) here in future
	-- This would involve checking a property before applying damage

	-- Clean up after dodge duration
	task.delay(Config.DodgeDuration, function()
		if bodyVelocity and bodyVelocity.Parent then
			bodyVelocity:Destroy()
		end
		isEvading = false

		-- Cooldown before next dodge
		task.wait(Config.DodgeCooldown - Config.DodgeDuration)
		canEvade = true
	end)

	print("Dodge roll performed:", dodgeAnimationName)
end

-- Handle sprint input
local function handleSprintInput(input, gameProcessed)
	-- Don't check gameProcessed for sprint - we want it to work regardless
	if isEvading then return end

	if input.KeyCode == Keybinds.Sprint then
		-- Check if player has enough stamina AND is holding W
		if currentStamina > 0 and UserInputService:IsKeyDown(Enum.KeyCode.W) then
			isSprinting = true
			humanoid.WalkSpeed = Config.SprintSpeed
			print("Sprinting enabled! WalkSpeed set to:", Config.SprintSpeed)
		else
			if currentStamina <= 0 then
				print("Not enough stamina to sprint!")
			else
				print("Must hold W to sprint!")
			end
		end
	end
end

local function handleSprintEnd(input, gameProcessed)
	-- Don't check gameProcessed here either
	if input.KeyCode == Keybinds.Sprint then
		isSprinting = false
		humanoid.WalkSpeed = Config.WalkSpeed
		print("Sprint stopped. WalkSpeed set back to:", Config.WalkSpeed)
	end
end

-- Handle evade input
local function handleEvadeInput(input, gameProcessed)
	if gameProcessed or isEvading then return end

	-- V key for dodge roll
	if input.KeyCode == Keybinds.Dodge then
		performDodge()
	end
end

-- ========================================
-- FUTURE SYSTEM PLACEHOLDERS
-- ========================================

-- Handle grapple input (FUTURE - Phase 3)
local function handleGrappleInput(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Keybinds.Grapple then
		print("Grapple pressed (E) - Not yet implemented")
		-- TODO: Implement grapple system in Phase 3
	end
end

-- Handle deflect input (FUTURE - Phase 5)
local function handleDeflectInput(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Keybinds.Deflect then
		print("Deflect pressed (Q) - Not yet implemented")
		-- TODO: Implement deflect system in Phase 5
	end
end

-- Handle toggle weapon input (FUTURE - Phase 4)
local function handleToggleWeaponInput(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Keybinds.ToggleWeapon then
		print("Toggle Weapon pressed (T) - Not yet implemented")
		-- TODO: Implement weapon switching in Phase 4
	end
end

-- Handle ability inputs (FUTURE - Phase 4)
local function handleAbilityInput(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Keybinds.Passive then
		print("Passive pressed (1) - Not yet implemented")
		-- TODO: Implement passive activation in Phase 4
	elseif input.KeyCode == Keybinds.Ability1 then
		print("Ability1 pressed (2) - Not yet implemented")
		-- TODO: Implement ability activation in Phase 4
	elseif input.KeyCode == Keybinds.Ultimate then
		print("Ultimate pressed (3) - Not yet implemented")
		-- TODO: Implement ultimate activation in Phase 4
	end
end

-- Main update loop
local function onHeartbeat(deltaTime)
	-- Don't process stamina if evading
	if isEvading then
		return
	end

	-- Check if still holding W while sprinting, and not pressing A, D, or S
	if isSprinting then
		if not UserInputService:IsKeyDown(Enum.KeyCode.W) then
			isSprinting = false
			humanoid.WalkSpeed = Config.WalkSpeed
			print("Sprint stopped - W key released")
		elseif UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.S) then
			isSprinting = false
			humanoid.WalkSpeed = Config.WalkSpeed
			print("Sprint stopped - A, D, or S pressed")
		end
	end

	-- Check if shift is held and W is pressed (allows shift then W to work)
	if not isSprinting and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and UserInputService:IsKeyDown(Enum.KeyCode.W) then
		if currentStamina > 0 and not UserInputService:IsKeyDown(Enum.KeyCode.A) and not UserInputService:IsKeyDown(Enum.KeyCode.D) and not UserInputService:IsKeyDown(Enum.KeyCode.S) then
			isSprinting = true
			humanoid.WalkSpeed = Config.SprintSpeed
		end
	end

	-- Handle stamina drain while sprinting
	if isSprinting then
		currentStamina = math.max(0, currentStamina - Config.SprintStaminaCost * deltaTime)

		-- Stop sprinting if out of stamina
		if currentStamina <= 0 then
			isSprinting = false
			humanoid.WalkSpeed = Config.WalkSpeed
		end

		lastActionTime = tick()
	else
		-- Regenerate stamina after delay
		if tick() - lastActionTime >= Config.StaminaRegenDelay then
			currentStamina = math.min(Config.MaxStamina, currentStamina + Config.StaminaRegenRate * deltaTime)
		end
	end

	-- Update stamina value for GUI
	local staminaValue = character:FindFirstChild("StaminaValue")
	if staminaValue then
		staminaValue.Value = currentStamina
	end
end

-- Setup function
local function setup()
	initializeHumanoid()
	loadAnimations()

	-- Connect input handlers
	UserInputService.InputBegan:Connect(handleSprintInput)
	UserInputService.InputEnded:Connect(handleSprintEnd)
	UserInputService.InputBegan:Connect(handleEvadeInput)

	-- Connect future input handlers
	UserInputService.InputBegan:Connect(handleGrappleInput)
	UserInputService.InputBegan:Connect(handleDeflectInput)
	UserInputService.InputBegan:Connect(handleToggleWeaponInput)
	UserInputService.InputBegan:Connect(handleAbilityInput)

	-- Connect update loop
	RunService.Heartbeat:Connect(onHeartbeat)

	print("CharacterController initialized for:", player.Name)
	print("Controls: Left Shift = Sprint, V = Dodge Roll, F = Toggle Camera View")
	print("Future Keybinds: E=Grapple, Q=Deflect, T=Toggle Weapon, 1/2/3=Abilities")
end

-- Initialize when character is ready
if character and humanoid and rootPart then
	setup()
end

-- Expose stamina value for UI
local function getStamina()
	return currentStamina, Config.MaxStamina
end

-- Expose evading state
local function getIsEvading()
	return isEvading
end

-- Expose dodge cooldown info
local function getEvadeCooldown()
	local currentTime = tick()
	local timeSinceLastEvade = currentTime - lastEvadeTime
	local remainingCooldown = math.max(0, Config.DodgeCooldown - timeSinceLastEvade)
	return remainingCooldown, Config.DodgeCooldown
end

-- Export for other scripts to access
return {
	GetStamina = getStamina,
	GetIsEvading = getIsEvading,
	GetEvadeCooldown = getEvadeCooldown,
	Config = Config
}
