local RS = game:GetService("RunService")
local Players = game:GetService("Players")

local PlayerDataService = {}

local SaveHandler = require(script.SaveHandler)
local Config = require(script.Config)

local ProfileStore = SaveHandler.GetProfileStore("PlayerSaves", Config.DefaultPlayerSave)
local Profiles = {}

----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

local function OnPlayerAdded(player: Player)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)

	if profile then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile:ListenToRelease(function()
			Profiles[player.Name] = nil
			player:Kick()
		end)

		if not player:IsDescendantOf(Players) then -- if the player left while data loading
			profile:Release()
		else
			Profiles[player.Name] = profile
			print("Loaded data for " .. player.Name .. ":", profile.Data)
		end
	else
		player:Kick()
	end
end

local function GetProfile(player: Player)
	if not Profiles[player.Name] then
		local start = tick()
		repeat
			task.wait()
			if tick() - start >= 3 then
				error("profile retrival timed out")
			end
		until Profiles[player.Name]
	end

	return Profiles[player.Name]
end

local function GetData(player: Player, key: string)
	local profile = GetProfile(player)
	assert(profile.Data[key], `No such data entry '{key}' found in database`)

	return profile.Data[key]
end

local function SetData(player: Player, key: string, value: any)
	local profile = GetProfile(player)
	assert(profile.Data[key], `No such data entry '{key}' found in database`)
	assert(
		type(profile.Data[key]) == type(value),
		`Type {type(value)} does not match the expected type {type(profile.Data[key])} for entry '{key}'`
	)
	profile.Data[key] = value
end

----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

function PlayerDataService:GetProfile(player: Player)
	return GetProfile(player)
end

function PlayerDataService:OnStart()
	for _, player in Players:GetPlayers() do
		task.spawn(OnPlayerAdded, player)
	end

	Players.PlayerAdded:Connect(OnPlayerAdded)
	Players.PlayerRemoving:Connect(function(player)
		Profiles[player.Name]:Release()
	end)

	game:BindToClose(function()
		if RS:IsStudio() then
			return
		end
		for _, player in ipairs(Players:GetPlayers()) do
			task.spawn(function()
				Profiles[player.Name]:Release()
			end)
		end
	end)
end

return PlayerDataService
