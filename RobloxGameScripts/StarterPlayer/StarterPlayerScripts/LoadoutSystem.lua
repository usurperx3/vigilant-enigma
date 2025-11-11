-- LocalScript: StarterPlayer>StarterPlayerScripts>LoadoutSystem
-- LoadoutSystem.lua [LocalScript]
-- Manages dual weapon loadout (Primary + Secondary)
-- Place in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Get weapon data
local WeaponData = require(ReplicatedStorage:WaitForChild("WeaponData"))

-- Loadout configuration
local Loadout = {
	PrimaryWeapon = "StarterFists",  -- Default primary
	SecondaryWeapon = "Firecracker",  -- Default secondary
	CurrentSlot = "Primary", -- Which slot is currently equipped
}

-- Tool references
local primaryTool = nil
local secondaryTool = nil
local currentTool = nil

-- Get or create tool for weapon
local function createWeaponTool(weaponName)
	-- Check if tool already exists in player's inventory
	local existingTool = player.Backpack:FindFirstChild(weaponName)
	if existingTool then
		return existingTool
	end

	-- Check if tool exists in character (already equipped)
	existingTool = character:FindFirstChild(weaponName)
	if existingTool and existingTool:IsA("Tool") then
		return existingTool
	end

	-- Create new tool
	local tool = Instance.new("Tool")
	tool.Name = weaponName
	tool.RequiresHandle = false
	tool.ManualActivationOnly = true
	tool.CanBeDropped = false

	-- Add weapon name attribute
	tool:SetAttribute("WeaponName", weaponName)

	-- Get weapon data for icon (if available)
	local weaponData = WeaponData.GetWeapon(weaponName)
	if weaponData then
		tool.ToolTip = weaponData.Description
		-- TODO: Set TextureId to weaponData.IconId when we have icons
	end

	return tool
end

-- Equip weapon from loadout slot
local function equipWeapon(slotName)
	-- Determine which weapon to equip
	local weaponName = slotName == "Primary" and Loadout.PrimaryWeapon or Loadout.SecondaryWeapon

	-- Unequip current weapon
	if currentTool and currentTool.Parent == character then
		currentTool.Parent = player.Backpack
	end

	-- Get or create the tool
	local tool = slotName == "Primary" and primaryTool or secondaryTool

	if not tool then
		tool = createWeaponTool(weaponName)
		tool.Parent = player.Backpack

		-- Store reference
		if slotName == "Primary" then
			primaryTool = tool
		else
			secondaryTool = tool
		end
	end

	-- Equip the tool
	if tool.Parent == player.Backpack then
		-- Wait a frame to ensure proper equipping
		task.wait()
		humanoid:EquipTool(tool)
	end

	currentTool = tool
	Loadout.CurrentSlot = slotName

	print("Equipped", slotName, "weapon:", weaponName)
end

-- Toggle between primary and secondary
local function toggleWeapon()
	if Loadout.CurrentSlot == "Primary" then
		equipWeapon("Secondary")
	else
		equipWeapon("Primary")
	end
end

-- Handle input
local function onInputBegan(input, gameProcessed)
	if gameProcessed then return end

	-- T key = Toggle weapon
	if input.KeyCode == Enum.KeyCode.T then
		toggleWeapon()
	end

	-- Number keys for direct slot selection
	if input.KeyCode == Enum.KeyCode.One then
		equipWeapon("Primary")
	end

	if input.KeyCode == Enum.KeyCode.Two then
		equipWeapon("Secondary")
	end
end

-- Initialize loadout
local function initializeLoadout()
	-- Wait for character to fully load
	local humanoid = character:WaitForChild("Humanoid")

	-- Create both weapon tools
	primaryTool = createWeaponTool(Loadout.PrimaryWeapon)
	secondaryTool = createWeaponTool(Loadout.SecondaryWeapon)

	-- Put both in backpack
	primaryTool.Parent = player.Backpack
	secondaryTool.Parent = player.Backpack

	-- Equip primary weapon by default
	task.wait(0.5) -- Wait for backpack to settle
	equipWeapon("Primary")

	print("Loadout initialized!")
	print("Primary:", Loadout.PrimaryWeapon)
	print("Secondary:", Loadout.SecondaryWeapon)
	print("Press T to swap, or 1/2 for direct selection")
end

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	primaryTool = nil
	secondaryTool = nil
	currentTool = nil

	-- Wait a bit then reinitialize
	task.wait(1)
	initializeLoadout()
end)

-- Setup
UserInputService.InputBegan:Connect(onInputBegan)

-- Initial setup
initializeLoadout()

print("LoadoutSystem initialized for:", player.Name)
