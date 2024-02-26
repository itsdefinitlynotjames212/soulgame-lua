local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

local Roact = require(ReplicatedStorage.Packages.Roact)
local Button = require(StarterPlayerScripts.GUI.components.Button)

local App = Roact.Component:extend("App")

function App:render()
	return Roact.createElement("ScreenGui", {}, {
		TextButton = Roact.createElement(Button, {
			Text = "click me",
			Size = UDim2.new(0, 200, 0, 50),
			DisabledTime = 5,
		}),
	})
end

return App
