local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Loader = require(ReplicatedStorage.Packages.Loader)
local HitboxHandler = require(ServerScriptService.modules.HitboxHandler)

Loader.SpawnAll(Loader.LoadDescendants(ServerScriptService.services, Loader.MatchesName("Service$")), "OnStart")

local Hitbox = HitboxHandler.CreateHitbox(Vector3.new(6, 6, 6), 0.1, CFrame.new(0, 0, 0), CFrame.new(0, 0, -2.5))
Hitbox:Start()
