local Baggins = Baggins

local L = AceLibrary("AceLocale-2.2"):new("Baggins")
local dewdrop = AceLibrary("Dewdrop-2.0")
local waterfall
if AceLibrary:HasInstance("Waterfall-1.0") then
	waterfall = AceLibrary("Waterfall-1.0")
end

local catsorttable = {}

function Baggins:InitOptions()

	self:RegisterDB("BagginsDB")
	
	self:RegisterDefaults('profile', {
		showsectiontitle = true,
		hideemptysections = true,
		hidedefaultbank = false,
		overridedefaultbags = false,
		compressempty = true,
		compressshards = true,
		compressammo = true,
		compressstackable = false,
		sortnewfirst = true,
		compressall = false,
		shrinkwidth = true,
		shrinkbagtitle = false,
		showspecialcount = true,
		showammocount = true,
		showsoulcount = true,
		showempty = true,
		showused = true,
		showtotal = true,
		combinecounts = false,
		highlightnew = true,
		hideduplicates = 'disabled',
		optimizesectionlayout = false,
		skin = 'default',
		scale = 1,
		rightoffset = 50,
		topoffset = 50,
		bottomoffset = 50,
		leftoffset = 50,
		layoutanchor = "BOTTOMRIGHT",
		qualitycolorintensity = 0.3,
		qualitycolor = true,
		qualitycolormin = 2,
		columns = 5,
		sort = "quality",
		layout = "auto",
		bags = { },
		categories = {},
		moneybag = 1,
		openatauction = true,
	})
	
	self:RegisterDefaults('account', {
		pt3mods = {},
		profiles = {},
	})
	
	local p = self.db.profile
	self.opts = {
		type = "group",
		icon = "Interface\\Icons\\INV_Jewelry_Ring_03",
		args = {
			Refresh = {
				name = L["Force Full Refresh"],
				type = "execute",
				order = 9,
				desc = L["Forces a Full Refresh of item sorting"],
				func = function() self:ForceFullRefresh() self:UpdateBags() end,
			},
			--[[
			EditBags = {
				name = L["Edit Bags"],
				type = "execute",
				order = 10,
				desc = L["Edit the Bag Definitions"],
				func = function() self:OpenBagEditTablet() end,
			},
			EditCategories = {
				name = L["Edit Categories"],
				type = "execute",
				order = 15,
				desc = L["Edit the Category Definitions"],
				func = function() self:OpenCategoryEditTablet() end,
			},--]]
			Waterfall = {
				name = L["Config Window"],
				type = "execute",
				order = 1,
				wfHidden = true,
				desc = L["Opens the Waterfall Config window"],
				func = function() waterfall:Open("Baggins") dewdrop:Close() end,
				disabled = function() return not waterfall end,
			},
			BagCatEdit = {
				name = L["Bag/Category Config"],
				type = "execute",
				order = 2,
				desc = L["Opens the Waterfall Config window"],
				func = function() waterfall:Open("BagginsEdit") dewdrop:Close() end,
				disabled = function() return not waterfall end,
			},
			LoadProfile = {
				name = L["Load Profile"],
				type = "group",
				desc = L["Load a built-in profile: NOTE: ALL Custom Bags will be lost and any edited built in categories will be lost."],
				order = 20,
				args = {
					Default = {
						name = L["Default"],
						type = "execute",
						desc = L["A default set of bags sorting your inventory into categories"],
						func = function() self:ApplyProfile(self.profiles.default)	end,
						order = 10,
					},
					AllInOne = {
						name = L["All in one"],
						type = "execute",
						desc = L["A single bag containing your whole inventory, sorted by quality"],
						func = function() self:ApplyProfile(self.profiles.allinone)	end,
						order = 15,
					},
					AllInOneSorted = {
						name = L["All In One Sorted"],
						type = "execute",
						desc = L["A single bag containing your whole inventory, sorted into categories"],
						func = function() self:ApplyProfile(self.profiles.allinonesorted) end,
						order = 20,
					},
					UserDefined = {
						name = L["User Defined"],
						type = "group",
						desc = L["Load a User Defined Profile"],
						order = 30,
						pass = true,
						func = function(name) local p = self.db.account.profiles[name] if p then self:ApplyProfile(p) end end,
						args = {},
					},
				},
			},
			SaveProfile = {
				name = L["Save Profile"],
				type = "group",
				desc = L["Save a User Defined Profile"],
				pass = true,
				order = 30,
				func = function(name) self:SaveProfile(name) end,
				set = function(key, name) self:SaveProfile(name) end,
				get = false,
				args = {
					New = {
						type = "text",
						name = L["New"],
						desc = L["Create a new Profile"],
						usage = "<Name>",
						get = false,
						order = 1
					},
				},
			},
			DeleteProfile = {
				name = L["Delete Profile"],
				type = "group",
				desc = L["Delete a User Defined Profile"],
				pass = true,
				order = 40,
				func = function(name) self:SaveProfile(name) end,
				confirm = true,
				func = function(name) self.db.account.profiles[name] = nil self:RefreshProfileOptions() end,
				args = {
				},
			},
			spacer3 = {
				type = "header",
				order = 90,
			},
			Items = {
				name = L["Items"],
				type = 'group',
				order = 120,
				desc = L["Item display settings"],
				args = {
					Compress = {
						name = L["Compress"],
						desc = L["Compress Multiple stacks into one item button"],
						type = "group",
						order = 10,
						disabled = function() return p.sort == "slot" end,
						args = {
							CompressAll = {
								name = L["Compress All"],
								type = "toggle",
								desc = L["Show all items as a single button with a count on it"],
								order = 10,
								get = function() return p.compressall end,
								set = function(value)
									p.compressall = value
									self:RebuildSectionLayouts()
									self:UpdateBags()
								end,
							},
							CompressStackable = {
								name = L["Compress Stackable Items"],
								type = "toggle",
								desc = L["Show stackable items as a single button with a count on it"],
								order = 20,
								disabled = function() return p.compressall end,
								get = function() return p.compressstackable or p.compressall end,
								set = function(value)
									p.compressstackable = value
									self:RebuildSectionLayouts()									
									self:UpdateBags()
								end,
							},
							spacer = {
								type = 'header',
								order = 90,
							},
							CompressEmptySlots = {
								name = L["Compress Empty Slots"],
								type = "toggle",
								desc = L["Show all empty slots as a single button with a count on it"],
								order = 100,
								disabled = function() return p.compressall end,
								get = function() return p.compressempty or p.compressall end,
								set = function(value)
									p.compressempty = value
									self:RebuildSectionLayouts()
									self:UpdateBags()
								end,
							},
							CompressShards = {
								name = L["Compress Soul Shards"],
								type = "toggle",
								desc = L["Show all soul shards as a single button with a count on it"],
								order = 110,
								disabled = function() return p.compressall end,
								get = function() return p.compressshards or p.compressall end,
								set = function(value)
									p.compressshards = value
									self:RebuildSectionLayouts()
									self:UpdateBags()
								end,
							},
							CompressAmmo = {
								name = L["Compress Ammo"],
								type = "toggle",
								desc = L["Show all ammo as a single button with a count on it"],
								order = 120,
								disabled = function() return p.compressall or p.compressstackable end,
								get = function() return p.compressammo or p.compressstackable or p.compressall end,
								set = function(value)
									p.compressammo = value
									self:RebuildSectionLayouts()
									self:UpdateBags()
								end,
							},
						}
					},
					QualityColor = {
						name = L["Quality Colors"],
						desc = L["Color item buttons based on the quality of the item"],
						type = "group",
						order = 15,
						args = {
							Enable = {
								name = L["Enable"],
								type = "toggle",
								desc = L["Enable quality coloring"],
								order = 10,
								get = function() return p.qualitycolor end,
								set = function(value)
									p.qualitycolor = value
									self:UpdateItemButtons()
								end,
							},
							Threshold = {
								name = L["Color Threshold"],
								type = "text",
								desc = L["Only color items of this quality or above"],
								order = 15,

								get = function() return ("%d"):format(p.qualitycolormin) end,
								set = function(value)
									p.qualitycolormin = tonumber(value)
									self:UpdateItemButtons()
								end,
								disabled = function() return not p.qualitycolor end,
								validate = { 
									["0"] = "|c00000000"..select(4,GetItemQualityColor(0))..ITEM_QUALITY0_DESC,
									["1"] = "|c10000000"..select(4,GetItemQualityColor(1))..ITEM_QUALITY1_DESC,
									["2"] = "|c20000000"..select(4,GetItemQualityColor(2))..ITEM_QUALITY2_DESC,
									["3"] = "|c30000000"..select(4,GetItemQualityColor(3))..ITEM_QUALITY3_DESC,
									["4"] = "|c40000000"..select(4,GetItemQualityColor(4))..ITEM_QUALITY4_DESC,
									["5"] = "|c50000000"..select(4,GetItemQualityColor(5))..ITEM_QUALITY5_DESC,
									["6"] = "|c60000000"..select(4,GetItemQualityColor(6))..ITEM_QUALITY6_DESC,
								}
							},
							Intensity = {
								name = L["Color Intensity"],
								type = "range",
								desc = L["Intensity of the quality coloring"],
								order = 20,
								max = 1,
								min = 0.1,
								step = 0.1,
								get = function() return p.qualitycolorintensity end,
								set = function(value)
									p.qualitycolorintensity = value
									self:UpdateItemButtons()
								end,
								disabled = function() return not p.qualitycolor end,
							},
						}
					},
					HideDuplicates = {
						name = L["Hide Duplicate Items"],
						type = "text",
						desc = L["Prevents items from appearing in more than one section/bag."],
						order = 20,
						get = function() return p.hideduplicates end,
						set = function(value)
							p.hideduplicates = value
							self:ResortSections()
							self:UpdateBags()
						end,
						validate = { 'global', 'bag', 'disabled' },
					},
					AlwaysReSort = {
						name = L["Always Resort"],
						type = "toggle",
						desc = L["Keeps Items sorted always, this will cause items to jump around when selling etc."],
						order = 22,
						get = function() return p.alwaysresort end,
						set = function(value)
							p.alwaysresort = value
						end
					},
					spacer = {
						type = 'header',
						order = 25,
					},
					HighlightNew = {
						name = L["Highlight New Items"],
						type = "toggle",
						desc = L["Add *New* to new items, *+++* to items that you have gained more of."],
						order = 30,
						get = function() return p.highlightnew end,
						set = function(value)
							p.highlightnew = value
							self:UpdateItemButtons()
						end
					},
					ResetNew = {
						name = L["Reset New Items"],
						type = "execute",
						desc = L["Resets the new items highlights."],
						order = 35,
						func = function()
							self:SaveItemCounts()
							self:ForceFullUpdate()
						end,
						disabled = function() return not p.highlightnew end,
					},
				}
			},
			Layout = {
				name = L["Layout"],
				type = 'group',
				order = 125,
				desc = L["Appearance and layout"],
				args = {
					Bags = {
						type = 'header',
						order = 5,
						name = L["Bags"],
					},
					Type = {
						name = L["Layout Type"],
						type = 'text',
						order = 10,
						desc = L["Sets how all bags are laid out on screen."],
						get = function() return p.layout end,
						set = function(value) p.layout = value self:UpdateLayout() end,
						validate = { "auto", "manual" },
					},
					LayoutAnchor = {
						name = L["Layout Anchor"],
						type = "text",
						order = 15,
						desc = L["Sets which corner of the layout bounds the bags will be anchored to."],
						get = function() return p.layoutanchor end,
						set = function(value) p.layoutanchor =  value self:LayoutBagFrames() end,
						validate = { TOPRIGHT = L["Top Right"],
									TOPLEFT = L["Top Left"],
									BOTTOMRIGHT = L["Bottom Right"],
									BOTTOMLEFT = L["Bottom Left"] },
						disabled = function() return p.layout ~= 'auto' end,
					},
					SetLayoutBounds = {
						name = L["Set Layout Bounds"],
						type = "execute",
						order = 20,
						desc = L["Shows a frame you can drag and size to set where the bags will be placed when Layout is automatic"],
						func = function() self:ShowPlacementFrame() end,
						disabled = function() return p.layout ~= 'auto' end,
					},
					Lock = {
						name = L["Lock"],
						type = "toggle",
						desc = L["Locks the bag frames making them unmovable"],
						order = 30,
						get = function() return p.lock or p.layout == "auto" end,
						set = function(value) p.lock = value end,
						disabled = function() return p.layout == "auto" end,
					},
		 			OpenAtAuction = {
		 				name = L["Automatically open at auction house"],
		 				type = "toggle",
		 				desc = L["Automatically open at auction house"],
		 				order = 35,
		 				get = function() return p.openatauction end,
		 				set = function(value) p.openatauction = value end,
		 			},
					ShrinkWidth = {
						name = L["Shrink Width"],
						type = "toggle",
						desc = L["Shrink the bag's width to fit the items contained in them"],
						order = 40,
						get = function() return p.shrinkwidth end,
						set = function(value)
							p.shrinkwidth = value
							self:UpdateBags()
						end,
					},
					ShrinkTitle = {
						name = L["Shrink bag title"],
						type = "toggle",
						desc = L["Mangle bag title to fit to content width"],
						order = 50,
						get = function() return p.shrinkbagtitle end,
						set = function(value)
							p.shrinkbagtitle = value
							self:UpdateBags()
						end,
					},
					Scale = {
						name = L["Scale"],
						type = "range",
						desc = L["Scale of the bag frames"],
						order = 60,
						max = 2,
						min = 0.3,
						step = 0.1,
						get = function() return p.scale end,
						set = function(value)
							p.scale = value 
							self:UpdateBagScale()
							self:UpdateLayout()
						end,
					},
					ShowMoney = {
						name = L["Show Money On Bag"],
						type = "group",
						desc = L["Which Bag to Show Money On"],
						order = 64,
						pass = true,
						get = function(key) return p.moneybag == key end,
						set = function(key, value) p.moneybag = key self:UpdateBags() end,
						args = {
							None = {
								type = "toggle",
								isRadio = true,
								name = L["None"],
								desc = L["None"],
								passValue = 0,
								order = 1,
							},
						}
					},
					Sections = {
						type = 'header',
						order = 65,
						name = L["Sections"],
					},
					SectionLayout = {
						name = L["Optimize Section Layout"],
						type = "toggle",
						desc = L["Change order and layout of sections in order to save display space."],
						order = 70,
						get = function() return p.optimizesectionlayout end,
						set = function(value)
							p.optimizesectionlayout = value
							self:UpdateBags()
						end
					},
					SectionTitle = {
						name = L["Show Section Title"],
						type = "toggle",
						desc = L["Show a title on each section of the bags"],
						order = 80,
						get = function() return p.showsectiontitle end,
						set = function(value)
							p.showsectiontitle = value
							self:UpdateBags()
						end
					},
					HideEmptySections = {
						name = L["Hide Empty Sections"],
						type = "toggle",
						desc = L["Hide sections that have no items in them."],
						order = 90,
						get = function() return p.hideemptysections end,
						set = function(value)
							p.hideemptysections = value
							self:UpdateBags()
						end
					},
					Sort = {
						name = L["Sort"],
						type = "text",
						desc = L["How items are sorted"],
						order = 100,
						get = function() return p.sort end,
						set = function(value) p.sort = value self:UpdateBags() end,
						validate = {'quality', 'name', 'type', 'slot', 'ilvl' }
					},
					SortNewFirst = {
						name = L["Sort New First"],
						type = "toggle",
						desc = L["Sorts New Items to the beginning of sections"],
						order = 105,
						get = function() return p.sortnewfirst end,
						set = function(value) p.sortnewfirst = value end,
					},
					Columns = {
						name = L["Columns"],
						type = "range",
						desc = L["Number of Columns shown in the bag frames"],
						order = 110,
						get = function() return p.columns end,
						set = function(value) p.columns = value self:UpdateBags() end,
						min = 2,
						max = 20,
						step = 1,
					},
				}
			},
			FubarText = {
				name = L["FuBar Text"],
				type = "group",
				desc = L["Options for the text shown on fubar"],
				order = 130,
				args = {	
					ShowEmpty = {
						name = L["Show empty bag slots"],
						type = "toggle",
						order = 10,
						desc = L["Show empty bag slots"],
						get = function() return p.showempty end,
						set = function(value)
							p.showempty = value
							self:UpdateText()
						end,
					},
					ShowUsed = {
						name = L["Show used bag slots"],
						type = "toggle",
						order = 20,
						desc = L["Show used bag slots"],
						get = function() return p.showused end,
						set = function(value)
							p.showused = value
							self:UpdateText()
						end,
					},
					ShowTotal = {
						name = L["Show Total bag slots"],
						type = "toggle",
						order = 30,
						desc = L["Show Total bag slots"],
						get = function() return p.showtotal end,
						set = function(value)
							p.showtotal = value
							self:UpdateText()
						end,
					},
					spacer = {
						type = 'header',
						order = 49,
					},
					ShowAmmo = {
						name = L["Show Ammo Bags Count"],
						type = "toggle",
						order = 50,
						desc = L["Show Ammo Bags Count"],
						get = function() return p.showammocount end,
						set = function(value)
							p.showammocount = value
							self:UpdateText()
						end,
					},
					ShowSoul = {
						name = L["Show Soul Bags Count"],
						type = "toggle",
						order = 55,
						desc = L["Show Soul Bags Count"],
						get = function() return p.showsoulcount end,
						set = function(value)
							p.showsoulcount = value
							self:UpdateText()
						end,
					},
					ShowSpecialty = {
						name = L["Show Specialty Bags Count"],
						type = "toggle",
						order = 60,
						desc = L["Show Specialty (profession etc) Bags Count"],
						get = function() return p.showspecialcount end,
						set = function(value)
							p.showspecialcount = value
							self:UpdateText()
						end,
					},
					spacer2 = {
						type = 'header',
						order = 98,
					},
					Combine = {
						name = L["Combine Counts"],
						type = "toggle",
						order = 99,
						desc = L["Show only one count with all the seclected types included"],
						get = function() return p.combinecounts end,
						set = function(value)
							p.combinecounts = value
							self:UpdateText()
						end,
					},
				},
			},
			
			spacer = {
				type = 'header',
				order = 150,
			},
			Skin = {
				name = L["Bag Skin"],
				type = "text",
				desc = L["Select bag skin"],
				order = 160,
				get = function() return p.skin end,
				set = 'ApplySkin',
				validate = self:GetSkinList()
			},
			HideDefaultBank = {
				name = L["Hide Default Bank"],
				type = "toggle",
				desc = L["Hide the default bank window."],
				order = 170,
				get = function() return p.hidedefaultbank end,
				set = function(value) p.hidedefaultbank = value end,
			},
			OverrideBags = {
				name = L["Override Default Bags"],
				type = "toggle",
				desc = L["Baggins will open instead of the default bags"],
				order = 180,
				get = function() return p.overridedefaultbags end,
				set = function(value) p.overridedefaultbags = value self:UpdateBagHooks() end,
			},
		}
	}
end

Baggins.profiles = {
	allinone = {
		layout = "manual",
		columns = 12,
		sorttype = "quality",
		showsectiontitle = true,
		bags = { 
			{ 
				name = L["All In One"],
				openWithAll = true,
				sections = 
				{ 
					{ name=L["Bags"], cats={L["Bags"]} }, 
					{ name=L["Ammo Bag"], cats={L["AmmoBag"]} }, 
					{ name=L["Soul Bag"], cats={L["SoulBag"]} }, 
					{ name=L["KeyRing"], cats={L["KeyRing"]} } 
				} 
			},
			{ 
				name = L["Bank All In One"],
				openWithAll = true,
				isBank = true,
				sections = 
				{ 
					{ name=L["Bank Bags"], cats={L["BankBags"]} },
				} 
			}
		}
	},
	allinonesorted = {
		layout = "manual",
		columns = 12,
		sorttype = "quality",
		showsectiontitle = true,
		optimizesectionlayout = true,
		bags = { 
			{ 
				name = L["All In One"],
				openWithAll = true,
				sections = 
				{
					{ name = L["New"], cats = { L["New"] } , allowdupes=true }, 
					{ name = L["Ammo"], cats = { L["AmmoBag"] } },
					{ name = L["SoulBag"], cats = { L["SoulBag"] } },
					{ name = L["KeyRing"], cats = { L["KeyRing"] },},
					{ name = L["Armor"], cats = { L["Armor"] },},
					{ name = L["Weapons"], cats = { L["Weapons"] } },
					{ name = L["Consumables"], cats = { L["Consumables"] } },
					{ name = L["Quest"], cats = { L["Quest"] } },
					{ name = L["Trade Goods"], cats = { L["Tradeskill Mats"], L["Gathered"] } },
					{ name = L["Other"], cats = { L["Other"] } }, 
				} 
			},
			{ 
				name = L["Bank All In One"],
				openWithAll = true,
				isBank = true,
				sections = 
				{ 
					{ name = L["Bank Equipment"], cats = { L["Armor"], L["Weapons"] },},
					{ name = L["Bank Consumables"], cats = { L["Consumables"] } },
					{ name = L["Bank Quest"], cats = { L["Quest"] } },
					{ name = L["Bank Trade Goods"], cats = { L["Tradeskill Mats"], L["Gathered"] } },
					{ name = L["Bank Other"], cats = { L["Other"] } }, 
				} 
			}
		}
	},
	default = {
		showsectiontitle = true,
		columns = 5,
		sorttype = "quality",
		layout = "auto",
		bags = {
			{
				name = L["Other"],
				openWithAll = true,
				sections = 
				{ 
					{ name=L["New"], cats = { L["New"] }, allowdupes=true }, 
					{ name=L["Other"], cats = { L["Other"] } }, 
					{ name=L["Trash"], cats = { L["Trash"], L["TrashEquip"] } }, 
					{ name=L["Empty"], cats = { L["Empty"] } } 
				}
			},
			{
				name = L["Equipment"],
				openWithAll = true,
				sections = 
				{ 
					{ name=L["Armor"], cats={ L["Armor"] } }, 
					{ name=L["Weapons"], cats={ L["Weapons"] } } 
				}
			},
			{
				name = L["Quest"],
				openWithAll = true,
				sections = 
				{ 
					{ name=L["Quest Items"], cats = { L["Quest"] } } 
				}
			},	
			{
				name = L["Consumables"],
				openWithAll = true,
				sections = 
				{
					{ name = L["Water"], cats = {L["Water"]}}, 
					{ name = L["Food"], cats = {L["Food"]}},
					{ name = L["First Aid"], cats = {L["FirstAid"]}},
					{ name = L["Potions"], cats = {L["Potions"]}},
					{ name = L["Scrolls"], cats = {L["Scrolls"]}},
					{ name = L["Misc"], cats = { L["Misc Consumables"] }},
				}
			},
			{
				name = L["Trade Goods"],
				openWithAll = true,
				sections = 
				{
					{ name=L["Mats"], cats={ L["Tradeskill Mats"] } },
					{ name=L["Gathered"], cats={ L["Gathered"] } },
				}
			},
			{
				name = L["Ammo"],
				openWithAll = true,
				sections = 
				{ 
					{ name=L["Ammo"], cats={ L["AmmoBag"] } }, 
					{ name=L["SoulShards"], cats={ L["SoulBag"] } } 
				}
			},		
			{
				name = L["KeyRing"],
				openWithAll = false,
				sections = 
				{ 
					{ name=L["KeyRing"], cats = { L["KeyRing"] } },
				}
			},
			{
				name = L["Bank Equipment"],
				openWithAll = true,
				isBank = true,
				sections = 
				{ 
					{ name=L["Armor"], cats={ L["Armor"] } }, 
					{ name=L["Weapons"], cats={ L["Weapons"] } } 
				}
			},
			{
				name = L["Bank Quest"],
				openWithAll = true,
				isBank = true,
				sections = 
				{ 
					{ name=L["Quest Items"], cats = { L["Quest"] } } 
				}
			},	
			{
				name = L["Bank Consumables"],
				openWithAll = true,
				isBank = true,
				sections = 
				{
					{ name = L["Water"], cats = {L["Water"]}}, 
					{ name = L["Food"], cats = {L["Food"]}},
					{ name = L["First Aid"], cats = {L["FirstAid"]}},
					{ name = L["Potions"], cats = {L["Potions"]}},
					{ name = L["Scrolls"], cats = {L["Scrolls"]}},
					{ name = L["Misc"], cats = { L["Misc Consumables"] }},
				}
			},
			{
				name = L["Bank Trade Goods"],
				openWithAll = true,
				isBank = true,
				sections = 
				{
					{ name=L["Mats"], cats={ L["Tradeskill Mats"] } },
					{ name=L["Gathered"], cats={ L["Gathered"] } },
				}
			},
			{
				name = L["Bank Other"],
				openWithAll = true,
				isBank = true,
				sections = 
				{ 
					{ name=L["Other"], cats = { L["Other"] } }, 
					{ name=L["Trash"], cats = { L["Trash"], L["TrashEquip"] } }, 
					{ name=L["Empty"], cats = { L["Empty"] } } 
				}
			},				
		}
	}
}

Baggins.defaultcategories = {
	[L["Misc Consumables"]] = { name=L["Misc Consumables"], {type="ItemType" ,itype = "Consumable"},{operation = "NOT",type = "PTSet",setname = "Consumable.Food.Edible",},{operation = "NOT",type = "PTSet",setname = "Consumable.Water",},{operation = "NOT",type = "PTSet",setname = "Consumable.Potion",},{operation = "NOT",type = "PTSet",setname = "Consumable.Scroll",},{operation = "NOT",type = "PTSet",setname = "Consumable.Bandage",},},
	[L["Consumables"]] = { name=L["Consumables"], {type="ItemType" ,itype = "Consumable"} },
	[L["Armor"]] = { name=L["Armor"], { type="ItemType", itype="Armor" }, { type="ItemType", itype="Armor", isubtype="Shields", operation="NOT" }, },
	[L["Weapons"]] = { name=L["Weapons"], { type="ItemType", itype="Weapon" }, { type="ItemType", itype="Armor", isubtype="Shields" }, { type="PTSet", setname="Tradeskill.Tool", operation="NOT" }, },
	[L["Quest"]] = { name=L["Quest"], { type="ItemType", itype="Quest" }, { type="Tooltip", text="ITEM_BIND_QUEST" } },
	[L["AmmoBag"]] = { name=L["AmmoBag"], { type="AmmoBag" } },
	[L["Trash"]] = { name=L["Trash"], { type="Quality", quality = 0, comp = "<=" } },
	[L["TrashEquip"]] = { name=L["TrashEquip"], { type="ItemType", itype="Armor" }, { type="ItemType", itype="Weapon", operation="OR" }, { type="Quality", quality = 1, comp = "<=", operation="AND" }, { type="PTSet", setname="Tradeskill.Tool", operation="NOT" }, { type="ItemType", itype="Quest", operation="NOT" }, },
	[L["Other"]] = { name=L["Other"], { type="Other" } },
	[L["Empty"]] = { name=L["Empty"], { type="Empty" }, { type="AmmoBag", operation="NOT"}, { type="ContainerType", ctype="Soul Bag", operation="NOT"}, },
	[L["Bags"]] = { name=L["Bags"], { type="Bag", bagid=1 }, { type="Bag", bagid=2, operation="OR" }, { type="Bag", bagid=3, operation="OR" }, { type="Bag", bagid=4, operation="OR" }, { type="Bag", bagid=0, operation="OR" }, { type="AmmoBag", operation="NOT"}, { type="ContainerType", ctype="Soul Bag", operation="NOT"} },
	[L["BankBags"]] = { name=L["BankBags"], { type="Bag", bagid=-1 }, { type="Bag", bagid=5, operation="OR" }, { type="Bag", bagid=6, operation="OR" }, { type="Bag", bagid=7, operation="OR" }, { type="Bag", bagid=8, operation="OR" }, { type="Bag", bagid=9, operation="OR" }, { type="Bag", bagid=10, operation="OR" }, { type="Bag", bagid=11, operation="OR" }, },
	[L["KeyRing"]] = { name=L["KeyRing"], { type="Bag", bagid=-2 }, },
	[L["Potions"]] = { name=L["Potions"], { type="PTSet", setname="Consumable.Potion" }, },
	[L["Food"]] = { name=L["Food"], { type="PTSet", setname="Consumable.Food.Edible" }, },
	[L["Scrolls"]] = { name=L["Scrolls"], { type="PTSet", setname="Consumable.Scroll" }, },
	[L["FirstAid"]] = { name=L["FirstAid"], { type="PTSet", setname="Tradeskill.Crafted.First Aid" }, },
	[L["Water"]] = { name=L["Water"], { type="PTSet", setname="Consumable.Water" }, },
	[L["SoulBag"]] = { name=L["SoulBag"], { type="ContainerType", ctype="Soul Bag" }, },
	[L["Tradeskill Mats"]] = { name=L["Tradeskill Mats"], { type="PTSet", setname="Tradeskill.Mat.ByProfession" }, },
	[L["Gathered"]] = { name=L["Gathered"], { type="PTSet", setname="Tradeskill.Gather" }, },
	[L["New"]] = { { ["name"] = L["New"], ["type"] = "NewItems" }, },
}


--deep copy of a table, will NOT handle tables as keys or circular references
local function deepCopy(to, from)
	for k in pairs(to) do
		to[k] = nil
	end

	for k, v in pairs(from) do
		if type(v) == "table" then
			to[k] = {}
			deepCopy(to[k], from[k])
		else
			to[k] = from[k]
		end
	end
end

local wipe=wipe
local function new() return {} end
local function del(t) wipe(t) end
local rdel = del


---------------------
-- Dynamic Options --
---------------------
function Baggins:BuildMoneyBagOptions()
	local args = Baggins.opts.args.Layout.args.ShowMoney.args
	if not args then return end
	for i, v in ipairs(args) do
		del(v)
		args[i] = nil
	end
	
	for i, v in ipairs(Baggins.db.profile.bags) do
		local name = v.name
		if name=="" then name="(unnamed)" end
		local opt = new()
		opt.name = name
		opt.desc = name
		opt.type = "toggle"
		opt.passValue = i
		opt.order = i * 10
		opt.isRadio = true		
		args[i] = opt
	end
end


------------------------
-- Profile Management --
------------------------

function Baggins:ApplyProfile(profile)
	local p = self.db.profile
	self:CloseAllBags()
	for k, v in pairs(profile) do  
		if type(v) == "table" then
			if not p[k] then
				p[k] = {}
			end
			deepCopy(p[k],v)
		else
			p[k] = v
		end
	end 
	for k, v in pairs(self.defaultcategories) do
		if not p.categories[k] then
			p.categories[k] = {}
		end
		deepCopy(p.categories[k], v)
	end
	--tablet:Refresh("BagginsEditCategories")
	--tablet:Refresh("BagginsEditBags")
	self:RefreshEditWaterfall() 
	
	--self:RebuildSectionLayouts()
	self:ResortSections()
	self:ResetCatInUse()
	self:CreateAllBags()
	self:OpenAllBags()
	self:BuildWaterfallTree()
	self:ForceFullRefresh()
	self:BuildMoneyBagOptions()
end

function Baggins:SaveProfile(name)
	if not name then return end
	local src = self.db.profile
	local profiles = self.db.account.profiles
	if not profiles[name] then
		profiles[name] = {}
	end
	local dest = profiles[name]
	for k, v in pairs(src) do  
		if type(v) == "table" then
			if not dest[k] then
				dest[k] = {}
			end
			deepCopy(dest[k],v)
		else
			dest[k] = v
		end
	end
	
	self:RefreshProfileOptions()
end

function Baggins:RefreshProfileOptions()
	local loadargs = Baggins.opts.args.LoadProfile.args.UserDefined.args
	local saveargs = Baggins.opts.args.SaveProfile.args
	local deleteargs = Baggins.opts.args.DeleteProfile.args
	
	if not loadargs and saveargs and deleteargs then return end
	
	for i, v in ipairs(loadargs) do
		del(v)
		loadargs[i] = nil
	end
	for i, v in ipairs(saveargs) do
		del(v)
		saveargs[i] = nil
	end
	for i, v in ipairs(deleteargs) do
		del(v)
		deleteargs[i] = nil
	end
	
	local count = 1
	for k, v in pairs(Baggins.db.account.profiles) do
		local opt = new()
		opt.name = k
		opt.desc = L["Save"].." "..k
		opt.type = "execute"
		opt.passValue = k
		opt.order = count * 10	
		saveargs[count] = opt		
		
		opt = new()
		opt.name = k
		opt.desc = L["Load"].." "..k
		opt.type = "execute"
		opt.passValue = k
		opt.order = count * 10	
		loadargs[count] = opt		
		
		opt = new()
		opt.name = k
		opt.desc = L["Delete"].." "..k
		opt.type = "execute"
		opt.passValue = k
		opt.confirm = true
		opt.order = count * 10	
		deleteargs[count] = opt		
		count = count + 1
	end
end

function Baggins:OnProfileDisable()
	self:CloseAllBags()
end

function Baggins:OnProfileEnable()
	local p = self.db.profile
	--check if this profile has been setup before, if not add the default bags and categories
	--cant leave these in the defaults since removing a bag would have it come back on reload
	local catsexist
	for k in pairs(p.categories) do
		catsexist = true
		break
	end
	if not catsexist then
		deepCopy(p.categories, self.defaultcategories)
	end
	 if #p.bags == 0 then
		deepCopy(p.bags, self.profiles.default.bags)
	end	
	
	self:CreateAllBags()
	
	--convert old ItemID rules to tables
	for catname, cat in pairs(self.db.profile.categories) do
		for ruleid, rule in pairs(cat) do
			if rule.ids and type(rule.ids) == "string" then
				local tmp = {(" "):split(rule.ids)}
				rule.ids = {}
				for i, v in pairs(tmp) do
					rule.ids[tonumber(v)] = true
				end
			end
		end
	end
	
	self:SetCategoryTable(self.db.profile.categories)
	self:ResortSections()
	self:ForceFullRefresh()
	self:UpdateBags()
	self:BuildMoneyBagOptions()
	self:RefreshProfileOptions()
end

----------------------
-- Bag Context Menu --
----------------------

function Baggins:DoBagMenu(bagframe)
	local p = self.db.profile
	dewdrop:Open(bagframe, "children", 
		function(level, value, ...)
			local event = p.bags[bagframe.bagid].isBank and "Dewdrop_Bank" or "Dewdrop_Bag"
			
			-- Fire on-dropdown-menu events: see http://www.wowace.com/forums/index.php?topic=6533
			self:TriggerEvent(event, dewdrop, "TOP", bagframe)
			dewdrop:AddSeparator()
			
			self:TriggerEvent(event, dewdrop, "COMMON", bagframe)
			dewdrop:AddSeparator()
			
			if self.db.profile.highlightnew then
				dewdrop:AddLine("text", L["Reset New Items"], "tooltipText", L["Resets the new items highlights."], "closeWhenClicked",true,
					"func", function() self:SaveItemCounts() self:ForceFullUpdate() end)
			end
			
			if p.compressall or p.compressstackable or p.compressempty or p.compressshards or p.compressammo then
				dewdrop:AddLine("text", L["Disable Compression Temporarily"], "tooltipText", L["Disabled Item Compression until the bags are closed."], 				"closeWhenClicked",true,
					"func", function() self.tempcompressnone = not self.tempcompressnone; self:RebuildSectionLayouts(); self:UpdateBags()  end,
					"checked", self.tempcompressnone
				)
			end
			
			self:TriggerEvent(event, dewdrop, "NORMAL", bagframe);
			dewdrop:AddSeparator();
			
            if waterfall then
                dewdrop:AddLine("text", L["Bag/Category Config"], "tooltipText", L["Edit the Bag Definitions"], "closeWhenClicked",true,
				"func", function() waterfall:Open("BagginsEdit") end)
            end
			--
			self:TriggerEvent(event, dewdrop, "UNCOMMON", bagframe)

		end
	);
end

--------------------
-- Edit Rule Menu --
--------------------
function Baggins:RefreshEditWaterfall()
    if waterfall then
        waterfall:Refresh("BagginsEdit")
    end
end

function Baggins:setRuleOperation(rule,operation)
	rule.operation = operation
	Baggins:OnRuleChanged()
end

function Baggins:setRuleType(rule,type)
	rule.type = type
	Baggins:CleanRule(rule)
	Baggins:OnRuleChanged()
end

function Baggins:CreateRulesDewdrop(ruleindex, rule, level, value, valueN_1, valueN_2, valueN_3, valueN_4)
	if level == 1 then
		dewdrop:AddLine('text', L["Editing Rule"], 'isTitle', true)
		
		dewdrop:AddLine('text', L["Type"], 'hasArrow', true,'value',"Type")
		dewdrop:AddLine()
		if not rule.type or rule.type == "New" then
			dewdrop:AddLine('text', L["Select a rule type to create the rule"], "isTitle",true)
		else
			Baggins:OpenRuleDewdrop(rule, level, value, valueN_1, valueN_2, valueN_3, valueN_4)
			if ruleindex > 1 then
				dewdrop:AddSeparator()
				dewdrop:AddLine('text', L["Operation"], 'hasArrow', true,'value',"Operation")
			end
		end
	elseif level == 2 and value == "Type" then
		for ruletype, ruledef in Baggins:RuleTypeIterator(true) do
			dewdrop:AddLine('text', ruledef.DisplayName, "checked", rule.type == ruletype,
				"tooltipTitle", ruledef.DisplayName, "tooltipText", ruledef.Description,
				"func",self.setRuleType, "arg1", self, "arg2", rule, "arg3", ruletype)
		end
	elseif level == 2 and value == "Operation" then
		dewdrop:AddLine('text', L["AND"], "checked", rule.operation == "AND","func",self.setRuleOperation, "arg1", self, "arg2", rule, "arg3", "AND")
		dewdrop:AddLine('text', L["OR"], "checked", rule.operation == "OR" or rule.operation == nil,"func",self.setRuleOperation, "arg1", self, "arg2", rule, "arg3", "OR")
		dewdrop:AddLine('text', L["NOT"], "checked", rule.operation == "NOT","func",self.setRuleOperation, "arg1", self, "arg2", rule, "arg3", "NOT")
	else
		Baggins:OpenRuleDewdrop(rule, level, value, valueN_1, valueN_2, valueN_3, valueN_4)
	end
end


----------------------
-- Waterfall Config --
----------------------
local WaterfallTree = {
		{
			text = L["Bags"],
			id = "Bags",
			isOpen = true,
		},
		{
			text = L["Categories"],
			id = "Categories",
			isOpen = true,
		},
}

local function categoryCompare(a, b)
	return a.text:upper() < b.text:upper()
end

function Baggins:BuildWaterfallTree()
	local BagTree = WaterfallTree[1]
	local CatTree = WaterfallTree[2]
	
	for i, v in ipairs(BagTree) do
	    for i2, v2 in ipairs(v) do
	        del(v2)
	        v[i2] = nil
	    end
		del(v)
		BagTree[i] = nil
	end
	local newcatentry
	for i, v in ipairs(CatTree) do
		del(v)
		CatTree[i] = nil
	end
	
	for bagid, bag in ipairs(self.db.profile.bags) do
		local newEntry = new()
		newEntry.text = bag.name
		newEntry.id = "Bag"..bagid
		tinsert(BagTree, newEntry)
		
		for sectionid, section in ipairs(bag.sections) do
		    local secEntry = new()
		    secEntry.text = section.name
		    secEntry.id = ("Section%s:%s"):format(bagid,sectionid)
		    tinsert(newEntry,secEntry)
		end
	end
	
	for catid, cat in pairs(self.db.profile.categories) do
		local newEntry = new()
		newEntry.text = catid
		newEntry.id = "Category-"..catid
		tinsert(CatTree, newEntry)
	end
	
	table.sort(CatTree,categoryCompare)

end

local function sectionClick(bagid,sectionid) 
	if IsShiftKeyDown() then
		Baggins:MoveSection(bagid, sectionid)
	elseif IsAltKeyDown() then
		Baggins:MoveSection(bagid, sectionid, true)
	elseif IsControlKeyDown() then 
		Baggins:StartDeleteSection(bagid,sectionid) 
	else 
		currentsection = nil
	end 
	Baggins:RefreshEditWaterfall() 
end

local function sectionAddCategoryClick(bagid,sectionid) 
	dewdrop:Open(Baggins.dewdropparent, "children", 
	function()
			while #catsorttable > 0 do
				table.remove(catsorttable,#catsorttable)
			end
			for catid in pairs(Baggins.db.profile.categories) do
				table.insert(catsorttable,catid)
			end
			table.sort(catsorttable)

			for k, catid in ipairs(catsorttable) do
			dewdrop:AddLine("text",catid,"func",function(category) Baggins:AddCategory(bagid,sectionid,category) Baggins:RefreshEditWaterfall()  end,"arg1",catid,"closeWhenClicked",true)
		end
	end,
	'point', "TOPLEFT",
	'relativePoint', "TOPLEFT",
	'cursorX', true, "cursorY", true)
end

local CopyToBagID
local CopyToImport

local function CopyBag(bagid)
	local bags = Baggins.db.profile.bags
	
	if CopyToImport then
	    for i, v in ipairs(bags[bagid].sections) do
	        tinsert(bags[CopyToBagID].sections,v)
	    end
	else
    	local origName = bags[CopyToBagID].name
    	deepCopy(bags[CopyToBagID],bags[bagid])
    	bags[CopyToBagID].name = origName
    end
	
	Baggins:ResetCatInUse()
	Baggins:BuildWaterfallTree()
	Baggins:ForceFullRefresh()
	Baggins:UpdateBags()
	Baggins:UpdateLayout()
	Baggins:RefreshEditWaterfall() 
	dewdrop:Close()
end

local function CopyBagFromProfile(bagid,profile)
	local bags = Baggins.db.profile.bags
	
	if CopyToImport then
	    for i, v in ipairs(profile.bags[bagid].sections) do
	        tinsert(bags[CopyToBagID].sections,v)
	    end
	else
	    local origName = bags[CopyToBagID].name
		deepCopy(bags[CopyToBagID],profile.bags[bagid])
	    bags[CopyToBagID].name = origName
	end

	
	Baggins:ResetCatInUse()
	Baggins:BuildWaterfallTree()
	Baggins:ForceFullRefresh()
	Baggins:UpdateBags()
	Baggins:UpdateLayout()
	Baggins:RefreshEditWaterfall() 
	dewdrop:Close()
end

local function BagCopyFromDewdrop(level, value_1, value_2, value_3)
	local self = Baggins
	local p = self.db.profile
	local acct = self.db.account
	local bags = p.bags
	
	if level == 1 then
		for bagid, bag in ipairs(bags) do
			if bagid ~= CopyToBagID then
				dewdrop:AddLine("text",bag.name,"func",
					CopyBag,"arg1",bagid
				)
			end
		end
		dewdrop:AddLine("text",L["From Profile"],"value","Profiles","hasArrow",true)
	elseif level == 2 then
		if value_1 == "Profiles" then
			dewdrop:AddLine("text",L["Default"],"value","Default","hasArrow",true)
			dewdrop:AddLine("text",L["All In One"],"value","All In One","hasArrow",true)
			dewdrop:AddLine("text",L["All In One Sorted"],"value","All In One Sorted","hasArrow",true)
			dewdrop:AddLine("text",L["User"],"value","User","hasArrow",true)
		end
	elseif level == 3 then
		if value_2 == "Profiles" then
			if value_1 == "User" then
				for k, v in pairs(acct.profiles) do
					dewdrop:AddLine("text",k,"value",k,"hasArrow",true)
				end
			elseif value_1 == "All In One" then
				for bagid, bag in ipairs(self.profiles.allinone.bags) do
					dewdrop:AddLine("text",bag.name,"func",
						CopyBagFromProfile,"arg1",bagid,"arg2",self.profiles.allinone
					)
				end
			elseif value_1 == "All In One Sorted" then
				for bagid, bag in ipairs(self.profiles.allinonesorted.bags) do
					dewdrop:AddLine("text",bag.name,"func",
						CopyBagFromProfile,"arg1",bagid,"arg2",self.profiles.allinonesorted
					)
				end
			elseif value_1 == "Default" then
				for bagid, bag in ipairs(self.profiles.default.bags) do
					dewdrop:AddLine("text",bag.name,"func",
						CopyBagFromProfile,"arg1",bagid,"arg2",self.profiles.default
					)
				end
			end			
		end
	elseif level == 4 then
		if value_3 == "Profiles" then
			if value_2 == "User" then
				local profile = acct.profiles[value_1]
				if profile then
					for bagid, bag in ipairs(profile.bags) do
						dewdrop:AddLine("text",bag.name,"func",
							CopyBagFromProfile,"arg1",bagid,"arg2",profile
						)
					end
				end
			end
		end
	end
end

local function OpenBagCopyFromDewdrop(bagid, import)
	CopyToBagID = bagid
	CopyToImport = import
	dewdrop:Open(Baggins.dewdropparent, "children", 
	BagCopyFromDewdrop,
	'point', "TOPLEFT",
	'relativePoint', "TOPLEFT",
	'cursorX', true, "cursorY", true)
end

local newcatname = ""

local function WaterfallChildren(id)
	if not id then
		return "Select a Bag/Category"
	end
	
	local p = Baggins.db.profile
	local bags = p.bags
	local categories = p.categories
	
	if id == "Bags" then
		for bagid, bag in ipairs(bags) do

			waterfall:AddControl("type","textbox","width",200,"setOnTextChanged",true,
			"getFunc",function(bag) return bag.name end,"getArg1",bag,
			"setFunc",function(bag, bagid, value) bag.name = value if WaterfallTree[1][bagid] then WaterfallTree[1][bagid].text = value end end,"setArg1",bag,"setArg2",bagid)
			
			waterfall:AddControl("type","button","text","^","noNewLine",true,"width",25,"fullRefresh",true,
							"execFunc",Baggins.MoveBag,
							"execArg1",Baggins,"execArg2",bagid)
			waterfall:AddControl("type","button","text","v","noNewLine",true,"width",25,"fullRefresh",true,
							"execFunc",Baggins.MoveBag,
							"execArg1",Baggins,"execArg2",bagid,"execArg3",true)
							
			waterfall:AddControl("type","button","text","X","noNewLine",true,"width",25,"fullRefresh",true,
							"execFunc",Baggins.RemoveBag,"confirm",L["Are you sure you want to delete this Bag? this cannot be undone"],
							"execArg1",Baggins,"execArg2",bagid)
		end
		waterfall:AddControl("type","label")
		waterfall:AddControl("type","button","text",L["New Bag"],"noNewLine",true,"width",150,"fullRefresh",true,
								"execFunc",Baggins.NewBag,
								"execArg1",Baggins,"execArg2","New")
		return L["Bags"]
	elseif id == "Categories" then
		waterfall:AddControl("type","label","text",L["Name"]..":")
			waterfall:AddControl("type","textbox","width",150,"noNewLine",true,
			"getFunc",function() return newcatname or "" end,
			"setFunc",function(value) newcatname = value if newcatname ~= "" then Baggins:NewCategory(newcatname) end waterfall:Open("BagginsEdit","Category-"..newcatname) newcatname = "" end,
			"changedFunc",function(value) newcatname = value end)
		waterfall:AddControl("type","button","text",L["Create"],"width",100,"noNewLine",true,
			"execFunc",function() if newcatname ~= "" then Baggins:NewCategory(newcatname) waterfall:Open("BagginsEdit","Category-"..newcatname) newcatname = "" end end)
	else
		
		local bagid = id:match("Bag(%d+)")
		if bagid then
			bagid = tonumber(bagid)
			local bag = bags[bagid]

			waterfall:AddControl("type","label","text",L["Name"]..":")
			waterfall:AddControl("type","textbox","width",200,"setOnTextChanged",true,
			"getFunc",function(bag) return bag.name end,"getArg1",bag,
			"setFunc",function(bag, bagid, value) bag.name = value if WaterfallTree[1][bagid] then WaterfallTree[1][bagid].text = value end end,"setArg1",bag,"setArg2",bagid,"noNewLine",true)
			waterfall:AddControl("type","label")
			waterfall:AddControl("type","button","text",L["Copy From"].." >",
				"execFunc",OpenBagCopyFromDewdrop,"execArg1",bagid,"width",150)
            waterfall:AddControl("type","button","text",L["Import Sections From"].." >",
				"execFunc",OpenBagCopyFromDewdrop,"execArg1",bagid,"execArg2",true,"width",150)
			waterfall:AddControl("type","label")            
			waterfall:AddControl("type","slider","text",L["Bag Priority"],"width",150,"min",1,"max",20,"step",1,
				"getFunc",function(bag) return bag.priority or 1 end,"getArg1",bag,
				"setFunc",function(bag, value) bag.priority = value Baggins:ResortSections() Baggins:UpdateBags() end,"setArg1",bag)
			waterfall:AddControl("type","checkbox","text",L["Bank"],"width",300,"fullRefresh",true,
				"getFunc",function(bag) return bag.isBank end,"getArg1",bag,
				"setFunc",function(bag, value) bag.isBank = value end,"setArg1",bag)
			waterfall:AddControl("type","checkbox","text",L["Open With All"],"width",300,"fullRefresh",true,
				"getFunc",function(bag) return bag.openWithAll end,"getArg1",bag,
				"setFunc",function(bag, value) bag.openWithAll = value end,"setArg1",bag)
				
			waterfall:AddControl("type","label")
			waterfall:AddControl("type","heading","text",L["Sections"])
			for sectionid, section in ipairs(bag.sections) do
			
				waterfall:AddControl("type","textbox","width",200,"setOnTextChanged",true,
				"getFunc",function(section) return section.name end,"getArg1",section,
				"setFunc",function(section, value) section.name = value end,"setArg1",section)
				
                waterfall:AddControl("type","button","text",L["Edit"],"noNewLine",true,"width",50,"fullRefresh",true,
					"execFunc",function(bagid,sectionid) 
								waterfall:Open("BagginsEdit", ("Section%s:%s"):format(bagid,sectionid))
					    end,
					    "execArg1",bagid,"execArg2",sectionid)
    				
				waterfall:AddControl("type","button","text","^","noNewLine",true,"width",25,"fullRefresh",true,
								"execFunc",Baggins.MoveSection,
								"execArg1",Baggins,"execArg2",bagid,"execArg3",sectionid)
				waterfall:AddControl("type","button","text","v","noNewLine",true,"width",25,"fullRefresh",true,
								"execFunc",Baggins.MoveSection,
								"execArg1",Baggins,"execArg2",bagid,"execArg3",sectionid,"execArg4",true)
								
				waterfall:AddControl("type","button","text","X","noNewLine",true,"width",25,"fullRefresh",true,
								"execFunc",Baggins.RemoveSection,"confirm",L["Are you sure you want to delete this Section? this cannot be undone"],
								"execArg1",Baggins,"execArg2",bagid,"execArg3",sectionid)
			end
			
			waterfall:AddControl("type","button","text",L["New Section"],"width",150,"fullRefresh",true,
								"execFunc",Baggins.NewSection,
								"execArg1",Baggins,"execArg2",bagid,"execArg3","New")
			
			return bag.name
		end
		
		local bagid, sectionid = id:match("Section(%d+):(%d+)")
		bagid = tonumber(bagid)
		sectionid = tonumber(sectionid)
		if bagid and sectionid then
            local bag = bags[tonumber(bagid)]
            local section = bag.sections[tonumber(sectionid)]
            if bag and section then
    	        waterfall:AddControl("type","label","text",L["Name"]..":")
    			waterfall:AddControl("type","textbox","width",200,"setOnTextChanged",true,
    			"getFunc",function(section) return section.name end,"getArg1",section,
    			"setFunc",function(section, value) section.name = value end,"setArg1",section,"noNewLine",true)
    			

    						
    			waterfall:AddControl("type","slider","text",L["Section Priority"],"width",150,"min",1,"max",20,"step",1,
    				"getFunc",function(bag) return section.priority or 1 end,"getArg1",section,
    				"setFunc",function(bag, value) section.priority = value Baggins:ResortSections() Baggins:UpdateBags() end,"setArg1",section)
    			waterfall:AddControl("type","checkbox","text",L["Allow Duplicates"],
    				"getFunc",function(bag) return section.allowdupes end,"getArg1",section,
    				"setFunc",function(bag, value) section.allowdupes = value Baggins:ResortSections() Baggins:ForceFullRefresh() Baggins:UpdateBags() end,"setArg1",section)
    			waterfall:AddControl("type","label","width",20)
    			waterfall:AddControl("type","heading","text",L["Categories"],"width",120,"noNewLine",true)
    
    			for categoryid, category in ipairs(section.cats) do
    				waterfall:AddControl("type","label","width",50)
    				waterfall:AddControl("type","linklabel","text",category,"noNewLine",true,"width",150,
    				"linkFunc",function(cat) waterfall:Open("BagginsEdit","Category-"..cat) end,"linkArg1",category)
    			waterfall:AddControl("type","linklabel","text","Remove","noNewLine",true,"r",1,"g",0.82,"b",0,
    				"linkFunc",Baggins.RemoveCategory,"confirm",L["Are you sure you want to remove this Category? this cannot be undone"],"fullRefresh",true,
    				"linkArg1",Baggins,"linkArg2",bagid,"linkArg3",sectionid,"linkArg4",categoryid)
    			end
    			waterfall:AddControl("type","label","width",50)
    			waterfall:AddControl("type","linklabel","text",L["Add Category"],"noNewLine",true,"r",1,"g",0.82,"b",0,
    					"linkFunc",sectionAddCategoryClick,
    					"linkArg1",bagid,"linkArg2",sectionid,"fullRefresh",true)
    					
    		    return ("%s - %s"):format(bag.name, section.name)
    		end
		end
		local catname = id:match("Category%-(.+)")
		if catname then
			local category = categories[catname]
			if not category then return "Invalid Category" end
			
			waterfall:AddControl("type","button","text",L["Delete"],
				"execFunc",Baggins.RemoveCategory,"execArg1",Baggins,"execArg2",catname,
				"confirm",L["Are you sure you want to remove this Category? this cannot be undone"],
				"disabled",Baggins.CategoryInUse,"disabledArg1",Baggins,"disabledArg2",catname)
			waterfall:AddControl("type","heading","text",L["Rules"])
			for ruleid, rule in ipairs(category) do
				local rulename
				if rule.type == "New" then
					rulename = L["New Rule"]
				else
					rulename = Baggins:GetRuleDesc(rule)
				end
				if ruleid > 1 then
					rulename = (rule.operation or "OR").." "..rulename
				end
				waterfall:AddControl("type","label","text",rulename,"width",170)
				waterfall:AddControl("type","button","text",L["Edit"],"noNewLine",true,"width",50,"fullRefresh",true,
					"execFunc",function(ruleid,rule) 
								dewdrop:Open(Baggins.dewdropparent, "children", function(...) Baggins:CreateRulesDewdrop(ruleid, rule, ...) end,
															'point', "TOPLEFT",
															'relativePoint', "TOPLEFT",
															'cursorX', true, "cursorY", true)
					end,
					"execArg1",ruleid,"execArg2",rule)
				waterfall:AddControl("type","button","text","^","noNewLine",true,"width",25,"fullRefresh",true,
								"execFunc",Baggins.MoveRule,
								"execArg1",Baggins,"execArg2",catname,"execArg3",ruleid)
				waterfall:AddControl("type","button","text","v","noNewLine",true,"width",25,"fullRefresh",true,
								"execFunc",Baggins.MoveRule,
								"execArg1",Baggins,"execArg2",catname,"execArg3",ruleid,"execArg4",true)
								
				waterfall:AddControl("type","button","text","X","noNewLine",true,"width",25,"fullRefresh",true,
								"execFunc",Baggins.RemoveRule,"confirm","Are You Sure?",
								"execArg1",Baggins,"execArg2",catname,"execArg3",ruleid)
			end
			waterfall:AddControl("type","button","text",L["Add Rule"],"textR",0.2,"textG",1,"textB",0.5,
					"execFunc",function(category) 
							table.insert(category, { type="New" })
					end,
					"execArg1",category,"width",80,"fullRefresh",true)
			waterfall:AddControl("type","label")
			
			return catname
		end
	end
	
	return id
end

function Baggins:RegisterWaterfall()
    if waterfall then
    	waterfall:Register("BagginsEdit","tree",WaterfallTree,"children",WaterfallChildren,"title","Baggins Bag/Category Editor","width",650)
    	waterfall:Register("Baggins","aceOptions",self.opts,"treeLevels",2,'colorR',0.5,'colorG',0.7,'colorB',1)
    end
end