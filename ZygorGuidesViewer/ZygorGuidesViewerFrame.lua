--ZYGORGUIDESVIEWERFRAME_TITLE = "Zygor Guides Viewer";

local ZGV = ZygorGuidesViewer
if not ZGV then return end

local doborderrgb = function(self)
	local progress = 1.0 - self:GetProgress()
	self.target:SetBackdropBorderColor(
		self.tor+(self.fromr-self.tor)*progress,
		self.tog+(self.fromg-self.tog)*progress,
		self.tob+(self.fromb-self.tob)*progress,
		self.toa+(self.froma-self.toa)*progress
	)
end

local obscured


local function Step_OnClick(self,button)
	if ZGV.CurrentStep==self.step then
		for i=1,20,1 do
			if MouseIsOver(self.lines[i].clicker) then self.lines[i].clicker:GetScript("OnClick")(self.lines[i].clicker,button) end
		end
		return
	end
	if not ZGV.CurrentGuide.steps[self.stepnum]
	or not ZGV.CurrentGuide.steps[self.stepnum]:AreRequirementsMet() then return end
	if not ZGV.db.profile.showallsteps then return end
	ZGV.pause = true
	ZGV:Debug("pausing in onclick")
	ZGV:FocusStep(self.stepnum)
end

local function Step_OnUpdate(self,button)
	if ZGV.CurrentStep==self.step then
		local clicker
		for i=1,20,1 do
			clicker=self.lines[i].clicker
			if clicker.over and not MouseIsOver(clicker) then
				clicker:GetScript("OnLeave")(clicker)
				clicker.over=false
			end
		end
		-- ugly! but first leave's, then enter's.
		obscured = (GetMouseFocus()~=WorldFrame and GetMouseFocus()~=self)

		for i=1,20,1 do
			clicker=self.lines[i].clicker
			if clicker:IsVisible() and MouseIsOver(clicker) and not clicker.over and not obscured then
				clicker:GetScript("OnEnter")(clicker)
				clicker.over=true
			end
		end
	end
end

local function clicker_onclick(self,button)
	ZGV:GoalOnClick(self,button)
end
local function clicker_onenter(self)
	ZGV:GoalOnEnter(self)
end
local function clicker_onleave(self)
	ZGV:GoalOnLeave(self)
end
	
function ZygorGuidesViewerFrame_Step_Setup(num)
	local function obj(name) return _G['ZygorGuidesViewerFrame_Step'..num..(name and '_'..name or '')] end

	local stepname = 'ZygorGuidesViewerFrame_Step'..num
	local step = _G[stepname]

	step.lines={}



	step:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", tile = true, tileSize = 8, insets = { left = 3, right = 3, top = 3, bottom = 3 }})
	step:GetRegions():SetTexture(1,1,1,1)

	step.border:SetAllPoints()
	step.border:SetBackdrop({ edgeFile = "Interface\\Addons\\ZygorGuidesViewer\\skin\\popup_border", edgeSize = 16 })

	step.slideup = obj("slideup")
	step.fadeout = obj("fadeout")

	
	step:EnableMouse(true)
	step:SetScript("OnClick", Step_OnClick)
	step:SetScript("OnUpdate", Step_OnUpdate)

	step:RegisterForDrag("LeftButton")
	step:RegisterForClicks("LeftButtonUp","RightButtonUp")

	local iconcount=16
	local function icon_seticon(self,n)
		self:SetTexCoord((n-1)/iconcount,n/iconcount,0,1)
	end


	ZGV.stepframes[num] = step

	for i=1,20,1 do
		local line = obj("Line"..i)
		local label = obj("Line"..i.."Text")
		if not label then break end

		local icon = obj("Line"..i.."Icon")
		local back = obj("Line"..i.."Back")
		local clicker = obj("Line"..i.."Clicker")

		line:ClearAllPoints()
		if i==1 then
			-- overridden in ZGV:UpdateFrame anyway
			--line:SetPoint("TOPLEFT",step,ZGV.STEPMARGIN_X,-ZGV.STEPMARGIN_Y)
			--line:SetPoint("TOPRIGHT",step,-ZGV.STEPMARGIN_X,-ZGV.STEPMARGIN_Y)
		else
			line:SetPoint("TOPLEFT",obj("Line"..(i-1)),"BOTTOMLEFT",0,0)
			line:SetPoint("TOPRIGHT",obj("Line"..(i-1)),"BOTTOMRIGHT",0,0)
		end
		line:SetHeight(12)
		line.num = i

		--label:SetMultilineIndent(true)

		label:ClearAllPoints()
		label:SetPoint("TOPLEFT",ZGV.ICON_INDENT,0)
		label:SetPoint("TOPRIGHT",0,0)

		step.lines[i]=line
		line.label=label

		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT",0,1)
		icon:SetTexture(ZGV.DIR.."\\Skin\\icons")
		icon.SetIcon = icon_seticon
		icon:SetIcon(1)

		back:ClearAllPoints()
		back:SetPoint("TOPLEFT")
		back:SetPoint("BOTTOMRIGHT")

		clicker:ClearAllPoints()
		clicker:SetPoint("TOPLEFT")
		clicker:SetPoint("BOTTOMRIGHT")
		--clicker.num = i
		--clicker:RegisterForClicks("LeftButtonUp","RightButtonUp")
		clicker:SetScript("OnClick",clicker_onclick)
		clicker:SetScript("OnEnter",clicker_onenter)
		clicker:SetScript("OnLeave",clicker_onleave)
		clicker:EnableMouse(false)

		--line.icon=icon
		--line.back=back
		--line.clicker=clicker
		line.anim_w2g = obj("Line"..i.."Back_white2green")
		line.anim_w2r = obj("Line"..i.."Back_white2rgba")

	end

	step:ClearAllPoints()
	if num==1 then
		step:SetPoint("TOPLEFT","ZygorGuidesViewerFrameScrollChild","TOPLEFT",0,0)
		step:SetPoint("TOPRIGHT","ZygorGuidesViewerFrameScrollChild","TOPRIGHT",0,0)
	else
		step:SetPoint("TOPLEFT",_G['ZygorGuidesViewerFrame_Step'..(num-1)],"BOTTOMLEFT",0,-ZGV.STEP_SPACING)
		step:SetPoint("TOPRIGHT",_G['ZygorGuidesViewerFrame_Step'..(num-1)],"BOTTOMRIGHT",0,-ZGV.STEP_SPACING)
		--frame:SetPoint("TOPLEFT",getglobal("ZygorGuidesViewerFrame_Step"..(stepnum-1)),"BOTTOMLEFT",0,-STEP_SPACING)
		--frame:SetPoint("TOPRIGHT",getglobal("ZygorGuidesViewerFrame_Step"..(stepnum-1)),"BOTTOMRIGHT",0,-STEP_SPACING)
	end

end

local function Spot_OnClick(self,button)
	ZGV:Debug("spot clicked")
	if self.spot then self.spot:OnClick() end
end

local function Spot_OnUpdate(self,button)
	if ZGV.CurrentStep==self.step then
		local clicker
		for i=1,20,1 do
			clicker=self.lines[i].clicker
			if clicker.over and not MouseIsOver(clicker) then
				clicker:GetScript("OnLeave")(clicker)
				clicker.over=false
			end
		end
		-- ugly! but first leave's, then enter's.
		obscured = (GetMouseFocus()~=WorldFrame and GetMouseFocus()~=self)

		for i=1,20,1 do
			clicker=self.lines[i].clicker
			if clicker:IsVisible() and MouseIsOver(clicker) and not clicker.over and not obscured then
				clicker:GetScript("OnEnter")(clicker)
				clicker.over=true
			end
		end
	end
end

local function SpotLabel_OnHyperlinkEnter(self,linkdata,link)
	--print("hyper enter")
	--print(linkdata)
	GameTooltip:SetOwner(self,"ANCHOR_CURSOR")
	GameTooltip:ClearAllPoints()
	GameTooltip:ClearLines()
	--GameTooltip:SetPoint("BOTTOMRIGHT",self,"TOPLEFT")
	GameTooltip:SetHyperlink(linkdata)
	GameTooltip:Show()
	ZGV.hasTooltipOverSpotLink=true
end

local function SpotLabel_OnHyperlinkLeave(self,linkdata,link)
	--print("hyper leave")
	GameTooltip:Hide()
	ZGV.hasTooltipOverSpotLink=nil
end

function ZygorGuidesViewerFrame_Spot_Setup(num)
	local function obj(name) return _G['ZygorGuidesViewerFrame_Spot'..num..(name and '_'..name or '')] end

	local spotname = 'ZygorGuidesViewerFrame_Spot'..num
	local spot = _G[spotname]

	spot.lines={}

	spot:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", tile = true, tileSize = 8, insets = { left = 3, right = 3, top = 3, bottom = 3 }})
	spot:GetRegions():SetTexture(1,1,1,1)

	spot.border:SetAllPoints()
	spot.border:SetBackdrop({ edgeFile = "Interface\\Addons\\ZygorGuidesViewer\\skin\\popup_border", edgeSize = 16 })

	spot:EnableMouse(true)
	spot:SetScript("OnClick", Spot_OnClick)
	spot:SetScript("OnUpdate", Spot_OnUpdate)
	spot:RegisterForDrag("LeftButton")
	spot:RegisterForClicks("LeftButtonUp","RightButtonUp")

	ZGV.spotframes[num] = spot

	for i=1,20 do
		local line = obj("Line"..i)
		local label = line.label
		if not label then break end

		--local icon = obj("Line"..i.."Icon")
		--local clicker = obj("Line"..i.."Clicker")

		line:ClearAllPoints()
		if i==1 then
			-- overridden in ZGV:UpdateFrame anyway
			--line:SetPoint("TOPLEFT",step,ZGV.STEPMARGIN_X,-ZGV.STEPMARGIN_Y)
			--line:SetPoint("TOPRIGHT",step,-ZGV.STEPMARGIN_X,-ZGV.STEPMARGIN_Y)
		else
			line:SetPoint("TOPLEFT",obj("Line"..(i-1)),"BOTTOMLEFT",0,0)
			line:SetPoint("TOPRIGHT",obj("Line"..(i-1)),"BOTTOMRIGHT",0,0)
		end
		line:SetHeight(12)
		line.num = i

		--label:SetMultilineIndent(true)

		label:ClearAllPoints()
		label:SetPoint("TOPLEFT",ZGV.ICON_INDENT,0)
		label:SetPoint("TOPRIGHT",0,0)

		label:SetHyperlinksEnabled(true)
		label:SetScript("OnHyperlinkEnter", SpotLabel_OnHyperlinkEnter)
		label:SetScript("OnHyperlinkLeave", SpotLabel_OnHyperlinkLeave)
		label:SetScript("OnLeave", SpotLabel_OnHyperlinkLeave)

		spot.lines[i]=line

		--[[
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT",0,1)
		icon:SetTexture(ZGV.DIR.."\\Skin\\icons")
		icon.SetIcon = icon_seticon
		icon:SetIcon(1)

		back:ClearAllPoints()
		back:SetPoint("TOPLEFT")
		back:SetPoint("BOTTOMRIGHT")

		clicker:ClearAllPoints()
		clicker:SetPoint("TOPLEFT")
		clicker:SetPoint("BOTTOMRIGHT")
		--clicker.num = i
		--clicker:RegisterForClicks("LeftButtonUp","RightButtonUp")
		clicker:SetScript("OnClick",clicker_onclick)
		clicker:SetScript("OnEnter",clicker_onenter)
		clicker:SetScript("OnLeave",clicker_onleave)
		clicker:EnableMouse(false)
		--]]

		--line.icon=icon
		--line.back=back
		--line.clicker=clicker
		--line.anim_w2g = obj("Line"..i.."Back_white2green")
		--line.anim_w2r = obj("Line"..i.."Back_white2rgba")

	end

	-- lay them out

	spot:ClearAllPoints()
	if num==1 then
		spot:SetPoint("TOPLEFT","ZygorGuidesViewerFrameScrollChild","TOPLEFT",0,0)
		spot:SetPoint("TOPRIGHT","ZygorGuidesViewerFrameScrollChild","TOPRIGHT",0,0)
	else
		spot:SetPoint("TOPLEFT",_G['ZygorGuidesViewerFrame_Spot'..(num-1)],"BOTTOMLEFT",0,-ZGV.STEP_SPACING)
		spot:SetPoint("TOPRIGHT",_G['ZygorGuidesViewerFrame_Spot'..(num-1)],"BOTTOMRIGHT",0,-ZGV.STEP_SPACING)
		--frame:SetPoint("TOPLEFT",getglobal("ZygorGuidesViewerFrame_Step"..(stepnum-1)),"BOTTOMLEFT",0,-STEP_SPACING)
		--frame:SetPoint("TOPRIGHT",getglobal("ZygorGuidesViewerFrame_Step"..(stepnum-1)),"BOTTOMRIGHT",0,-STEP_SPACING)
	end

end



local ZGVF
local Border
local GuideButton
local TitleBar
local Skipper

function ZygorGuidesViewerFrame_OnLoad(self)
	ZGVF = self
	Border = ZGVF.Border
	Skipper = Border.Gears.Corners.Skipper
	GuideButton = Border.Gears.GuideButton
	TitleBar = Border.TitleBar

--	this.selectedButtonID = 2;
--	this:RegisterEvent("QUEST_LOG_UPDATE");
--	this:RegisterEvent("QUEST_WATCH_UPDATE");
--	this:RegisterEvent("UPDATE_FACTION");
--	this:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
--	this:RegisterEvent("PARTY_MEMBERS_CHANGED");
--	this:RegisterEvent("PARTY_MEMBER_ENABLE");
--	this:RegisterEvent("PARTY_MEMBER_DISABLE");

	self:SetClampRectInsets(0,0,10,0)

	for i=1,20 do
		
		ZygorGuidesViewerFrame_Step_Setup(i)

		-- and now, the final trick: the mystery action button.

		local name = 'ZygorGuidesViewerFrame_Act'..i

		local action = CreateFrame("CheckButton", name.."Action", UIParent, "SecureActionButtonTemplate")
		local petaction = CreateFrame("CheckButton", name.."PetAction", UIParent, "PetActionButtonTemplate")

		action:SetFrameStrata("MEDIUM")
		action:SetToplevel(true)
		action:SetWidth(15)
		action:SetHeight(15)
		action:SetScript("OnEnter", function(self)
			--if InCombatLockdown() then return end
			--self:SetFrameStrata("DIALOG")
			--self:SetWidth(32)
			--self:SetHeight(32)
			--select(2,self:GetAnimationGroups()):Stop()
			--select(1,self:GetAnimationGroups()):Play()
			local link
			if self:GetAttribute("type1")=="item" then
				link = select(2,GetItemInfo(self:GetAttribute("item1")))
				GameTooltip:SetOwner(self,"ANCHOR_PRESERVE")
				GameTooltip:ClearAllPoints()
				GameTooltip:SetPoint("BOTTOMRIGHT",self,"TOPLEFT")
				GameTooltip:SetHyperlink(link)
				GameTooltip:Show()
			end
			if self:GetAttribute("type1")=="spell" then
				GameTooltip:SetOwner(self,"ANCHOR_PRESERVE")
				GameTooltip:ClearAllPoints()
				GameTooltip:SetPoint("BOTTOMRIGHT",self,"TOPLEFT")
				GameTooltip:SetSpellByID(self.spellid)
				GameTooltip:Show()
			end
		end)
		action:SetScript("OnLeave", function(self)
			--if InCombatLockdown() then return end
			--self:SetWidth(15)
			--self:SetHeight(15)
			--self:SetFrameStrata("MEDIUM")
			GameTooltip:Hide()
			--select(1,self:GetAnimationGroups()):Stop()
			--select(2,self:GetAnimationGroups()):Play()
		end)
		action:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")

		action.tex = action:CreateTexture(name.."ActionIcon","OVERLAY")
		action.tex:SetAllPoints(action)
		action.tex:SetWidth(15)
		action.tex:SetHeight(15)
		action.tex:SetHeight(15)

		petaction:SetFrameStrata("HIGH")
		petaction:SetWidth(15)
		petaction:SetHeight(15)
		_G[name..'PetActionNormalTexture2']:SetAlpha(0)
		--petaction:SetScript("OnClick",PetActionButton_OnClick) -- taint
		petaction:SetScript("OnDragStart",nil)
		--petaction:SetScript("OnReceiveDrag",nil) --doesn't work

		local cd = CreateFrame("Cooldown", name.."ActionCooldown", action, "CooldownFrameTemplate")
		action.cd = cd
		cd:SetPoint("CENTER", 0, -1)
		cd:SetAllPoints()
		cd:Hide()

	end

	for i=1,20 do
		ZygorGuidesViewerFrame_Spot_Setup(i)
	end

	ZygorGuidesViewerFrameScroll:EnableMouseWheel(1)
	ZygorGuidesViewerFrameScroll:SetScript("OnMouseWheel",function(self,delta)
		--if ZGV.db.profile.showallsteps then
			ZygorGuidesViewerFrameScrollScrollBar:SetValue(ZygorGuidesViewerFrameScrollScrollBar:GetValue()-delta*3)
		--else
		--	ZygorGuidesViewer:SkipStep(-delta)
		--end
	end)
	ZygorGuidesViewerFrameScroll.SetVerticalScroll = function(val) ZGV:UpdateFrame() end

	local bg = self:CreateAnimationGroup()
	bg:SetLooping("NONE")
	local f = bg:CreateAnimation("Animation","ZygorGuidesViewerFrame_bdflash")
	self.bdflash = f
	f:SetDuration(1.0)
	f:SetMaxFramerate(99)
	f:SetSmoothing("OUT")
	f:SetScript("OnUpdate",doborderrgb)
	f.target = ZygorGuidesViewerFrame_Border
	f.StartRGB = function(self,r,g,b,a,r2,g2,b2,a2)
		self.fromr,self.fromg,self.fromb,self.froma = r,g,b,a
		self.tor,self.tog,self.tob,self.toa = r2,g2,b2,a2
		self:Stop()
		self:Play()
	end
	
	ZGVF.ThinFlash:SetBackdropColor(1,1,1,0.5)
	ZGVF.ThinFlash:SetAlpha(0.0)

	--local back=ZygorGuidesViewerFrame_Border:GetRegions()
	--back:SetBlendMode("ADD")

	Border.SetBackdropBorderColorRGB = function(self,col)
		self:SetBackdropBorderColor(col.r,col.g,col.b,col.a)
	end


	ZygorGuidesViewerFrameScrollScrollBarScrollUpButton:SetScript("OnClick",function(self,button) self:GetParent():SetValue(self:GetParent():GetValue()-1) end)

	-- arrow holder tex coords:
	-- 862/1024,907/1024,124/512,169/512

	ZygorGuidesViewerFrameScrollScrollBarScrollDownButton:SetScript("OnClick",function(self,button) self:GetParent():SetValue(self:GetParent():GetValue()+1) end)

	ZygorGuidesViewerFrameScrollScrollBarThumbTexture:SetTexCoord(871/1024,896/1024,202/512,256/512)
	ZygorGuidesViewerFrameScrollScrollBarThumbTexture:SetWidth(12)
	ZygorGuidesViewerFrameScrollScrollBarThumbTexture:SetHeight(30)

	local tracker = ZygorGuidesViewerFrameScrollScrollBar:CreateTexture("ZygorGuidesViewerFrameScrollScrollBarTrackerTexture")
	tracker:SetTexCoord(878/1024,888/1024,292/512,302/512)
	tracker:SetWidth(10)
	tracker:SetPoint("TOP",ZygorGuidesViewerFrameScrollScrollBarScrollUpButton,"BOTTOM",-1,2)
	tracker:SetPoint("BOTTOM",ZygorGuidesViewerFrameScrollScrollBarScrollDownButton,"TOP",-1,-2)

	ZygorGuidesViewerFrameScroll.scrollBarHideable = 1

	ZygorGuidesViewerFrame_Skipper_PrevButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	ZygorGuidesViewerFrame_Skipper_NextButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	ZygorGuidesViewerFrame_Border_SectionTitle:SetFont("Interface\\Addons\\ZygorGuidesViewer\\skin\\antiquen.ttf",11)
	--ZygorGuidesViewerFrame_Skipper_Step:SetFont("Interface\\Addons\\ZygorGuidesViewer\\skin\\VinerHandITC.ttf",14)
	--ZygorGuidesViewerFrame_Border_SectionTitle:SetJustifyV("MIDDLE")

	--ZGVF.SmoothSetHeight = ZGVF_SetHeight

	self.mouseCount=0
	self.leftCount=0

	self.oldxPos,self.oldyPos = 0,0
end

function ZygorGuidesViewerFrame_OnHide()
	ZGV:Frame_OnHide()
end

function ZygorGuidesViewerFrame_OnShow()
	ZGV:Frame_OnShow()
end

local delay=0.5
local fadespeed=0.15
local xPos,yPos
local stepframe,line

local throttle=0

function ZygorGuidesViewerFrameMaster_OnUpdate(self,elapsed)
	if not ZGV.guidesloaded and ZGV.db and ZGV.db.char.maint_startguides then
		local st=GetTime()
		repeat
			ZGV:Startup()
		until GetTime()-st>0.01
	end
end

function ZygorGuidesViewerFrame_OnUpdate(self,elapsed)
	--[[
	if not self.aligned then
		self.aligned=true
		ZGV:AlignFrame()
	end

	if ZGV.temp_scansize then
		local scale = self:GetScale()
		local left,top,bottom,right = self:GetLeft(),self:GetTop(),self:GetBottom(),self:GetRight()
		ZGV:Debug(("In OnUpdate: %.2f scale: left %.2f, top %.2f, bottom %.2f, right %.2f"):format(scale,left,top,bottom,right))
		ZGV.temp_scansize=false
	end
	--]]

	if ZGV.delayFlash and ZGV.delayFlash==2 then
		ZGV.delayFlash = 3
	end

	throttle=throttle+elapsed ; if throttle<0.05 then return end ; elapsed=throttle ; throttle=0

	if ZGV.framemoving then
		--ZygorGuidesViewer:UpdateFrame(nil,true)
		ZGV:UpdateFrameCurrent()
	end

	local locked = ZGV.db.profile.windowlocked

	-- auto-hide border
	if ZGV.db.profile.hideborder then
		-- never hide while the window is being moved
		if ZGV.framemoving then
			self.leftCount=0
		end

		--if ZGV.db.profile.windowlocked then
			xPos,yPos = GetCursorPosition()
			if xPos~=self.oldxPos or yPos~=self.oldyPos then self.mouseCount=0 end
			self.oldxPos,self.oldyPos = xPos,yPos
		--end

		if (  (locked and MouseIsOver(TitleBar,10,-10,-30,30))
		   or (--[[not locked and]] MouseIsOver(ZGVF,0,0,-20,0))
		   ) and ZGV.borderfadedout then
			self.mouseCount = self.mouseCount+elapsed
			self.leftCount=0
			if self.mouseCount>delay then
				UIFrameFadeIn(Border,fadespeed,0.0,ZGV.db.profile.opacitymain)
				UIFrameFadeIn(Skipper,fadespeed,0.0,ZGV.db.profile.opacitymain)
				ZGV.borderfadedout=nil
			end
			GuideButton.delay=-2
		end

		if not MouseIsOver(self,10,-10,-30,30)
		and (not ZGV.Tab1 or not MouseIsOver(ZGV.Tab1))
		and (not ZGV.Tab2 or not MouseIsOver(ZGV.Tab2)) then
			self.leftCount = self.leftCount+elapsed
			self.mouseCount=0
			if self.leftCount>delay and Border:GetAlpha()>0.05 and not ZGV.borderfadedout then
				UIFrameFadeOut(Border,fadespeed,ZGV.db.profile.opacitymain,0.0)
				UIFrameFadeOut(Skipper,fadespeed,ZGV.db.profile.opacitymain,0.0)
				ZGV.borderfadedout=true
			end
		end
		
		if Border:GetAlpha()<0.05 then
			Border:Hide()
			Skipper:Hide()
		else
			Border:Show()
			if Skipper.mustbevisible then Skipper:Show() end
		end
	else
		Border:Show()
		Border:SetAlpha(1)
		if Skipper.mustbevisible then
			Skipper:Show()
			Skipper:SetAlpha(1)
		end
	end

	--[[
	local gt=GetTime()-(ZygorGuidesViewerFrame_ThinFlash.starttime or 0)
	if gt>0 and ZygorGuidesViewerFrame_ThinFlash:IsShown() then
		local a = 0.5 - gt*3
		ZygorGuidesViewerFrame_ThinFlash:SetAlpha(a)
		if (a<0.01) then
			--ZygorGuidesViewerFrame_ThinFlash:Hide()
		end
	end
	--]]

	-- flash
	-- the regular code sets ZGV.delayFlash to 1 and then to 2; upon first update it gets promoted to 3, and only upon that is the flash fired
	-- this is to make sure it flashes after steps had time to rearrange themselves
	if ZGV.delayFlash and ZGV.delayFlash==3 then
		local ThinFlash = ZGVF.ThinFlash
		Border.Gears.Corners.Flash.sub.flash:Stop()
		ThinFlash.flash:Stop()
		if Border:IsVisible() then
			Border.Gears.Corners.Flash.sub.flash:Play()
		else
			if ZGV.db.profile.showallsteps then
				ThinFlash:ClearAllPoints()
				ThinFlash:SetPoint("TOPLEFT",ZygorGuidesViewerFrameScroll,"TOPLEFT",-18,18)
				local lastbottom=0
				for i=2,20 do
					if ZGV.stepframes[i]:IsVisible() then lastbottom=ZygorGuidesViewerFrameScroll:GetTop()-ZGV.stepframes[i]:GetBottom() end
				end
				if lastbottom>0 then
					lastbottom = ZygorGuidesViewerFrameScroll:GetHeight()-lastbottom
				end
				ThinFlash:SetPoint("BOTTOMRIGHT",ZygorGuidesViewerFrameScroll,"BOTTOMRIGHT",18 - 15,-18 + lastbottom)
			else
				ThinFlash:ClearAllPoints()
				ThinFlash:SetPoint("TOPLEFT",ZygorGuidesViewerFrame_Step1,"TOPLEFT",-18,18)
				ThinFlash:SetPoint("BOTTOMRIGHT",ZygorGuidesViewerFrame_Step1,"BOTTOMRIGHT",18,-18)
			end
			ThinFlash.flash:Play()
			--ZygorGuidesViewerFrame_ThinFlash.starttime = GetTime()+0.2
			ThinFlash:Show()
		end
		ZGV.delayFlash = 0
	end


	-- title button slide in
	local but = ZygorGuidesViewerFrame_Border_GuideButton
	if Border:IsShown() and (MouseIsOver(TitleBar,0,0,50,-50) or not ZGV.CurrentGuide) and not ZGV.loading then
		if locked then
			xPos,yPos = GetCursorPosition()
			if (not but.oldxPos or not but.oldyPos or xPos~=but.oldxPos or yPos~=but.oldyPos) and but.delay>0 then but.delay=0 end
			but.oldxPos,but.oldyPos = xPos,yPos
		end

		but.delay=but.delay+elapsed * (locked and 2 or 4)
		if but.delay>1.5 or but.pos>0.01 then
			but.pos = but.pos + elapsed*4
			if but.pos>1 then but.pos=1 end
			local a = 3.14159+0.34159+(math.sin(but.pos*1.5708))*2.8
			but:Show()
			but:dorot(a)
		end
	end
	if but:IsShown() and not MouseIsOver(ZygorGuidesViewerFrame_Border_TitleBar,0,0,50,-50) and ZGV.CurrentGuide and not DropDownList1:IsShown() and not DropDownList2:IsShown() then
		if but.pos<0.01 then
			but:Hide()
			if but.delay>0 then but.delay=0 end
		else
			but.pos = but.pos - elapsed*4
			if but.pos<0 then but.pos=0 end
			local a = 3.14159+0.34159+(math.sin(but.pos*1.5708))*2.8
			but:dorot(a)
		end
	end

	-- title button flash
	if not ZGV.CurrentGuide and not ZGV.loading then
		local t=GetTime()
		t=t-floor(t)
		if t>0.5 then
			GuideButton:LockHighlight()
		else
			GuideButton:UnlockHighlight()
		end
	end

	if ZGV.frameNeedsUpdating then
		ZGV.frameNeedsUpdating=nil
		ZGV:Debug("frameNeedsUpdating, so updating.")
		ZGV:UpdateFrame()
	end

	-- and now the FAST step surfing
	if ZGV.fastforward then
		ZGV.completionelapsed = ZGV.completionelapsed + elapsed
		if ZGV.completionelapsed>=ZGV.completioninterval then
			ZGV:TryToCompleteStep(true)
		end
	end

	for i=1,50 do
		local spot = ZGV.spotframes[i]
		if spot and spot:IsShown() then
			for l=1,20 do
				if spot.lines[l] and spot.lines[l].label.reenableHyperlinks then
					spot.lines[l].label:SetHyperlinksEnabled(true)
					spot.lines[l].label.reenableHyperlinks = nil
				end
			end
		end
	end

end


--[[
function ZGVFSectionDropDown_Initialize(frame,level,menulist)
	ZGV:InitializeDropDown(frame,level,menulist)
end

function ZGVFSectionDropDown_Func()
	ZGV:SetGuide(this.value)
--	ToggleDropDownMenu(1, nil, ZygorGuidesViewerFrame_SectionDropDown, ZygorGuidesViewerFrame, 0, 0);
end
--]]

function ZGVF_SetHeight(self,height)
	self.targetheight = height
	ZygorGuidesViewerFrame_size:Play()
end