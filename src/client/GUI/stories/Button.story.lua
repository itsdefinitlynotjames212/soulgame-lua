local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Button = require(StarterPlayer.StarterPlayerScripts.GUI.components.Button)

local props: Button.ButtonProps = {
	Text = "click me",
	Size = UDim2.new(0, 200, 0, 50),
	DisabledTime = 5,
}

return {
	summary = "A generic button to be used anywhere",
	story = Roact.createElement(Button, props),
}
