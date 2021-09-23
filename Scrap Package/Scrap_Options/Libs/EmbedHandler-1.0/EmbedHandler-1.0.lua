--[[
Copyright 2009 João Cardoso
EmbedHandler is distributed under the terms of the GNU General Public License (or the Lesser GPL).
This file is part of EmbedHandler.

EmbedHandler is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

EmbedHandler is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with EmbedHandler. If not, see <http://www.gnu.org/licenses/>.
--]]

local lib, old = LibStub:NewLibrary('EmbedHandler-1.0', 3)
if not lib then
	return
else
	lib.internal = {}
	lib.empty = {}
	
	if not old then
		lib.embeds = {}
	end
end

local internal, embeds, empty, data, isFunc = lib.internal, lib.embeds, lib.empty
local type, pairs, unpack, select = type, pairs, unpack, select --speed up!


--[[ User API ]]--

function lib:Embed(target, ...)
	data = {}
	for i = 1, select('#', ...) do
		data[select(i, ...)] = true
	end
	
	internal.Embed(self, target, data)
	internal.SaveData(self, target, data)
end

function lib:SpecificEmbed(target, ...)
	data = {specific = 1, ...}
	
	internal.SpecificEmbed(self, target, data)
	internal.SaveData(self, target, data)
end

function lib:IterateEmbeds()
	return pairs(embeds[self] or empty)
end
	
function lib:UpdateEmbeds()
	for target,data in lib.IterateEmbeds(self) do --it's safer to index the lib
		if data.specific ~= 1 then
			internal.Embed(self, target, data)
		else
			internal.SpecificEmbed(self, target, data)
		end
	end
end


--[[ Internal API ]]--

function internal:Embed(target, data)
	for k,v in pairs(self) do
		isFunc = type(v) == 'function'
		if (isFunc and not data[k]) or (data[k] and not isFunc) then
			target[k] = self[k]
		end
	end
end

function internal:SpecificEmbed(target, data)
	for i,k in ipairs(data) do
		target[k] = self[k]
	end
end

function internal:SaveData(target, data)
	embeds[self] = embeds[self] or {}
	embeds[self][target] = data
end

lib:UpdateEmbeds()