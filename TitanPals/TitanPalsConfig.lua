local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
local LB = LibStub("AceLocale-3.0"):GetLocale("TitanPals", true)
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfig = LibStub("AceConfig-3.0")
--local Dewdrop = nil
--if AceLibrary:HasInstance("Dewdrop-2.0") then Dewdrop = AceLibrary("Dewdrop-2.0") end

-- ******************************** Config Panel *******************************

-- ******************************** Data Arrays *******************************
palsDB = nil;
palsAuthor = nil;
TitanPalsFormatToRemove = "None";

-- Core ( enUS only non-translateable )
LB["TITAN_PALS_CORE_ID"] = "Pals";
LB["TITAN_PALS_CORE_VERSION"] = GetAddOnMetadata("TitanPals","Version");
LB["TITAN_PALS_CORE_DTAG"] = "<TitanPals Debug>";
LB["TITAN_PALS_CORE_ITAG"] = "<TitanPals Info>";
LB["TITAN_PALS_CORE_ETAG"] = "<TitanPals Error>";
LB["TITAN_PALS_CORE_ADDVER"] = "r54";
--LB["TITAN_PALS_CORE_ARTWORK"] = "Interface\\AddOns\\TitanPals\\Artwork\\TitanPals";
LB["TITAN_PALS_CORE_ARTWORK"] = "Interface\\FriendsFrame\\UI-Toast-ChatInviteIcon";

-- **************************************************************************
-- NAME : TitanPanelPals_ConfigUtils(a)
-- DESC : Pull information from .toc for config dialog
-- **************************************************************************
local function TitanPanelPals_ConfigUtils(a)
     if ( a == "GetAuthor" ) then
          return GetAddOnMetadata("TitanPals", "Authors") or L["TITAN_NA"];
     elseif ( a == "GetTranslation" ) then
          return GetAddOnMetadata("TitanPals", "X-Translation") or L["TITAN_NA"];
     elseif ( a == "GetCategory" ) then
          return GetAddOnMetadata("TitanPals", "X-Category") or L["TITAN_NA"];
     elseif ( a == "GetEmail" ) then
          return GetAddOnMetadata("TitanPals", "X-Email") or L["TITAN_NA"];
     elseif ( a == "GetWebsite" ) then
          return GetAddOnMetadata("TitanPals", "X-Website") or L["TITAN_NA"];
     elseif ( a == "GetVersion" ) then
          return tostring(GetAddOnMetadata("TitanPals", "Version")) or L["TITAN_NA"];
     end
end

-- **************************************************************************
-- NAME : optionsPals
-- DESC : this is the root of the config dialog
-- **************************************************************************
local PalsOpt = {
     name = LB["TITAN_PALS_CONFIG"],
     type = "group",
     args = {
          confgendesc = {
               order = 1,
               type = "description",
               name = LB["TITAN_PALS_CONFIG_LABEL"],
               cmdHidden = true
          },
	  cat1 = {
	       order = 2,
               name = LB["TITAN_PALS_CONFIG_ABOUT"],
               type = "group", inline = true,
               args = {
                    confversiondesc = {
                         order = 1,
                         type = "description",			
                         name = "|cffffd700".."Version"..": ".._G["GREEN_FONT_COLOR_CODE"]..TitanPanelPals_ConfigUtils("GetVersion"),
                         cmdHidden = true
                    },
                    confauthordesc = {
                         order = 2,
                         type = "description",
                         name = "|cffffd700".."Author"..": ".."|cffff8c00"..TitanPanelPals_ConfigUtils("GetAuthor"),
                         cmdHidden = true
                    },
                    conflangauthordesc = {
                         order = 3,
                         type = "description",
                         name = "|cffffd700".."Translations"..": ".."|cffff8c00"..TitanPanelPals_ConfigUtils("GetTranslation"),
                         cmdHidden = true
                    },
                    confcatdesc = {
                         order = 3,
                         type = "description",
                         name = "|cffffd700".."Category"..": ".._G["HIGHLIGHT_FONT_COLOR_CODE"]..TitanPanelPals_ConfigUtils("GetCategory"),
                         cmdHidden = true
                    },
                    confemaildesc = {
                         order = 4,
                         type = "description",
                         name = "|cffffd700".."Email"..": ".._G["HIGHLIGHT_FONT_COLOR_CODE"]..TitanPanelPals_ConfigUtils("GetEmail"),
                         cmdHidden = true
                    },
                    confwebsitedesc = {
                         order = 5,
                         type = "description",
                         name = "|cffffd700".."Website"..": ".._G["HIGHLIGHT_FONT_COLOR_CODE"]..TitanPanelPals_ConfigUtils("GetWebsite"),
                         cmdHidden = true
                    },
               },
	  },
	  cat2 = {
               order = 3,
	       name = LB["TITAN_PALS_CONFIG_SET_HEADER_2"],
	       type = "group",
	       args = {
                    tooltipshowignored = {
                         name = LB["TITAN_PALS_CONFIG_SHOWIGNORED"],
                         desc = LB["TITAN_PALS_CONFIG_SHOWIGNORED_DESC"],
                         order = 1, type = "toggle",
                         get = function() return TitanPals.Settings.ShowIgnored; end,
                         set = function() TitanPanelPals_CoreUtils("Toggle", "Settings:ShowIgnored"); end,
                    },
                    tooltipshowmem = {
                         name = LB["TITAN_PALS_CONFIG_SHOWMEM"],
                         desc = LB["TITAN_PALS_CONFIG_SHOWMEM_DESC"],
                         order = 2, type = "toggle",
                         get = function() return TitanPals.Settings.ShowMem; end,
                         set = function() TitanPanelPals_CoreUtils("Toggle", "Settings:ShowMem"); end,
                    },
                    tooltipbannor = {
                         name = LB["TITAN_PALS_CONFIG_BANNOR"],
                         desc = LB["TITAN_PALS_CONFIG_BANNOR_DESC"],
                         order = 3, type = "toggle",
                         get = function() return TitanPals.Settings.DisplayB; end,
                         set = function() TitanPanelPals_CoreUtils("Toggle", "Settings:DisplayB"); end,
                    },
		    tooltipshowoffline = {
                         name = LB["TITAN_PALS_CONFIG_SHOWOFFLINE"],
                         desc = LB["TITAN_PALS_CONFIG_SHOWOFFLINE_DESC"],
                         order = 4, type = "toggle",
                         get = function() return TitanPals.Settings.ShowOffline; end,
                         set = function() TitanPanelPals_CoreUtils("Toggle", "Settings:ShowOffline"); end,
                    },
                    tooltipnoalts = {
                         name = LB["TITAN_PALS_CONFIG_NOALTS"],
                         desc = LB["TITAN_PALS_CONFIG_NOALTS_DESC"],
                         order = 5, type = "toggle",
                         get = function() return TitanPals.Settings.NoAlts; end,
                         set = function() TitanPanelPals_CoreUtils("Toggle", "Settings:NoAlts"); end,
                    },
               },
	  },
	  cat3 = {
	       order = 4,
               name = LB["TITAN_PALS_CONFIG_SET_HEADER"],
               type = "group",
               args = {
	            tooltippresets = {
                         order = 1, type = "select", width = "full",
                         name = LB["TITAN_PALS_CONFIG_PRESETS"],
                         desc = LB["TITAN_PALS_CONFIG_PRESETS_DESC"],
                         get = function() return TitanPals.Settings.TFormat; end,
                         set = function(_, v) TitanPals.Settings["TFormat"] = v; end,
                         values = function()
                              local preList = {};
                              local v;
                              for _, v in pairs( TitanPals["presets"] ) do
                                   if ( v.value ~= TitanPals.Settings.TFormat ) then
                                        preList[v.value] = "|cff19ff19"..v.value.."|r"
                                   else
                                        preList[v.value] = "|cffffff9a"..v.value.."|r"
                                   end
                              end
                              table.sort(preList, function(a, b)
                                   return string.lower(TitanPals["persets"][a].name) < string.lower(TitanPals["persets"][b].name)
                              end)
                              return preList;
                         end
                    },
                    nulloption1 = {
                         order = 2,
                         type = "description",
                         name = LB["TITAN_PALS_CONFIG_PRESETS_PREVIEW"],
                         cmdHidden = true
                    },
               },
	  },
	  cat4 = {
               order = 5,
               name = LB["TITAN_PALS_CONFIG_HEADER_ADD"],
               type = "group",
               args = {
                    tooltipaddcustom = {
                         order = 1,
			 type = "input", width = "full",
			 name = LB["TITAN_PALS_CONFIG_CUSTOM_TOOLTIP"],
			 desc = LB["TITAN_PALS_CONFIG_CUSTOM_TOOLTIP_DESC"],
			 get = function() return end,
			 set = function(_, v)
                              local tc = table.getn(TitanPals["presets"]);
			      tc = ( tc + 1 );
			      local tName = "Style #"..tc;
			      local tValue = v;
			      TitanPanelPals_AddNewPreset(tName, tValue)
			 end,
		    },
                    nulloptionct = {
                         order = 2,
			 type = "description",
			 name = LB["TITAN_PALS_CONFIG_CUSTOM_TOOLTIP_INST"],
			 cmdHidden = true
                    },
               },
	  },
          cat5 = {
               order = 6,
               name = LB["TITAN_PALS_CONFIG_HEADER_REMOVE"],
               type = "group",
	       args = {
	            tooltippresetsremove = {
                         order = 1, type = "select", width = "full",
                         name = LB["TITAN_PALS_CONFIG_PRESETS"],
                         desc = LB["TITAN_PALS_CONFIG_REMOVE_PRESETS_DESC"],
                         get = function() return TitanPalsFormatToRemove; end,
                         set = function(_, v) 
                              TitanPals.Temp["TitanPalsFormatToRemove"] = v;
                              TitanPalsFormatToRemove = v; 
			 end,
                         values = function()
                              local preList = {};
                              local v;
                              for _, v in pairs( TitanPals["presets"] ) do
                                   if ( v.value ~= TitanPals.Settings.TFormat ) then
                                        preList[v.value] = "|cff19ff19"..v.name.." "..v.value.."|r"
                                   end
                                   if ( v.value == TitanPalsFormatToRemove ) then
                                        preList[v.value] = "|cffffff9a"..v.name.." "..v.value.."|r"
                                   end
                              end
                              if TitanPalsFormatToRemove ~= "None" then
                                   preList["None"] = "|cff19ff19"..L["TITAN_NONE"].."|r"
                              else
                                   preList["None"] = "|cffffff9a"..L["TITAN_NONE"].."|r"
                              end
                              table.sort(preList, function(a, b)
                                   return string.lower(TitanPals["persets"][a].name) < string.lower(TitanPals["persets"][b].name)
                              end)
                              return preList;
                         end
                    },
		    tooltippresetremovebutton = {
                         order = 2, type = "execute",
			 name = LB["TITAN_PALS_CONFIG_REMOVE"],
			 desc = LB["TITAN_PALS_CONFIG_REMOVE_DESC"],
                         func = function()
                              if ( TitanPalsFormatToRemove == "None" ) then return end
                              local k, v;
                              for k, v in pairs (TitanPals["presets"]) do
                                   if ( v.value == TitanPalsFormatToRemove ) then
                                        table.remove(TitanPals["presets"], k)
                                        TitanPalsFormatToRemove = "None"
                                        break;
                                   end
                              end
                         end,
		    },
               },
          },
	  cat6 = {
               order = 6,
               name = LB["TITAN_PALS_CONFIG_SET_HEADER_STATUS"],
	       type = "group",
               args = {
                    statustypes = {
                         order = 1, type = "select", width = "full",
                         name = LB["TITAN_PALS_CONFIG_STATUS_TYPES"],
                         desc = LB["TITAN_PALS_CONFIG_STATUS_TYPES_DESC"],
                         get = function() return TitanPals.Settings.SFormat; end,
                         set = function(_, v) TitanPals.Settings["SFormat"] = v; end,
                         values = function()
                              local preList = {};
                              local v;
                              for _, v in pairs( TitanPals["sTypes"] ) do
                                   if ( v.value ~= TitanPals.Settings.SFormat ) then
                                        preList[v.value] = "|cff19ff19"..v.value.."|r"
                                   else
                                        preList[v.value] = "|cffffff9a"..v.value.."|r"
                                   end
                              end
                              table.sort( preList, function( a, b )
                                   return string.lower( TitanPals["sTypes"][a].name ) < string.lower( TitanPals["sTypes"][b].name )
                              end)
                              return preList;
                         end
                    },
                    nulloptionct = {
                         order = 2,
                         type = "description",
                         name = LB["TITAN_PALS_CONFIG_STATUS_TYPES_INST"],
                         cmdHidden = true
                    },
               },
          },
          cat7 = {
               order = 7,
	       name =  LB["TITAN_PALS_CONFIG_HEADER_REALID"];
	       type = "group",
	       args = {
                    realidonoroff = {
			 name = LB["TITAN_PALS_CONFIG_REALID_ONOFF"],
			 desc = LB["TITAN_PALS_CONFIG_REALID_ONOFF_DESC"],
                         order = 1, type = "toggle", width = "full",
			 get = function() return TitanPals.Settings.ShowBNTooltip; end,
			 set = function() 
                              TitanPanelPals_CoreUtils("Toggle", "Settings:ShowBNTooltip");
                              TitanPanelButton_UpdateButton(LB["TITAN_PALS_CORE_ID"]);
                         end,
		    },
		    tooltipacustomrealid = {
                         order = 2,
			 type = "select", width = "full",
			 name = LB["TITAN_PALS_CONFIG_CUSTOM_TOOLTIP_REALID"],
			 desc = LB["TITAN_PALS_CONFIG_CUSTOM_TOOLTIP_REALID_DESC"],
			 get = function() return TitanPals.Settings.RealIDFormat end,
			 set = function(_, v) TitanPals.Settings["RealIDFormat"] = v; end,
                         values = function()
                              local preList = {};
                              local v;
                              for _, v in pairs( TitanPals["realidformats"] ) do
                                   if ( v.value ~= TitanPals.Settings.RealIDFormat ) then
                                        preList[v.value] = "|cff19ff19"..v.value.."|r"
                                   else
                                        preList[v.value] = "|cffffff9a"..v.value.."|r"
                                   end
                              end
                              table.sort(preList, function(a, b)
                                   return string.lower(TitanPals["realidformats"][a].name) < string.lower(TitanPals["realidformats"][b].name)
                              end)
                              return preList;
                         end
		    },
                    nulloption1 = {
                         order = 3,
                         type = "description",
                         name = "\n",
                         cmdHidden = true
                    },
                    confrealinondesc = {
                         order = 4,
                         type = "description",
                         name = LB["TITAN_PALS_CONFIG_REALID_NOTE1_ON"],
                         cmdHidden = true
                    },
                    nulloption2 = {
                         order = 5,
                         type = "description",
                         name = "\n",
                         cmdHidden = true
                    },
                    confrealidoffdesc = {
                         order = 6,
                         type = "description",
                         name = LB["TITAN_PALS_CONFIG_REALID_NOTE1_OFF"],
                         cmdHidden = true
                    },
               },
	  },
	  cat8 = {
               order = 8,
               name = LB["TITAN_PALS_CONFIG_HEADER_REALID_ADD"],
               type = "group",
               args = {
                    tooltipaddrealidcustom = {
                         order = 1,
			 type = "input", width = "full",
			 name = LB["TITAN_PALS_CONFIG_CUSTOM_REALID_TOOLTIP"],
			 desc = LB["TITAN_PALS_CONFIG_CUSTOM_REALID_TOOLTIP_DESC"],
			 get = function() return end,
			 set = function(_, v)
                              local tc = table.getn(TitanPals["realidformats"]);
			      tc = ( tc + 1 );
			      local tName = "Format #"..tc;
			      local tValue = v;
			      TitanPanelPals_AddNewRealIDPreset(tName, tValue)
			 end,
		    },
                    nulloptionct = {
                         order = 2,
			 type = "description",
			 name = LB["TITAN_PALS_CONFIG_CUSTOM_REALID_TOOLTIP_INST"],
			 cmdHidden = true
                    },
               },
	  },
          cat9 = {
               order = 9,
               name = LB["TITAN_PALS_CONFIG_HEADER_REALID_REMOVE"],
               type = "group",
	       args = {
	            tooltippresetsremove = {
                         order = 1, type = "select", width = "full",
                         name = LB["TITAN_PALS_CONFIG_REALID_PRESETS"],
                         desc = LB["TITAN_PALS_CONFIG_REALID_REMOVE_PRESETS_DESC"],
                         get = function() return TitanPalsFormatToRemove; end,
                         set = function(_, v) 
                              TitanPals.Temp["TitanPalsFormatToRemove"] = v;
                              TitanPalsFormatToRemove = v; 
			 end,
                         values = function()
                              local preList = {};
                              local v;
                              for _, v in pairs( TitanPals["realidformats"] ) do
                                   if ( v.value ~= TitanPals.Settings.RealIDFormat ) then
                                        preList[v.value] = "|cff19ff19"..v.name.." "..v.value.."|r"
                                   end
                                   if ( v.value == TitanPalsFormatToRemove ) then
                                        preList[v.value] = "|cffffff9a"..v.name.." "..v.value.."|r"
                                   end
                              end
                              if TitanPalsFormatToRemove ~= "None" then
                                   preList["None"] = "|cff19ff19"..L["TITAN_NONE"].."|r"
                              else
                                   preList["None"] = "|cffffff9a"..L["TITAN_NONE"].."|r"
                              end
                              table.sort(preList, function(a, b)
                                   return string.lower(TitanPals["realidformats"][a].name) < string.lower(TitanPals["realidformats"][b].name)
                              end)
                              return preList;
                         end
                    },
		    tooltippresetremovebutton = {
                         order = 2, type = "execute",
			 name = LB["TITAN_PALS_CONFIG_REALID_REMOVE"],
			 desc = LB["TITAN_PALS_CONFIG_REALID_REMOVE_DESC"],
                         func = function()
                              if ( TitanPalsFormatToRemove == "None" ) then return end
                              local k, v;
                              for k, v in pairs (TitanPals["realidformats"]) do
                                   if ( v.value == TitanPalsFormatToRemove ) then
                                        table.remove(TitanPals["realidformats"], k)
                                        TitanPalsFormatToRemove = "None"
                                        break;
                                   end
                              end
                         end,
		    },
               },
          },
     },
}

-- **************************************************************************
-- NAME : TitanPanelPals_AddNewPreset()
-- DESC : This will add a custom tooltip preset
-- **************************************************************************
function TitanPanelPals_AddNewPreset(presetname, presetvalue)
     local found
     for _,i in pairs(TitanPals["presets"]) do
          if i.name == presetname or i.value == presetvalue then
               found = true; break;
          end
     end	
     if ( not found ) then table.insert(TitanPals["presets"], { name = presetname, value = presetvalue }) end
end

-- **************************************************************************
-- NAME : TitanPanelPals_AddNewRealIDPreset()
-- DESC : This will add a custom tooltip preset for RealID Display
-- **************************************************************************
function TitanPanelPals_AddNewRealIDPreset(presetname, presetvalue)
     local found
     for _,i in pairs(TitanPals["realidformats"]) do
          if i.name == presetname or i.value == presetvalue then
               found = true; break;
          end
     end	
     if ( not found ) then table.insert(TitanPals["realidformats"], { name = presetname, value = presetvalue }) end
end

-- **************************************************************************
-- NAME : TitanPanelPalsButton_OnLoad()
-- DESC : Registers the plugin upon it loading
-- **************************************************************************
function TitanPanelPalsButton_OnLoad(self)
     self.registry = {
          id = LB["TITAN_PALS_CORE_ID"],
          builtIn = false,
          version = TITAN_VERSION,
          menuText = LB["TITAN_PALS_MENU_TEXT"],
          buttonTextFunction = "TitanPanelPalsButton_GetButtonText";
	  tooltipTitle = LB["TITAN_PALS_TOOLTIP"],
          tooltipCustomFunction = TitanPanelPals_SetTooltip;
          icon = LB["TITAN_PALS_CORE_ARTWORK"],
          iconWidth = 16,
          category = "Information",
          savedVariables = {
	       ShowIcon = 1,
	       ShowLabelText = 1,
          }
     };
     self:RegisterEvent("FRIENDLIST_UPDATE");
     self:RegisterEvent("IGNORELIST_UPDATE");
     self:RegisterEvent("ADDON_LOADED");
     self:RegisterEvent("PLAYER_ENTERING_WORLD");
     self:RegisterEvent("PLAYER_REGEN_DISABLED");
     self:RegisterEvent("PLAYER_REGEN_ENABLED");
     self:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE");
     self:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE");
     -- Titan Pals Config
     AceConfig:RegisterOptionsTable("Titan Panel Pals", PalsOpt);
     AceConfigDialog:AddToBlizOptions("Titan Panel Pals", LB["TITAN_PALS_CONFIG"]);
     TitanPanelPals_Init();
end