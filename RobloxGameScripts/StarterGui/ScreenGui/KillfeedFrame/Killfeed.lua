-- LocalScript: StarterGui>ScreenGui>KillfeedFrame>Killfeed
-- Killfeed.lua [LocalScript]
-- Displays elimination feed in top right corner
-- Place in StarterGui > ScreenGui > KillfeedFrame

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- GUI References
local screenGui = script.Parent.Parent -- ScreenGui
screenGui.IgnoreGuiInset = true

local killfeedFrame = script.Parent -- KillfeedFrame
killfeedFrame.Size = UDim2.new(1, 0, 1, 0)
killfeedFrame.BackgroundTransparency = 1

-- Killfeed configuration
local MAX_ENTRIES = 5
local ENTRY_DISPLAY_TIME = 5 -- seconds
local ENTRY_HEIGHT = 30
local ENTRY_SPACING = 5

-- Create killfeed container
local killfeedContainer = killfeedFrame:FindFirstChild("KillfeedContainer")
if not killfeedContainer then
	killfeedContainer = Instance.new("Frame")
	killfeedContainer.Name = "KillfeedContainer"
	killfeedContainer.Size = UDim2.new(0, 360, 0, (ENTRY_HEIGHT + ENTRY_SPACING) * MAX_ENTRIES)
	killfeedContainer.Position = UDim2.new(1, -20, 0, 20) -- Top right
	killfeedContainer.AnchorPoint = Vector2.new(1, 0)
	killfeedContainer.BackgroundTransparency = 1
	killfeedContainer.ClipsDescendants = true
	killfeedContainer.Parent = killfeedFrame
end

-- Active killfeed entries
local activeEntries = {}

-- Create a killfeed entry
local function createKillfeedEntry(killerName, victimName, weaponIcon, killType)
	-- Entry container
	local entry = Instance.new("Frame")
	entry.Name = "KillfeedEntry"
	entry.Size = UDim2.new(1, 0, 0, ENTRY_HEIGHT)
	entry.Position = UDim2.new(0, 0, 0, 0)
	entry.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	entry.BackgroundTransparency = 0.3
	entry.BorderSizePixel = 0
	entry.Parent = killfeedContainer

	local entryCorner = Instance.new("UICorner")
	entryCorner.CornerRadius = UDim.new(0, 6)
	entryCorner.Parent = entry

	-- Killer name
	local killerLabel = Instance.new("TextLabel")
	killerLabel.Name = "KillerLabel"
	killerLabel.Size = UDim2.new(0.4, -5, 1, 0)
	killerLabel.Position = UDim2.new(0, 5, 0, 0)
	killerLabel.BackgroundTransparency = 1
	killerLabel.Text = killerName
	killerLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red for killer
	killerLabel.TextSize = 12
	killerLabel.Font = Enum.Font.GothamBold
	killerLabel.TextXAlignment = Enum.TextXAlignment.Right
	killerLabel.TextStrokeTransparency = 0.5
	killerLabel.Parent = entry

	-- Special kill type indicator (DOMINATING!, REVENGE!, etc.)
	if killType then
		local killTypeLabel = Instance.new("TextLabel")
		killTypeLabel.Name = "KillTypeLabel"
		killTypeLabel.Size = UDim2.new(0.4, 0, 1, 0)
		killTypeLabel.Position = UDim2.new(0.3, 0, 0, 0)
		killTypeLabel.BackgroundTransparency = 1
		killTypeLabel.Text = killType
		killTypeLabel.TextColor3 = Color3.fromRGB(255, 200, 50) -- Gold
		killTypeLabel.TextSize = 14
		killTypeLabel.Font = Enum.Font.GothamBold
		killTypeLabel.TextStrokeTransparency = 0.3
		killTypeLabel.Parent = entry
	else
		-- Weapon icon/arrow
		local weaponLabel = Instance.new("TextLabel")
		weaponLabel.Name = "WeaponLabel"
		weaponLabel.Size = UDim2.new(0, 40, 1, 0)
		weaponLabel.Position = UDim2.new(0.5, -20, 0, 0)
		weaponLabel.BackgroundTransparency = 1
		weaponLabel.Text = "→" -- Arrow (will be weapon icon later)
		weaponLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
		weaponLabel.TextSize = 16
		weaponLabel.Font = Enum.Font.GothamBold
		weaponLabel.Parent = entry
	end

	-- Victim name
	local victimLabel = Instance.new("TextLabel")
	victimLabel.Name = "VictimLabel"
	victimLabel.Size = UDim2.new(0.4, -5, 1, 0)
	victimLabel.Position = UDim2.new(0.6, 0, 0, 0)
	victimLabel.BackgroundTransparency = 1
	victimLabel.Text = victimName
	victimLabel.TextColor3 = Color3.fromRGB(200, 200, 200) -- White for victim
	victimLabel.TextSize = 12
	victimLabel.Font = Enum.Font.Gotham
	victimLabel.TextXAlignment = Enum.TextXAlignment.Left
	victimLabel.TextStrokeTransparency = 0.5
	victimLabel.Parent = entry

	return entry
end

-- Add entry to killfeed
local function addKillfeedEntry(killerName, victimName, weaponIcon, killType)
	-- Remove oldest entry if at max
	if #activeEntries >= MAX_ENTRIES then
		local oldestEntry = table.remove(activeEntries, 1)
		oldestEntry:Destroy()
	end

	-- Create new entry
	local newEntry = createKillfeedEntry(killerName, victimName, weaponIcon, killType)
	table.insert(activeEntries, newEntry)

	-- Reposition all entries
	for i, entry in ipairs(activeEntries) do
		local targetPosition = UDim2.new(0, 0, 0, (i - 1) * (ENTRY_HEIGHT + ENTRY_SPACING))

		local tween = TweenService:Create(
			entry,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Position = targetPosition}
		)
		tween:Play()
	end

	-- Fade out after display time
	task.delay(ENTRY_DISPLAY_TIME, function()
		if newEntry and newEntry.Parent then
			local fadeTween = TweenService:Create(
				newEntry,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{BackgroundTransparency = 1}
			)
			fadeTween:Play()

			-- Fade all text elements
			for _, child in ipairs(newEntry:GetChildren()) do
				if child:IsA("TextLabel") then
					local textFade = TweenService:Create(
						child,
						TweenInfo.new(0.5),
						{TextTransparency = 1, TextStrokeTransparency = 1}
					)
					textFade:Play()
				end
			end

			task.wait(0.5)

			-- Remove from active entries
			for i, entry in ipairs(activeEntries) do
				if entry == newEntry then
					table.remove(activeEntries, i)
					break
				end
			end

			newEntry:Destroy()
		end
	end)
end

-- Listen for kill events (placeholder - will connect to combat system)
-- This would normally be triggered by a RemoteEvent from the server
local function onPlayerKilled(killerName, victimName, weaponIcon, killType)
	addKillfeedEntry(killerName, victimName, weaponIcon, killType)
end

print("Killfeed initialized for:", player.Name)
print("Note: Killfeed events are placeholder - will integrate with combat system later")

-- Export function for other scripts to call
return {
	AddKill = onPlayerKilled
 }
