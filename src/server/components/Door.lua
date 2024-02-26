local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")

local Door = {
	Tag = "Door",
}
Door.__index = Door

type DoorInstance = Model & {
	Doorframe: Model & {
		Hinge: BasePart & {
			WeldConstraint: WeldConstraint,
		},
	},
	Base: BasePart & {
		ProximityPrompt: ProximityPrompt,
	},
}

local Trove = require(ReplicatedStorage.Packages.Trove)

function Door.new(door: DoorInstance)
	local self = setmetatable({}, Door)
	self._hinge = door.Doorframe.Hinge
	self._closedPositionCFrame = self._hinge.CFrame
	self._prompt = door.Base.ProximityPrompt
	self._tweenInfo = TweenInfo.new(5.5)
	self._trove = Trove.new()
	self._trove:Add(door)
	return self
end

function Door:Open()
	TS:Create(self._hinge, self._tweenInfo, { CFrame = self._hinge.CFrame * CFrame.Angles(0, math.rad(-90), 0) }):Play()
end

function Door:Close()
	TS:Create(self._hinge, self._tweenInfo, { CFrame = self._closedPositionCFrame }):Play()
end

function Door:Start()
	self._trove:Connect(self._prompt.Triggered, function()
		if self._prompt.ActionText == "Close" then
			self:Close()
			self._prompt.ActionText = "Open"
		else
			self:Open()
			self._prompt.ActionText = "Close"
		end
	end)
end

function Door:Stop()
	self._trove:Destroy()
end

return Door
