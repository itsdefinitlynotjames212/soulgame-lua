local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RS = game:GetService("RunService")

local HitboxManager = {}
HitboxManager.__index = HitboxManager

local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)

local hitboxes = {}

function HitboxManager.CreateHitbox(
	size: Vector3,
	length: number,
	cframe: CFrame,
	offset: CFrame,
	shape: Enum.PartType?,
	visualize: boolean?
)
	return setmetatable({
		_size = size,
		_length = length,
		_cframe = cframe,
		_offset = offset,
		_shape = shape or Enum.PartType.Block,
		_visualize = visualize or true,
		_key = HttpService:GenerateGUID(false),
		_color = Color3.new(255, 0, 0),
		_transparancy = 0.8,

		_hitlist = {},
		_touchingparts = {},
		_params = OverlapParams.new(),

		_trove = Trove.new(),
		_touchstart = Signal.new(),
		_touchend = Signal.new(),
	}, HitboxManager)
end

function HitboxManager:_cast() end
function HitboxManager:_visualizer() end
function HitboxManager:_clear()
	self._hitlist = {}

	hitboxes[self._key] = nil
	self._trove:Disconnect()
end

function HitboxManager:Start()
	if hitboxes[self._key] then
		return
	end
	hitboxes[self._key] = self
	print(hitboxes)

	task.spawn(function()
		self._trove:Connect(RS.Heartbeat, function()
			self:_visualizer()
			self:_cast()
		end)
	end)
end

function HitboxManager:Stop()
	self._trove:Destroy()
	self:_clear()

	setmetatable(self, nil)
end

return HitboxManager
