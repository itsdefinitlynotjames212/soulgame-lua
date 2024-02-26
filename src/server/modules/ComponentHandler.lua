local CollectionService = game:GetService("CollectionService")

local ComponentHandler = {}
local CachedInstances = {}

function load(inputs: { ModuleScript? })
	for _, input in inputs do
		if not input:IsA("ModuleScript") then
			continue
		end
		local module = require(input)
		local Tag = module.Tag

		local function InstanceAdded(instance: Instance)
			CachedInstances[instance] = CachedInstances[instance] or {}
			local component = module.new(instance)
			CachedInstances[instance][Tag] = component
			component:Start()
		end

		local function InstanceRemoved(instance: Instance)
			for tag, component in CachedInstances[instance] do
				component:Stop()
				component[tag] = nil
			end
		end

		for _, existing in CollectionService:GetTagged(Tag) do
			InstanceAdded(existing)
		end
		CollectionService:GetInstanceAddedSignal(Tag):Connect(InstanceAdded)
		CollectionService:GetInstanceRemovedSignal(Tag):Connect(InstanceRemoved)
	end
end

function ComponentHandler.Load(components)
	if typeof(components) == "Instance" then
		load(components:GetChildren())
	elseif typeof(components) == "table" then
		load(components)
	end
end

function ComponentHandler.GetComponents(instance: Instance)
	return CachedInstances[instance]
end

return ComponentHandler
