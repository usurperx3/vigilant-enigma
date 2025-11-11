-- LocalScript: StarterPlayer>StarterCharacterScripts>CombatController
-- CombatController.lua [LocalScript] - FIXED VERSION
-- Handles combat system - attacks, combos, hit detection
-- Place in StarterPlayer > StarterCharacterScripts (NOT StarterPlayerScripts!)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Get weapon data
local WeaponData = require(ReplicatedStorage:WaitForChild("WeaponData"))
local currentWeapon = nil -- No weapon equipped by default
local equippedTool = nil -- Reference to equipped Tool

-- Remote events for server validation
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local AttackEvent = RemoteEvents:WaitForChild("AttackEvent")
local HitEvent = RemoteEvents:WaitForChild("HitEvent")
local NPCHitEvent = RemoteEvents:WaitForChild("NPCHitEvent") -- New event for NPCs

-- Combat state
local isAttacking = false
local comboCount = 0
local lastAttackTime = 0
local canAttack = true

-- Ability states
local abilityTier1Active = false -- Passive
local abilityTier2Cooldown = 0
local abilityTier3Cooldown = 0

-- Check if weapon is equipped
local function hasWeaponEquipped()
	return currentWeapon ~= nil and equippedTool ~= nil
end

-- Get current stamina from CharacterController
local function getCurrentStamina()
	local staminaValue = character:FindFirstChild("StaminaValue")
	return staminaValue and staminaValue.Value or 0
end

-- Consume stamina
local function consumeStamina(amount)
	local staminaValue = character:FindFirstChild("StaminaValue")
	if staminaValue then
		staminaValue.Value = math.max(0, staminaValue.Value - amount)
	end
end

-- Create hitbox for melee attacks
local function createHitbox(size, duration, damageAmount, attackType)
	local hitbox = Instance.new("Part")
	hitbox.Size = size or Vector3.new(5, 5, 5)
	hitbox.CFrame = rootPart.CFrame * CFrame.new(0, 0, -3) -- In front of player
	hitbox.Transparency = 1 -- Invisible
	hitbox.CanCollide = false
	hitbox.Anchored = true
	hitbox.Parent = workspace

	-- Visualize hitbox in testing (uncomment to see)
	-- hitbox.Transparency = 0.7
	-- hitbox.Color = Color3.fromRGB(255, 0, 0)

	-- Store hit entities to prevent double-hitting
	local hitEntities = {}

	-- Detect hits
	local connection
	connection = hitbox.Touched:Connect(function(hit)
		local hitCharacter = hit.Parent
		if not hitCharacter then return end
		if hitCharacter == character then return end -- Don't hit yourself
		if hitEntities[hitCharacter] then return end -- Already hit this entity

		local hitHumanoid = hitCharacter:FindFirstChild("Humanoid")
		if not hitHumanoid then return end -- No humanoid = not a valid target

		hitEntities[hitCharacter] = true

		-- Check if it's a player or NPC
		local enemyPlayer = Players:GetPlayerFromCharacter(hitCharacter)

		if enemyPlayer then
			-- It's a player - send to server for validation
			HitEvent:FireServer(enemyPlayer, damageAmount, attackType, comboCount)
			print("Hit player:", enemyPlayer.Name, "for", damageAmount, "damage!")
		else
			-- It's an NPC/dummy - damage directly (client-side for NPCs)
			NPCHitEvent:FireServer(hitCharacter, damageAmount, attackType)
			print("Hit NPC:", hitCharacter.Name, "for", damageAmount, "damage!")
		end
	end)

	-- Remove hitbox after duration
	task.delay(duration or 0.2, function()
		connection:Disconnect()
		hitbox:Destroy()
	end)
end

-- Play attack animation
local function playAttackAnimation(animationName)
	-- Placeholder - will load actual animations later
	print("Playing animation:", animationName)

	-- TODO: Load and play animation from currentWeapon.Animations[animationName]
end

-- Play VFX effect
local function playVFX(effectName)
	-- Placeholder - will spawn VFX particles later
	print("Playing VFX:", effectName)

	-- TODO: Spawn particle effect from currentWeapon.VFX[effectName]
end

-- Play SFX sound
local function playSFX(soundName)
	-- Placeholder - will play sound later
	print("Playing SFX:", soundName)

	-- TODO: Play sound from currentWeapon.SFX[soundName]
end

-- Perform light attack
local function performLightAttack()
	-- CHECK: Must have weapon equipped
	if not hasWeaponEquipped() then
		print("No weapon equipped!")
		return
	end

	if isAttacking or not canAttack then return end

	-- Check stamina
	if getCurrentStamina() < currentWeapon.StaminaCosts.LightAttack then
		print("Not enough stamina for light attack!")
		return
	end

	-- Check combo window
	local currentTime = tick()
	if currentTime - lastAttackTime > currentWeapon.ComboWindow then
		comboCount = 0 -- Reset combo
	end

	-- Increment combo
	comboCount = math.min(comboCount + 1, currentWeapon.MaxComboHits)

	-- Consume stamina
	consumeStamina(currentWeapon.StaminaCosts.LightAttack)

	-- Set attacking state
	isAttacking = true
	lastAttackTime = currentTime

	-- Get attack data based on combo
	local attackAnim = "LightAttack" .. comboCount
	local attackSpeed = currentWeapon.AttackSpeed[attackAnim]

	-- Calculate damage
	local damage = 0
	if comboCount == 1 then
		damage = currentWeapon.Damage.LightAttack1
	elseif comboCount == 2 then
		damage = currentWeapon.Damage.LightAttack2
	elseif comboCount == 3 then
		damage = currentWeapon.Damage.LightAttack3
	end

	-- Play effects
	playAttackAnimation(attackAnim)
	playVFX("PreAttack" .. comboCount)
	playSFX("LightAttackWhoosh" .. comboCount)

	-- Create hitbox with damage info
	task.delay(0.1, function() -- Small delay for windup
		createHitbox(Vector3.new(5, 5, 5), 0.2, damage, "Light")
	end)

	-- End attack after animation
	task.delay(attackSpeed, function()
		isAttacking = false

		-- Reset combo if max reached
		if comboCount >= currentWeapon.MaxComboHits then
			comboCount = 0
		end
	end)

	-- Notify server
	AttackEvent:FireServer("Light", comboCount)

	print("Light attack", comboCount, "performed!")
end

-- Perform heavy attack
local function performHeavyAttack()
	-- CHECK: Must have weapon equipped
	if not hasWeaponEquipped() then
		print("No weapon equipped!")
		return
	end

	if isAttacking or not canAttack then return end

	-- Check stamina
	if getCurrentStamina() < currentWeapon.StaminaCosts.HeavyAttack then
		print("Not enough stamina for heavy attack!")
		return
	end

	-- Consume stamina
	consumeStamina(currentWeapon.StaminaCosts.HeavyAttack)

	-- Reset combo
	comboCount = 0

	-- Set attacking state
	isAttacking = true
	lastAttackTime = tick()

	-- Play effects
	playAttackAnimation("HeavyAttack")
	playVFX("PreHeavy")
	playSFX("HeavyAttackWhoosh")

	-- Create larger hitbox with delay (windup)
	task.delay(0.3, function() -- Longer windup for heavy
		createHitbox(Vector3.new(7, 7, 7), 0.3, currentWeapon.Damage.HeavyAttack, "Heavy")
	end)

	-- End attack
	task.delay(currentWeapon.AttackSpeed.HeavyAttack, function()
		isAttacking = false
	end)

	-- Notify server
	AttackEvent:FireServer("Heavy", 1)

	print("Heavy attack performed!")
end

-- Handle input
local function onInputBegan(input, gameProcessed)
	if gameProcessed then return end

	-- Left mouse button = Light attack
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		performLightAttack()
	end

	-- Right mouse button = Heavy attack
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		performHeavyAttack()
	end

	-- Ability inputs (Tier 1/2/3) - also require weapon
	if input.KeyCode == Enum.KeyCode.One then
		if hasWeaponEquipped() then
			print("Passive ability - always active (Tier 1)")
		end
	end

	if input.KeyCode == Enum.KeyCode.Two then
		if not hasWeaponEquipped() then
			print("No weapon equipped!")
			return
		end

		if abilityTier2Cooldown <= 0 then
			print("Ability activated! (Tier 2)")
			-- TODO: Implement Tier 2 ability effect
			abilityTier2Cooldown = currentWeapon.Ability.Cooldown
		else
			print("Ability on cooldown:", abilityTier2Cooldown, "seconds")
		end
	end

	if input.KeyCode == Enum.KeyCode.Three then
		if not hasWeaponEquipped() then
			print("No weapon equipped!")
			return
		end

		if abilityTier3Cooldown <= 0 then
			print("Ultimate activated! (Tier 3)")
			-- TODO: Implement Tier 3 ultimate effect
			abilityTier3Cooldown = currentWeapon.Ultimate.Cooldown
		else
			print("Ultimate on cooldown:", abilityTier3Cooldown, "seconds")
		end
	end
end

-- Update cooldowns
local function updateCooldowns(deltaTime)
	if abilityTier2Cooldown > 0 then
		abilityTier2Cooldown = math.max(0, abilityTier2Cooldown - deltaTime)
	end

	if abilityTier3Cooldown > 0 then
		abilityTier3Cooldown = math.max(0, abilityTier3Cooldown - deltaTime)
	end
end

-- Equip weapon (called when Tool is equipped)
local function equipWeapon(tool)
	-- Get weapon name from tool
	local weaponName = tool:GetAttribute("WeaponName") or "StarterFists"

	-- Load weapon data
	currentWeapon = WeaponData.GetWeapon(weaponName)
	equippedTool = tool

	if currentWeapon then
		print("Equipped weapon:", currentWeapon.Name)

		-- Reset combat state
		isAttacking = false
		comboCount = 0

		-- Update LoadoutDisplay
		local equippedWeaponValue = character:FindFirstChild("EquippedWeapon")
		if equippedWeaponValue then
			equippedWeaponValue.Value = currentWeapon.IconId
		end

		-- Update current slot display (Primary or Secondary)
		local currentSlotValue = character:FindFirstChild("CurrentSlot")
		if currentSlotValue then
			-- Determine slot based on weapon name
			if weaponName == "StarterFists" then
				currentSlotValue.Value = "Primary"
			elseif weaponName == "Firecracker" then
				currentSlotValue.Value = "Secondary"
			end
		end
	else
		warn("Weapon data not found for:", weaponName)
	end
end

-- Unequip weapon (called when Tool is unequipped)
local function unequipWeapon()
	if currentWeapon then
		print("Unequipped weapon:", currentWeapon.Name)
	end

	currentWeapon = nil
	equippedTool = nil

	-- Reset combat state
	isAttacking = false
	comboCount = 0

	-- Update LoadoutDisplay
	local equippedWeaponValue = character:FindFirstChild("EquippedWeapon")
	if equippedWeaponValue then
		equippedWeaponValue.Value = ""
	end
end

-- Monitor character for Tool equip/unequip
local function monitorTools()
	-- Listen for tool equipped
	character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			equipWeapon(child)
		end
	end)

	-- Listen for tool unequipped
	character.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") and child == equippedTool then
			unequipWeapon()
		end
	end)

	-- Check if tool is already equipped
	local existingTool = character:FindFirstChildOfClass("Tool")
	if existingTool then
		equipWeapon(existingTool)
	end
end

-- Setup
local function setup()
	UserInputService.InputBegan:Connect(onInputBegan)
	RunService.Heartbeat:Connect(updateCooldowns)
	monitorTools()

	print("CombatController initialized!")
	print("Controls: Left Click = Light Attack, Right Click = Heavy Attack, 1/2/3 = Abilities")
	print("Note: You must have a weapon equipped to attack!")
end

setup()

-- Export for other scripts
return {
	GetCurrentWeapon = function() return currentWeapon end,
	IsAttacking = function() return isAttacking end,
	HasWeaponEquipped = hasWeaponEquipped,
}
