local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local Button = Roact.Component:extend("Button")

export type ButtonProps = {
	Text: string,
	Size: UDim2,
	DisabledTime: number,
}

function Button:init()
	self:setState({
		canActivate = true,
	})
end

function Button:render()
	local props: ButtonProps = self.props

	if self.state.canActivate then
		return Roact.createElement("TextButton", {
			Size = props.Size,
			Text = props.Text,
			[Roact.Event.Activated] = function()
				self:setState({
					canActivate = false,
				})
				task.delay(props.DisabledTime, function()
					self:setState({
						canActivate = true,
					})
				end)
			end,
		})
	else
		return Roact.createElement("TextLabel", {
			Size = props.Size,
			Text = "processing...",
		})
	end
end

return Button
