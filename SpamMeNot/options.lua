--[[    
    SpamMeNot: Detects and blocks commercial spam
    Copyright (C) 2008 Robert Stiles (robs@codexsoftware.co.uk)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

local L = LibStub("AceLocale-3.0"):GetLocale("SpamMeNot")

local options = {
	name = "SpamMeNot",
	handler = SpamMeNot, 
	icon =  "Interface\\Icons\\Ability_Warrior_Defensivestance.jpg",
	type= "group",
	args = {
		version = {
			order = 1,
			type = "description",
			name = "X",
		},
	
		by = {
			order = 2,
			type = "description",
			name = string.format(L["By %s of %s"], "Kebian", "Defias Brotherhood (EU)")
		},
		enable = {
			order = 3,
			type = "toggle",
			name = L["Enable"],
			desc = L["Enable SpamMeNot"],
			get = "IsEnabled",
			set = "ToggleEnabled",
		},
		gui = {
			order = 4,
			type = "execute",
			name = L["Open GUI"],
			desc = L["Opens SpamMeNot's Graphical User Interface (GUI)"],			
			func = "OpenGUI",
		},
		general = {
			type = "group",
			name = L["General"],
			guiInline = true,
			args = {
				showDebug = {
					type = "toggle",
					name = L["Show Debug"],
					desc = L["Toggles the display of debug messages."],
					get = "IsShowDebug",
					set = "ToggleShowDebug",
				},
				silent = {
					type = "toggle",
					name = L["Silent Mode"],
					desc = L["Silently disposes of spam."],
					get = "IsSilent",
					set = "ToggleSilent",
				},
				trade = {
					type = "toggle",
					name = L["Monitor Trade"],
					desc = L["Whether or not to monitor the trade channel."],
					get = "IsMonitoringTrade",
					set = "ToggleMonitorTrade",			
				},
				updatemon = {
					type = "toggle",
					name = L["Update Monitor"],
					desc = L["Informs you if a newer SpamMeNot version is found."],
					get = "IsUpdateMonitorOn",
					set = "ToggleUpdateMonitor",
				},
				ignoreKnownAddOnChannels = {
					type = "toggle",
					name = L["Ignore AddOn Channels"],
					desc = L["Whether or not to monitor chat channels used by known AddOns."],
					get = "IsIgnoringKnownAddOnChannels",
					set = "ToggleIgnoreKnownAddOnChannels",
				},
				blockRepeatedText = {
					type = "toggle",
					name = L["Block Repeated Text"],
					desc = L["Block repeated text spammed in quick succession."],
					get = "IsBlockingRepeatedText",
					set = "ToggleBlockingRepeatedText",
				},
			},			
		},
		
		scoring = {
			type = "group",
			name = L["Scoring"],
			guiInline = true,
			args = {
				blockScore = {
					type = "range",
					name = L["Block Score"],
					desc = L["Each message received is given a score.  This value tells SpamMeNot at what score the text is considered to be spam. 100 is the recommended value."],					
					min = 50,
					max = 150,
					step = 1,
					get = "GetBlockScore",
					set = "SetBlockScore",
					order = 1,
				},
				autoReport = {
					type = "toggle",
					name = L["Auto Report"],
					desc = L["Enable spam auto-reporting."],
					get = "IsAutoReporting",
					set = "ToggleAutoReporting",
					order = 2,
				},
				reportScore = {
					type = "range",
					name = L["Report Score"],
					desc = L["Indicates what score a message has to achieve before it is auto-reported. 150 is the recommended value."],
					min = 100,
					max = 200,
					step = 1,
					get = "GetReportScore",
					set = "SetReportScore",
					order = 3,
				},			
			},
		},
		
		levelfilter = {
			type= "group",
			name = L["Level Filter"],
			guiInline = true,
			args = {
				enable = {
					type="toggle",
					name = L["Enable"],
					desc = L["Enables the level blocking filter (used for whispers)."],
					get = "IsLevelFiltering",
					set = "ToggleLevelFiltering",
				},
				level = {
					type="range",
					name = L["Level"],
					desc = L["Block whispers from people at this level and below."],
					min = 1,
					max = 80,
					step = 1,
					get = "GetFilterLevel",
					set = "SetFilterLevel",
				},
			},
		},
	},
}

function SpamMeNot:SetupOptions()
	options.args.version.name = string.format(L["Version %s (r %s)"],  self.version, self.build)

    LibStub("AceConfig-3.0"):RegisterOptionsTable("SpamMeNot", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SpamMeNot", "SpamMeNot")

end

function SpamMeNot:IsBlockingRepeatedText()
	return self.db.profile.blockRepeatedText
end

function SpamMeNot:ToggleBlockingRepeatedText()
	self.db.profile.blockRepeatedText = not self.db.profile.blockRepeatedText
end

function SpamMeNot:IsMonitoringTrade()
	return self.db.profile.monitorTrade	
end

function SpamMeNot:ToggleMonitorTrade()
	self.db.profile.monitorTrade = not self.db.profile.monitorTrade
end

function SpamMeNot:IsIgnoringKnownAddOnChannels()
	return self.db.profile.ignoreKnownAddOnChannels
end


function SpamMeNot:ToggleIgnoreKnownAddOnChannels()
	self.db.profile.ignoreKnownAddOnChannels = not self.db.profile.ignoreKnownAddOnChannels
end

function SpamMeNot:IsSilent()
	return self.db.profile.isSilent
end

function SpamMeNot:ToggleSilent()
	self.db.profile.isSilent = not self.db.profile.isSilent
end

function SpamMeNot:IsAutoReporting()
	return self.db.profile.autoReport
end

function SpamMeNot:ToggleAutoReporting(info)
	self.db.profile.autoReport = not self.db.profile.autoReport
	--options.args.scoring.args.reportScore:SetDisabled(not self.db.profile.autoReport)	
end

function SpamMeNot:IsLevelFiltering()
	return self.db.profile.isLevelFiltering
end

function SpamMeNot:ToggleLevelFiltering()
	self.db.profile.isLevelFiltering = not self.db.profile.isLevelFiltering
end

function SpamMeNot:GetFilterLevel()
	return self.db.profile.filterLevel
end

function SpamMeNot:SetFilterLevel(info, val)
	self.db.profile.filterLevel = val
end

function SpamMeNot:IsShowDebug()
    return self.db.profile.showDebug
end

function SpamMeNot:ToggleShowDebug()
	self.db.profile.showDebug = not self.db.profile.showDebug
end

function SpamMeNot:ToggleEnabled()
	if self:IsEnabled() then
		self:Disable()
		self.db.profile.enabled = false
	else
		self:Enable()
		self.db.profile.enabled = true
	end
end

function SpamMeNot:GetBlockScore()
	return self.db.profile.blockScore
end

function SpamMeNot:SetBlockScore(info, val)
	self.db.profile.blockScore = val
end

function SpamMeNot:GetReportScore()
	return self.db.profile.reportScore
end

function SpamMeNot:SetReportScore(info, val)
	self.db.profile.reportScore = val
end

function SpamMeNot:OpenGUI()
	self.gui:Show()
end

function SpamMeNot:IsUpdateMonitorOn()
	return self.db.profile.updateMonitor
end

function SpamMeNot:ToggleUpdateMonitor()
	self.db.profile.updateMonitor = not self.db.profile.updateMonitor
	if self.db.profile.updateMonitor then
		SpamMeNot.updateMonitor:Enable()
	else
		SpamMeNot.updateMonitor:Disable()
	end	
end
