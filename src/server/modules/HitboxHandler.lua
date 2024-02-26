local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RS = game:GetService("RunService")

local HitboxHandler = {}
HitboxHandler.__index = HitboxHandler

local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)

local hitbox_forms = {
	["proportion"] = {
		[Enum.PartType.Ball] = "Radius",
		[Enum.PartType.Block] = "Size",
	},

	["shape"] = {
		[Enum.PartType.Ball] = "SphereHandleAdornment",
		[Enum.PartType.Block] = "BoxHandleAdornment",
	},
}

local spacial_query_funcs = {
	[Enum.PartType.Ball] = function(self)
		return workspace:GetPartBoundsInRadius(self._cframe.p + self._offset.p, self._size, self._params)
	end,

	[Enum.PartType.Block] = function(self)
		return workspace:GetPartBoundsInBox(self._position_cframe * self._offset, self._size, self._params)
	end,
}

local hitboxes = {}

function HitboxHandler.CreateHitbox(
	size: Vector3,
	lifetime: number,
	position: CFrame,
	offset: CFrame,
	shape: Enum.PartType?,
	visualize: boolean?,
	hitbox_owner: Instance?
)
	return setmetatable({
		_size = size,
		_lifetime = lifetime,
		_position_cframe = position, -- if set to an instance instead of a cframe bad things will happen!!!
		_offset = offset,
		_shape = shape or Enum.PartType.Block,
		_visualize = visualize or true,
		_key = HttpService:GenerateGUID(false),
		_visualized_hitbox = nil,
		_color = Color3.new(255, 0, 0),
		_transparancy = 0.8,

		_params = OverlapParams.new(),
		_hitlist = {},
		_touching_parts = {},
		_hitbox_owner = hitbox_owner,

		_trove = Trove.new(),
		_touch_start = Signal.new(),
		_touch_end = Signal.new(),
	}, HitboxHandler)
end

function HitboxHandler:_visualize_hitbox()
	if not self.visualize then
		return
	end

	if self._visualized_hitbox then
		self._visualized_hitbox.CFrame = self._position_cframe * self._offset
	else
		self._visualized_hitbox = Instance.new(hitbox_forms.shape[self._shape])
		self._visualized_hitbox.Name = `visualized_hitbox_{self._key}`
		self._visualized_hitbox.Adornee = workspace.Terrain
		self._visualized_hitbox[hitbox_forms.proportion[self._shape]] = self._size
		self._visualized_hitbox.CFrame = self._position_cframe * self._offset
		self._visualized_hitbox.Color3 = self._color
		self._visualized_hitbox.Transparancy = self._transparancy
		self._visualized_hitbox.Parent = workspace.Terrain
	end
	self._trove:Add(self._visualized_hitbox)
end
function HitboxHandler:_clear()
	self._hitlist = {}
	hitboxes[self._key] = nil
	self._trove:Destroy()

	if self._visualize then
		self._visualized_hitbox:Destroy()
		self._visulized_hitbox = nil
	end
end

function HitboxHandler:_insert_touching_part(part: BasePart)
	if table.find(self._touching_parts, part) then
		return
	end
	table.insert(self._touching_parts, part)
end

function HitboxHandler:_cast()
	-- main hitbox logic
	self._params.FilterType = Enum.RaycastFilterType.Exclude
	self._params.FilterDescendantsInstances = {
		self._hitbox_owner,
	}
	self._params.MaxParts = 1
	local start = tick()

	-- task.spawn(function()
	-- 	while task.wait() do
	-- 		if tick() - start >= self._lifetime then
	-- 			self:Stop()
	-- 		end
	-- 	end
	-- end)

	local parts = spacial_query_funcs[self._shape](self)
	for _, hit in parts do
		local character = hit:FindFirstAncestorOfClass("Model") or hit.Parent
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid and not self._hitlist[table.find(self._hitlist, humanoid)] then
			table.insert(self._hitlist, humanoid)
			self:_insert_touching_part(hit)

			self._touch_start:Fire(humanoid)
			print("touched")
		end
	end
end

function HitboxHandler:Start()
	if hitboxes[self._key] then
		error("A hitbox with that key has already been made, start the hitbox instead.")
	end
	hitboxes[self._key] = self

	task.spawn(function()
		self._trove:Connect(RS.Heartbeat, function()
			self:_cast()
			self:_visualize_hitbox()
		end)
	end)
end

function HitboxHandler:Stop()
	self:_clear()

	setmetatable(self, nil)
end

return HitboxHandler
