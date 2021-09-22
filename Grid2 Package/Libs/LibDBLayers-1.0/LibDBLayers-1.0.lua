--[[
THIS CODE IS TOTALLY UNSUITABLE FOR ANYTHING BUT GETTING A VAGUE SENSE OF THE FINAL PRODUCT

/script Grid2DB = nil; Grid2OptionsDB = nil; ReloadUI()

LibDBLayers-1.0 manages the SavedVariables of your addon.
* Difference between LibDBLayers and AceDB:
** No metatables.  Settings for an object are flattened into a single table.
** Settings can be shared per account (global), class, or spec (custom).
* It offers support for defaults, and a layered hierarchy of settings.
* It is designed to have verbose layered settings in your AddonOptionsDB which is only loaded and used when setting up defaults or changing options.
* The layered settings are flattenned into single compact tables for each object in your AddonDB
* Support for versioning

===== Normal use =====
* Iterate through the character/spec setup and create create your objects and assign their flattened dbx from AddonDB.objects to them.
* Dereference myObject: myObject.dbx.mySavedVariable1 etc.
===== First time use =====
* The lod options of your mod gets loaded
* AddonDB and AddonOptionsDB are created
* Default settings for the current character are added.
===== Upgrade use =====
* An obsolete version causes MyAddonOptions (+ any MyAddonPlugin1Options etc.) to load.
* The new options are added (if possible) without overriding already existing objects.

**Note this is still under development and currently guided and motivated by Grid2 needs.**
--]]

-- Note this is still under development and currently guided by Grid2 needs.

-- * **profile-current** Index into setup-layers.
-- * **profile-available** For a particular character, the list of (spec specific) profiles profile-current can switch to without loading (lod) MyAddonOptions.
-- * **versions** Stores keys for plugins etc. so they can determine when their settings need updating and thus loading of their lod options.
-- * **setup-layers** Individual setups for all characters/specs in the account.  These are lists of objects found in objects.
-- * **objects** Objects, keyed to a particular layer.  So may contain "heals" and / or "heals".
-- * These sections are common to both AddonDB and AddonOptionsDB
-- * The AddonOptionsDB ones are more verbose and separate the various layers.
-- * The AddonDB ones are flattened versions of them.
-- @usage
-- Example AddonDB and AddonOptionsDB (Grid2):
--

local MAJOR, MINOR = "LibDBLayers-1.0", 1
local LibDBLayers, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not LibDBLayers then return end -- No upgrade needed

local type = type
local pairs, next = pairs, next

LibDBLayers.db_registry = LibDBLayers.db_registry or {}
LibDBLayers.frame = LibDBLayers.frame or CreateFrame("Frame")

local CallbackHandler
local CallbackDummy = { Fire = function() end }


LibDBLayers.defaultSpec = {
	druid = "tree",
	paladin = "holy1",
	priest = "holy2",
	shaman = "resto",
}
local realmKey = GetRealmName()
local charKey = UnitName("player") .. " - " .. realmKey
local _, classKey = UnitClass("player")
classKey = strlower(classKey)
local specKey = LibDBLayers.defaultSpec[classKey]


function LibDBLayers:GetDefaultKeys()
	return charKey, classKey, specKey
end

-- Set up the listed sub tables in the table provided
function LibDBLayers:SetupPath(root, ...)
	local current = root
	for i = 1, select('#', ...), 1 do
		local key = select(i, ...)
		if (not current[key]) then
			current[key] = {}
		end
		current = current[key]
	end
	return current
end

-- Copy (nested) options from src to dst
function LibDBLayers:CopyDB(src, dst)
	if (src) then
		for k, v in pairs(src) do
			if (type(v) == "table") then
				local temp = {}
				self:CopyDB(v, temp)
				dst[k] = temp
			else
				dst[k] = v
			end
		end
	end
end


function LibDBLayers:MakeDefaultDB(db, charKey, classKey, specKey)
	local profileCurrent = self:SetupPath(db, "profile-current")

	local profileCurrentKey = profileCurrent[charKey]
	if (not profileCurrentKey) then
		profileCurrentKey = "account-" .. classKey
		if (specKey) then
			profileCurrentKey = profileCurrentKey .. "-" .. specKey
		end
		profileCurrent[charKey] = profileCurrentKey
	end
	
	local availableList = self:SetupPath(db, "profile-available", charKey)
	if (not availableList[profileCurrentKey]) then
		availableList = {}
		availableList[profileCurrentKey] = availableList
	end
		
	local setup = self:SetupPath(db, "setup-layers")
	local objects = self:SetupPath(db, "objects")
	local versions = self:SetupPath(db, "versions")
	self:SetupPath(db.versions, "globals")
	
	return setup, objects, versions, profileCurrentKey
end

-- Initialize the mods runtime data.
-- First time through all versions would be missing which subsequently causes options to load and defaults applied.
-- In normal usage settings are used as is and options are not loaded
-- @param modName String the name of the lod Options mod
-- @param svRuntime Table the sv used by the mod at runtime.
-- @param charKeyO String optional UnitName .. "-" .. RealmName.  If not nil, overides the default or current setting.
-- @param classKeyO String optional lowercase of UnitClass.  If not nil, overides the default or current setting.
-- @param specKeyO String optional spec.  If not nil, overides the default or current setting.
-- @usage
-- local dblData = DBL:InitializeRuntime("MyModName", MyModDB)
-- @return dblData mod specific info used as a parameter to most functions
function LibDBLayers:InitializeRuntime(modName, svRuntime, charKeyO, classKeyO, specKeyO)
	local dblData = LibDBLayers.db_registry[modName] or {}
	LibDBLayers.db_registry[modName] = dblData
	
	dblData.svRuntime = svRuntime	-- destination of flattened options
	dblData.charKey = charKeyO or dblData.charKey or charKey
	dblData.classKey = classKeyO or dblData.classKey or classKey
	dblData.specKey = specKeyO or dblData.specKey or specKey
	
	dblData.setupDst, dblData.objectsDst, dblData.versionsDst, dblData.profileCurrentKey = LibDBLayers:MakeDefaultDB(svRuntime, dblData.charKey, dblData.classKey, dblData.specKey)
	dblData.setupFlat = self:SetupPath(svRuntime, "setup-flat")

	return dblData
end

-- Initialize the mods options.  These are verbose and layered and lod.
-- @param modName String the name of the lod Options mod
-- @param svOptions Table the sv used by the mod to store setup options.
-- @param charKeyO String optional UnitName .. "-" .. RealmName.  If not nil, overides the default or current setting.
-- @param classKeyO String optional lowercase of UnitClass.  If not nil, overides the default or current setting.
-- @param specKeyO String optional spec.  If not nil, overides the default or current setting.
-- @usage
-- local dblData = DBL:InitializeOptions("MyModName", MyModOptionsDB)
-- @return dblData mod specific info used as a parameter to most functions
function LibDBLayers:InitializeOptions(modName, svOptions, charKeyO, classKeyO, specKeyO)
	local dblData = LibDBLayers.db_registry[modName] or {}
	LibDBLayers.db_registry[modName] = dblData
	
	dblData.svOptions = svOptions	-- source of layered options that are flattened on their way to svRuntime
	dblData.charKey = charKeyO or dblData.charKey or charKey
	dblData.classKey = classKeyO or dblData.classKey or classKey
	dblData.specKey = specKeyO or dblData.specKey or specKey
	
	dblData.setupSrc, dblData.objectsSrc, dblData.versionsSrc, dblData.profileCurrentKey = self:MakeDefaultDB(svOptions, dblData.charKey, dblData.classKey, dblData.specKey)
	dblData.setupIndexes = {}
	dblData.layerOrder = {}

	return dblData
end


-- Get the data for a particular mod.
-- @param modName String the name of the lod Options mod
-- @usage
-- local dblData = DBL:GetData("MyModName")
-- @return dblData mod specific info used as a parameter to most functions
function LibDBLayers:GetData(modName)
	local dblData = LibDBLayers.db_registry[modName]
	return dblData
end

-- Get the data for a particular mod.
-- @param modName String the name of the lod Options mod
-- @usage
-- local profileCurrent = DBL:GetData("MyModName")
-- @return dblData mod specific info used as a parameter to most functions
function LibDBLayers:GetProfileCurrent(dblData)
	local profileCurrent = dblData.svRuntime["profile-current"][dblData.charKey]
	return profileCurrent
end

-- Loads options if any versions are newer than the one in dblData.versionsDst.
-- @param dblData Table containing dblData.versionsDst, a table of (nested) key/version pairs
-- @param optionsName String the name of the lod Options mod
-- @param funcLoad Function optional Initialization code to call on first load
-- @param ... Pairs of layer, currentVersion. "account" is stored at the top level, other layers in sub tables.
-- @usage
-- local upgrade = DBL:LoadOptions(versions, optionsName, "account", 1, "druid", 3, "tree", 1)
-- @return upgrade, true if some options need upgrading
function LibDBLayers:LoadOptions(optionsName, dblData, funcLoad, ...)
	local versions, upgrade, forceLoad
	
	if (dblData) then
		versions = dblData.versionsDst
	else
--print("LibDBLayers:LoadOptions forceload versions:", ...)
		forceLoad = true
	end

	-- Only load if version is old
	if (versions) then
		local count = select('#', ...)
		assert(count % 2 == 0, "Version parameters need to be multiples of layer, version")
		local checkScope
		for i = 2, count, 2 do
			local layer = select((i - 1), ...)
			if (layer) then
				local version = select(i, ...)
				if (layer == "class") then
					layer = dblData.classKey
				end

				if (layer == "account") then
					checkScope = versions
				else
					checkScope = versions[layer]
					if (not checkScope) then
						checkScope = {}
						versions[layer] = checkScope
					end
				end
-- print("LibDBLayers:LoadOptions", optionsName, "layer:", layer, "version:", version, "=", checkScope[optionsName], checkScope)

				if (not checkScope[optionsName]) then
					checkScope[optionsName] = 0
				end
				if (checkScope[optionsName] < version) then
-- print("LibDBLayers:LoadOptions upgrade needed", optionsName, "current version:", checkScope[optionsName])
					upgrade = true
				end
			end
		end
	end

	if ((upgrade or forceLoad) and not IsAddOnLoaded(optionsName)) then
-- print("LibDBLayers:LoadOptions ==>loading", optionsName)
		LoadAddOn(optionsName)
		if (funcLoad) then
			if (type(funcLoad) == "function") then
				funcLoad()
			elseif (type(funcLoad) == "string") then
				local options = _G[optionsName]
				if (options) then
					options[funcLoad]()
				end
			end
		end
	end
-- print("LibDBLayers:LoadOptions", optionsName, "IsAddOnLoaded:", IsAddOnLoaded(optionsName))
-- print(" ")
	
	return upgrade
end

-- Upgrade defaults if any versions are newer than the one in dblData.versionsDst.
-- @param optionsName String the name of the lod Options mod
-- @param dblData Table containing dblData.versionsDst, a table of (nested) key/version pairs
-- @param funcUpgrade Function Called if the defaults need upgrading
-- @param ... Pairs of layer, currentVersion. "account" is stored at the top level, other layers in sub tables.
-- @usage
-- local flatten = DBL:UpgradeDefaults(versions, optionsName, MyOptionX.UpgradeDefaults, "account", 1, "druid", 3, "tree", 1)
-- @return flatten, true if some options were upgraded, and thus need to be flattenned and copied to svRuntime
function LibDBLayers:UpgradeDefaults(optionsName, dblData, funcUpgrade, ...)
-- print("LibDBLayers:UpgradeDefaults", optionsName, "funcUpgrade", funcUpgrade, "...", ...)
	local versions = dblData.versionsDst
	local versionsSrc = dblData.versionsSrc
	local flatten

	local count = select('#', ...)
	assert(count % 2 == 0, "Version parameters need to be multiples of layer, version")
	local checkScope
--print("LibDBLayers:UpgradeDefaults", optionsName, "funcUpgrade", funcUpgrade, "count", count)
	for i = 2, count, 2 do
		local layer = select((i - 1), ...)
		if (layer) then
			local version = select(i, ...)
			if (layer == "class") then
				layer = dblData.classKey
			end

			if (layer == "account") then
				checkScope = versions
			else
				checkScope = versions[layer]
			end
-- print("LibDBLayers:UpgradeDefaults checking", optionsName, layer, version, "=", checkScope[optionsName], checkScope)

			if (checkScope[optionsName] < version) then
-- print("LibDBLayers:UpgradeDefaults upgrading", optionsName, layer, version, "=", checkScope[optionsName], checkScope)
				flatten = true

				-- Initialize source versions
				if (layer == "account") then
					checkScope = versionsSrc
				else
					checkScope = versionsSrc[layer]
					if (not checkScope) then
						checkScope = {}
						versionsSrc[layer] = checkScope
					end
				end
				if (not checkScope[optionsName]) then
					checkScope[optionsName] = 0
				end
			end
		end
	end
	
	if (flatten) then
		funcUpgrade(dblData)
	end

	return flatten
end


-- Initialize global storage if required for the given type.
-- Globals are not layered and copied directly to runtime
-- dblData - data table for the mod
-- typeKey - type of object to initialize
-- @usage
-- DBL:InitializeGlobalType(dblData, "alerts")
function LibDBLayers:InitializeGlobalType(dblData, typeKey)
	self:SetupPath(dblData.objectsDst, typeKey, "globals")
end


-- Initialize storage if required for the given type.
-- dblData - data table for the mod
-- typeKey - type of object to initialize
-- layerOrder - table of <layer, layerIndex> pairs.  layerIndex = 1..n
-- @usage
-- DBL:InitializeObjectType(dblData, "statuses")
function LibDBLayers:InitializeObjectType(dblData, typeKey, layerOrder)
	local layers = self:SetupPath(dblData.layerOrder, typeKey)
	self:CopyDB(layerOrder, layers)
	
	for layer in pairs(layerOrder) do
		self:SetupPath(dblData.setupSrc, typeKey, layer)
		self:SetupPath(dblData.setupDst, typeKey, layer)
		self:SetupPath(dblData.objectsSrc, typeKey, layer)
		self:SetupPath(dblData.objectsDst, typeKey, layer)
	end
end
--/dump Grid2.dblData.layerOrder

-- Get the flattened setup list for typeKey
-- dblData - data table for the mod
-- typeKey - type of object to add
function LibDBLayers:GetLayerOrder(dblData, typeKey)
	return dblData.layerOrder[typeKey]
end


-- Set up a particular layer.  Does not overide existing values.
-- dblData - data table for the mod
-- typeKey - type of object to add
-- layer - "account", <class>, <spec|custom> etc
-- baseKey - key for the object
-- dbx - pairs of config values
-- override - if true, then overide existing values.
function LibDBLayers:SetupLayerObject(dblData, typeKey, layer, baseKey, dbx, override)
	local setup = dblData.setupSrc[typeKey][layer]
	local objects = dblData.objectsSrc[typeKey][layer]
	
	if (override or not setup[baseKey]) then
		if (dbx) then
			setup[baseKey] = true
		elseif (dbx == false) then
			setup[baseKey] = false
		else
			setup[baseKey] = nil
		end
	end
	if (override or not objects[baseKey]) then
		objects[baseKey] = dbx
	end
end

-- Set up a mapping.
-- dblData - data table for the mod
-- typeKey - type of map object to add
-- layer - "account", <class>, <spec|custom> etc
-- baseKey - key for the object to map from
-- mapKey - key for the object to map to
-- mapValue - value for the key.  Can be meaningful for sorting.
-- override - if true, then overide existing values.
function LibDBLayers:SetupMapObject(dblData, typeKey, layer, baseKey, mapKey, mapValue, override)
	local setup = dblData.setupSrc[typeKey][layer]
	local objects = dblData.objectsSrc[typeKey][layer]

	local map = objects[baseKey]
	if (not map and mapValue ~= nil) then
		map = {}
		objects[baseKey] = map
		setup[baseKey] = true
	end
	
-- print(baseKey, "->", mapKey, mapValue)
	if (map and (override or map[mapKey] == nil)) then
		map[mapKey] = mapValue
	end
end

function LibDBLayers:GetOrderIndexed(dblData, typeKey)
	-- Create a reverse lookup
	local layerIndexed = self:SetupPath(dblData, "layerIndexed", typeKey)
	local layerOrder = dblData.layerOrder[typeKey]
	if (not next(layerIndexed)) then
		for baseKey, layerIndex in pairs(layerOrder) do
			layerIndexed[layerIndex] = baseKey
		end
	end
	
	return layerIndexed
end

-- For a particular type, apply globals, and otherwise flatten and copy settings from options to the runtime dbx 
-- ToDo: add a globals mechanism
-- dblData - data table for the mod
-- typeKey - type of object to flatten
function LibDBLayers:FlattenSetupType(dblData, typeKey)
	local setupSrc = dblData.setupSrc[typeKey]
	local objectsSrc = dblData.objectsSrc[typeKey]
	local objectsDst = dblData.objectsDst[typeKey]

	--Create a list of keys required with their deepest order index
	local profileCurrentKey = dblData.profileCurrentKey
	local flatKeys = self:SetupPath(dblData.setupFlat, typeKey, profileCurrentKey)
	wipe(flatKeys)
	local layerOrder = dblData.layerOrder[typeKey]
	for layer, setup in pairs(setupSrc) do
		local srcOrder = layerOrder[layer]
		if (srcOrder) then
			for baseKey in pairs(setup) do
				local dstOrder = flatKeys[baseKey] or 0
				if (srcOrder > dstOrder) then
					flatKeys[baseKey] = srcOrder
				end
			end
		end
	end

	local layerIndexed = self:GetOrderIndexed(dblData, typeKey)
	for baseKey, layerIndex in pairs(flatKeys) do
		-- Copy setup keys
		local layer = layerIndexed[layerIndex]
		flatKeys[baseKey] = layer

		-- Create flattened dbx
		local dbFlat = objectsDst[layer][baseKey] or {}
		objectsDst[layer][baseKey] = dbFlat
		wipe(dbFlat)
		for index = 1, layerIndex, 1 do
			layer = layerIndexed[index]
			self:CopyDB(objectsSrc[layer][baseKey], dbFlat)
		end
	end
end

local srcKeys = {}
-- Flatten a mapping between two object types (from -> to)
-- Ensure the most layer specific objects are mapped 
-- dblData - data table for the mod
-- typeKey - type of object to flatten
-- fromKey - type of from object to flatten
-- toKey - type of to object to flatten
function LibDBLayers:FlattenMap(dblData, typeKey, fromKey, toKey)
	local setupSrc = dblData.setupSrc[typeKey]
	local objectsSrc = dblData.objectsSrc[typeKey]
	local objectsDst = dblData.objectsDst[typeKey]

	--Create a list of keys required with their deepest order index
	local profileCurrentKey = dblData.profileCurrentKey
	local flatKeys = self:SetupPath(dblData.setupFlat, typeKey, profileCurrentKey)
	wipe(flatKeys)
	local layerOrder = dblData.layerOrder[typeKey]
	for layer, setup in pairs(setupSrc) do
		local srcOrder = layerOrder[layer]
		if (srcOrder) then
			for baseKey in pairs(setup) do
				local dstOrder = flatKeys[baseKey] or 0
				if (srcOrder > dstOrder) then
					flatKeys[baseKey] = srcOrder
				end
			end
		end
	end

	local layerIndexed = self:GetOrderIndexed(dblData, typeKey)
	for baseKey, layerIndex in pairs(flatKeys) do
		-- Copy setup keys
		local layer = layerIndexed[layerIndex]
		flatKeys[baseKey] = layer

		-- Create flattened dbx
		local dbFlat = objectsDst[layer][baseKey] or {}
		objectsDst[layer][baseKey] = dbFlat
		wipe(dbFlat)
		for index = 1, layerIndex, 1 do
			layer = layerIndexed[index]
			self:CopyDB(objectsSrc[layer][baseKey], dbFlat)
		end
	end

	-- ToDo: ensure value uniqueness for the mapped key values?
	-- ToDo: do existence checks here on fromKey, toKey?
-- print(" ")
end
--[[
/dump Grid2.dblData.objectsSrc["statusMap"]["account"]["alpha"]
--]]

-- Delete a particular layer 
-- dblData - data table for the mod
-- typeKey - type of object to add
-- baseKey - key for the object
-- layer - "account", <class>, <spec|custom> etc
function LibDBLayers:DeleteLayerObject(dblData, typeKey, layer, baseKey)
	local setup = dblData.setupSrc[typeKey][layer]
	local objects = dblData.objectsSrc[typeKey][layer]

	setup[baseKey] = nil
	objects[baseKey] = nil
end

-- Delete a particular mapping  between baseKey and mapKey
-- dblData - data table for the mod
-- typeKey - type of object to add
-- layer - "account", <class>, <spec|custom> etc
-- baseKey - key for the object mapped from
-- mapKey - key for the object mapped to
function LibDBLayers:DeleteMapObject(dblData, typeKey, layer, baseKey, mapKey)
	local setup = dblData.setupSrc[typeKey][layer]
	local objects = dblData.objectsSrc[typeKey][layer]

	if (objects) then
		local map = objects[baseKey]
		if (map) then
			map[mapKey] = nil
			
			--Delete the entire map at that layer if empty
			if (next(map) == nil) then
				objects[baseKey] = nil
				setup[baseKey] = nil
			end
		else
			setup[baseKey] = nil
		end
	end
end

-- Get the layer of a given object
-- dblData - data table for the mod
-- typeKey - type of object to add
-- baseKey - key for the object
-- layer - "account", <class>, <spec|custom> etc
function LibDBLayers:GetObjectLayer(dblData, typeKey, baseKey)
	local setupSrc = dblData.setupSrc[typeKey]
	local layerOrder = dblData.layerOrder[typeKey]
	local deepestLayer
	local deepestLayerIndex = 0
	assert(setupSrc and layerOrder, "LibDBLayers:GetObjectLayer " .. tostring(setupSrc) .. tostring(layerOrder) .. typeKey .. baseKey)
	for layer, setup in pairs(setupSrc) do
		if (setup[baseKey]) then
			local index = layerOrder[layer]
			if (index and index > deepestLayerIndex) then
				deepestLayerIndex = index
				deepestLayer = layer
			end
		end
	end
	return deepestLayer
end

-- Set the layer of a given object to newLayer
-- dblData - data table for the mod
-- typeKey - type of object to add
-- baseKey - key for the object
-- newLayer - "account", <class>, <spec|custom> etc
-- objectType - default for "type" field of the dbx
function LibDBLayers:SetObjectLayer(dblData, typeKey, baseKey, newLayer, dbxOld)
	local setupSrc = dblData.setupSrc[typeKey]
	local layerOrder = dblData.layerOrder[typeKey]
	local deepestLayerIndex = layerOrder[newLayer]
	for layer, setup in pairs(setupSrc) do
		local index = layerOrder[layer]
		local objects = dblData.objectsSrc[typeKey][layer]
		local dbx = objects[baseKey]
		if (index) then
			if (index > deepestLayerIndex) then
--print("SetObjectLayer deleting", typeKey, baseKey, layer)
				setup[baseKey] = nil
				if (dbx and not next(dbx)) then
					objects[baseKey] = nil
				end
			else
--print("SetObjectLayer adding setup", typeKey, baseKey, layer)
				setup[baseKey] = true
				if (not dbx) then
--print("SetObjectLayer adding objects", typeKey, baseKey, layer)
					dbx = {}
					objects[baseKey] = dbx
					self:CopyDB(dbxOld, dbx)
					-- ToDo: extend this to use a set of required keys for the copy
				end
			end
		end
	end
end

-- Get the layer of a given object
-- dblData - data table for the mod
-- typeKey - type of object to add
-- baseKey - key for the object
-- layer - "account", <class>, <spec|custom> etc
function LibDBLayers:GetMapLayer(dblData, typeKey, baseKey, mapKey)
	local setupSrc = dblData.setupSrc[typeKey]
	local objectsSrc = dblData.objectsSrc[typeKey]
	local layerOrder = dblData.layerOrder[typeKey]
	local deepestLayer
	local deepestLayerIndex = 0
	assert(setupSrc and layerOrder, "LibDBLayers:GetMapLayer " .. tostring(setupSrc) .. tostring(layerOrder) .. typeKey .. baseKey)
	for layer, setup in pairs(setupSrc) do
		if (setup[baseKey]) then
			local objects = objectsSrc[layer]
			local map = objects[baseKey]
			if (map[mapKey]) then
				local index = layerOrder[layer]
				if (index and index > deepestLayerIndex) then
					deepestLayerIndex = index
					deepestLayer = layer
-- print("   GetMapLayer", index, deepestLayer)
				end
			end
		end
	end
	return deepestLayer
end

-- Set the layer of a given object to newLayer
-- dblData - data table for the mod
-- typeKey - type of object to add
-- baseKey - key for the object
-- newLayer - "account", <class>, <spec|custom> etc
function LibDBLayers:SetMapLayer(dblData, typeKey, baseKey, mapKey, mapValue, newLayer)
	local setupSrc = dblData.setupSrc[typeKey]
	local layerOrder = dblData.layerOrder[typeKey]
	local deepestLayerIndex = layerOrder[newLayer]
-- print("SetMapLayer deepestLayerIndex", deepestLayerIndex, newLayer)
	for layer, setup in pairs(setupSrc) do
		local index = layerOrder[layer]
		local objects = dblData.objectsSrc[typeKey][layer]
		local dbx = objects[baseKey]
		if (index) then
			if (index > deepestLayerIndex) then
-- print("SetMapLayer deleting", typeKey, baseKey, mapKey, layer)
				self:SetupMapObject(dblData, typeKey, layer, baseKey, mapKey, nil, true)
			elseif (index == deepestLayerIndex) then
-- print("SetMapLayer adding", typeKey, baseKey, mapKey, mapValue, layer)
				self:SetupMapObject(dblData, typeKey, layer, baseKey, mapKey, mapValue, true)
			end
		end
	end
end

-- Get the runtime dbx of a given object
-- dblData - data table for the mod
-- typeKey - type of object to get
function LibDBLayers:GetRuntimeGlobals(dblData, typeKey)
	local dbx = dblData.objectsDst[typeKey]["globals"]
	return dbx
end


-- Get the runtime dbx of a given object
-- dblData - data table for the mod
-- typeKey - type of object to get
-- baseKey - key of the object
function LibDBLayers:GetRuntimeDbx(dblData, typeKey, baseKey)
	local profileCurrentKey = dblData.profileCurrentKey
	local layer = dblData.setupFlat[typeKey][profileCurrentKey][baseKey]
	local dbx
	if (layer) then
		dbx = dblData.objectsDst[typeKey][layer][baseKey]
	end
	return dbx
end


-- Get the runtime dbx (if any) of a given object
-- dblData - data table for the mod
-- typeKey - type of object to get
-- baseKey - key of the object
function LibDBLayers:GetOptionsDbx(dblData, typeKey, baseKey)
	local profileCurrentKey = dblData.profileCurrentKey
	local layer = dblData.setupFlat[typeKey][profileCurrentKey][baseKey]
	local dbx
	if (layer) then
		dbx = dblData.objectsSrc[typeKey][layer][baseKey]
	end
	return dbx
end


-- Get the flattened setup list for typeKey
-- dblData - data table for the mod
-- typeKey - type of object to add
function LibDBLayers:GetRuntimeSetup(dblData, typeKey)
	local profileCurrentKey = dblData.profileCurrentKey
	return dblData.setupFlat[typeKey][profileCurrentKey]
end

-- Get the setup list for typeKey
-- dblData - data table for the mod
-- typeKey - type of object to add
function LibDBLayers:GetOptionsSetup(dblData, typeKey)
	local profileCurrentKey = dblData.profileCurrentKey
	return dblData.setupSrc[typeKey]
end

-- Get the objects list for typeKey
-- dblData - data table for the mod
-- typeKey - type of object to add
function LibDBLayers:GetOptionsObjects(dblData, typeKey)
	local profileCurrentKey = dblData.profileCurrentKey
	return dblData.objectsSrc[typeKey]
end

