local Config = {}

export type PlayerInventoryItem = {
	name: string,
	id: string,
	equipped: boolean,
}

export type PlayerInventory = {
	items: { PlayerInventoryItem },
}

export type PlayerSave = {
	Inventory: PlayerInventory,
}

local DefaultPlayerSave: PlayerSave = {
	Inventory = {
		items = {},
	},
}

Config.DefaultPlayerSave = DefaultPlayerSave

return Config
