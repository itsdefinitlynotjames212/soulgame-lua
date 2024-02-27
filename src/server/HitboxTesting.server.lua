local ServerScriptService = game:GetService("ServerScriptService")

local HitboxHandler = require(ServerScriptService.modules.HitboxHandler)

local hitbox = HitboxHandler.CreateHitbox(
	Vector3.new(50, 50, 50),
	5,
	workspace.HitboxTest.CFrame,
	CFrame.new(0, 0, 0),
	Enum.PartType.Block,
	true,
	"Default"
)
hitbox:Start()

hitbox.touched:Connect(function(humanoid)
	local hum = humanoid :: Humanoid
	hum:TakeDamage(50)
end)
