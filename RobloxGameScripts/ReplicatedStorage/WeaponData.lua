-- ModuleScript: ReplicatedStorage>WeaponData
-- WeaponData.lua [ModuleScript]
-- Centralized weapon data system
-- Place in ReplicatedStorage

local WeaponData = {}

-- ========================================
-- TEMPLATE WEAPON: "Starter Fists"
-- This is the template showing all systems
-- ========================================

WeaponData.StarterFists = {
	-- Basic Info
	Name = "Starter Fists",
	Description = "Basic unarmed combat. Template for all weapons.",
	Attribute = "Universal", -- Strength/Agility/Intelligence/Universal

	-- Visuals
	ModelId = nil, -- Tool model (nil = uses default R15 fists)
	IconId = "rbxassetid://0", -- Inventory icon (placeholder)
	CoreVFX = "rbxassetid://0", -- Weapon core particle effect (placeholder)

	-- Combat Stats
	Damage = {
		LightAttack1 = 8,
		LightAttack2 = 10,
		LightAttack3 = 15, -- Finisher does more
		HeavyAttack = 25,
	},

	-- Stamina Costs
	StaminaCosts = {
		LightAttack = 12,
		HeavyAttack = 25,
	},

	-- Attack Speed (seconds per phase)
	AttackSpeed = {
		LightAttack1 = 0.4, -- Fast jab
		LightAttack2 = 0.4, -- Fast jab
		LightAttack3 = 0.6, -- Slower finisher
		HeavyAttack = 0.8,  -- Slow windup
	},

	-- Combo System
	ComboWindow = 1.5, -- Seconds to continue combo
	MaxComboHits = 3,

	-- Movement Stats
	Dodge = {
		Distance = 15,
		Duration = 0.4,
		IFrames = 0.2, -- Invincibility frames
	},

	Grapple = {
		AnchorSpeed = 100,
		ZipSpeed = 80,
		AnchorDistance = 100,
	},

	Deflect = {
		Window = 0.3, -- Timing window in seconds
		StaminaCost = 15,
	},

	-- ========================================
	-- ANIMATION IDs (Placeholders)
	-- ========================================
	Animations = {
		-- Idle/Movement
		Idle = "rbxassetid://0",
		Walk = "rbxassetid://0",
		Run = "rbxassetid://0",

		-- Light Attacks
		LightAttack1 = "rbxassetid://0", -- Left jab
		LightAttack2 = "rbxassetid://0", -- Right jab
		LightAttack3 = "rbxassetid://0", -- Uppercut finisher

		-- Heavy Attack
		HeavyAttack = "rbxassetid://0", -- Strong punch

		-- Dodge (per weapon - can be different)
		DodgeRollForward = "rbxassetid://0",
		DodgeRollBackward = "rbxassetid://0",
		DodgeRollLeft = "rbxassetid://0",
		DodgeRollRight = "rbxassetid://0",

		-- Deflect
		Deflect = "rbxassetid://0",

		-- Abilities (Tier system)
		PassiveActivate = "rbxassetid://0",
		AbilityActivate = "rbxassetid://0",
		UltimateActivate = "rbxassetid://0",
	},

	-- ========================================
	-- VFX (Visual Effects) - Asset IDs
	-- ========================================
	VFX = {
		-- Pre-Attack (wind-up/telegraph)
		PreAttack1 = "rbxassetid://0", -- Light attack 1 windup
		PreAttack2 = "rbxassetid://0", -- Light attack 2 windup
		PreAttack3 = "rbxassetid://0", -- Light attack 3 windup
		PreHeavy = "rbxassetid://0",   -- Heavy attack windup

		-- On Hit (impact effects)
		OnHit1 = "rbxassetid://0", -- Light hit 1
		OnHit2 = "rbxassetid://0", -- Light hit 2
		OnHit3 = "rbxassetid://0", -- Light hit 3 (finisher)
		OnHitHeavy = "rbxassetid://0", -- Heavy hit

		-- On KO (elimination effects)
		OnKO = "rbxassetid://0", -- Special effect when this weapon KOs someone

		-- Abilities
		PassiveVFX = "rbxassetid://0",
		AbilityVFX = "rbxassetid://0",
		UltimateVFX = "rbxassetid://0",

		-- Trail (weapon trail during swings)
		Trail = "rbxassetid://0",
	},

	-- ========================================
	-- SFX (Sound Effects) - Asset IDs
	-- ========================================
	SFX = {
		-- Attack Sounds (whooshes)
		LightAttackWhoosh1 = "rbxassetid://0",
		LightAttackWhoosh2 = "rbxassetid://0",
		LightAttackWhoosh3 = "rbxassetid://0",
		HeavyAttackWhoosh = "rbxassetid://0",

		-- Impact Sounds
		HitImpact1 = "rbxassetid://0",
		HitImpact2 = "rbxassetid://0",
		HitImpact3 = "rbxassetid://0",
		HitImpactHeavy = "rbxassetid://0",

		-- Elimination Sound
		KOSound = "rbxassetid://0",

		-- Movement Sounds (per weapon)
		Walking1 = "rbxassetid://0", -- Randomly selected
		Walking2 = "rbxassetid://0",
		Walking3 = "rbxassetid://0",
		Sprinting1 = "rbxassetid://0",
		Sprinting2 = "rbxassetid://0",
		Sprinting3 = "rbxassetid://0",

		-- Equipment Sounds (equip/unequip)
		Equipment1 = "rbxassetid://0", -- Randomly selected and reused
		Equipment2 = "rbxassetid://0",
		Equipment3 = "rbxassetid://0",

		-- Abilities
		PassiveSFX = "rbxassetid://0",
		AbilitySFX = "rbxassetid://0",
		UltimateSFX = "rbxassetid://0",
	},

	-- ========================================
	-- TIER SYSTEM (Passive/Ability/Ultimate)
	-- ========================================

	-- TIER 1: Passive (Always active once unlocked with 0 Sol Dust)
	Passive = {
		Name = "Fighter's Spirit",
		Description = "Gain 5% movement speed after landing 3 consecutive hits",
		Icon = "rbxassetid://0",
		Cooldown = 0, -- Passive = no cooldown

		-- Function called when passive triggers
		-- This is just metadata - actual implementation in CombatController
		Effect = {
			Type = "SpeedBoost",
			Value = 0.05, -- 5% speed increase
			Duration = 5, -- seconds
			Trigger = "3HitCombo",
		}
	},

	-- TIER 2: Ability (Unlocked at 100 Sol Dust in match)
	Ability = {
		Name = "Power Strike",
		Description = "Next heavy attack deals 50% more damage",
		Icon = "rbxassetid://0",
		Cooldown = 8, -- seconds
		StaminaCost = 20,

		Effect = {
			Type = "DamageBoost",
			Value = 0.5, -- 50% damage increase
			Duration = 5, -- Window to use boosted attack
			AppliesTo = "NextHeavyAttack",
		}
	},

	-- TIER 3: Ultimate (Unlocked at 250 Sol Dust in match)
	Ultimate = {
		Name = "Berserker Rage",
		Description = "Gain 30% attack speed and damage for 8 seconds",
		Icon = "rbxassetid://0",
		Cooldown = 30, -- seconds
		StaminaCost = 50,

		Effect = {
			Type = "MultiBoost",
			AttackSpeedBoost = 0.3, -- 30% faster
			DamageBoost = 0.3, -- 30% more damage
			Duration = 8, -- seconds
		}
	},
}

-- Helper function to get weapon data
function WeaponData.GetWeapon(weaponName)
	return WeaponData[weaponName]
end

-- Helper function to get all weapons (for future weapon selection)
function WeaponData.GetAllWeapons()
	local weapons = {}
	for name, data in pairs(WeaponData) do
		if type(data) == "table" and data.Name then
			table.insert(weapons, data)
		end
	end
	return weapons
end

-- ========================================
-- SECONDARY WEAPON: "Firecracker"
-- Fast, low damage, high mobility
-- ========================================

WeaponData.Firecracker = {
	-- Basic Info
	Name = "Firecracker",
	Description = "Quick explosive punches. Low damage, fast attacks.",
	Attribute = "Agility", -- Fast, mobile weapon

	-- Visuals
	ModelId = nil, -- Tool model (nil = uses default fists with particles)
	IconId = "rbxassetid://0", -- Inventory icon (placeholder)
	CoreVFX = "rbxassetid://0", -- Orange/red sparks

	-- Combat Stats (Lower damage, faster attacks)
	Damage = {
		LightAttack1 = 5,  -- Lower than Starter Fists
		LightAttack2 = 6,
		LightAttack3 = 10, -- Quick finisher
		HeavyAttack = 18,  -- Lower than Starter Fists
	},

	-- Stamina Costs (Cheaper attacks for spam)
	StaminaCosts = {
		LightAttack = 8,  -- Less than Starter Fists (12)
		HeavyAttack = 18, -- Less than Starter Fists (25)
	},

	-- Attack Speed (FASTER than Starter Fists)
	AttackSpeed = {
		LightAttack1 = 0.3, -- Faster than Starter Fists (0.4)
		LightAttack2 = 0.3,
		LightAttack3 = 0.4, -- Faster finisher (vs 0.6)
		HeavyAttack = 0.6,  -- Faster heavy (vs 0.8)
	},

	-- Combo System
	ComboWindow = 2.0, -- Longer window (easier to combo)
	MaxComboHits = 3,

	-- Movement Stats (Higher mobility)
	Dodge = {
		Distance = 18,  -- Farther than Starter Fists (15)
		Duration = 0.35, -- Slightly faster (vs 0.4)
		IFrames = 0.25, -- Longer invincibility (vs 0.2)
	},

	Grapple = {
		AnchorSpeed = 120, -- Faster than Starter Fists (100)
		ZipSpeed = 100,    -- Faster than Starter Fists (80)
		AnchorDistance = 110, -- Slightly farther (vs 100)
	},

	Deflect = {
		Window = 0.35, -- Slightly easier timing (vs 0.3)
		StaminaCost = 12, -- Cheaper (vs 15)
	},

	-- ========================================
	-- ANIMATION IDs (Placeholders)
	-- ========================================
	Animations = {
		-- Idle/Movement (same as fists for now)
		Idle = "rbxassetid://0",
		Walk = "rbxassetid://0",
		Run = "rbxassetid://0",

		-- Light Attacks (faster, snappier animations)
		LightAttack1 = "rbxassetid://0", -- Quick jab
		LightAttack2 = "rbxassetid://0", -- Quick cross
		LightAttack3 = "rbxassetid://0", -- Spin kick finisher

		-- Heavy Attack
		HeavyAttack = "rbxassetid://0", -- Explosive punch

		-- Dodge (per weapon)
		DodgeRollForward = "rbxassetid://0",
		DodgeRollBackward = "rbxassetid://0",
		DodgeRollLeft = "rbxassetid://0",
		DodgeRollRight = "rbxassetid://0",

		-- Deflect
		Deflect = "rbxassetid://0",

		-- Abilities
		PassiveActivate = "rbxassetid://0",
		AbilityActivate = "rbxassetid://0",
		UltimateActivate = "rbxassetid://0",
	},

	-- ========================================
	-- VFX (Visual Effects) - Orange/Red Sparks
	-- ========================================
	VFX = {
		-- Pre-Attack (orange sparks building up)
		PreAttack1 = "rbxassetid://0",
		PreAttack2 = "rbxassetid://0",
		PreAttack3 = "rbxassetid://0",
		PreHeavy = "rbxassetid://0",

		-- On Hit (small explosions)
		OnHit1 = "rbxassetid://0",
		OnHit2 = "rbxassetid://0",
		OnHit3 = "rbxassetid://0",
		OnHitHeavy = "rbxassetid://0",

		-- On KO (bigger explosion)
		OnKO = "rbxassetid://0",

		-- Abilities
		PassiveVFX = "rbxassetid://0",
		AbilityVFX = "rbxassetid://0",
		UltimateVFX = "rbxassetid://0",

		-- Trail (orange/red spark trail)
		Trail = "rbxassetid://0",
	},

	-- ========================================
	-- SFX (Sound Effects) - Crackling sounds
	-- ========================================
	SFX = {
		-- Attack Sounds (crackling whooshes)
		LightAttackWhoosh1 = "rbxassetid://0",
		LightAttackWhoosh2 = "rbxassetid://0",
		LightAttackWhoosh3 = "rbxassetid://0",
		HeavyAttackWhoosh = "rbxassetid://0",

		-- Impact Sounds (small pops)
		HitImpact1 = "rbxassetid://0",
		HitImpact2 = "rbxassetid://0",
		HitImpact3 = "rbxassetid://0",
		HitImpactHeavy = "rbxassetid://0",

		-- Elimination Sound (big boom)
		KOSound = "rbxassetid://0",

		-- Movement Sounds (lighter footsteps)
		Walking1 = "rbxassetid://0",
		Walking2 = "rbxassetid://0",
		Walking3 = "rbxassetid://0",
		Sprinting1 = "rbxassetid://0",
		Sprinting2 = "rbxassetid://0",
		Sprinting3 = "rbxassetid://0",

		-- Equipment Sounds (crackling)
		Equipment1 = "rbxassetid://0",
		Equipment2 = "rbxassetid://0",
		Equipment3 = "rbxassetid://0",

		-- Abilities
		PassiveSFX = "rbxassetid://0",
		AbilitySFX = "rbxassetid://0",
		UltimateSFX = "rbxassetid://0",
	},

	-- ========================================
	-- TIER SYSTEM (Passive/Ability/Ultimate)
	-- ========================================

	-- TIER 1: Passive
	Passive = {
		Name = "Spark Step",
		Description = "Every 5th hit creates a small explosion, damaging nearby enemies",
		Icon = "rbxassetid://0",
		Cooldown = 0,

		Effect = {
			Type = "AOEOnHit",
			Trigger = "Every5Hits",
			AOEDamage = 5,
			AOERadius = 5,
		}
	},

	-- TIER 2: Ability
	Ability = {
		Name = "Firecracker Dash",
		Description = "Dash forward with explosive speed, leaving fire trail",
		Icon = "rbxassetid://0",
		Cooldown = 6, -- Shorter cooldown (vs 8)
		StaminaCost = 15,

		Effect = {
			Type = "Dash",
			Distance = 20,
			Speed = 100,
			TrailDamage = 3,
			TrailDuration = 2,
		}
	},

	-- TIER 3: Ultimate
	Ultimate = {
		Name = "Firecracker Frenzy",
		Description = "Rapid-fire punches, each creating small explosions",
		Icon = "rbxassetid://0",
		Cooldown = 25, -- Shorter cooldown (vs 30)
		StaminaCost = 40,

		Effect = {
			Type = "RapidAttack",
			Duration = 5,
			AttackSpeedBoost = 0.5, -- 50% faster
			AOEPerHit = true,
			AOEDamage = 5,
			AOERadius = 3,
		}
	},
}

return WeaponData
