local Baggins = Baggins

----------------
-- Skin stuff --
----------------

do -- private
	local skins = {}
	local skinlist = {}
	local function void() end

	function Baggins:GetSkinList()
		for k in pairs(skinlist) do
			skinlist[k] = nil
		end
		for name in pairs(skins) do
			table.insert(skinlist, name)
		end
		return skinlist
	end
	
	function Baggins:GetSkin(name)
		return skins[name]
	end
	
	function Baggins:RegisterSkin(name, skin)
		skin.core = self
		skin.name = skin.name or name
		skin.SkinSection = skin.SkinSection or void
		skin.SkinItem = skin.SkinItem or void
		skin.SkinBag = skin.SkinBag or void
		skin.UnskinSection = skin.UnskinSection or void
		skin.UnskinItem = skin.UnskinItem or void
		skin.UnskinBag = skin.UnskinBag or void
		skins[name] = skin
	end

end

function Baggins:DisableSkin(name)
	local oldskin = self:GetSkin(name)
	if oldskin and self.currentSkin == oldskin then
		for bagid,bagframe in ipairs(self.bagframes) do
			for secid,sectionframe in ipairs(bagframe.sections) do
				for itemid,itemframe in ipairs(sectionframe.items) do
					oldskin:UnskinItem(itemframe)
				end
				oldskin:UnskinSection(sectionframe)
			end
			oldskin:UnskinBag(bagframe)
		end
		self.currentSkin = nil
	end
end

function Baggins:EnableSkin(name)
	local newskin = self:GetSkin(name)
	if newskin and self.currentSkin ~= newskin then
		for bagid,bagframe in ipairs(self.bagframes) do
			for secid,sectionframe in ipairs(bagframe.sections) do
				for itemid,itemframe in ipairs(sectionframe.items) do
					newskin:SkinItem(itemframe)
				end
				newskin:SkinSection(sectionframe)
				sectionframe.dirty = true
			end
			newskin:SkinBag(bagframe)
			bagframe.dirty = true
		end
		self.currentSkin = newskin
		self:UpdateBags()
	end
end

function Baggins:ApplySkin(name)
	if name ~= self.db.profile.skin and self:GetSkin(name) then
		self:DisableSkin(self.db.profile.skin)
		self.db.profile.skin = name
		self:EnableSkin(name)
	end
end

------------------
-- Default Skin --
------------------
 
local defaultSkin = {

	BagLeftPadding = 10,
	BagRightPadding = 10,
	BagTopPadding = 32,
	BagBottomPadding = 10,
	TitlePadding = 32+48,
	SectionTitleHeight = 13,
	
	EmptySlotTexture = false,

	BagFrameBackdrop = {
		bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
		tile = true, tileSize = 16, edgeSize = 16, 
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	},
	
	NormalBagColor = 'black',
	BankBagColor = 'blue',
	
}
	
function defaultSkin:SkinBag(frame)
	frame:SetBackdrop(self.BagFrameBackdrop)

	frame.closebutton:SetPoint("TOPRIGHT",frame,"TOPRIGHT",0,0)
	
	frame.compressbutton:ClearAllPoints();
	frame.compressbutton:SetPoint("TOPRIGHT", frame.closebutton, "TOPLEFT", -4, -2);
	
	frame.title:SetVertexColor(1,1,1,1)
	frame.title:ClearAllPoints()
	-- double anchoring is required to resize bag properly
	frame.title:SetPoint("TOPLEFT",frame,"TOPLEFT",10,-10)
	frame.title:SetPoint("RIGHT",frame.closebutton,"LEFT",0,0)
	frame.title:SetHeight(12)
	frame.title:SetJustifyH('LEFT')
end

function defaultSkin:SetBankVisual(frame, isBank)
	local color = self.core.colors[self.NormalBagColor]
	if isBank then
		color = self.core.colors[self.BankBagColor]
	end
	frame:SetBackdropColor(color.r, color.g, color.b)
end

function defaultSkin:SkinSection(frame)
	frame.title:SetVertexColor(1,1,1,1)
	frame.title:SetText("")
	frame.title:SetPoint("TOPLEFT",frame,"TOPLEFT",0,0)
	frame.title:SetHeight(13)
end

Baggins:RegisterSkin('default', defaultSkin)

------------------------
-- Blizzard-like Skin --
------------------------

local blizzardSkin = setmetatable({

	EmptySlotTexture = 'Interface\\AddOns\\Baggins\\Textures\\EmptySlot',

	BagLeftPadding = 12,
	BagRightPadding = 11,
	BagTopPadding = 50,
	BagBottomPadding = 11,
	TitlePadding = 80,

	BagFrameBackdrop = {
		bgFile = 'Interface\\AddOns\\Baggins\\Textures\\AltBG', 
		edgeFile = 'Interface\\AddOns\\Baggins\\Textures\\BagFrameBorder', 
		tile = true, tileSize = 256, edgeSize = 32, 
		insets = { left = 7, right = 6, top = 7, bottom = 6 }
	},

	NormalBagColor = 'white',

}, {__index = defaultSkin}) -- inherits from defaultSkin

function blizzardSkin:SkinBag(frame)
	frame:SetBackdrop(self.BagFrameBackdrop)
	
	frame.closebutton:SetPoint("TOPRIGHT",frame,"TOPRIGHT",0,-1)
	
	frame.compressbutton:ClearAllPoints();
	frame.compressbutton:SetPoint("TOPRIGHT", frame.closebutton, "BOTTOMRIGHT", -12, 8);
	
	
	if not frame.portrait then
		frame.portrait = frame:CreateTexture(frame:GetName().."Portrait","OVERLAY")
		frame.portrait:SetWidth(48)
		frame.portrait:SetHeight(48)
		frame.portrait:SetPoint("TOPLEFT", frame, "TOPLEFT", -4, 0)
		frame.portrait:SetTexture('Interface\\AddOns\\Baggins\\Textures\\BagFramePortraitFrame')
		frame.portrait:SetTexCoord(0, 0.745, 0, 0.745)
	end
	frame.portrait:Show()

	frame.title:ClearAllPoints()
	frame.title:SetVertexColor(1,1,1,1)
	-- double anchoring is required to resize bag properly
	frame.title:SetPoint("LEFT",frame.portrait,"RIGHT",0,0)
	frame.title:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-33,-9)
	frame.title:SetHeight(12)
	frame.title:SetJustifyH('RIGHT')

	if not frame.icon then
		frame.icon = frame:CreateTexture(frame:GetName().."Icon","ARTWORK")
		frame.icon:SetWidth(34)
		frame.icon:SetHeight(34)
		frame.icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, -5)
		frame.icon:SetTexture("Interface\\Icons\\INV_Jewelry_Ring_03")
	end
	frame.icon:Show()
	
end

function blizzardSkin:UnskinBag(frame)
	frame.portrait:Hide()
	frame.icon:Hide()
end

function blizzardSkin:SetBankVisual(frame, isBank)
	local color = self.core.colors[self.NormalBagColor]
	if isBank then
		color = self.core.colors[self.BankBagColor]
	end
	frame:SetBackdropColor(color.r, color.g, color.b)
	frame:SetBackdropBorderColor(color.r, color.g, color.b)
	frame.portrait:SetVertexColor(color.r, color.g, color.b)
end


Baggins:RegisterSkin('blizzard', blizzardSkin)

------------------------
-- oSkin-like Skin --
------------------------

local oSkin = setmetatable({}, {__index = defaultSkin}) -- inherits from defaultSkin

function oSkin:SkinBag(frame)
	defaultSkin.SkinBag(self, frame) -- call inherited skinning
	
	if not frame.tfade then 
		frame.tfade = frame:CreateTexture(nil, 'BORDER') 
		frame.tfade:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
		frame.tfade:SetPoint('TOPLEFT', frame, 'TOPLEFT',1,-1)
		frame.tfade:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT',-1,1)
		frame.tfade:SetBlendMode('ADD')
		frame.tfade:SetGradientAlpha('VERTICAL', .1, .1, .1, 0, .2, .2, .2, 0.6)
		frame.tfade:SetPoint('TOPLEFT', frame, 'TOPLEFT', 6, -6)
		frame.tfade:SetPoint('BOTTOMRIGHT', frame, 'TOPRIGHT', -6, -30)
	end
	frame.tfade:Show()
	
end

function oSkin:UnskinBag(frame)
	frame.tfade:Hide()
end

Baggins:RegisterSkin('oSkin', oSkin)