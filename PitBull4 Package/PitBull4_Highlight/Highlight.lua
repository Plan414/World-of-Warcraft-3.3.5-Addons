if select(6, GetAddOnInfo("PitBull4_" .. (debugstack():match("[o%.][d%.][u%.]les\\(.-)\\") or ""))) ~= "MISSING" then return end

local PitBull4 = _G.PitBull4
if not PitBull4 then
	error("PitBull4_Highlight requires PitBull4")
end

local L = PitBull4.L

local PitBull4_Highlight = PitBull4:NewModule("Highlight", "AceEvent-3.0")

PitBull4_Highlight:SetModuleType("custom")
PitBull4_Highlight:SetName(L["Highlight"])
PitBull4_Highlight:SetDescription(L["Show a highlight when hovering or targeting."])
PitBull4_Highlight:SetDefaults({
	color = { 1, 1, 1, 1 },
	show_target = true,
	while_hover = true,
})

local EXEMPT_UNITS = {}
for i = 1, 5 do
	EXEMPT_UNITS[("target"):rep(i)] = true
end

local target_guid = nil
local mouse_focus = nil
function PitBull4_Highlight:OnEnable()
	self:AddFrameScriptHook("OnEnter")
	self:AddFrameScriptHook("OnLeave")
	
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	
	self:PLAYER_TARGET_CHANGED()
end

function PitBull4_Highlight:OnDisable()
	self:RemoveFrameScriptHook("OnEnter")
	self:RemoveFrameScriptHook("OnLeave")
end

function PitBull4_Highlight:UpdateFrame(frame)
	local highlight = frame.Highlight
	
	if not self:ShouldShow(frame) then
		if highlight then
			highlight:Hide()
		end
		return false
	end

	if not highlight then
		highlight = PitBull4.Controls.MakeFrame(frame)
		frame.Highlight = highlight
		highlight:SetAllPoints(frame)
		highlight:SetFrameLevel(frame:GetFrameLevel() + 17)
	
		local texture = PitBull4.Controls.MakeTexture(highlight, "OVERLAY")
		highlight.texture = texture
		texture:SetTexture([=[Interface\QuestFrame\UI-QuestTitleHighlight]=])
		texture:SetBlendMode("ADD")
		texture:SetAlpha(0.5)
		texture:SetAllPoints(highlight)
		texture:SetVertexColor(unpack(self:GetLayoutDB(frame).color))
	end

	highlight:Show()
	
	return false
end

function PitBull4_Highlight:ClearFrame(frame)
	if not frame.Highlight then
		return false
	end
	
	frame.Highlight.texture = frame.Highlight.texture:Delete()
	frame.Highlight = frame.Highlight:Delete()
	
	return false
end

function PitBull4_Highlight:OnEnter(frame)
	mouse_focus = frame
	self:Update(frame)
end

function PitBull4_Highlight:OnLeave(frame)
	mouse_focus = nil
	self:Update(frame)
end

function PitBull4_Highlight:ShouldShow(frame)
	local db = self:GetLayoutDB(frame)
	
	if mouse_focus == frame and db.while_hover then
		return true
	end
	
	if not target_guid or frame.guid ~= target_guid or EXEMPT_UNITS[frame.unit] then
		return false
	end
	
	if not db.show_target then
		return false
	end
	
	return true
end

function PitBull4_Highlight:PLAYER_TARGET_CHANGED()
	target_guid = UnitGUID("target")
	
	self:UpdateAll()
end

PitBull4_Highlight:SetLayoutOptionsFunction(function(self)
	return 'color', {
		type = 'color',
		name = L["Color"],
		desc = L["Color that the highlight should be."],
		hasAlpha = true,
		get = function(info)
			return unpack(PitBull4.Options.GetLayoutDB(self).color)
		end,
		set = function(info, r, g, b, a)
			local color = PitBull4.Options.GetLayoutDB(self).color
			color[1], color[2], color[3], color[4] = r, g, b, a

			-- Individually update the color for the layout that's changing color
			-- since we only bother to set the color on creation of the highlight
			-- frame.
			local layout = PitBull4.Options.GetCurrentLayout()
			for frame in PitBull4:IterateFramesForLayout(layout, true) do
				local texture = frame.Highlight and frame.Highlight.texture
				if texture then
					texture:SetVertexColor(r, g, b, a)
				end
			end
		end,
	}, 'show_target', {
		type = 'toggle',
		name = L["When targetted"],
		desc = L["Highlight this unit frame when it is the same as your current target."],
		get = function(info)
			return PitBull4.Options.GetLayoutDB(self).show_target
		end,
		set = function(info, value)
			PitBull4.Options.GetLayoutDB(self).show_target = value
			
			self:PLAYER_TARGET_CHANGED()
		end,
	}, 'while_hover', {
		type = 'toggle',
		name = L["On mouse hover"],
		desc = L["Highlight this unit frame while the mouse hovers over it."],
		get = function(info)
			return PitBull4.Options.GetLayoutDB(self).while_hover
		end,
		set = function(info, value)
			PitBull4.Options.GetLayoutDB(self).while_hover = value

			PitBull4.Options.UpdateFrames()
		end,
	}
end)
