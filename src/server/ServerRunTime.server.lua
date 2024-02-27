local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Loader = require(ReplicatedStorage.Packages.Loader)

Loader.SpawnAll(Loader.LoadDescendants(ServerScriptService.services, Loader.MatchesName("Service$")), "OnStart")
