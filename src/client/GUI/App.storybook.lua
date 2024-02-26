local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Roact = require(ReplicatedStorage.Packages.Roact)

return {
	roact = Roact,
	storyRoots = {
		StarterPlayer.StarterPlayerScripts.GUI.stories,
	},
}
