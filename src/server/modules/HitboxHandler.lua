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
		return workspace:GetPartBoundsInRadius(self._position_cframe.p + self._offset.p, self._size, self._params)
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
	hitmode: "Default" | "DOT"?,
	dot_length: number?
)
	local self = setmetatable({}, HitboxHandler)
	self._key = HttpService:GenerateGUID(false)

	self._trove = Trove.new()
	self.touched = Signal.new()
	self._trove:Add(self.touched)

	self._size = size
	self._lifetime = lifetime
	self._position_cframe = position -- if set to an instance instead of a cframe bad things will happen!!!
	self._offset = offset
	self._shape = shape or Enum.PartType.Block :: Enum.PartType
	self._visualize = visualize :: boolean
	self._visual_hitbox = nil :: BoxHandleAdornment | SphereHandleAdornment

	self._trove:Add(self._visual_hitbox)
	self._trove:Add(function()
		self._visual_hitbox = nil
	end)

	self._hitmode = hitmode or "Default"
	self._dot_length = dot_length or 0
	self._params = OverlapParams.new()
	self._hitlist = {}
	self._touching_parts = {}

	return self
end

function HitboxHandler:_visualize_hitbox()
	if self._visual_hitbox then
		self._visual_hitbox.CFrame = self._position_cframe * self._offset
	else
		self._visual_hitbox = Instance.new(hitbox_forms.shape[self._shape])
		self._visual_hitbox.Name = `visualized_hitbox_{self._key}`
		self._visual_hitbox.Adornee = workspace.Terrain
		self._visual_hitbox[hitbox_forms.proportion[self._shape]] = self._size
		self._visual_hitbox.CFrame = self._position_cframe * self._offset
		self._visual_hitbox.Color3 = Color3.new(255, 0, 0)
		self._visual_hitbox.Transparency = 0.8
		self._visual_hitbox.Parent = workspace.Terrain
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
	local parts = spacial_query_funcs[self._shape](self)
	for _, hit in parts do
		local character = hit:FindFirstAncestorOfClass("Model") or hit.Parent :: Model
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or self._hitlist[table.find(self._hitlist, character.Name)] then
			return
		end

		if self._hitmode == "Default" then
			table.insert(self._hitlist, character.Name)
			self:_insert_touching_part(hit)

			self.touched:Fire(humanoid)
		elseif self._hitmode == "DOT" then
			task.wait(self._dot_time)
			self:_insert_touching_part(hit)

			self.touched:Fire(humanoid)
		end
	end
end

function HitboxHandler:Start()
	if hitboxes[self._key] then
		error("A hitbox with that key has already been made, start the hitbox instead.")
	end
	hitboxes[self._key] = self
	local hitbox_start = tick()
	print(hitboxes)

	task.spawn(function()
		self._trove:Connect(RS.Heartbeat, function()
			self:_cast()
			self:_visualize_hitbox()

			if tick() - hitbox_start >= self._lifetime then
				self:Stop()
			end
		end)
	end)
end

function HitboxHandler:Stop()
	self._hitlist = {}
	hitboxes[self._key] = nil
	self._trove:Destroy()

	setmetatable(self, nil)
end

return HitboxHandler
