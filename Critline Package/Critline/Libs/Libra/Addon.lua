local Libra = LibStub("Libra")
local Type, Version = "Addon", 4
if Libra:GetModuleVersion(Type) >= Version then return end

Libra.modules[Type] = Libra.modules[Type] or {}

local object = Libra.modules[Type]
object.frame = object.frame or CreateFrame("Frame")
object.addons = object.addons or {}
object.events = object.events or {}
object.onUpdates = object.onUpdates or {}
object.defaults = object.defaults or {}

local function safecall(object, method, ...)
	if object[method] then
		object[method](object, ...)
	end
end

local function removeDefaults(tbl, defaults)
	for k, v in pairs(defaults) do
		if type(v) == "table" then
			removeDefaults(tbl[k], v)
			if not next(tbl[k]) then
				tbl[k] = nil
			end
		elseif v == tbl[k] then
			tbl[k] = nil
		end
	end
end

object.frame:RegisterEvent("ADDON_LOADED")
object.frame:RegisterEvent("PLAYER_LOGOUT")
object.frame:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		local addon = object.addons[...]
		if addon then
			safecall(addon, "OnInitialize")
			addon.OnInitialize = nil
			for i, module in addon:IterateModules() do
				safecall(module, "OnInitialize")
				module.OnInitialize = nil
			end
		end
	end
	if event == "PLAYER_LOGOUT" then
		for tbl, defaults in pairs(object.defaults) do
			removeDefaults(tbl, defaults)
		end
	end
	for module, eventHandler in pairs(object.events[event]) do
		eventHandler(module, ...)
	end
end)

local function onUpdate(self, elapsed)
	for module, update in pairs(object.onUpdates) do
		update(module, elapsed)
	end
end

local mt = {
	__index = function(table, key)
		local newTable = {}
		table[key] = newTable
		return newTable
	end
}

setmetatable(object.events, mt)

local AddonPrototype = {}
local ObjectPrototype = {}

local function AddonEmbed(target)
	for k, v in pairs(AddonPrototype) do
		target[k] = v
	end
end

local function ObjectEmbed(target)
	for k, v in pairs(ObjectPrototype) do
		target[k] = v
	end
end

function Libra:NewAddon(name, addonObject)
	if object.addons[name] then
		error(format("Addon '%s' already exists.", name), 2)
	end
	
	local addon = addonObject or {}
	addon.name = name
	addon.modules = {}
	addon.messages = setmetatable({}, mt)
	AddonEmbed(addon)
	ObjectEmbed(addon)
	object.addons[name] = addon
	return addon, name
end

function Libra:GetAddon(name)
	return object.addons[name]
end

function AddonPrototype:NewModule(name, table)
	if self:GetModule(name) then
		error(format("Module '%s' already exists in %s.", name, self.name), 2)
	end
	
	local module = table or {}
	ObjectEmbed(module)
	module.name = name
	module.messages = setmetatable({}, mt)
	tinsert(self.modules, module)
	safecall(self, "OnModuleCreated", name, module)
	return module, name
end

function AddonPrototype:GetModule(name)
	for i, module in self:IterateModules() do
		if module.name == name then
			return module
		end
	end
end

function AddonPrototype:IterateModules()
	return next, self.modules
end

local function copyDefaults(src, dst)
	if not src then return {} end
	if not dst then dst = {} end
	for k, v in pairs(src) do
		if type(v) == "table" then
			dst[k] = copyDefaults(v, dst[k])
		elseif type(v) ~= type(dst[k]) then
			dst[k] = v
		end
	end
	return dst
end

function AddonPrototype:CreateDB(global, defaults)
	local db = _G[global]
	db = copyDefaults(defaults, db)
	_G[global] = db
	object.defaults[db] = defaults
	return db
end

function ObjectPrototype:RegisterEvent(event, handler)
	if not next(object.events[event]) then
		object.frame:RegisterEvent(event)
	end
	if type(handler) ~= "function" then
		handler = self[handler] or self[event]
	end
	object.events[event][self] = handler
end

function ObjectPrototype:UnregisterEvent(event)
	object.events[event][self] = nil
	if not next(object.events[event]) then
		object.frame:UnregisterEvent(event)
	end
end

function ObjectPrototype:SendMessage(message, ...)
	for module, messageHandler in pairs(self.messages[message]) do
		messageHandler(module, ...)
	end
end

function ObjectPrototype:RegisterMessage(module, message, handler)
	if type(handler) ~= "function" then
		handler = module[handler] or module[message]
	end
	self.messages[message][module] = handler
end

function ObjectPrototype:UnregisterMessage(module, message)
	self.messages[message][module] = nil
end

function ObjectPrototype:SetOnUpdate(handler)
	if not next(object.onUpdates) then
		object.frame:SetScript("OnUpdate", onUpdate)
	end
	if type(handler) ~= "function" then
		handler = self[handler]
	end
	object.onUpdates[self] = handler
end

function ObjectPrototype:RemoveOnUpdate()
	object.onUpdates[self] = nil
	if not next(object.onUpdates) then
		object.frame:SetScript("OnUpdate", nil)
	end
end

-- upgrade embeds
for k, v in pairs(object.addons) do
	AddonEmbed(v)
	ObjectEmbed(v)
	for i, v in v:IterateModules() do
		ObjectEmbed(v)
	end
end

Libra:RegisterModule(Type, Version)