local ServerScriptService = game:GetService("ServerScriptService")


local HitboxHandler = require(ServerScriptService.modules.HitboxHandler)

local hitbox = HitboxHandler.CreateHitbox(Vector3.new(6, 6, 6), 10, CFrame.new(0, 0, 0), CFrame.new(0, 0, 0))
hitbox:Start()