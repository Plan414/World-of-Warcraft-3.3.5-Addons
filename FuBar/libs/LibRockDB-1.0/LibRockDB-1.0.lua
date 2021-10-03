--[[
Name: LibRockDB-1.0
Revision: $Rev: 240 $
Developed by: ckknight (ckknight@gmail.com)
Website: http://www.wowace.com/
Description: Library to allow for fast, clean, and featureful saved variable access.
Dependencies: LibRock-1.0
License: LGPL v2.1
]]

local MAJOR_VERSION = "LibRockDB-1.0"
local MINOR_VERSION = tonumber(("$Revision: 240 $"):match("(%d+)")) + 90000

if not Rock then error(MAJOR_VERSION .. " requires LibRock-1.0") end

local RockDB, oldLib = Rock:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not RockDB then
	return
end

-- #AUTODOC_NAMESPACE RockDB

local _G = _G
local Rock = _G.Rock
local pairs = _G.pairs
local next = _G.next
local geterrorhandler = _G.geterrorhandler
local pcall = _G.pcall
local rawset = _G.rawset
local error = _G.error
local type = _G.type
local tostring = _G.tostring
local rawget = _G.rawget
local setmetatable = _G.setmetatable
local GetAddOnInfo = _G.GetAddOnInfo
local GetNumAddOns = _G.GetNumAddOns
local debugstack = _G.debugstack
local assert = _G.assert
local select = _G.select
local ipairs = _G.ipairs

local L = setmetatable({}, {__index=function(self,key) self[key] = key; return key end})

if GetLocale() == "zhTW" then
	L["Character: "] = "角色: "
	L["%s of %s"] = "%s - %s"
	L["Realm: "] = "伺服器: "
	L["Class: "] = "職業: "
	L["Default"] = "預設"
	L["Alternative"] = "替代"
	L["Profile"] = "記錄檔"
	L["Set profile for this addon."] = "設定插件的記錄檔。"
	L["Choose"] = "選擇"
	L["Choose a profile."] = "選擇記錄檔。"
	L["Copy from"] = "複製"
	L["Copy settings from another profile."] = "由其他記錄檔度複製設定。"
	L["Other"] = "其他"
	L["Choose another profile."] = "選擇另一個記錄檔。"
	L["<profile name>"] = "<記錄檔名稱>"
	L["Remove"] = "刪除"
	L["Removes a profile. Note that no check is made whether this profile is in use by other characters or not."] = "刪除記錄檔。注意，有可能別的角色也使用這個記錄檔。"
	L["Reset profile"] = "重設記錄檔"
	L["Clear all settings of the current profile."] = "清除目前的記錄檔上的所有設定。"
	L["Reset all settings."] = "重設所有設定。"
	L["Reset"] = "重設"
elseif GetLocale() == "koKR" then
	L["Character: "] = "캐릭터: "
	L["%s of %s"] = "%s - %s"
	L["Realm: "] = "서버: "
	L["Class: "] = "직업: "
	L["Default"] = "기본값"
	L["Alternative"] = "대체"
	L["Profile"] = "프로필"
	L["Set profile for this addon."] = "이 애드온을 위한 프로필을 설정합니다."
	L["Choose"] = "선택"
	L["Choose a profile."] = "프로필을 선택합니다."
	L["Copy from"] = "복사"
	L["Copy settings from another profile."] = "세팅된 다른 프로필을 복사합니다."
	L["Other"] = "기타"
	L["Choose another profile."] = "다른 프로필을 선택합니다."
	L["<profile name>"] = "<프로필 이름>"
	L["Remove"] = "삭제"
	L["Removes a profile. Note that no check is made whether this profile is in use by other characters or not."] = "프로필을 삭제합니다."
	L["Reset profile"] = "프로필 초기화"
	L["Clear all settings of the current profile."] = "모든 세팅에서 현재 프로필을 제거합니다."
	L["Reset all settings."] = "모든 세팅 초기화"
	L["Reset"] = "초기화"
elseif GetLocale() == "frFR" then
	L["Character: "] = "Personnage : "
	L["%s of %s"] = "%s de %s"
	L["Realm: "] = "Royaume : "
	L["Class: "] = "Classe : "
	L["Default"] = "Défaut"
	L["Alternative"] = "Alternative"
	L["Profile"] = "Profil"
	L["Set profile for this addon."] = "Détermine le profil à utiliser pour cet addon."
	L["Choose"] = "Choisir"
	L["Choose a profile."] = "Permet de choisir un profil."
	L["Copy from"] = "Copier à partir de"
	L["Copy settings from another profile."] = "Copie les paramètres d'un autre profil."
	L["Other"] = "Autre"
	L["Choose another profile."] = "Permet de choisir un autre profil."
	L["<profile name>"] = "<nom du profil>"
	L["Remove"] = "Enlever"
	L["Removes a profile. Note that no check is made whether this profile is in use by other characters or not."] = "Enlève un profil. Notez qu'aucune vérification n'est faites pour savoir si ce profil est utilisé par un autre personnage ou pas."
	L["Reset profile"] = "Réinitialiser le profil"
	L["Clear all settings of the current profile."] = "Efface tous les paramètres du profil actuel."
	L["Reset all settings."] = "Réinitialiser tous les paramètres"
	L["Reset"] = "Réinitialiser"
elseif GetLocale() == "zhCN" then
	L["Character: "] = "角色: "
	L["%s of %s"] = "%s - %s"
	L["Realm: "] = "服务器: "
	L["Class: "] = "职业: "
	L["Default"] = "默认值"
	L["Alternative"] = "替换"
	L["Profile"] = "个人配置"
	L["Set profile for this addon."] = "设置插件的个人配置。"
	L["Choose"] = "选择"
	L["Choose a profile."] = "选择配置文件。"
	L["Copy from"] = "复制"
	L["Copy settings from another profile."] = "从其他配置文件复制设置。"
	L["Other"] = "其他"
	L["Choose another profile."] = "选择其他配置文件。"
	L["<profile name>"] = "<个人配置文件名>"
	L["Remove"] = "删除"
	L["Removes a profile. Note that no check is made whether this profile is in use by other characters or not."] = "删除此配置。注意：有可能其他角色使用了。"
	L["Reset profile"] = "重置个人配置"
	L["Clear all settings of the current profile."] = "清除当前个人配置上所有设置。"
	L["Reset all settings."] = "重置全部设置。"
	L["Reset"] = "重置"	
end

RockDB.frame = oldLib and oldLib.frame or _G.CreateFrame("Frame")
local frame = RockDB.frame
frame:UnregisterAllEvents()
-- dictionary of object to { init = true/false, dbName = "GlobalDB", charName = "CharDB", db = _G[dbName], charDB = _G[charName], defaults = { ["dataType"] = { --[[ stuff ]] } }, namespaces = { ["namespace"] = dbTable }, namespaceDefaults = { ["namespace"] = { ["dataType"] = { --[[ stuff]] } } } }
RockDB.data = setmetatable(oldLib and oldLib.data or {}, {__mode='k'})
local data = RockDB.data

local newList, del, newDict, unpackDictAndDel = Rock:GetRecyclingFunctions(MAJOR_VERSION, "newList", "del", "newDict", "unpackDictAndDel")

local precondition, postcondition, argCheck = Rock:GetContractFunctions(MAJOR_VERSION, "precondition", "postcondition", "argCheck")

local _,race = _G.UnitRace("player")
local faction
if race == "Orc" or race == "Scourge" or race == "Troll" or race == "Tauren" or race == "BloodElf" then
	faction = _G.FACTION_HORDE
else
	faction = _G.FACTION_ALLIANCE
end
local server = _G.GetRealmName():trim()
local _,classID = _G.UnitClass("player")
classID = classID:sub(1, 1) .. classID:sub(2):lower() -- Warrior instead of WARRIOR
local charID = _G.UnitName("player") .. " - " .. server
local realmID = server .. " - " .. faction

local function figureCurrentAddon(pos)
	local stack = debugstack(pos+1, 1, 0)
	local folder = stack:match("[Oo%.][Nn%.][Ss%.]\\([^\\]+)\\")
	if folder then
		return folder
	end

	local partFolder = stack:match("...([^\\]+)\\")
	if partFolder then
		local partFolder_len = #partFolder
		for i = 1, GetNumAddOns() do
			local name = GetAddOnInfo(i)
			if #name >= partFolder_len then
				local partName = name:sub(-partFolder_len)
				if partName == partFolder then
					return name
				end
			end
		end
	end
	return nil
end

local function caseInsensitiveLookup(t, key)
	if not t then
		return nil
	end
	local value = t[key]
	if value ~= nil then
		return key, value
	end
	local key_lower = key:lower()
	for k,v in pairs(t) do
		if type(k) == "string" and k:lower() == key then
			return k, v
		end
	end
	return nil, nil
end

local function fixKeyCasing(t, key)
	local value = t[key]
	if value ~= nil then
		return
	end
	local key_lower = key:lower()
	for k,v in pairs(t) do
		if type(k) == "string" and k:lower() == key then
			t[k] = nil
			t[key] = v
			return
		end
	end
end

local function cleanDefaults(t, defaults, blocker)
	if defaults then
		for k,v in pairs(t) do
			if (not blocker or (blocker[k] == nil and blocker['*'] == nil and blocker['**'] == nil)) and (defaults[k] ~= nil or defaults['*'] ~= nil or defaults['**'] ~= nil) then
				local u = defaults[k]
				if u == nil then
					u = defaults['*']
					if u == nil then
						u = defaults['**']
					end
				end
				if v == u then
					t[k] = nil
				elseif type(v) == "table" and type(u) == "table" then
					if cleanDefaults(v, u) then
						t[k] = del(v)
					else
						local w = defaults['**']
						if w ~= u then
							if cleanDefaults(v, w, u) then
								t[k] = del(v)
							end
						end
					end
				end
			end
		end
	end
	return t and next(t) == nil
end

local function inheritDefaults(t, defaults)
	if not defaults then
		return t
	end
	for k,v in pairs(defaults) do
		if k == "*" or k == "**" then
			local v = v
			if type(v) == "table" then
				local mt = newList()
				function mt:__index(key)
					if key == nil then
						return nil
					end
					local value = newList()
					self[key] = value
					inheritDefaults(value, v)
					return value
				end
				setmetatable(t, mt)
				for key in pairs(t) do
					if (defaults[key] == nil or key == k) and type(t[key]) == "table" then
						inheritDefaults(t[key], v)
					end
				end
			else
				local mt = newList()
				function mt:__index(key)
					if key == nil then
						return nil
					end
					self[key] = v
					return v
				end
				setmetatable(t, mt)
			end
		else
			if type(v) == "table" then
				if type(rawget(t, k)) ~= "table" then
					t[k] = newList()
				end
				inheritDefaults(t[k], v)
				if type(defaults["**"] == "table") then
					inheritDefaults(t[k], defaults["**"])
				end
			elseif rawget(t, k) == nil then
				t[k] = v
			end
		end
	end
	return t
end

local db_mt = { __index = function(object_db, key)
	local object = rawget(object_db, 'object')
	local data_object = data[object]
	if not data_object then
		if key == "raw" then
			return
		end
		error("Must call `SetDatabase' before accessing the db object", 2)
	end
	local db = data_object.db
	if not db then
		if key == "raw" then
			return
		end
		error("Cannot access db object before ADDON_LOADED", 2)
	end
	if key == "char" then
		local charDB = data_object.charDB
		if charDB then
			if type(charDB.global) ~= "table" then
				charDB.global = newList()
			end
			rawset(object_db, 'char', charDB.global)
		else
			if type(db.chars) ~= "table" then
				db.chars = newList()
			end
			if type(db.chars[charID]) ~= "table" then
				db.chars[charID] = newList()
			end
			rawset(object_db, 'char', db.chars[charID])
		end
		if data_object.defaults and data_object.defaults.char then
			inheritDefaults(object_db.char, data_object.defaults.char)
		end
		return object_db.char
	elseif key == "account" then
		if type(db.account) ~= "table" then
			db.account = newList()
		end
		rawset(object_db, 'account', db.account)
		if data_object.defaults and data_object.defaults.account then
			inheritDefaults(object_db.account, data_object.defaults.account)
		end
		return object_db.account
	elseif key == "realm" or key == "server" or key == "faction" or key == "class" or key == "profile" then
		local key_plural, id
		if key == "realm" then
			key_plural, id = "realms", realmID
		elseif key == "server" then
			key_plural, id = "servers", server
		elseif key == "faction" then
			key_plural, id = "factions", faction
		elseif key == "class" then
			key_plural, id = "classes", classID
		elseif key == "profile" then
			key_plural = "profiles"
			id = db.currentProfile and db.currentProfile[charID] or data_object.defaultProfile
			if id == "char" then
				id = "char/" .. charID
			elseif id == "class" then
				id = "class/" .. classID
			elseif id == "realm" then
				id = "realm/" .. realmID
			end
			if db[key_plural] then
				fixKeyCasing(db[key_plural], id)
			end
		end
		if type(db[key_plural]) ~= "table" then
			db[key_plural] = newList()
		end
		if type(db[key_plural][id]) ~= "table" then
			db[key_plural][id] = newList()
		end
		rawset(object_db, key, db[key_plural][id])
		if data_object.defaults and data_object.defaults[key] then
			inheritDefaults(object_db[key], data_object.defaults[key])
		end
		return object_db[key]
	elseif key == "raw" or key == "namespaces" or key == "defaults" then
		return nil
	end
	error(("Cannot access key %q in db table. You may want to use db.profile[%q]"):format(tostring(key), tostring(key)), 2)
end, __newindex = function(object_db, key, value)
	error(("Cannot access key %q in db table. You may want to use db.profile[%q]"):format(tostring(key), tostring(key)), 2)
end }

local namespace_db_mt = { __index = function(object_nsdb, key)
	local object = rawget(object_nsdb, 'object')
	if not object then
		error("Must call `SetDatabase' before accessing the db object", 2)
	end
	local namespace = rawget(object_nsdb, 'namespace')
	if not namespace then
		error("Must call `SetDatabase' before accessing the db object", 2)
	end
	local data_object = data[object]
	if not data_object then
		error("Must call `SetDatabase' before accessing the db object", 2)
	end
	local db = data_object.db
	if not db then
		error("Cannot access db object before ADDON_LOADED", 2)
	end
	if key == "char" then
		local charDB = data_object.charDB
		if charDB then
			if type(charDB.namespaces) ~= "table" then
				charDB.namespaces = newList()
			end
			if type(charDB.namespaces[namespace]) ~= "table" then
				charDB.namespaces[namespace] = newList()
			end
			rawset(object_nsdb, 'char', charDB.namespaces[namespace])
		else
			if type(db.namespaces) ~= "table" then
				db.namespaces = newList()
			end
			if type(db.namespaces[namespace]) ~= "table" then
				db.namespaces[namespace] = newList()
			end
			if type(db.namespaces[namespace].chars) ~= "table" then
				db.namespaces[namespace].chars = newList()
			end
			if type(db.namespaces[namespace].chars[charID]) ~= "table" then
				db.namespaces[namespace].chars[charID] = newList()
			end
			rawset(object_nsdb, 'char', db.namespaces[namespace].chars[charID])
		end
		if data_object.namespaceDefaults and data_object.namespaceDefaults[namespace] and data_object.namespaceDefaults[namespace].char then
			inheritDefaults(object_nsdb.char, data_object.namespaceDefaults[namespace].char)
		end
		return object_nsdb.char
	elseif key == "account" then
		if type(db.namespaces) ~= "table" then
			db.namespaces = newList()
		end
		if type(db.namespaces[namespace]) ~= "table" then
			db.namespaces[namespace] = newList()
		end
		if type(db.namespaces[namespace].account) ~= "table" then
			db.namespaces[namespace].account = newList()
		end
		rawset(object_nsdb, 'account', db.namespaces[namespace].account)
		if data_object.namespaceDefaults and data_object.namespaceDefaults[namespace] and data_object.namespaceDefaults[namespace].account then
			inheritDefaults(object_nsdb.account, data_object.namespaceDefaults[namespace].account)
		end
		return object_nsdb.account
	elseif key == "realm" or key == "server" or key == "faction" or key == "class" or key == "profile" then
		local key_plural, id
		if key == "realm" then
			key_plural, id = "realms", realmID
		elseif key == "server" then
			key_plural, id = "servers", server
		elseif key == "faction" then
			key_plural, id = "factions", faction
		elseif key == "class" then
			key_plural, id = "classes", classID
		elseif key == "profile" then
			key_plural = "profiles"
			id = db.currentProfile and db.currentProfile[charID] or data_object.defaultProfile
			if id == "char" then
				id = "char/" .. charID
			elseif id == "class" then
				id = "class/" .. classID
			elseif id == "realm" then
				id = "realm/" .. realmID
			end
			if db.namespaces and db.namespaces[namespace] and db.namespaces[namespace][key_plural] then
				fixKeyCasing(db.namespaces[namespace][key_plural], id)
			end
		end
		if type(db.namespaces) ~= "table" then
			db.namespaces = newList()
		end
		if type(db.namespaces[namespace]) ~= "table" then
			db.namespaces[namespace] = newList()
		end
		if type(db.namespaces[namespace][key_plural]) ~= "table" then
			db.namespaces[namespace][key_plural] = newList()
		end
		if type(db.namespaces[namespace][key_plural][id]) ~= "table" then
			db.namespaces[namespace][key_plural][id] = newList()
		end
		rawset(object_nsdb, key, db.namespaces[namespace][key_plural][id])
		if data_object.namespaceDefaults and data_object.namespaceDefaults[namespace] and data_object.namespaceDefaults[namespace][key] then
			inheritDefaults(object_nsdb[key], data_object.namespaceDefaults[namespace][key])
		end
		return object_nsdb[key]
	elseif key == "raw" or key == "namespaces" or key == "defaults" then
		return nil
	end
	error(("Cannot access key %q in db table. You may want to use db.profile[%q]"):format(tostring(key), tostring(key)), 2)
end, __newindex = function(object_db, key, value)
	error(("Cannot access key %q in db table. You may want to use db.profile[%q]"):format(tostring(key), tostring(key)), 2)
end }

--[[---------------------------------------------------------------------------
Notes:
	* Sets a saved variable so as to correlate to the database table.
	* Setting the charName is unnecessary if you never use char-specific data. If you do use them, it can be a good idea to have.
	* This is to be called before ADDON_LOADED
Arguments:
	string - global name of the saved variable.
	string - global name of the per-character saved variable.
Example:
	MyAddon:SetDatabase("MyAddonDB")
	-- or
	MyAddon:SetDatabase("MyAddonDB", "MyAddonCharDB")
-----------------------------------------------------------------------------]]
function RockDB:SetDatabase(dbName, charName)
	local data_self = newList()
	data[self] = data_self

	data_self.addon = figureCurrentAddon(2)
	data_self.dbName = dbName
	data_self.charName = charName
	data_self.defaultProfile = "Default"
end
precondition(RockDB, 'SetDatabase', function(self, dbName, charName)
	local data_self = data[self]
	if data_self then
		error("Cannot call `SetDatabase' more than once.", 3)
	end
	argCheck(dbName, 2, "string")
	argCheck(charName, 3, "string", "nil")
end)

--[[---------------------------------------------------------------------------
Notes:
	* Acquires a namespace within the database.
	* This is especially handy for a module system to use, simply get a namespace with the same name as your module, and it acts as a fully functioning database.
Arguments:
	string - name of the namespace
Example:
	MyAddon_Bank.db = MyAddon:AcquireDBNamespace("Bank")
-----------------------------------------------------------------------------]]
function RockDB:GetDatabaseNamespace(namespace)
	local data_self = data[self]

	local data_self_namespaces = data_self.namespaces
	if not data_self_namespaces then
		data_self_namespaces = newList()
		data_self.namespaces = data_self_namespaces
	end

	local data_self_namespaces_namespace = data_self_namespaces[namespace]
	if not data_self_namespaces_namespace then
		data_self_namespaces_namespace = newList()
		data_self_namespaces[namespace] = data_self_namespaces_namespace
		data_self_namespaces_namespace.object = self
		data_self_namespaces_namespace.namespace = namespace

		local data_self_namespaceDefaults = data_self.namespaceDefaults
		if data_self_namespaceDefaults then
			data_self_namespaces_namespace.defaults = data_self_namespaceDefaults[namespace]
		end
	end
	setmetatable(data_self_namespaces_namespace, namespace_db_mt)
	return data_self_namespaces_namespace
end
precondition(RockDB, 'GetDatabaseNamespace', function(self, namespace)
	local data_self = data[self]
	if not data_self then
		error("Cannot call `GetDatabaseNamespace' before `SetDatabase'.", 3)
	end
	argCheck(namespace, 2, "string")
end)

--[[---------------------------------------------------------------------------
Notes:
	* Set default values for a specific database type.
	* The defaults table can have subtables as well (as many as you want). This can be used to define your basic db structure.
	* You can also set a whole table's default value by using the special key ['*'], which even works with tables.
	* There is another key, ['**'], which does the same thing as ['*'] ''but'' also populates inside sibling nodes. For example, <tt>{ ['**'] = { alpha = true, bravo = true, charlie = true}, monkey = { bravo = false } }</tt> makes monkey behave like <tt>{ alpha = true, bravo = false, charlie = true }</tt>
	* If you use the 'profile' dataType, it applies to ''all'' profiles.
	* This is to be called between `SetDatabase' and ADDON_LOADED.
Arguments:
	string - "char", "class", "realm", "server", "account", "faction", or "profile" - correlates to the type of data you're working with.
	table - the defaults
Example:
	MyAddon:SetDatabaseDefaults('char', {
	    alpha = {
	        bravo = {
	            charlie = true
	        }
	    }
	})
	assert(MyAddon.db.char.alpha.bravo.charlie == true)

	MyAddon:SetDatabaseDefaults('realm', {
	    ['*'] = false -- special key
	})
	assert(MyAddon.db.realm.anyKeyHere == false)

	MyAddon:SetDatabaseDefaults('class', {
	    colors = {
	        ['**'] = {
	             r = 1, g = 1, b = 1
	        },
			crazyBoss = {
				name = "The boss"
			}
	    }
	})
	assert(MyAddon.db.class.colors.boss.r == 1)
	MyAddon.db.class.colors.boss.r = 0
	assert(MyAddon.db.class.colors.boss.r == 0)
	assert(MyAddon.db.class.colors.otherBoss.r == 1)
	assert(MyAddon.db.class.colors.crazyBoss.r == 1)
	assert(MyAddon.db.class.colors.crazyBoss.name == "The boss")
-----------------------------------------------------------------------------]]
function RockDB:SetDatabaseDefaults(kind, defaults)
	local data_self = data[self]

	local data_self_defaults = data_self.defaults
	if not data_self_defaults then
		data_self_defaults = newList()
		data_self.defaults = data_self_defaults
	end
	rawset(self.db, 'defaults', data_self_defaults)
	data_self_defaults[kind] = defaults
end
precondition(RockDB, 'SetDatabaseDefaults', function(self, kind, defaults)
	local data_self = data[self]
	if not data_self then
		error("Cannot call `SetDatabaseDefaults' before `SetDatabase'.", 3)
	end
	if data_self.init then
		error("Cannot call `SetDatabaseDefaults' after ADDON_LOADED.", 3)
	end
	argCheck(kind, 2, "string")
	if kind ~= "char" and kind ~= "class" and kind ~= "profile" and kind ~= "account" and kind ~= "realm" and kind ~= "faction" and kind ~= "server" then
		error(("Bad argument #2 to `SetDatabaseDefaults'. Expected %q, %q, %q, %q, %q, %q, or %q, got %q)"):format("char", "class", "profile", "account", "realm", "server", "faction", kind), 3)
	end
	argCheck(defaults, 3, "table")
	if data_self.defaults and data_self.defaults[kind] then
		error(("Cannot call `SetDatabaseDefaults' for %q more than once."):format(kind), 3)
	end
end)

--[[---------------------------------------------------------------------------
Notes:
	* Set default values for a specific database type for a specified namespace.
	* The defaults table can have subtables as well (as many as you want). This can be used to define your basic db structure.
	* You can also set a whole table's default value by using the special key ['*'], which even works with tables.
	* There is another key, ['**'], which does the same thing as ['*'] ''but'' also populates inside sibling nodes. For example, <tt>{ ['**'] = { alpha = true, bravo = true, charlie = true}, monkey = { bravo = false } }</tt> makes monkey behave like <tt>{ alpha = true, bravo = false, charlie = true }</tt>
	* If you use the 'profile' dataType, it applies to ''all'' profiles.
	* This is to be called between :SetDatabase and ADDON_LOADED.
Arguments:
	string - name of the namespace
	string - "char", "class", "realm", "server", "account", "faction", or "profile" - correlates to the type of data you're working with.
	table - the defaults
Example:
	MyAddon:SetDatabaseNamespaceDefaults('Bank', 'char', {
	    value = 50
	})

	assert(MyAddon:GetDatabaseNamespace('Bank').char.value == 50)
-----------------------------------------------------------------------------]]
function RockDB:SetDatabaseNamespaceDefaults(namespace, kind, defaults)
	local data_self = data[self]
	local data_self_namespaceDefaults = data_self.namespaceDefaults
	if not data_self_namespaceDefaults then
		data_self_namespaceDefaults = newList()
		data_self.namespaceDefaults = data_self_namespaceDefaults
	end
	local data_self_namespaceDefaults_namespace = data_self_namespaceDefaults[namespace]
	if not data_self_namespaceDefaults_namespace then
		data_self_namespaceDefaults_namespace = newList()
		data_self_namespaceDefaults[namespace] = data_self_namespaceDefaults_namespace
	end
	data_self_namespaceDefaults_namespace[kind] = defaults

	local data_self_namespaces = data_self.namespaces
	if data_self_namespaces then
		local data_self_namespaces_namespace = data_self_namespaces[namespace]
		if data_self_namespaces_namespace then
			rawset(data_self_namespaces_namespace, 'defaults', data_self_namespaceDefaults_namespace)
		end
	end
end
precondition(RockDB, 'SetDatabaseNamespaceDefaults', function(self, namespace, kind, defaults)
	local data_self = data[self]
	if not data_self then
		error("Cannot call `SetDatabaseNamespaceDefaults' before `SetDatabase'.", 3)
	end
	argCheck(namespace, 2, "string")
	argCheck(kind, 3, "string")
	if kind ~= "char" and kind ~= "class" and kind ~= "profile" and kind ~= "account" and kind ~= "realm" and kind ~= "faction" and kind ~= "server" then
		error(("Bad argument #3 to `SetDatabaseNamespaceDefaults'. Expected %q, %q, %q, %q, %q, %q, or %q, got %q)"):format("char", "class", "profile", "account", "realm", "server", "faction", kind), 3)
	end
	argCheck(defaults, 4, "table")
	if data_self.namespaceDefaults and data_self.namespaceDefaults[namespace] and data_self.namespaceDefaults[namespace][kind] then
		error(("Cannot call `SetDatabaseNamespaceDefaults' for %q : %q more than once."):format(namespace, kind), 3)
	end
end)

--[[---------------------------------------------------------------------------
Notes:
	* Sets the default profile.
	* If this is unspecified, "Default" is assumed.
	* Can be any arbitrary name, but it's recommended to use "Default", "Alternative", "char", "class", or "realm".
Arguments:
	string - the name of the profile.
Example:
	MyAddon:SetDefaultProfile("char") -- will default to the character profile on a per-character basis.
-----------------------------------------------------------------------------]]
function RockDB:SetDefaultProfile(profile)
	data[self].defaultProfile = profile
end
precondition(RockDB, 'SetDefaultProfile', function(self, profile)
	local data_self = data[self]
	if not data_self then
		error("Cannot call `SetDefaultProfile' before `SetDatabase'.", 3)
	end
	if data_self.init then
		error("Cannot call `SetDefaultProfile' after ADDON_LOADED.", 3)
	end
	argCheck(profile, 2, "string")
end)

-- #NODOC
function RockDB:InitializeDatabase(object)
	local data_object = data[object]
	if not data_object then
		error(("Must call `SetDatabase' before ADDON_LOADED for %s"):format(tostring(object)))
	end
	if data_object.init then
		-- already initialized
		return
	end
	data_object.init = true
	local dbName = data_object.dbName
	local db = _G[dbName]
	if type(db) ~= "table" then
		db = newList()
		_G[dbName] = db
	end
	data_object.db = db
	local charName = data_object.charName
	local charDB
	if charName then
		charDB = _G[charName]
		if type(charDB) ~= "table" then
			charDB = newList()
			_G[charName] = charDB
		end
	end
	data_object.charDB = charDB
	rawset(object.db, 'raw', db)
end

-- #NODOC
function RockDB:UninitializeDatabase(object)
	local data_object = data[object]
	if not data_object then
		return
	end
	local object_db = object.db
	if not object_db then
		return
	end

	local object_OnDatabaseCleanup = object.OnDatabaseCleanup
	if object_OnDatabaseCleanup then
		local success, ret = pcall(object_OnDatabaseCleanup, object)
		if not success then
			geterrorhandler(ret)
			return
		end
	end

	setmetatable(object_db, nil)

	local db = data_object.db

	local data_object_defaults = data_object.defaults
	if data_object_defaults then
		if object_db.char and cleanDefaults(object_db.char, data_object_defaults.char) then
			local charName = data_object.charName
			if charName then
				if _G[charName] and _G[charName].global == object_db.char then
					_G[charName].global = nil
					if not next(_G[charName]) then
						_G[charName] = nil
					end
				end
			else
				if db.chars then
					db.chars[charID] = nil
					if not next(db.chars) then
						db.chars = nil
					end
				end
			end
		end
		if object_db.account and cleanDefaults(object_db.account, data_object_defaults.account) then
			db.account = nil
		end
		local kinds = newList("realm", "server", "faction", "class", "profile")
		for _,key in ipairs(kinds) do
			local key_plural, id
			if key == "realm" then
				key_plural, id = "realms", realmID
			elseif key == "server" then
				key_plural, id = "servers", server
			elseif key == "faction" then
				key_plural, id = "factions", faction
			elseif key == "class" then
				key_plural, id = "classes", classID
			elseif key == "profile" then
				key_plural = "profiles"
				id = db.currentProfile and db.currentProfile[charID] or data_object.defaultProfile
				if id == "char" then
					id = "char/" .. charID
				elseif id == "class" then
					id = "class/" .. classID
				elseif id == "realm" then
					id = "realm/" .. realmID
				end
				if db[key_plural] then
					fixKeyCasing(db[key_plural], id)
				end
			end
			if object_db[key] and cleanDefaults(object_db[key], data_object_defaults[key]) and db[key_plural] then
				db[key_plural][id] = nil
				if not next(db[key_plural]) then
					db[key_plural] = nil
				end
			end
		end
		kinds = del(kinds)
	end

	if not next(db) then
		_G[data_object.dbName] = nil
		return
	end

	local data_object_namespaceDefaults = data_object.namespaceDefaults
	if not data_object_namespaceDefaults then
		return
	end
	local data_object_namespaces = data_object.namespaces
	if not data_object_namespaces then
		return
	end
	for namespace, nsdb in pairs(data_object_namespaces) do
		local data_object_namespaceDefaults_namespace = data_object_namespaceDefaults[namespace]
		local db_namespaces_namespace = db.namespaces and db.namespaces[namespace]
		if data_object_namespaceDefaults_namespace then
			setmetatable(nsdb, nil)
			if nsdb.char and cleanDefaults(nsdb.char, data_object_namespaceDefaults_namespace.char) then
				local charName = data_object.charName
				if charName then
					if _G[charName] and _G[charName].namespaces and _G[charName].namespaces[namespace] == nsdb.char then
						_G[charName].namespaces[namespace] = nil
						if not next(_G[charName].namespaces) then
							_G[charName].namespaces = nil
							if not next(_G[charName]) then
								_G[charName] = nil
							end
						end
					end
				else
					if db_namespaces_namespace and db_namespaces_namespace.chars then
						db_namespaces_namespace.chars[charID] = nil
						if not next(db_namespaces_namespace.chars) then
							db_namespaces_namespace.chars = nil
						end
					end
				end
			end
			if db_namespaces_namespace then
				if nsdb.account and cleanDefaults(nsdb.account, data_object_namespaceDefaults_namespace.account) then
					db_namespaces_namespace.account = nil
				end

				local kinds = newList("realm", "server", "faction", "class", "profile")
				for _,key in ipairs(kinds) do
					local key_plural, id
					if key == "realm" then
						key_plural, id = "realms", realmID
					elseif key == "server" then
						key_plural, id = "servers", server
					elseif key == "faction" then
						key_plural, id = "factions", faction
					elseif key == "class" then
						key_plural, id = "classes", classID
					elseif key == "profile" then
						key_plural = "profiles"
						id = db.currentProfile and db.currentProfile[charID] or data_object.defaultProfile
						if id == "char" then
							id = "char/" .. charID
						elseif id == "class" then
							id = "class/" .. classID
						elseif id == "realm" then
							id = "realm/" .. realmID
						end
						if db_namespaces_namespace[key_plural] then
							fixKeyCasing(db_namespaces_namespace[key_plural], id)
						end
					end
					if nsdb[key] and cleanDefaults(nsdb[key], data_object_namespaceDefaults_namespace[key]) and db_namespaces_namespace[key_plural] then
						db_namespaces_namespace[key_plural][id] = nil
						if not next(db_namespaces_namespace[key_plural]) then
							db_namespaces_namespace[key_plural] = nil
						end
					end
				end
				kinds = del(kinds)
				if not next(db_namespaces_namespace) then
					db.namespaces[namespace] = nil
				end
			end
			if db.namespaces then
				if not next(db.namespaces) then
					db.namespaces = nil
				end
			end
		end
	end

	if not next(db) then
		_G[data_object.dbName] = nil
	end
end

--[[---------------------------------------------------------------------------
Notes:
	* If you are in a char, class, or realm profile, "short" will be "char", "class", or "realm" and "long" will be "char/Player of Realm Name", "class/Warlock", or "realm/My Realm - Horde". Otherwise, "short" and "long" will be equivalent.
	* "Default" is the default profile unless specified by :SetDefaultProfile.
	* This is only accurate after ADDON_LOADED.
Returns:
	; "short" : string - The current profile, short-form.
	; "long" : string - The current profile, in its full, long form.
Example:
	local short, long = MyAddon:GetProfile()
-----------------------------------------------------------------------------]]
function RockDB:GetProfile()
	local data_self = data[self]
	if not data_self then
		return nil
	end
	local db = data_self.db
	if not db then
		return nil
	end
	local profile = db.currentProfile and db.currentProfile[charID]
	if not profile then
		profile = data_self.defaultProfile
	end

	if profile == "char" then
		return "char", "char/" .. charID
	elseif profile == "class" then
		return "class", "class/" .. classID
	elseif profile == "realm" then
		return "realm", "realm/" .. realmID
	end
	return profile, profile
end

--[[---------------------------------------------------------------------------
Notes:
	* Set the current profile to the given profile name.
	* If "profile" is "char", "realm", or "class", it gets set to the appropriate profile based on the current character.
	* This will call :OnProfileDisable() if available, change the profile, then call :OnProfileEnable("oldName", oldData) if available. In turn, this will call any embeds :OnEmbedProfileDisable(self) and :OnProfileEnable(self, "oldName", oldData) if available.
	* Defaults will properly transfer to the new profile without harm.
Arguments:
	string - the new profile name
Example:
	MyAddon:SetProfile("Monkey") -- for all your monkey-based goodness.
	MyAddon:SetProfile("char") -- change to your character
-----------------------------------------------------------------------------]]
function RockDB:SetProfile(name)
	local data_self = data[self]
	local name_lower = name:lower()
	if name_lower:match("^char/") then
		name = "char"
		name_lower = "char"
	elseif name_lower:match("^realm/") then
		name = "realm"
		name_lower = "realm"
	elseif name_lower:match("^class/") then
		name = "class"
		name_lower = "class"
	end
	local db = data_self.db
	local db_currentProfile = db.currentProfile
	local oldProfile = db_currentProfile and db_currentProfile[charID] or data_self.defaultProfile
	if oldProfile:lower() == name_lower then
		if oldProfile ~= name and oldProfile ~= data_self.defaultProfile then
			-- casing difference
			db_currentProfile[charID] = name
		end
		-- no change
		return
	end
	local self_db = self.db
	local oldProfileData = self_db.profile
	local realName = name
	if name_lower == "char" then
		realName = name .. "/" .. charID
	elseif name_lower == "realm" then
		realName = name .. "/" .. realmID
	elseif name_lower == "class" then
		realName = name .. "/" .. classID
	end
	for mixin in Rock:IterateObjectMixins(self) do
		local mixin_OnEmbedProfileDisable = mixin.OnEmbedProfileDisable
		if mixin_OnEmbedProfileDisable then
			local success, ret = pcall(mixin_OnEmbedProfileDisable, mixin, self, realName)
			if not success then
				geterrorhandler()(ret)
			end
		end
	end
	local self_OnProfileDisable = self.OnProfileDisable
	if self_OnProfileDisable then
		local success, ret = pcall(self_OnProfileDisable, self, realName)
		if not success then
			geterrorhandler()(ret)
		end
	end

	if not db_currentProfile then
		db_currentProfile = newList()
		db.currentProfile = db_currentProfile
	end
	db_currentProfile[charID] = name ~= data_self.defaultProfile and name or nil
	if not next(db_currentProfile) then
		db.currentProfile = del(db_currentProfile)
	end
	rawset(self_db, 'profile', nil)
	if data_self.namespaces then
		for k,v in pairs(data_self.namespaces) do
			rawset(v, 'profile', nil)
		end
	end

	for mixin in Rock:IterateObjectMixins(self) do
		local mixin_OnEmbedProfileEnable = mixin.OnEmbedProfileEnable
		if mixin_OnEmbedProfileEnable then
			local success, ret = pcall(mixin_OnEmbedProfileEnable, mixin, self, realName)
			if not success then
				geterrorhandler()(ret)
			end
		end
	end
	local self_OnProfileEnable = self.OnProfileEnable
	if self_OnProfileEnable then
		local success, ret = pcall(self_OnProfileEnable, self, realName)
		if not success then
			geterrorhandler()(ret)
		end
	end

	if cleanDefaults(oldProfileData, data_self.defaults and data_self.defaults.profile) then
		db.profiles[oldProfile] = del(oldProfileData)
		if next(db.profiles) == nil then
			db.profiles = del(db.profiles)
		end
	end

	Rock:RecheckEnabledStates()
end
precondition(RockDB, 'SetProfile', function(self, name)
	local data_self = data[self]
	if not data_self then
		error("Cannot call `SetProfile' before `SetDatabase'.", 3)
	end
	if not data_self.init then
		error("Cannot call `SetProfile' before ADDON_LOADED.", 3)
	end
	argCheck(name, 2, "string")
end)

--[[---------------------------------------------------------------------------
Notes:
	* Deletes the given profile
	* This will error if it is the current profile, as that cannot be deleted.
Arguments:
	string - the new profile name
Example:
	MyAddon:RemoveProfile("Monkey") -- remove all monkey-based goodness.
-----------------------------------------------------------------------------]]
function RockDB:RemoveProfile(profile)
	local data_self = data[self]

	local db = data_self.db

	local currentProfile = db.currentProfile and db.currentProfile[charID] or data_self.defaultProfile
	local profile_lower = profile:lower()
	if currentProfile:lower() == profile_lower then
		error(("Cannot delete profile %q, it is currently in use."):format(profile), 2)
	end

	local good = false
	if db.profiles then
		for k in pairs(db.profiles) do
			if k:lower() == profile_lower then
				db.profiles[k] = nil
			end
		end
		if not next(db.profiles) then
			db.profiles = del(db.profiles)
		end
	end

	if db.namespaces then
		for _,v in pairs(db.namespaces) do
			if v.profiles then
				for k in pairs(v.profiles) do
					if k:lower() == profile_lower then
						v.profiles[k] = nil
					end
				end
				if not next(v.profiles) then
					v.profiles = del(v.profiles)
				end
			end
		end
	end
end
precondition(RockDB, 'RemoveProfile', function(self, name)
	local data_self = data[self]
	if not data_self then
		error("Cannot call `RemoveProfile' before `SetDatabase'.", 3)
	end
	if not data_self.init then
		error("Cannot call `RemoveProfile' before ADDON_LOADED.", 3)
	end
	argCheck(name, 2, "string")
end)

--[[---------------------------------------------------------------------------
Notes:
	* Resets the database or a specific part of it.
	* This will call :OnResetDatabase(kind, namespace) once complete.
Arguments:
	string or nil - the data type to reset. If nil, then it means all data types.
	string or nil - the namespace to reset. If nil, then it means the whole database.
Example:
	MyAddon:RemoveProfile("Monkey") -- remove all monkey-based goodness.
-----------------------------------------------------------------------------]]
function RockDB:ResetDatabase(kind, namespace)
	local data_self = data[self]
	local self_db = self.db
	local db = data_self.db
	if not kind then
		local kinds = newList("char", "class", "profile", "account", "realm", "faction", "server")
		if not namespace then
			local dbName = data_self.dbName
			_G[dbName] = nil
			local charName = data_self.charName
			if charName then
				_G[charName] = nil
			end
			data_self.init = nil
			RockDB:InitializeDatabase(self)
			for _,kind in ipairs(kinds) do
				rawset(self_db, kind, nil)
			end
			if data_self.namespaces then
				for k, v in pairs(data_self.namespaces) do
					for _,kind in ipairs(kinds) do
						rawset(v, kind, nil)
					end
				end
			end
		else
			if db.namespaces then
				db.namespaces[namespace] = nil
			end
			if data_self.namespaces and data_self.namespaces[namespace] then
				for _,kind in ipairs(kinds) do
					rawset(data_self.namespaces[namespace], kind, nil)
				end
			end
		end
		kinds = del(kinds)
	else
		if kind == "account" then
			if not namespace then
				db.account = nil
				if db.namespaces then
					for name,v in pairs(db.namespaces) do
						v.account = nil
					end
				end
			else
				if db.namespaces and db.namespaces[namespace] then
					db.namespaces[namespace].account = nil
				end
			end
		elseif kind == "char" then
			local charName = data_self.charName
			if not namespace then
				if charName then
					_G[charName] = nil
				else
					if db.chars then
						db.chars[charID] = nil
					end
					if db.namespaces then
						for name,v in pairs(db.namespaces) do
							if v.chars then
								v.chars[charID] = nil
							end
						end
					end
				end
			else
				if charName then
					local _G_charName = _G[charName]
					if _G_charName and _G_charName.namespaces then
						_G_charName.namespaces[namespace] = nil
					end
				else
					if db.namespaces and db.namespaces[namespace] and db.namespaces[namespace].chars then
						db.namespaces[namespace].chars[charID] = nil
					end
				end
			end
		else
			local key_plural, id
			if kind == "realm" then
				key_plural, id = "realms", realmID
			elseif kind == "server" then
				key_plural, id = "servers", server
			elseif kind == "faction" then
				key_plural, id = "factions", faction
			elseif kind == "class" then
				key_plural, id = "classes", classID
			elseif kind == "profile" then
				key_plural = "profiles"
				id = db.currentProfile and db.currentProfile[charID] or data_self.defaultProfile
				if id == "char" then
					id = "char/" .. charID
				elseif id == "class" then
					id = "class/" .. classID
				elseif id == "realm" then
					id = "realm/" .. realmID
				end
				if db[key_plural] then
					fixKeyCasing(db[key_plural], id)
				end
			end
			if not namespace then
				if db[key_plural] then
					db[key_plural][id] = nil
				end
				if db.namespaces then
					for name,v in pairs(db.namespaces) do
						if v[key_plural] then
							v[key_plural][id] = nil
						end
					end
				end
			else
				if db.namespaces and db.namespaces[namespace] and db.namespaces[namespace][key_plural] then
					db.namespaces[namespace][key_plural][id] = nil
				end
			end
		end
		if not namespace then
			rawset(self_db, kind, nil)
			if data_self.namespaces then
				for k, v in pairs(data_self.namespaces) do
					rawset(v, kind, nil)
				end
			end
		else
			if data_self.namespaces and data_self.namespaces[namespace] then
				rawset(data_self.namespaces[namespace], kind, nil)
			end
		end
	end
	Rock:RecheckEnabledStates()
	local self_OnResetDatabase = self.OnResetDatabase
	if self_OnResetDatabase then
		local success, ret = pcall(self_OnResetDatabase, self, kind, namespace)
		if not success then
			geterrorhandler()(ret)
		end
	end
end
precondition(RockDB, 'ResetDatabase', function(self, kind, namespace)
	local data_self = data[self]
	if not data_self then
		error("Cannot call `ResetDatabase' before `SetDatabase'.", 3)
	end
	if not data_self.init then
		error("Cannot call `ResetDatabase' before ADDON_LOADED.", 3)
	end
	argCheck(kind, 2, "string", "nil")
	if kind and kind ~= "char" and kind ~= "class" and kind ~= "profile" and kind ~= "account" and kind ~= "realm" and kind ~= "faction" and kind ~= "server" then
		error(("Bad argument #2 to `SetDatabaseDefaults'. Expected %q, %q, %q, %q, %q, %q, or %q, got %q)"):format("char", "class", "profile", "account", "realm", "server", "faction", kind), 2)
	end
	argCheck(namespace, 3, "string", "nil")
end)

local function copy(t)
	if type(t) ~= "table" then
		return t
	end
	local u = newList()
	for k,v in pairs(t) do
		u[copy(k)] = copy(v)
	end
	return u
end

--[[---------------------------------------------------------------------------
Notes:
	* Copy a profile from the given one to the current one.
Arguments:
	string - the profile name to copy from.
Example:
	MyAddon:CopyProfile("Monkey") -- copy from the Monkey profile to the current one
-----------------------------------------------------------------------------]]
function RockDB:CopyProfile(name)
	local data_self = data[self]

	local self_db = self.db
	local db = data_self.db

	if not db.profiles or not caseInsensitiveLookup(db.profiles, name) then
		local good = false
		if db.namespaces then
			for _, ns in pairs(db.namespaces) do
				if ns.profiles and caseInsensitiveLookup(ns.profiles, name) then
					good = true
					break
				end
			end
		end
		if not good then
			error(("Cannot copy from profile %q, it does not exist."):format(name), 2)
		end
	end

	local name_lower = name:lower()
	local currentProfile = db.currentProfile and db.currentProfile[charID] or data_self.defaultProfile
	if currentProfile:lower() == name_lower then
		error(("Cannot copy from profile %q, it is currently in use."):format(name), 2)
	end
	local oldProfileData = self_db.profile
	for mixin in Rock:IterateObjectMixins(self) do
		local mixin_OnEmbedProfileDisable = mixin.OnEmbedProfileDisable
		if mixin_OnEmbedProfileDisable then
			local success, ret = pcall(mixin_OnEmbedProfileDisable, mixin, self, currentProfile)
			if not success then
				geterrorhandler()(ret)
			end
		end
	end
	local self_OnProfileDisable = self.OnProfileDisable
	if self_OnProfileDisable then
		local success, ret = pcall(self_OnProfileDisable, self, currentProfile)
		if not success then
			geterrorhandler()(ret)
		end
	end

	for k,v in pairs(oldProfileData) do
		oldProfileData[k] = nil
	end

	local _,copyFromData = caseInsensitiveLookup(db.profiles, name)
	if copyFromData then
		for k,v in pairs(copyFromData) do
			oldProfileData[copy(k)] = copy(v)
		end
	end
	inheritDefaults(oldProfileData, data_self.defaults and data_self.defaults.profile)
	if data_self.namespaces then
		for namespace,u in pairs(data_self.namespaces) do
			local u_profile = u.profile
			for k,v in pairs(u_profile) do
				u_profile[k] = nil
			end
			if db.namespaces and db.namespaces[namespace] then
				local _,copyFromData = caseInsensitiveLookup(db.namespaces[namespace].profiles, name)
				if copyFromData then
					for k,v in pairs(copyFromData) do
						u_profile[copy(k)] = copy(v)
					end
				end
				inheritDefaults(u_profile, data_self.namespaceDefaults and data_self.namespaceDefaults[namespace] and data_self.namespaceDefaults[namespace].profile)
			end	
		end
	end

	for mixin in Rock:IterateObjectMixins(self) do
		local mixin_OnEmbedProfileEnable = mixin.OnEmbedProfileEnable
		if mixin_OnEmbedProfileEnable then
			local success, ret = pcall(mixin_OnEmbedProfileEnable, mixin, self, oldProfileData, name)
			if not success then
				geterrorhandler()(ret)
			end
		end
	end
	local self_OnProfileEnable = self.OnProfileEnable
	if self_OnProfileEnable then
		local success, ret = pcall(self_OnProfileEnable, self, oldProfileData, name)
		if not success then
			geterrorhandler()(ret)
		end
	end

	Rock:RecheckEnabledStates()
end
precondition(RockDB, 'CopyProfile', function(self, name)
	local data_self = data[self]
	if not data_self then
		error("Cannot call `CopyProfile' before `SetDatabase'.", 3)
	end
	if not data_self.init then
		error("Cannot call `CopyProfile' before ADDON_LOADED.", 3)
	end
	argCheck(name, 2, "string")
end)

for object in Rock:IterateMixinObjects(RockDB) do
	local object_db = object.db
	if object_db then -- should exist
		setmetatable(object_db, nil)
		object_db.char = nil
		object_db.account = nil
		object_db.profile = nil
		object_db.realm = nil
		object_db.server = nil
		object_db.faction = nil
		object_db.class = nil
		setmetatable(object_db, db_mt)
	end
	local data_object = data[object]
	if data_object then
		local data_object_namespaces = data_object.namespaces
		if data_object_namespaces then
			for namespace, nsdb in pairs(data_object_namespaces) do
				setmetatable(nsdb, nil)
				nsdb.char = nil
				nsdb.account = nil
				nsdb.profile = nil
				nsdb.realm = nil
				nsdb.server = nil
				nsdb.faction = nil
				nsdb.class = nil
				setmetatable(nsdb, namespace_db_mt)
			end
		end
	end
end

function RockDB:OnEmbedInitialize(object)
	self:InitializeDatabase(object)
end

function RockDB:OnEmbed(object)
	local object_db = newList()
	object.db = object_db
	object_db.object = object
	setmetatable(object_db, db_mt)
end

function RockDB:OnUnembed(object)
	RockDB:UninitializeDatabase(object)
	object.db = nil
	data[object] = nil
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", function(this, event, ...)
	if event == "ADDON_LOADED" then
		local name = (...)
		for object, v in pairs(data) do
			if v.addon == name then
				RockDB:InitializeDatabase(object)
			end
		end
	elseif event == "PLAYER_LOGOUT" then
		for object in Rock:IterateMixinObjects(RockDB) do
			RockDB:UninitializeDatabase(object)
		end
	end
end)

local function GetProfile_proxy(addon, ...)
	return addon:GetProfile(...)
end
local function SetProfile_proxy(addon, ...)
	return addon:SetProfile(...)
end
local function CopyProfile_proxy(addon, ...)
	return addon:CopyProfile(...)
end
local function RemoveProfile_proxy(addon, ...)
	return addon:RemoveProfile(...)
end
local function ResetDatabase_proxy(addon, ...)
	return addon:ResetDatabase(...)
end
local function GetProfileList(addon)
	local t = newList()
	t.char = L["Character: "] .. L["%s of %s"]:format(UnitName("player"), server)
	t.realm = L["Realm: "] .. realmID
	t.class = L["Class: "] .. classID
	t.Default = L["Default"]
	local addon_db = addon.db
	local db = addon_db and addon_db.raw
	if db then
		if db.profiles then
			for k in pairs(db.profiles) do
				if not k:find("^char/") and not k:find("^realm/") and not k:find("^class/") and not t[k] then
					t[k] = k
				end
			end
		end
		if db.namespaces then
			for _,n in pairs(db.namespaces) do
				if n.profiles then
					for k in pairs(n.profiles) do
						if not k:find("^char/") and not k:find("^realm/") and not k:find("^class/") and not t[k] then
							t[k] = k
						end
					end
				end
			end
		end
		local curr = db.currentProfile and db.currentProfile[charID]
		if curr and not t[curr] then
			t[curr] = curr
		end
	end
	if t.Alternative then
		t.Alternative = L["Alternative"]
	end
	return "@dict", unpackDictAndDel(t)
end
local function GetProfileCopyList(addon)
	local t = newList()
	local addon_db = addon.db
	local db = addon_db and addon_db.raw
	if db then
		local _,currentProfile = RockDB.GetProfile(addon)
		if db.profiles then
			for k in pairs(db.profiles) do
				if currentProfile ~= k then
					if k:find("^char/") then
						local name = k:sub(6)
						local player, realm = name:match("^(.*) %- (.*)$")
						if player then
							name = L["%s of %s"]:format(player, realm)
						end
						t[k] = L["Character: "] .. name
					elseif k:find("^realm/") then
						local name = k:sub(7)
						t[k] = L["Realm: "] .. name
					elseif k:find("^class/") then
						local name = k:sub(7)
						t[k] = L["Class: "] .. name
					else
						t[k] = k
					end
				end
			end
		end
		if db.namespaces then
			for _,n in pairs(db.namespaces) do
				if n.profiles then
					for k in pairs(n.profiles) do
						if currentProfile ~= k then
							if k:find('^char/') then
								local name = k:sub(6)
								local player, realm = name:match("^(.*) %- (.*)$")
								if player then
									name = L["%s of %s"]:format(player, realm)
								end
								t[k] = L["Character: "] .. name
							elseif k:find('^realm/') then
								local name = k:sub(7)
								t[k] = L["Realm: "] .. name
							elseif k:find('^class/') then
								local name = k:sub(7)
								t[k] = L["Class: "] .. name
							else
								t[k] = k
							end
						end
					end
				end
			end
		end
		if t.Default then
			t.Default = L["Default"]
		end
		if t.Alternative then
			t.Alternative = L["Alternative"]
		end
	end
	return "@dict", unpackDictAndDel(t)
end
local function IsCopyListDisabled(addon)
	local t = newDict(select(2, GetProfileCopyList(addon)))
	local disabled = next(t) == nil
	t = del(t)
	return disabled
end

-- #NODOC
function RockDB:GetEmbedRockConfigOptions(addon)
	return 'profile', {
		type = 'group',
		name = L["Profile"],
		desc = L["Set profile for this addon."],
		order = -1,
		handler = addon,
		args = {
			choose = {
				name = L["Choose"],
				desc = L["Choose a profile."],
				type = 'choice',
				get = GetProfile_proxy,
				set = SetProfile_proxy,
				choices = GetProfileList,
				passValue = addon
			},
			copy = {
				name = L["Copy from"],
				desc = L["Copy settings from another profile."],
				type = 'choice',
				get = false,
				set = CopyProfile_proxy,
				passValue = addon,
				choices = GetProfileCopyList,
				disabled = IsCopyListDisabled,
			},
			other = {
				name = L["Other"],
				desc = L["Choose another profile."],
				usage = L["<profile name>"],
				type = 'string',
				get = GetProfile_proxy,
				set = SetProfile_proxy,
				passValue = addon
			},
			remove = {
				name = L["Remove"],
				desc = L["Removes a profile. Note that no check is made whether this profile is in use by other characters or not."],
				type = 'choice',
				get = false,
				set = RemoveProfile_proxy,
				choices = GetProfileCopyList,
				disabled = IsCopyListDisabled,
				passValue = addon
			},
			reset = {
				name = L["Reset profile"],
				desc = L["Clear all settings of the current profile."],
				type = 'execute',
				func = ResetDatabase_proxy,
				passValue = addon,
				passValue2 = "profile",
				confirmText = L["Reset all settings."],
				buttonText = L["Reset"],
			}
		}
	}
end

RockDB:SetExportedMethods("SetDatabase", "SetDefaultProfile", "SetDatabaseDefaults", "SetDatabaseNamespaceDefaults", "GetProfile", "SetProfile", "GetDatabaseNamespace", "RemoveProfile", "ResetDatabase", "CopyProfile")

Rock:FinalizeLibrary(MAJOR_VERSION)

Rock:AddUnitTest(MAJOR_VERSION, function()
	local t = { name = MAJOR_VERSION .. "_UnitTest" }

	RockDB:Embed(t)
	assert(t.db)

	t:SetDatabase(MAJOR_VERSION .. "_UnitTestDB")
	RockDB:InitializeDatabase(t)
	assert(type(_G[MAJOR_VERSION .. "_UnitTestDB"]) == "table")

	_G[MAJOR_VERSION .. "_UnitTestDB"] = nil
end)

Rock:AddUnitTest(MAJOR_VERSION, function()
	-- standard access
	local t = { name = MAJOR_VERSION .. "_UnitTest" }

	RockDB:Embed(t)
	assert(t.db)

	t:SetDatabase(MAJOR_VERSION .. "_UnitTestDB")
	RockDB:InitializeDatabase(t)
	assert(type(_G[MAJOR_VERSION .. "_UnitTestDB"]) == "table")

	local kinds = { "profile", "char", "account", "realm", "server", "faction", "class" }
	for _, kind in ipairs(kinds) do
		assert(not t.db[kind].Alpha)
		t.db[kind].Alpha = true
		assert(t.db[kind].Alpha)
		assert(not t.db[kind].Bravo)
		t.db[kind].Bravo = true
		assert(t.db[kind].Bravo)
		t.db[kind].Alpha = false
		assert(not t.db[kind].Alpha)
		assert(t.db[kind].Bravo)
	end

	RockDB:Unembed(t)
	assert(_G[MAJOR_VERSION .. "_UnitTestDB"]) -- stuff changed, DB should still exist
	_G[MAJOR_VERSION .. "_UnitTestDB"] = nil
end)

Rock:AddUnitTest(MAJOR_VERSION, function()
	-- w/ CharDB
	local t = { name = MAJOR_VERSION .. "_UnitTest" }

	RockDB:Embed(t)
	assert(t.db)

	t:SetDatabase(MAJOR_VERSION .. "_UnitTestDB", MAJOR_VERSION .. "_UnitTestCharDB")
	RockDB:InitializeDatabase(t)
	assert(type(_G[MAJOR_VERSION .. "_UnitTestDB"]) == "table")
	assert(type(_G[MAJOR_VERSION .. "_UnitTestCharDB"]) == "table")

	local kinds = { "profile", "char", "account", "realm", "server", "faction", "class" }
	for _, kind in ipairs(kinds) do
		assert(not t.db[kind].Alpha)
		t.db[kind].Alpha = true
		assert(t.db[kind].Alpha)
		assert(not t.db[kind].Bravo)
		t.db[kind].Bravo = true
		assert(t.db[kind].Bravo)
		t.db[kind].Alpha = false
		assert(not t.db[kind].Alpha)
		assert(t.db[kind].Bravo)
	end

	_G[MAJOR_VERSION .. "_UnitTestDB"] = nil
	_G[MAJOR_VERSION .. "_UnitTestCharDB"] = nil
end)

Rock:AddUnitTest(MAJOR_VERSION, function()
	-- namespacing
	local t = { name = MAJOR_VERSION .. "_UnitTest" }

	RockDB:Embed(t)
	assert(t.db)

	t:SetDatabase(MAJOR_VERSION .. "_UnitTestDB")
	RockDB:InitializeDatabase(t)
	assert(type(_G[MAJOR_VERSION .. "_UnitTestDB"]) == "table")

	local nsdb = t:GetDatabaseNamespace("MyNamespace")

	local kinds = { "profile", "char", "account", "realm", "server", "faction", "class" }
	for _, kind in ipairs(kinds) do
		assert(not nsdb[kind].Alpha)
		nsdb[kind].Alpha = true
		assert(nsdb[kind].Alpha)
		assert(not nsdb[kind].Bravo)
		nsdb[kind].Bravo = true
		assert(nsdb[kind].Bravo)
		nsdb[kind].Alpha = false
		assert(not nsdb[kind].Alpha)
		assert(nsdb[kind].Bravo)
	end

	_G[MAJOR_VERSION .. "_UnitTestDB"] = nil
end)

Rock:AddUnitTest(MAJOR_VERSION, function()
	-- defaults
	local t = { name = MAJOR_VERSION .. "_UnitTest" }

	RockDB:Embed(t)
	assert(t.db)

	t:SetDatabase(MAJOR_VERSION .. "_UnitTestDB")
	t:SetDatabaseDefaults("profile", {
		alpha = {
			bravo = "charlie"
		},
		delta = {
			['*'] = "echo",
			foxtrot = "golf",
		},
		hotel = {
			['*'] = {},
			india = "juliet",
		},
		kilo = {
			['**'] = {
				lima = "mike",
			},
			november = {
				oscar = "papa",
				-- should have lima = "mike" as well
			}
		},
	})
	RockDB:InitializeDatabase(t)
	assert(type(_G[MAJOR_VERSION .. "_UnitTestDB"]) == "table")

	assert(t.db.profile.alpha.bravo == "charlie")
	assert(t.db.profile.delta.foxtrot == "golf")
	assert(t.db.profile.delta.dummy == "echo")
	assert(t.db.profile.hotel.india == "juliet")
	assert(type(t.db.profile.hotel.dummy) == "table")
	assert(not next(t.db.profile.hotel.dummy))
	t.db.profile.hotel.dummy.value = true
	assert(t.db.profile.hotel.dummy.value == true)
	assert(t.db.profile.kilo.dummy.lima == "mike")
	assert(t.db.profile.kilo.dummy.oscar == nil)
	assert(t.db.profile.kilo.november.lima == "mike")
	assert(t.db.profile.kilo.november.oscar == "papa")
	t.db.profile.hotel.dummy.value = nil

	t:GetDatabaseNamespace("Bank")
	t:SetDatabaseNamespaceDefaults("Bank", "profile", {
		blah = true,
	})

	RockDB:Unembed(t)
	assert(not _G[MAJOR_VERSION .. "_UnitTestDB"]) -- nothing changed, DB clear
end)

Rock:AddUnitTest(MAJOR_VERSION, function()
	-- defaults
	local t = { name = MAJOR_VERSION .. "_UnitTest" }

	RockDB:Embed(t)
	assert(t.db)


	t:SetDatabase(MAJOR_VERSION .. "_UnitTestDB")
	t:SetDatabaseDefaults("profile", {
		blah = true,
	})
	local nsdb = t:GetDatabaseNamespace("Bank")
	t:SetDatabaseNamespaceDefaults("Bank", "profile", {
		alpha = {
			bravo = "charlie"
		},
		delta = {
			['*'] = "echo",
			foxtrot = "golf",
		},
		hotel = {
			['*'] = {},
			india = "juliet",
		},
		kilo = {
			['**'] = {
				lima = "mike",
			},
			november = {
				oscar = "papa",
				-- should have lima = "mike" as well
			}
		},
	})
	RockDB:InitializeDatabase(t)
	assert(type(_G[MAJOR_VERSION .. "_UnitTestDB"]) == "table")

	assert(nsdb.profile.alpha.bravo == "charlie")
	assert(nsdb.profile.delta.foxtrot == "golf")
	assert(nsdb.profile.delta.dummy == "echo")
	assert(nsdb.profile.hotel.india == "juliet")
	assert(type(nsdb.profile.hotel.dummy) == "table")
	assert(not next(nsdb.profile.hotel.dummy))
	nsdb.profile.hotel.dummy.value = true
	assert(nsdb.profile.hotel.dummy.value == true)
	assert(nsdb.profile.kilo.dummy.lima == "mike")
	assert(nsdb.profile.kilo.dummy.oscar == nil)
	assert(nsdb.profile.kilo.november.lima == "mike")
	assert(nsdb.profile.kilo.november.oscar == "papa")
	nsdb.profile.hotel.dummy.value = nil

	RockDB:Unembed(t)
	assert(not _G[MAJOR_VERSION .. "_UnitTestDB"]) -- nothing changed, DB clear
end)

Rock:AddUnitTest(MAJOR_VERSION, function()
	-- changing profiles
	local t = { name = MAJOR_VERSION .. "_UnitTest" }

	RockDB:Embed(t)
	assert(t.db)

	t:SetDatabase(MAJOR_VERSION .. "_UnitTestDB")
	RockDB:InitializeDatabase(t)
	assert(type(_G[MAJOR_VERSION .. "_UnitTestDB"]) == "table")

	assert(t:GetProfile() == "Default")
	assert(select(2, t:GetProfile()) == "Default")
	assert(not t.db.profile.alpha)
	t.db.profile.alpha = "bravo"
	assert(t.db.profile.alpha == "bravo")
	t:SetProfile("Alternative")
	assert(t:GetProfile() == "Alternative")
	assert(select(2, t:GetProfile()) == "Alternative")
	assert(not t.db.profile.alpha)
	t.db.profile.alpha = "charlie"
	assert(t.db.profile.alpha == "charlie")
	t:SetProfile("Default")
	assert(t:GetProfile() == "Default")
	assert(select(2, t:GetProfile()) == "Default")
	assert(t.db.profile.alpha == "bravo")

	t:RemoveProfile("Alternative")
	t:SetProfile("Alternative")
	assert(t:GetProfile() == "Alternative")
	assert(select(2, t:GetProfile()) == "Alternative")
	assert(not t.db.profile.alpha)

	t:SetProfile("char")
	assert(t:GetProfile() == "char")
	assert(select(2, t:GetProfile()):match("^char/."))
	t:SetProfile("class")
	assert(t:GetProfile() == "class")
	assert(select(2, t:GetProfile()):match("^class/."))
	t:SetProfile("realm")
	assert(t:GetProfile() == "realm")
	assert(select(2, t:GetProfile()):match("^realm/."))

	_G[MAJOR_VERSION .. "_UnitTestDB"] = nil
end)

Rock:AddUnitTest(MAJOR_VERSION, function()
	-- copying profiles
	local t = { name = MAJOR_VERSION .. "_UnitTest" }

	RockDB:Embed(t)
	assert(t.db)

	t:SetDatabase(MAJOR_VERSION .. "_UnitTestDB")
	RockDB:InitializeDatabase(t)
	assert(type(_G[MAJOR_VERSION .. "_UnitTestDB"]) == "table")

	assert(t:GetProfile() == "Default")
	assert(select(2, t:GetProfile()) == "Default")
	assert(not t.db.profile.alpha)
	t.db.profile.alpha = "bravo"
	assert(t.db.profile.alpha == "bravo")
	t:SetProfile("Alternative")
	assert(t:GetProfile() == "Alternative")
	assert(select(2, t:GetProfile()) == "Alternative")
	assert(not t.db.profile.alpha)
	t.db.profile.alpha = "charlie"
	assert(t.db.profile.alpha == "charlie")
	t:SetProfile("Default")
	assert(t:GetProfile() == "Default")
	assert(select(2, t:GetProfile()) == "Default")
	assert(t.db.profile.alpha == "bravo")
	t:CopyProfile("Alternative")
	assert(t:GetProfile() == "Default")
	assert(select(2, t:GetProfile()) == "Default")
	assert(t.db.profile.alpha == "charlie")

	_G[MAJOR_VERSION .. "_UnitTestDB"] = nil
end)

Rock:AddUnitTest(MAJOR_VERSION, function()
	-- resetting database
	local t = { name = MAJOR_VERSION .. "_UnitTest" }

	RockDB:Embed(t)
	assert(t.db)

	t:SetDatabase(MAJOR_VERSION .. "_UnitTestDB")
	RockDB:InitializeDatabase(t)
	assert(type(_G[MAJOR_VERSION .. "_UnitTestDB"]) == "table")

	assert(t.db.char.alpha == nil)
	t.db.char.alpha = "bravo"
	assert(t.db.char.alpha == "bravo")
	t:ResetDatabase()
	assert(t.db.char.alpha == nil)
	t.db.char.alpha = "bravo"
	assert(t.db.char.alpha == "bravo")
	t:ResetDatabase("char")
	assert(t.db.char.alpha == nil)

	local nsdb = t:GetDatabaseNamespace("MyModule")
	assert(nsdb.char.alpha == nil)
	nsdb.char.alpha = "bravo"
	assert(nsdb.char.alpha == "bravo")
	t:ResetDatabase()
	assert(nsdb.char.alpha == nil)
	nsdb.char.alpha = "bravo"
	assert(nsdb.char.alpha == "bravo")
	t:ResetDatabase("char")
	assert(nsdb.char.alpha == nil)

	t.db.char.alpha = "bravo"
	nsdb.char.alpha = "bravo"
	assert(t.db.char.alpha == "bravo")
	assert(nsdb.char.alpha == "bravo")
	t:ResetDatabase("char", "MyModule")
	assert(t.db.char.alpha == "bravo")
	assert(nsdb.char.alpha == nil)
	nsdb.char.alpha = "bravo"
	assert(nsdb.char.alpha == "bravo")
	t:ResetDatabase(nil, "MyModule")
	assert(t.db.char.alpha == "bravo")
	assert(nsdb.char.alpha == nil)

	_G[MAJOR_VERSION .. "_UnitTestDB"] = nil
end)
