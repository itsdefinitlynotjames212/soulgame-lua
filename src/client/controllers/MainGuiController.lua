local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Roact = require(ReplicatedStorage.Packages.Roact)
local MainGuiHandler = require(StarterPlayer.StarterPlayerScripts.GUI.MainGuiHandler)

local GuiController = {}

function GuiController:OnStart()
	local GUI = Players.LocalPlayer:WaitForChild("PlayerGui")
	local App = Roact.createElement(MainGuiHandler)

	Roact.mount(App, GUI, "MainGUI")
end

return GuiController
