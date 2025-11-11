-- Script: ServerScriptService>CombatServer
-- CombatServer.lua [Script]
-- Server-side combat validation and damage application
-- Place in ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create RemoteEvents folder if it doesn't exist
local RemoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not RemoteEvents then
	RemoteEvents = Instance.new("Folder")
	RemoteEvents.Name = "RemoteEvents"
	RemoteEvents.Parent = ReplicatedStorage
end

-- Create remote events
local AttackEvent = RemoteEvents:FindFirstChild("AttackEvent")
if not AttackEvent then
	AttackEvent = Instance.new("RemoteEvent")
	AttackEvent.Name = "AttackEvent"
	AttackEvent.Parent = RemoteEvents
end

local HitEvent = RemoteEvents:FindFirstChild("HitEvent")
if not HitEvent then
	HitEvent = Instance.new("RemoteEvent")
	HitEvent.Name = "HitEvent"
	HitEvent.Parent = RemoteEvents
end

-- Create NPC hit event (for damaging workspace NPCs/dummies)
local NPCHitEvent = RemoteEvents:FindFirstChild("NPCHitEvent")
if not NPCHitEvent then
	NPCHitEvent = Instance.new("RemoteEvent")
	NPCHitEvent.Name = "NPCHitEvent"
	NPCHitEvent.Parent = RemoteEvents
end

-- Track player combat stats
local playerStats = {}

-- Initialize player stats
local function initializePlayer(player)
	playerStats[player] = {
		LastAttackTime = 0,
		AttackCount = 0,
		SolDust = 0,
		Kills = 0,
		Deaths = 0,
		DominatingPlayer = nil, -- Player they're dominating
		DominationKills = 0, -- Kills on that player
	}

	-- Wait for character
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")

		-- Create Sol Dust value
		local solDustValue = character:FindFirstChild("SolDustValue")
		if not solDustValue then
			solDustValue = Instance.new("NumberValue")
			solDustValue.Name = "SolDustValue"
			solDustValue.Value = 0
			solDustValue.Parent = character
		end

		-- Handle death
		humanoid.Died:Connect(function()
			playerStats[player].Deaths = playerStats[player].Deaths + 1
			print(player.Name, "died. Total deaths:", playerStats[player].Deaths)

			-- Reset Sol Dust on death (in-match progression resets)
			solDustValue.Value = 0
			playerStats[player].SolDust = 0
		end)
	end)
end

-- Award Sol Dust
local function awardSolDust(player, amount, reason)
	if not playerStats[player] then return end

	local character = player.Character
	if not character then return end

	local solDustValue = character:FindFirstChild("SolDustValue")
	if solDustValue then
		solDustValue.Value = solDustValue.Value + amount
		playerStats[player].SolDust = solDustValue.Value
		print(player.Name, "earned", amount, "Sol Dust for", reason, "Total:", solDustValue.Value)
	end
end

-- Handle attack event (for logging/anti-cheat)
AttackEvent.OnServerEvent:Connect(function(player, attackType, comboCount)
	if not playerStats[player] then return end

	-- Basic anti-cheat: rate limiting
	local currentTime = tick()
	if currentTime - playerStats[player].LastAttackTime < 0.2 then
		warn(player.Name, "attacking too fast! Possible exploit.")
		return
	end

	playerStats[player].LastAttackTime = currentTime
	playerStats[player].AttackCount = playerStats[player].AttackCount + 1

	print(player.Name, "performed", attackType, "attack", comboCount)
end)

-- Handle hit event (apply damage)
HitEvent.OnServerEvent:Connect(function(attacker, victim, damage, attackType, comboCount)
	if not attacker or not victim then return end
	if not playerStats[attacker] or not playerStats[victim] then return end

	-- Validate players are in game
	if not attacker.Character or not victim.Character then return end

	local attackerRoot = attacker.Character:FindFirstChild("HumanoidRootPart")
	local victimRoot = victim.Character:FindFirstChild("HumanoidRootPart")
	local victimHumanoid = victim.Character:FindFirstChild("Humanoid")

	if not attackerRoot or not victimRoot or not victimHumanoid then return end

	-- Validate distance (anti-cheat)
	local distance = (attackerRoot.Position - victimRoot.Position).Magnitude
	local maxDistance = attackType == "Heavy" and 10 or 7

	if distance > maxDistance then
		warn(attacker.Name, "hit from too far away! Distance:", distance)
		return
	end

	-- Apply damage
	victimHumanoid:TakeDamage(damage)

	-- Award Sol Dust for hit (5 per hit)
	awardSolDust(attacker, 5, "hit")

	print(attacker.Name, "hit", victim.Name, "for", damage, "damage!")

	-- Check if victim died
	if victimHumanoid.Health <= 0 then
		-- Award Sol Dust for kill (20)
		awardSolDust(attacker, 20, "elimination")

		-- Track kills
		playerStats[attacker].Kills = playerStats[attacker].Kills + 1

		-- Check for domination
		if playerStats[attacker].DominatingPlayer == victim then
			playerStats[attacker].DominationKills = playerStats[attacker].DominationKills + 1

			if playerStats[attacker].DominationKills >= 3 then
				print(attacker.Name, "is DOMINATING", victim.Name, "!")
				-- TODO: Trigger killfeed event for domination
				awardSolDust(attacker, 10, "domination")
			end
		else
			-- Start tracking domination
			playerStats[attacker].DominatingPlayer = victim
			playerStats[attacker].DominationKills = 1
		end

		print(attacker.Name, "eliminated", victim.Name, "! Total kills:", playerStats[attacker].Kills)
	end
end)

-- Handle NPC hit event (for workspace dummies/NPCs)
NPCHitEvent.OnServerEvent:Connect(function(attacker, npcCharacter, damage, attackType)
	if not attacker or not npcCharacter then return end
	if not playerStats[attacker] then return end
	if not attacker.Character then return end

	-- Validate NPC character
	local npcHumanoid = npcCharacter:FindFirstChild("Humanoid")
	local npcRoot = npcCharacter:FindFirstChild("HumanoidRootPart")
	local attackerRoot = attacker.Character:FindFirstChild("HumanoidRootPart")

	if not npcHumanoid or not npcRoot or not attackerRoot then return end

	-- Validate distance (anti-cheat)
	local distance = (attackerRoot.Position - npcRoot.Position).Magnitude
	local maxDistance = attackType == "Heavy" and 10 or 7

	if distance > maxDistance then
		warn(attacker.Name, "hit NPC from too far away! Distance:", distance)
		return
	end

	-- Apply damage to NPC
	npcHumanoid:TakeDamage(damage)

	-- Award Sol Dust for NPC hit (3 per hit, less than player)
	awardSolDust(attacker, 3, "NPC hit")

	print(attacker.Name, "hit NPC", npcCharacter.Name, "for", damage, "damage!")

	-- Check if NPC died
	if npcHumanoid.Health <= 0 then
		-- Award Sol Dust for NPC kill (10, less than player kill)
		awardSolDust(attacker, 10, "NPC elimination")
		print(attacker.Name, "eliminated NPC", npcCharacter.Name, "!")
	end
end)

-- Player join/leave handling
Players.PlayerAdded:Connect(initializePlayer)

Players.PlayerRemoving:Connect(function(player)
	playerStats[player] = nil
end)

-- Initialize existing players
for _, player in ipairs(Players:GetPlayers()) do
	initializePlayer(player)
end

print("CombatServer initialized!")
print("Combat system ready for PVP!")



-- GUI STRUCTURE MAP (for AI debugging assistance)
--[[
{"Name":"StarterGui","ClassName":"StarterGui","Properties":[],"Children":[{"Name":"ScreenGui","ClassName":"ScreenGui","Properties":{"Enabled":true,"ZIndexBehavior":"Enum.ZIndexBehavior.Sibling","ResetOnSpawn":true,"IgnoreGuiInset":false,"DisplayOrder":0},"Children":[{"Name":"StaminaFrame","ClassName":"Frame","Properties":{"Visible":true,"AnchorPoint":[0,0],"BackgroundTransparency":1,"Position":[0,0,0,0],"BorderColor3":[0,0,0],"Size":[1,0,1,0],"BorderSizePixel":0,"BackgroundColor3":[1,1,1]},"Children":[{"Name":"StaminaGui","ClassName":"LocalScript","Properties":[],"Children":[],"Attributes":[]}],"Attributes":[]},{"Name":"VitalsFrame","ClassName":"Frame","Properties":{"Visible":true,"AnchorPoint":[0,0],"BackgroundTransparency":1,"Position":[0,0,0,0],"BorderColor3":[0,0,0],"Size":[0,100,0,100],"BorderSizePixel":0,"BackgroundColor3":[1,1,1]},"Children":[{"Name":"HPBar","ClassName":"LocalScript","Properties":[],"Children":[],"Attributes":[]},{"Name":"KOShields","ClassName":"LocalScript","Properties":[],"Children":[],"Attributes":[]}],"Attributes":[]},{"Name":"LoadoutFrame","ClassName":"Frame","Properties":{"Visible":true,"AnchorPoint":[0,0],"BackgroundTransparency":1,"Position":[0,0,0,0],"BorderColor3":[0,0,0],"Size":[0,100,0,100],"BorderSizePixel":0,"BackgroundColor3":[1,1,1]},"Children":[{"Name":"LoadoutDisplay","ClassName":"LocalScript","Properties":[],"Children":[],"Attributes":[]}],"Attributes":[]},{"Name":"TierBarFrame","ClassName":"Frame","Properties":{"Visible":true,"AnchorPoint":[0,0],"BackgroundTransparency":1,"Position":[0,0,0,0],"BorderColor3":[0,0,0],"Size":[0,100,0,100],"BorderSizePixel":0,"BackgroundColor3":[1,1,1]},"Children":[{"Name":"TierBar","ClassName":"LocalScript","Properties":[],"Children":[],"Attributes":[]}],"Attributes":[]},{"Name":"CooldownsFrame","ClassName":"Frame","Properties":{"Visible":true,"AnchorPoint":[0,0],"BackgroundTransparency":1,"Position":[0,-90,0,50],"BorderColor3":[0,0,0],"Size":[0,100,0,100],"BorderSizePixel":0,"BackgroundColor3":[1,1,1]},"Children":[{"Name":"ActionCooldowns","ClassName":"LocalScript","Properties":[],"Children":[],"Attributes":[]}],"Attributes":[]},{"Name":"KillfeedFrame","ClassName":"Frame","Properties":{"Visible":true,"AnchorPoint":[0,0],"BackgroundTransparency":1,"Position":[0,0,0,0],"BorderColor3":[0,0,0],"Size":[0,100,0,100],"BorderSizePixel":0,"BackgroundColor3":[1,1,1]},"Children":[{"Name":"Killfeed","ClassName":"LocalScript","Properties":[],"Children":[],"Attributes":[]}],"Attributes":[]}],"Attributes":[]}],"Attributes":[]}
--]]
