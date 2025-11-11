-- ModuleScript: ReplicatedStorage>GameConfig
-- GameConfig.lua
-- Centralized configuration for the entire RPG game
-- Place in ReplicatedStorage

local GameConfig = {}

-- ========================================
-- PLAYER SETTINGS
-- ========================================
GameConfig.Player = {
	-- Base Stats
	MaxHealth = 100,
	MaxStamina = 100,

	-- Movement
	WalkSpeed = 16,
	SprintSpeed = 24,
	JumpPower = 50,

	-- Stamina Costs (per second or per action)
	SprintStaminaCost = 10, -- per second
	EvadeStaminaCost = 25,  -- per dodge roll
	GrappleStaminaCost = 50, -- per grapple

	-- Stamina Regeneration
	StaminaRegenDelay = 5, -- seconds after last action
	StaminaRegenRate = 20, -- per second

	-- Wall Stick Settings
	WallStickDuration = 30, -- seconds
	WallStickStaminaDrain = 5, -- per second
}

-- ========================================
-- COMBAT SETTINGS
-- ========================================
GameConfig.Combat = {
	-- Base Attack Costs
	LightAttackStamina = 12,
	HeavyAttackStamina = 25,

	-- Combo Settings
	MaxComboHits = 3,
	ComboWindowTime = 1.5, -- seconds to continue combo

	-- Deflect Settings
	DeflectWindow = 0.3, -- seconds (timing window)
	DeflectStaminaCost = 15,

	-- Damage Settings
	BaseKOShieldModifier = 1.0, -- Multiplier for damage calculation

	-- Stagger/Hitstun
	LightAttackStun = 0.3, -- seconds
	HeavyAttackStun = 0.6, -- seconds
}

-- ========================================
-- GRAPPLE SETTINGS
-- ========================================
GameConfig.Grapple = {
	-- Default Stats (can be overridden by weapons)
	DefaultAnchorSpeed = 100, -- studs per second
	DefaultZipSpeed = 80,
	DefaultAnchorDistance = 100, -- studs

	-- Cooldowns
	GrappleCooldown = 3, -- seconds

	-- Wall Stick
	WallStickEnabled = true,
	WallDetectionRange = 5, -- studs
}

-- ========================================
-- WEAPON SYSTEM
-- ========================================
GameConfig.Weapons = {
	-- Tier Progression
	MaxTiers = 3,
	TierUnlockThresholds = {
		[1] = 0,    -- Tier 1: Passive (no cost, starts unlocked in match)
		[2] = 100,  -- Tier 2: Ability (requires 100 Sol Dust in match)
		[3] = 250,  -- Tier 3: Ultimate (requires 250 Sol Dust in match)
	},

	-- Sol Dust Earning
	SolDustPerHit = 5,
	SolDustPerKill = 20,
	SolDustDominationBonus = 10,
	SolDustRevengeBonus = 15,

	-- Animation Phase System
	DefaultPhaseBlendTime = 0.1,

	-- Attributes
	Attributes = {
		Strength = "Strength",
		Agility = "Agility",
		Intelligence = "Intelligence"
	}
}

-- ========================================
-- PVP SETTINGS
-- ========================================
GameConfig.PVP = {
	-- Arena Settings
	MaxPlayersPerArena = 16,
	RespawnTime = 3, -- seconds

	-- Domination System
	DominationKillThreshold = 3, -- kills on same player

	-- Killfeed
	KillfeedDisplayTime = 5, -- seconds
	MaxKillfeedEntries = 5,
}

-- ========================================
-- UI SETTINGS
-- ========================================
GameConfig.UI = {
	-- Stamina Bar Colors
	StaminaColorHigh = Color3.fromRGB(0, 255, 0), -- Green
	StaminaColorMid = Color3.fromRGB(255, 255, 0), -- Yellow
	StaminaColorLow = Color3.fromRGB(255, 0, 0),   -- Red

	-- Tier Bar
	TierBarFillSpeed = 0.5, -- seconds to animate fill

	-- Attribute Colors
	AttributeColors = {
		Strength = Color3.fromRGB(255, 50, 50),     -- Red
		Agility = Color3.fromRGB(50, 255, 50),      -- Green
		Intelligence = Color3.fromRGB(50, 150, 255) -- Blue
	},
}

-- ========================================
-- CAMERA SETTINGS
-- ========================================
GameConfig.Camera = {
	-- Distance
	MinDistance = 8,
	MaxDistance = 20,
	DefaultDistance = 12,
	ZoomSpeed = 2,

	-- Rotation
	MinPitch = -80,
	MaxPitch = 80,
	MouseSensitivity = 0.3,

	-- Smoothing
	Smoothness = 0.15,

	-- Offset (Over-the-shoulder style)
	OffsetY = 2,  -- Height above character
	OffsetX = 4,  -- Horizontal offset (negative = left shoulder, positive = right shoulder)
	OffsetZ = 0,  -- Forward/backward offset
}

-- ========================================
-- ANIMATION IDS (Replace with your actual IDs)
-- ========================================
GameConfig.Animations = {
	-- Universal Animations
	Idle = nil, -- "rbxassetid://YOUR_ID"
	Walk = nil,
	Run = nil,
	Sprint = nil,
	Jump = nil,
	Fall = nil,
	Land = nil,

	-- Combat Animations
	LightAttack1 = nil,
	LightAttack2 = nil,
	LightAttack3 = nil,
	HeavyAttack = nil,
	Deflect = nil,
	DodgeRoll = nil,
	HitReaction = nil,
	KO = nil,

	-- Grapple Animations
	GrappleThrow = nil,
	GrappleZip = nil,
	WallStick = nil,

	-- Entry
	SpawnEntry = nil,
}

-- ========================================
-- AUDIO IDS (Replace with your actual IDs)
-- ========================================
GameConfig.Audio = {
	-- UI Sounds
	ButtonClick = nil,
	MenuOpen = nil,

	-- Combat Sounds
	LightAttackWhoosh = nil,
	HeavyAttackWhoosh = nil,
	HitImpact = nil,
	Deflect = nil,

	-- Abilities (weapon-specific sounds will be in weapon data)
	AbilityActivate = nil,
	UltimateActivate = nil,
}

-- ========================================
-- UTILITY FUNCTIONS
-- ========================================

-- Get stamina color based on percentage
function GameConfig.GetStaminaColor(percentage)
	if percentage > 0.6 then
		return GameConfig.UI.StaminaColorHigh
	elseif percentage > 0.3 then
		return GameConfig.UI.StaminaColorMid
	else
		return GameConfig.UI.StaminaColorLow
	end
end

-- Get attribute color
function GameConfig.GetAttributeColor(attributeName)
	return GameConfig.UI.AttributeColors[attributeName] or Color3.new(1, 1, 1)
end

-- Calculate damage (basic formula from your design doc)
function GameConfig.CalculateDamage(baseDamage, koShieldModifier)
	koShieldModifier = koShieldModifier or GameConfig.Combat.BaseKOShieldModifier
	return baseDamage * koShieldModifier
end

return GameConfig
