local sizeScale = 0.8;
local longSide = 256 * sizeScale;
local shortSide = 128 * sizeScale;

function CheeseSpellActivationOverlay_OnLoad(self)
	self.overlaysInUse = {};
	self.unusedOverlays = {};
	
	Cheese_RegisterEvent("CHEESE_SPELL_ACTIVATION_OVERLAY_SHOW", self, CheeseSpellActivationOverlay_OnEventOverlayShow);
	Cheese_RegisterEvent("CHEESE_SPELL_ACTIVATION_OVERLAY_HIDE", self, CheeseSpellActivationOverlay_OnEventOverlayHide);
	
	self:SetSize(longSide, longSide)
end

function CheeseSpellActivationOverlay_OnEventOverlayShow(self, spellID, texture, positions, scale, r, g, b)
	if ( cheeseDisplaySpellActivationOverlays ~= "0" ) then 
		CheeseSpellActivationOverlay_ShowAllOverlays(self, spellID, texture, positions, scale, r, g, b)
	end
end

function CheeseSpellActivationOverlay_OnEventOverlayHide(self, spellID)
	if ( spellID ) then
		CheeseSpellActivationOverlay_HideOverlays(self, spellID);
	else
		CheeseSpellActivationOverlay_HideAllOverlays(self);
	end
end

local complexLocationTable = {
	["RIGHT (FLIPPED)"] = {
		RIGHT = {	hFlip = true },
	},
	["BOTTOM (FLIPPED)"] = {
		BOTTOM = { vFlip = true },
	},
	["LEFT + RIGHT (FLIPPED)"] = {
		LEFT = {},
		RIGHT = { hFlip = true },
	},
	["TOP + BOTTOM (FLIPPED)"] = {
		TOP = {},
		BOTTOM = { vFlip = true },
	},
}

function CheeseSpellActivationOverlay_ShowAllOverlays(self, spellID, texturePath, positions, scale, r, g, b)
	positions = strupper(positions);
	if ( complexLocationTable[positions] ) then
		for location, info in pairs(complexLocationTable[positions]) do
			CheeseSpellActivationOverlay_ShowOverlay(self, spellID, texturePath, location, scale, r, g, b, info.vFlip, info.hFlip);
		end
	else
		CheeseSpellActivationOverlay_ShowOverlay(self, spellID, texturePath, positions, scale, r, g, b, false, false);
	end
end

function CheeseSpellActivationOverlay_ShowOverlay(self, spellID, texturePath, position, scale, r, g, b, vFlip, hFlip)
	local overlay = CheeseSpellActivationOverlay_GetOverlay(self, spellID, position);
	overlay.spellID = spellID;
	overlay.position = position;
	
	overlay:ClearAllPoints();
	
	local texLeft, texRight, texTop, texBottom = 0, 1, 0, 1;
	if ( vFlip ) then
		texTop, texBottom = 1, 0;
	end
	if ( hFlip ) then
		texLeft, texRight = 1, 0;
	end
	overlay.texture:SetTexCoord(texLeft, texRight, texTop, texBottom);
	
	local width, height;
	if ( position == "CENTER" ) then
		width, height = longSide, longSide;
		overlay:SetPoint("CENTER", self, "CENTER", 0, 0);
	elseif ( position == "LEFT" ) then
		width, height = shortSide, longSide;
		overlay:SetPoint("RIGHT", self, "LEFT", 0, 0);
	elseif ( position == "RIGHT" ) then
		width, height = shortSide, longSide;
		overlay:SetPoint("LEFT", self, "RIGHT", 0, 0);
	elseif ( position == "TOP" ) then
		width, height = longSide, shortSide;
		overlay:SetPoint("BOTTOM", self, "TOP");
	elseif ( position == "BOTTOM" ) then
		width, height = longSide, shortSide;
		overlay:SetPoint("TOP", self, "BOTTOM");
	elseif ( position == "TOPRIGHT" ) then
		width, height = shortSide, shortSide;
		overlay:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 0, 0);
	elseif ( position == "TOPLEFT" ) then
		width, height = shortSide, shortSide;
		overlay:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 0, 0);
	elseif ( position == "BOTTOMRIGHT" ) then
		width, height = shortSide, shortSide;
		overlay:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", 0, 0);
	elseif ( position == "BOTTOMLEFT" ) then
		width, height = shortSide, shortSide;
		overlay:SetPoint("TOPRIGHT", self, "BOTTOMLEFT", 0, 0);
	else
		--GMError("Unknown SpellActivationOverlay position: "..tostring(position));
		return;
	end
	
	overlay:SetSize(width * scale, height * scale);
	
	overlay.texture:SetTexture(texturePath);
	overlay.texture:SetVertexColor(r / 255, g / 255, b / 255);
	
	overlay.animOut:Stop();	--In case we're in the process of animating this out.
	--PlaySoundKitID(23287);
	overlay:Show();
end

function CheeseSpellActivationOverlay_GetOverlay(self, spellID, position)
	local overlayList = self.overlaysInUse[spellID];
	local overlay;
	if ( overlayList ) then
		for i=1, #overlayList do
			if ( overlayList[i].position == position ) then
				overlay = overlayList[i];
			end
		end
	end
	
	if ( not overlay ) then
		overlay = CheeseSpellActivationOverlay_GetUnusedOverlay(self);
		if ( overlayList ) then
			tinsert(overlayList, overlay);
		else
			self.overlaysInUse[spellID] = { overlay };
		end
	end
	
	return overlay;
end

function CheeseSpellActivationOverlay_HideOverlays(self, spellID)
	local overlayList = self.overlaysInUse[spellID];
	if ( overlayList ) then
		for i=1, #overlayList do
			local overlay = overlayList[i];
			overlay.pulse:Pause();
			overlay.animOut:Play();
		end
	end
end

function CheeseSpellActivationOverlay_HideAllOverlays(self)
	for spellID, overlayList in pairs(self.overlaysInUse) do
		CheeseSpellActivationOverlay_HideOverlays(self, spellID);
	end
end

function CheeseSpellActivationOverlay_GetUnusedOverlay(self)
	local overlay = tremove(self.unusedOverlays, #self.unusedOverlays);
	if ( not overlay ) then
		overlay = CheeseSpellActivationOverlay_CreateOverlay(self);
	end
	return overlay;
end

function CheeseSpellActivationOverlay_CreateOverlay(self)
	return CreateFrame("Frame", nil, self, "CheeseSpellActivationOverlayTemplate");
end

function CheeseSpellActivationOverlayTexture_OnShow(self)
	self.animIn:Play();
end

function CheeseSpellActivationOverlayTexture_OnFadeInPlay(animGroup)
	animGroup:GetParent():SetAlpha(0);
end

function CheeseSpellActivationOverlayTexture_OnFadeInFinished(animGroup)
	local overlay = animGroup:GetParent();
	overlay:SetAlpha(1);
	overlay.pulse:Play();
end

function CheeseSpellActivationOverlayTexture_OnFadeOutFinished(anim)
	CheeseAlphaTemplate_OnFinished(anim);
	local overlay = anim:GetRegionParent();
	local overlayParent = overlay:GetParent();
	overlay.pulse:Stop();
	overlay:Hide();
	tDeleteItem(overlayParent.overlaysInUse[overlay.spellID], overlay)
	tinsert(overlayParent.unusedOverlays, overlay);
end
