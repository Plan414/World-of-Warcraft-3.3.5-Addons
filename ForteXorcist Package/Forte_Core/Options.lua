--ForteXorcist v1.980.8 by Xus 28-09-2012 for 5.0

local FW = FW;
local FWL = FW.L;
local strfind = strfind;
local strformat = string.format;
local gsub = string.gsub;
local abs = math.abs;
local floor = math.floor;
local ceil = math.ceil;
local ipairs = ipairs;
local pairs = pairs;
local unpack = unpack;
local select = select;
local GetTime = GetTime;
local _G = _G;
local erase = FW.ERASE;
local CreateFrame = CreateFrame;
local OptionsPanel; -- will refer to the options panel frame

local optionsbuilt = false;
local filterdropdown;
local texturedropdown;
local fontdropdown;
local sounddropdown;
local backdropdropdown;
local listdropdown;

local FW_Options = {};
FW.Options = FW_Options;
local Frames = FW.Frames;

local MAIN_DATA_TABLE = 8;
local SUB_DATA_TABLE = 6;
local NEW_INSTANCE_STRING = " + new ";
local STATES = FW.STATES;

local profile_link;

local function GetLink(index,root)
	return root.Data[index]["link"];
end
local function GetLinkTable(index,root)
	local link = GetLink(index,root);
	return link and root.Links[link];
end

local function GetName(index,root)
	return root.Data[index]["name"];
end

local function FW_RefreshOptionsThrottle()
	FW:RegisterThrottle(FW.RefreshOptions);
end

local function FW_RefreshOptionsNoStyleThrottle()
	FW:RegisterThrottle(FW.RefreshOptionsNoStyle);
end

local function MatchOption(from,to,name)
	if type(from[name]) == type(to[name]) then
		if type(from[name]) == "table" then
			local m = true;
			for k, v in pairs(from[name]) do
				if not MatchOption(from[name],to[name],k) then
					m = false;
					break;
				end
			end
			return m;
		else
			return to[name] == from[name];
		end
	else
		return false;
	end
end

function CopyOption(from,to,name)
	if type(from[name]) == "table" then
		if type(to[name]) == "table" then
			erase(to[name]);
		else
			to[name] = {};
		end
		for k, v in pairs(from[name]) do
			CopyOption(from[name],to[name],k)
		end
	else
		to[name] = from[name];
	end
end
--local linked_profiles = {};
--local temp = {};

local function ForAllOptionsTables(index,func,root,parent_root,parent_index) -- run this function for the current profile and its clones, func( table, optionkey, root )
	for o, d in pairs( root.Instances[index] ) do
		if type(d) == "table" and d.Instances then
			for i, instance in ipairs(d.Instances) do
				ForAllOptionsTables(i,func,d,root,index);
			end
		else
			func(index,o,root,parent_root,parent_index);
		end
	end
end

function FW:ForAllOptionsTables(index,func,root,parent_root,parent_index)
	ForAllOptionsTables(index,func,root,parent_root,parent_index);
end

local function GetLinkedOption2(index,o,root,parent_root,parent_index)
	if parent_root then
		local name,instance = GetName(index,root),root.Instance;
		local link = GetLinkTable(parent_index,parent_root);
		return link and link[instance] and link[instance][name] and link[instance][name][o];
	else
		local link = GetLinkTable(index,root);
		return link and link[o];
	end
end

local function GetLinkedOption(obj,profile) -- called from option object ONLY
	if profile then
		return GetLinkedOption2(obj.main_data.root.Active,obj.o,obj.main_data.root,obj.main_data.parent_root,obj.main_data.parent_root and obj.main_data.parent_root.Active);
	elseif obj.main_data.parent_root then
		return GetLinkedOption2(obj.main_data.root.Active,obj.o,obj.main_data.root);
	end
end

local function SetLinkedOption2(index,o,val,root,parent_root,parent_index)
	if not val then
		val = nil; -- only keep 'true'
	end
	if parent_root then
		local name,instance = GetName(index,root),root.Instance;
		local link = GetLinkTable(parent_index,parent_root);
			if link then
			if not link[instance] then
				link[instance] = {};
			end
			if not link[instance][name] then
				link[instance][name] = {};
			end
			link[instance][name][o] = val;
		end
	else
		local link = GetLinkTable(index,root);
		if link then
			link[o] = val;
		end
	end
end

local function SetLinkedOption(obj,profile,val) -- called from option object
	if profile then
		SetLinkedOption2(obj.main_data.root.Active,obj.o,val,obj.main_data.root,obj.main_data.parent_root,obj.main_data.parent_root and obj.main_data.parent_root.Active);
	elseif obj.main_data.parent_root then
		SetLinkedOption2(obj.main_data.root.Active,obj.o,val,obj.main_data.root);
	end
end

local function AutoFixProfile()
	--[[if profile_link then
		local nm = 0;
		--local ignored = "";
		for o, v in pairs(FW.Settings) do
			if not strfind(o,"Instances$") and not Frames[o] then -- ignore all frame/instance keys
				if GetLinkedOptionProfile2(o,nil) then
					for i, p in ipairs( linked_profiles ) do
						-- only using match too because I want to see how many get fixed...
						if not MatchOption(FW.Settings, FW.Saved.Profiles[p], o) then
							CopyOption(FW.Settings, FW.Saved.Profiles[p], o);
							nm = nm + 1;
						end
					end
				end
			end
		end
		-- run matching for all frames
		for instance in pairs(Frames) do
			--if ExistsInAllLinked(instance) then
				for o, v in pairs(FW.Settings[instance]) do
					if GetLinkedOptionProfile2(o,instance) then
						for i, p in ipairs( linked_profiles ) do
							-- only using match too because I want to see how many get fixed...
							if not MatchOption(FW.Settings[instance], FW.Saved.Profiles[p][instance], o) then
								CopyOption(FW.Settings[instance], FW.Saved.Profiles[p][instance], o);
								nm = nm + 1;
							end
						end
					end
				end
			--else
			--	ignored = ignored..instance.." ";
			--end
		end
		FW:Show("ForteXorcist: Fixed "..nm.." settings!",0,1,0);
		--if ignored ~= "" then
		--	FW:Show("The following frames were ignored, because they didn't excist in all profiles: "..ignored,0,1,0);
		--end
		OptionsPanel:Draw();
	--end]]
end

local total,matched = 0,0;


function SetMatchCloneFunc(t,o,root,parent_root)
	--[[if parent_root then -- this options belongs to instances
		if GetOptionsMatch2(t,o,root,parent_root) then -- 
			SetLinkedOption2
		end
	end
	if GetOptionsMatch2(t,o,root) then
	
	end
	]]
end

function SetMatchFunc(index,o,root,parent_root,parent_index)
	if GetOptionsMatch2(index,o,root,parent_root,parent_index) then -- 
		SetLinkedOption2(index,o,true,root,parent_root,parent_index);
		matched = matched + 1;
	end
	total = total + 1;
end

local function getFirstOfLink(li,root)
	for index, data in ipairs(root.Data) do
		if li == data.link then
			return index;
		end
	end
end

local function AutoLinkProfile(index)
	index = index or FW.Saved.Profiles.Active;
	if GetLink(index,FW.Saved.Profiles) then
		total,matched = 0,0;
		ForAllOptionsTables(index,SetMatchFunc,FW.Saved.Profiles);
		FW:Show("ForteXorcist: Linked "..matched.."/"..total.." options!",0,1,0);
		OptionsPanel:Draw();
	--else
		--FW:Show("ForteXorcist: Please link two or more Profiles together first!",0,1,0);
	end
end

local function AutoLinkProfiles()
	for li in ipairs(FW.Saved.Profiles.Links) do
		local index = getFirstOfLink(li,FW.Saved.Profiles);
		if index then AutoLinkProfile(index); end
	end
end

local function AutoLinkClone(index,root)
	index = index or root.Active;
	if GetLink(index,root) then
		total,matched = 0,0;
		ForAllOptionsTables(index,SetMatchFunc,root);
		FW:Show("ForteXorcist: Linked "..matched.."/"..total.." options!",0,1,0);
		OptionsPanel:Draw();
	--else
		--FW:Show("ForteXorcist: Please link two or more Clones together first!",0,1,0);
	end
end

local function AutoLinkClones()
	for pi,pp in ipairs(FW.Saved.Profiles.Instances) do
		for o, data in pairs(pp) do
			if type(data) == "table" and data.Instances then
				for li in ipairs(data.Links) do
					local index = getFirstOfLink(li,data);
					if index then AutoLinkClone(index,data); end
				end
			end
		end
	end
end

function FW:SetLinkedOptions(index,o,root,parent_root,parent_index,func) -- use this to set linked option values!
	if parent_root and GetLinkedOption2(index,o,root,parent_root,parent_index) then
		local name,instance = GetName(index,root),root.Instance;
		local li = GetLink(parent_index,parent_root);
		local s = root.Instances[index];
		for pi,pd in ipairs(parent_root.Instances) do
			if parent_root.Data[pi].link == li and parent_index ~= pi then
				if pd[instance] then
					for i,d in ipairs(pd[instance].Data) do
						if d.name == name then
							CopyOption(s, pd[instance].Instances[i], o);	
						end
					end
				end
			end
		end
	end
	if root and GetLinkedOption2(index,o,root) then
		local li = GetLink(index,root);
		local s = root.Instances[index];
		for i,d in ipairs(root.Data) do
			if d.link == li and index ~= i then
				CopyOption(s, root.Instances[i], o);
				if parent_root and func then -- run functions for the updated clones too
					func( Frames[ "FX_"..root.Instance..i ] );
				end
			end
		end
	end
end

function GetOptionsMatch2(index,o,root,parent_root,parent_index)
	if parent_root then
		local li = GetLink(parent_index,parent_root);
		if li then
			local s = root.Instances[index];
			local name,instance = GetName(index,root),root.Instance;
			for pi,pd in ipairs(parent_root.Instances) do
				if parent_root.Data[pi].link == li and index ~= pi then
					if pd[instance] then
						for i,d in ipairs(pd[instance].Data) do
							if d.name == name then
								if not MatchOption(s, pd[instance].Instances[i], o) then
									return false;
								end
							end
						end
					end
				end
			end
		end
	else
		local li = GetLink(index,root);
		if li then
			local s = root.Instances[index];
			for i,d in ipairs(root.Data) do
				if d.link == li and index ~= i then
					if not MatchOption(s, root.Instances[i], o) then
						return false;
					end
				end
			end
		end
	end
	return true;
end

function GetOptionsMatch(obj,profile)
	if profile then
		return GetOptionsMatch2(obj.main_data.root.Active,obj.o,obj.main_data.root,obj.main_data.parent_root,obj.main_data.parent_root and obj.main_data.parent_root.Active);
	elseif obj.main_data.parent_root then
		return GetOptionsMatch2(obj.main_data.root.Active,obj.o,obj.main_data.root);
	end
	return true;
end

local function OptionFunction(obj,refresh)
	
	FW:SetLinkedOptions(obj.main_data.root.Active,obj.o,obj.main_data.root,obj.main_data.parent_root,obj.main_data.parent_root and obj.main_data.parent_root.Active,obj.option_func);
	
	obj.cross_profile_match = GetOptionsMatch(obj,true);
	obj.cross_clone_match = GetOptionsMatch(obj,false);
		
	if obj.option_func then
		--FW:Show("run func");
		obj.option_func(obj.instance);
	end
	--FW:RefreshOptions();
	if refresh then
		FW_RefreshOptionsNoStyleThrottle();
	elseif obj:IsVisible() then

		obj:Hide();
		obj:Show();
	end
end

local function ResetExpanded()
	for main_index, main_data in ipairs(FW_Options) do -- MAIN OPTION LEVEL
		for sub_index, sub_data in ipairs(main_data[MAIN_DATA_TABLE]) do -- SUB OPTION LEVEL
			if sub_data.option then
				sub_data.option.expand = nil;
			end
		end
	end
	OptionsPanel:Draw();
end

do
	local temp = {};
	function FW:InstanceSetLink(index,root,link)
		local old;
		if not link then -- aka removing link
			old = root.Data[index]["link"];
		end
		root.Data[index]["link"] = link;
		if old then -- delete link if only one profile still uses it
			FW:InstanceGetLinkedTo(old,root,temp)
			if #temp == 1 then
				FW:InstanceDeleteLink(old,root); -- also removes the deleted link from instances that still use it
			end
		end
	end
	function FW:InstanceLink(target,root)
		local current = root.Active;
		local current_link = GetLink(current,root);
		local target_link = GetLink(target,root);
		if current_link then
			if current_link == target_link then
				FW:InstanceSetLink(target,root,nil);--FW:Show("unlink");
			elseif target_link then
				FW:InstanceGetLinkedTo(target_link,root,temp);-- assign current_link to all profiles linked to target_link
				for i, index in ipairs(temp) do
					FW:InstanceSetLink(index,root,current_link);
				end
			else
				FW:InstanceSetLink(target,root,current_link);-- assign current_link to target profile
			end
		else
			if target_link then
				FW:InstanceSetLink(current,root,target_link);-- assign target_link to current profile
			else
				local link = FW:InstanceCreateLink(root);-- create new link and assign to both
				FW:InstanceSetLink(current,root,link);
				FW:InstanceSetLink(target,root,link);
			end
		end
		OptionsPanel:Draw();
		OptionsPanel:Refresh();
	end
end

local function InstanceLink(obj)
	FW:InstanceLink(obj.index,obj.parent.parent.root);
end

function FW:InstanceDeleteLink(index,root)
	tremove(root.Links,index);
	for i, d in ipairs(root.Data) do
		if d["link"] then
			if d["link"] == index then
				d["link"] = nil;
			elseif d["link"] > index then
				d["link"] = d["link"] - 1 ;
			end
		end
	end
end

function FW:InstanceCreateLink(root)
	tinsert(root.Links,{});
	return #root.Links;
end

function FW:InstanceGetLinkedTo(link,root,temp,ignore)
	erase(temp);
	if link then
		for i,d in ipairs(root.Data) do
			if d["link"] == link and ignore ~= i then
				tinsert(temp,i);
			end
		end
	end
end

local function linkAll(root)
	for index,instance in ipairs(root.Instances) do
		for i,d in pairs(instance) do
			if type(d) == "table" and d.Instances then
				linkAll(d);
			end
		end
	end
	if #root.Instances > 1 then
		local link = FW:InstanceCreateLink(root);
		FW:InstanceSetLink(1,root,link);
		for i=2,#root.Instances,1 do
			FW:InstanceSetLink(i,root,link);
		end
		ForAllOptionsTables(1,SetMatchFunc,root);
	end
end

function FW:SmartLinkAll()
	for i,p in ipairs(FW.Saved.Profiles.Instances) do
		FW.Saved.Profiles.Instances[i].LinkProfile = true;
		FW.Saved.Profiles.Instances[i].LinkClone = true;
	end
	linkAll(FW.Saved.Profiles);
	OptionsPanel:Draw();
	OptionsPanel:Refresh();
	FW:Show("ForteXorcist: All profiles and clones are now linked, and options with the same settings are linked as well. In addition, future new profiles and clones will be linked automatically. You can change automatic linking at 'Advanced Options > Options Linking'.",0,1,0);
end

function FW:LinkOnCreate(index,root)
	if FW.Settings then -- only do if already loaded...
		if root.Characters and FW.Settings.LinkProfile or not root.Characters and FW.Settings.LinkClone then
			local current = root.Active;
			local current_link = GetLink(current,root);
			if current_link then
				FW:InstanceSetLink(index,root,current_link);-- assign current_link to target profile
			else
				local link = FW:InstanceCreateLink(root);-- create new link and assign to both
				FW:InstanceSetLink(current,root,link);
				FW:InstanceSetLink(index,root,link);

				ForAllOptionsTables(current,SetMatchFunc,root);
				--if not root.Characters and FW.Settings.LinkProfile then -- also link new clone settings to profiles if needed??
				--	ForAllOptionsTables(current,SetMatchFunc,root,FW.Saved.Profiles,FW.Saved.Profiles.Active);
				--end
			end
		end
	end
end

local cx,cy;
function FW:IsLocked(frame)
	if frame.s and frame.s.lock ~=nil then
		return frame.s.lock;
	else
		return FW.Settings.GlobalLock;
	end
end

function FW:CorrectPosition(frame)
	FW:SetPosition(frame,frame.s.x,frame.s.y);
end

local function FW_GetHeight(frame)
	return frame:GetHeight()*frame:GetEffectiveScale();
end

local function FW_GetWidth(frame)
	return frame:GetWidth()*frame:GetEffectiveScale();
end

local function FW_GetTop(frame)
	return frame:GetTop()*frame:GetEffectiveScale();
end

local function FW_GetBottom(frame)
	return frame:GetBottom()*frame:GetEffectiveScale();
end

local function FW_GetLeft(frame)
	return frame:GetLeft()*frame:GetEffectiveScale();
end

local function FW_GetRight(frame)
	return frame:GetRight()*frame:GetEffectiveScale();
end

local function FW_CoordinatesString(frame)
	return strformat("%.0f",frame.s.x).." "..strformat("%.0f",frame.s.y);
end

local function FW_ToggleFilterList()
	OptionsPanel:Draw();
end

local function FW_GetSubSaveTable(obj,create)
	local main_title,sub_title = obj.main_data[1],obj.sub_data[1];
	if not FW.Saved.CATEGORIES[ main_title ] then
		if not create then
			return;
		end
		FW.Saved.CATEGORIES[ main_title ] = {};
	end
	if not FW.Saved.CATEGORIES[ main_title ][ sub_title ] then
		if not create then
			return;
		end
		 FW.Saved.CATEGORIES[ main_title ][ sub_title ] = {};
	end
	return FW.Saved.CATEGORIES[ main_title ][ sub_title ];
end

local function FW_DragFrames()
	local frame1,frame2;
	local cx,cy = GetCursorPosition();
	for f,frame in pairs(Frames) do
		if frame.fwmovingx then
			frame1 = _G[strsub(f,1,4).."Background"] or frame;
			local oy = select(2,FW:GetCenter(frame)) - select(2,FW:GetCenter(frame1));
			local x = frame.fwmovingx+cx;
			local y = frame.fwmovingy+cy;
			local hh = FW_GetHeight(frame1)/2;
			local hw = FW_GetWidth(frame1)/2;
			local vl = frame.fwmovingx+cx-hw;
			local vr = frame.fwmovingx+cx+hw;
			local vt = frame.fwmovingy+cy+hh-oy;
			local vb = frame.fwmovingy+cy-hh-oy;
			if FW.Settings.FrameSnap and f~="FWOptions"  then
				for ff,dd in pairs(Frames) do
					if ff~=f and ff~="FWOptions" then
						frame2 = _G[strsub(ff,1,4).."Background"] or dd;
						if frame2:IsVisible() then
							local t = FW_GetTop(frame2);
							local b = FW_GetBottom(frame2);
							local l = FW_GetLeft(frame2);
							local r = FW_GetRight(frame2);
							if t > vt-FW.Settings.FrameSnapDistance and t < vt+FW.Settings.FrameSnapDistance then
								y = t - hh + oy;
							elseif b > vt-FW.Settings.FrameSnapDistance and b < vt+FW.Settings.FrameSnapDistance then
								y = b - hh -FW.Settings.FrameDistance + oy;
							elseif t < vb+FW.Settings.FrameSnapDistance and t > vb-FW.Settings.FrameSnapDistance then
								y = t + hh + FW.Settings.FrameDistance + oy;
							elseif b < vb+FW.Settings.FrameSnapDistance and b > vb-FW.Settings.FrameSnapDistance then
								y = b + hh + oy;
							end
							if r > vr-FW.Settings.FrameSnapDistance and r < vr+FW.Settings.FrameSnapDistance then
								x = r - hw;
							elseif l > vr-FW.Settings.FrameSnapDistance and l < vr+FW.Settings.FrameSnapDistance then
								x = l - hw -FW.Settings.FrameDistance;
							elseif r < vl+FW.Settings.FrameSnapDistance and r > vl-FW.Settings.FrameSnapDistance then
								x = r + hw + FW.Settings.FrameDistance;
							elseif l < vl+FW.Settings.FrameSnapDistance and l > vl-FW.Settings.FrameSnapDistance then
								x = l + hw;
							end								
						end
					end
				end
				if vt>FW_GetTop(UIParent) then
					y = FW_GetTop(UIParent) -hh - FW.Settings.FrameDistance + oy;
				elseif vb< 0 then
					y = hh + FW.Settings.FrameDistance + oy;
				end
				if vr>FW_GetRight(UIParent) then
					x = FW_GetRight(UIParent) -hw - FW.Settings.FrameDistance;
				elseif vl<0 then
					x = hw + FW.Settings.FrameDistance;
				end
			end
			FW:SetPosition(frame,x,y);			
			frame.s.x,frame.s.y = x,y;
			for main_index, main_data in ipairs(FW_Options) do -- MAIN OPTION LEVEL
				if main_data.option and main_data.option.frame == f then
					main_data.option.frameheader.coordinates:SetText(FW_CoordinatesString(frame));
					break;
				end
			end
			return;
		end
		--if frame.fwsizing then
		--end
	end
end

function FW:StartMoving(frame,button)
	cx,cy = GetCursorPosition();
	if not FW:IsLocked(frame) and button=="LeftButton" and (not frame.combat_sensitive or not STATES.INCOMBAT) then 
		FW:RegisterUpdatedEvent(FW_DragFrames);
		local tx,ty = FW:GetCenter(frame);
		frame.fwmovingx = tx-cx;
		frame.fwmovingy = ty-cy;
	end
end

function FW:Moved() -- should return if my mouse moved between press and release...
	local x,y = GetCursorPosition();
	return x~=cx or y~=cy;
end

function FW:StopMoving(frame)
	frame.fwmovingx = nil;
	frame.fwmovingy = nil;
	FW:UnregisterUpdatedEvent(FW_DragFrames);
end

local function FW_SetLockIcon(button)
	local instance = button.parent.parent.instance;
	if instance then
		--FW:Show(frame.." "..tostring(FW:IsLocked(frame)));
		if FW:IsLocked( instance ) then
			button.normaltexture:SetTexCoord(0,0.25,0,1);
			button.highlighttexture:SetTexCoord(0,0.25,0,1);
			button.title = FWL.UNLOCK;
			button.tip = FWL.UNLOCK_TT;
		else
			button.normaltexture:SetTexCoord(0.25,0.50,0,1);
			button.highlighttexture:SetTexCoord(0.25,0.50,0,1);
			button.title = FWL.LOCK;
			button.tip = FWL.LOCK_TT;
		end
		if button.over then FW:ShowTip(button);end
	end
end

local function FW_LockFrame(button)
	local instance = button.parent.parent.instance;
	if instance then
		instance.s.lock = not instance.s.lock;
		instance:Update();
		FW_SetLockIcon(button);
	end
end

local function FW_SetFrameAlpha(button)
	local instance = button.parent.parent.instance;
	button.parent.alpha:SetText(strformat("%.1f",instance.s.alpha));
	instance:Update();
end

local function FW_SetFrameScale(button)
	local instance = button.parent.parent.instance;
	button.parent.scale:SetText(strformat("%.1f",instance.s.scale));
	instance:Update();
end

local function FW_ColorSelectedSpell(obj) -- only thing this does is highlght the spell that's currently active
	if obj.expandbutton then
		if obj.expand then
			local spell = obj.editbox:GetText();
			local l;
			local i = 1;
			obj.expandbutton:LockHighlight();
			while obj.items[i] and obj.items[i]:IsShown() do
				if obj.items[i].editbox:GetText() == spell then
					obj.items[i].editbox:SetTextColor(1,1,1);
					obj.items[i].background:Show();
				else
					obj.items[i].editbox:SetTextColor(0,1,0);
					obj.items[i].background:Hide();
				end
				i=i+1;
			end
		else
			obj.expandbutton:UnlockHighlight();
		end
	end
end

local function FW_StringToCoordinates(s)
	local s1,s2 = strsplit(" ",s);
	s1,s2 = tonumber(s1),tonumber(s2);
	if s1 and s2 then
		return s1,s2;
	end	
end

local function FW_StringToColor(s) -- used for filters and normal coloring
	local s1,s2,s3,s4 = strsplit(" ",s);
	s1,s2,s3,s4 = tonumber(s1),tonumber(s2),tonumber(s3),tonumber(s4);
	if s1 and s2 and s3 then
		return s1,s2,s3,s4;
	end
end

local function FW_FilterColorString(setting)
	if not setting then return "";end
	local s = "";
	for i=2,#setting,1 do
		if s=="" then
			s = s..strformat("%.2f",setting[i]);
		else
			s = s.." "..strformat("%.2f",setting[i]);
		end
	end
	return s;
end

local function FW_ColorString(setting)
	if not setting then return "";end
	local s = "";
	for i,v in ipairs(setting) do
		if s=="" then
			s = s..strformat("%.2f",v);
		else
			s = s.." "..strformat("%.2f",v);
		end
	end
	return s;
end

local function FW_SetFilterColor(data,obj)
	if data and (data[1] == FW.FILTER_COLOR or data[1] == FW.FILTER_SHOW_COLOR) then
		if not data[2] then
			data[2],data[3],data[4] = 1,1,1;
		end
		obj.colorswatch:EnableMouse(true);
		obj.colorswatch.normaltexture:SetVertexColor(data[2],data[3],data[4],1);
		obj.editbox2:EnableMouse(true);
		obj.editbox2:SetText(FW_FilterColorString(data));
	else
		obj.colorswatch:EnableMouse(false);
		obj.colorswatch.normaltexture:SetVertexColor(0,0,0,0.1);
		obj.editbox2:EnableMouse(false);
		obj.editbox2:SetText("");
	end
end

local function FW_FilterSpellUpdate(obj) -- now also called when the type is changed
	local spell = obj.editbox:GetText();
	local filter = obj.o;
	local typ = obj.typebutton.val or 1;

	if obj.s[filter][spell] and obj.s[filter][spell][typ] then
		obj.actionbutton:SetText(FW:TypeName(obj.s[filter][spell][typ][1],obj.actionbutton.list));
	else
		obj.actionbutton:SetText(FW:TypeName(0,obj.actionbutton.list));
	end
 	FW_SetFilterColor(obj.s[filter][spell] and obj.s[filter][spell][typ],obj);
	FW_ColorSelectedSpell(obj);
end

local function FC_BuildFilterList(obj)
	local l;
	local y = 0;
	local i = 1;
	--FW:Show(s:GetName());
	
	local list1 = obj.actionbutton.list;
	local list2 = obj.typebutton.list;

	if obj.expand then -- make and show the list
		local fo,si,fl = unpack(FW.Settings.OptionsFont);
		for k, v in pairs(obj.s[obj.o]) do
			for key, val in pairs(v) do
				if val[1] ~= 0 then -- ignore filters set to 'none'
					l = obj.items[i] or obj:NewFilterListItem(i);
					
					l.o = obj.o;
					l.s = obj.s;
					l.d = obj.d;
					
					l.editbox:SetText(k);
					l.actionbutton.list = list1;
					l.typebutton.list = list2;
					l.typebutton.val = key;
					l.typebutton:SetText(FW:TypeName(key,list2));
					
					l.typebutton:SetFont(fo,si,fl);
					l.actionbutton:SetFont(fo,si,fl);
					l.editbox2:SetFont(fo,si-2,fl);
					l.editbox:SetFont(fo,si,fl);
					
					FW_FilterSpellUpdate(l);
					
					y = y - 20;
					
					l:SetPoint("TOPLEFT", obj, "TOPLEFT",0,y);
					l:Show();
					
					i = i + 1;
				end
			end
		end
	end
	
	-- hide the rest of the list
	
	obj:Finalize(i);
	FW_ColorSelectedSpell(obj);
	return y;
end


local function FW_SetFilterType(t) -- receives the value number 
	-- the standard code that actually updates the value displayed on the button etc
	local spell = filterdropdown.button.parent.editbox:GetText();
	local filter = filterdropdown.button.parent.o;
	filterdropdown.button.parent.editbox2:ClearFocus();
	filterdropdown.button:SetText(FW:TypeName(t,filterdropdown.button.list));
	-- actually do something with this change
	local s = filterdropdown.button.parent.s;
	local typ = filterdropdown.button.parent.typebutton.val or 1;
	
	if filterdropdown.button.list == FW.FilterListOptions then -- this is the ACTION selection dropdown
		
		if not s[filter][spell] then
			s[filter][spell] = {};
		end
		if not s[filter][spell][typ] then
			s[filter][spell][typ] = {};
		end
		s[filter][spell][typ][1]=t;
		
		if filterdropdown.button.parent.expand == null then
			filterdropdown.button.parent.parent:func();
		else
			filterdropdown.button.parent:func();
		end
		
		FW_ToggleFilterList();  -- rebuild filter list
		
	else -- this is the TYPE selection dropdown
		
		if filterdropdown.button.parent.expand == nil then -- this is a list item edit!!
			-- i want to change the actual type and keep the rest of the settings...
			local old = filterdropdown.button.val;
			if not s[filter][spell][t] then
				s[filter][spell][t] = {};
			end
			s[filter][spell][t][1] = s[filter][spell][old][1];
			s[filter][spell][t][2] = s[filter][spell][old][2];
			s[filter][spell][t][3] = s[filter][spell][old][3];
			s[filter][spell][t][4] = s[filter][spell][old][4];	
			s[filter][spell][old] = nil;
			
			filterdropdown.button.parent.parent:func();
			
			FW_ToggleFilterList();  -- rebuild filter list			
		end
	end
	filterdropdown.button.val = t; -- <<-- the easiest way... stores the value INDEX that's selected

	if filterdropdown.button.parent.expand == null then -- this is a list item edit!!
		FW_FilterSpellUpdate(filterdropdown.button.parent.parent); -- refresh main filter parent
	else
		FW_FilterSpellUpdate(filterdropdown.button.parent);
	end
end

local function fixColorNumber(v)
	return FW:RoundTo(v,0.01);
end

local function fixColorRGB(r,g,b)
	return fixColorNumber(r),fixColorNumber(g),fixColorNumber(b);
end

local function FW_FilterColorPickerApply()
	_G.ColorPickerFrame.setting[2],_G.ColorPickerFrame.setting[3],_G.ColorPickerFrame.setting[4]=fixColorRGB(_G.ColorPickerFrame:GetColorRGB());
	_G.ColorPickerFrame.colorswatch.normaltexture:SetVertexColor(_G.ColorPickerFrame.setting[2],_G.ColorPickerFrame.setting[3],_G.ColorPickerFrame.setting[4],1);
	_G.ColorPickerFrame.colorswatch.parent.editbox2:SetText(FW_FilterColorString(_G.ColorPickerFrame.setting));

	if _G.ColorPickerFrame.colorswatch.parent.func then
		_G.ColorPickerFrame.colorswatch.parent:func();
	else
		_G.ColorPickerFrame.colorswatch.parent.parent:func();
	end
end

local function FW_FilterColorPickerCancel()
	_G.ColorPickerFrame.setting[2],_G.ColorPickerFrame.setting[3],_G.ColorPickerFrame.setting[4]=_G.ColorPickerFrame.previousValues[1],_G.ColorPickerFrame.previousValues[2],_G.ColorPickerFrame.previousValues[3];
	_G.ColorPickerFrame.colorswatch.normaltexture:SetVertexColor(_G.ColorPickerFrame.setting[2],_G.ColorPickerFrame.setting[3],_G.ColorPickerFrame.setting[4],1);
	_G.ColorPickerFrame.colorswatch.parent.editbox2:SetText(FW_FilterColorString(_G.ColorPickerFrame.setting));
	
	if _G.ColorPickerFrame.colorswatch.parent.func then
		_G.ColorPickerFrame.colorswatch.parent:func();
	else
		_G.ColorPickerFrame.colorswatch.parent.parent:func();
	end
end

local function FW_FontApply(font)
	fontdropdown.button.parent.s[fontdropdown.button.parent.o][1] = font;
	fontdropdown.button:SetText(FW:FontName(font));
	fontdropdown.button:SetFont(unpack(fontdropdown.button.parent.s[fontdropdown.button.parent.o]));
	fontdropdown.button.parent.editbox:SetText(font);
	fontdropdown.button.parent:func();
end

local function FW_TextureApply(texture)
	texturedropdown.button.parent.s[texturedropdown.button.parent.o] = texture;
	texturedropdown.button:SetNormalTexture(texture);
	texturedropdown.button.parent.editbox:SetText(texture);
	texturedropdown.button.parent:func();
end

local function FW_AlphaApply()
	local o = _G.ColorPickerFrame.colorswatch.parent.o;
	local s = _G.ColorPickerFrame.colorswatch.parent.s;
	if s[o] then
		if _G.ColorPickerFrame.hasOpacity then
			s[o][4] =  1.0 - fixColorNumber(OpacitySliderFrame:GetValue());
		else
			s[o][4] =  nil;
		end
		_G.ColorPickerFrame.colorswatch.normaltexture:SetVertexColor(s[o][1],s[o][2],s[o][3],s[o][4]);
		_G.ColorPickerFrame.colorswatch.fullalphatexture:SetVertexColor(s[o][1],s[o][2],s[o][3]);
		_G.ColorPickerFrame.colorswatch.parent.editbox:SetText(FW_ColorString(s[o]));
	end
	_G.ColorPickerFrame.colorswatch.parent:func();
end

local function FW_ColorPickerApply()
	local o = _G.ColorPickerFrame.colorswatch.parent.o;
	local s = _G.ColorPickerFrame.colorswatch.parent.s;
	_G.ColorPickerFrame.colorswatch.parent.s[o][1],s[o][2],s[o][3] = fixColorRGB(_G.ColorPickerFrame:GetColorRGB());

	_G.ColorPickerFrame.colorswatch.normaltexture:SetVertexColor(s[o][1],s[o][2],s[o][3],s[o][4]);
	_G.ColorPickerFrame.colorswatch.fullalphatexture:SetVertexColor(s[o][1],s[o][2],s[o][3]);
	_G.ColorPickerFrame.colorswatch.parent.editbox:SetText(FW_ColorString(s[o]));
	_G.ColorPickerFrame.colorswatch.parent:func();
end

local function FW_ColorPickerCancel()
	local o = _G.ColorPickerFrame.colorswatch.parent.o;
	local s = _G.ColorPickerFrame.colorswatch.parent.s;
	s[o][1],s[o][2],s[o][3] = _G.ColorPickerFrame.previousValues[1],_G.ColorPickerFrame.previousValues[2],_G.ColorPickerFrame.previousValues[3];
	s[o][4] = _G.ColorPickerFrame.previousValues[4];
	
	_G.ColorPickerFrame.colorswatch.normaltexture:SetVertexColor(s[o][1],s[o][2],s[o][3],s[o][4]);
	_G.ColorPickerFrame.colorswatch.fullalphatexture:SetVertexColor(s[o][1],s[o][2],s[o][3]);
	_G.ColorPickerFrame.colorswatch.parent.editbox:SetText(FW_ColorString(s[o]));
	
	_G.ColorPickerFrame.colorswatch.parent:func();
end

local function FW_SoundApply(sound)
	sounddropdown.button.parent.s[sounddropdown.button.parent.o][1] = sound;
	sounddropdown.button:SetText(FW:SoundName(sound));
	sounddropdown.button.parent.editbox:SetText(sound);
	sounddropdown.button.parent:func();
end

local function FW_RestorePosition(button)
	local instance = button.parent.parent.instance;
	if instance then
		instance:ClearAllPoints();
		instance:SetPoint("CENTER",UIParent, "CENTER",0,0);
		instance.s.x,instance.s.y = FW:GetCenter(instance);
		
		button.parent.coordinates:SetText(FW_CoordinatesString(instance));
	end
end

local function FW_RestoreDefaults(obj)
	if obj.parent.index then
		for i, d in ipairs(FW_Options[obj.parent.index][MAIN_DATA_TABLE][obj.index][SUB_DATA_TABLE]) do -- OPTION LEVEL
			if d.option and d.option.default then
				d.option.default:Click();
			end
		end
	else
		for sub_index, sub_data in ipairs(FW_Options[obj.index][MAIN_DATA_TABLE]) do -- SUB OPTION LEVEL
			for i, d in ipairs(sub_data[SUB_DATA_TABLE]) do -- OPTION LEVEL
				if d.option and d.option.default then
					d.option.default:Click();
				end
			end
		end
	end
	--OptionsPanel:Refresh();
end

local function FW_RestoreFrameDefaults(obj)
	if obj.instance then
		if obj.instance.s.lock then -- default is unlocked, so toggle if locked
			obj.frameheader.lock:Click();
		end
		obj.frameheader.scalerestore:Click();
		obj.frameheader.position:Click();
		obj.frameheader.alpharestore:Click();
	end
end

local function FW_AutoComplete(self,...) -- auto complete editbox with keys from x tables
	local text = self:GetText();
	local textlen = strlen(text);
	
	-- fix special characters here if needed
	text = gsub(text, "%(", "%%(");
	text = gsub(text, "%)", "%%)");
	text = gsub(text, "%-", "%%-");
	
	for i=1,select("#",...),1 do
		local t = (select(i,...));
		if t then
			for name in pairs(t) do

				if ( text ~= "" and strfind(strlower(name), "^"..strlower(text)) ) then
					self:SetText(name);
					self:HighlightText(textlen, -1);
					return;
				end
			end
		end
	end
end

------------------------------------------------------------
-- START ALL INTERFACE TEMPLATES
------------------------------------------------------------
-- these templates assume that the settings and defaults to use can change
-- but the names of the options will remain the same

local function NewTextString(parent)
	local obj = parent:CreateFontString(nil,"ARTWORK","FWFontNormal");
	obj.parent = parent;
	obj:SetJustifyH("LEFT");
	obj.SetEnabled = function(self,enabled)
		if enabled then
			obj:SetFontObject("FWFontNormal");
		else
			obj:SetFontObject("FWFontDisable");
		end
	end
	return obj;
end

local function NewColorSwatch(parent)
	local obj = CreateFrame("Button",nil,parent);
	obj.parent = parent;
	local o = obj.parent.o;
	obj:SetWidth(18);
	obj:SetHeight(18);
	
	obj.fullalphatexture = obj:CreateTexture(nil,"OVERLAY");
	obj.fullalphatexture:SetTexture("Interface\\ChatFrame\\ChatFrameColorSwatch");
	obj.fullalphatexture:SetWidth(18);
	obj.fullalphatexture:SetHeight(18);
	obj.fullalphatexture:SetPoint("CENTER",obj,"CENTER",0,0);
	obj.fullalphatexture:SetTexCoord(0,0, 0,1, 1,0, 1000,1000);	
	
	obj.backgroundtexture = obj:CreateTexture(nil,"BACKGROUND");
	obj.backgroundtexture:SetTexture(0.8,0.8,0.8);
	obj.backgroundtexture:SetWidth(16);
	obj.backgroundtexture:SetHeight(16);
	obj.backgroundtexture:SetPoint("CENTER",obj,"CENTER",0,0);
	obj.backgroundtexture:SetVertexColor(1.00,0.82,0.00);

	obj:SetNormalTexture("Interface\\ChatFrame\\ChatFrameColorSwatch");
	obj.normaltexture = obj:GetNormalTexture();
	
	--scripts

	obj.title = FWL.CLICK_TO_EDIT;
	obj.tip = FWL.CLICK_TO_EDIT_TT;
	
	obj.SetEnabled = function(self,enabled)
		obj:EnableMouse(enabled);
		if enabled then
			obj.backgroundtexture:SetVertexColor(1.00,0.82,0.00);
		else
			obj.backgroundtexture:SetVertexColor(0.5,0.5,0.5);
		end
	end

	obj:SetScript("OnClick",function(self)
				
		CloseMenus();
		_G.ColorPickerFrame.func = FW_ColorPickerApply;
		_G.ColorPickerFrame.colorswatch = self;
		
		if obj.parent.d[o] and obj.parent.d[o][4] then
			_G.ColorPickerFrame.hasOpacity = 1;
			_G.ColorPickerFrame.opacityFunc = FW_AlphaApply;
			_G.ColorPickerFrame.opacity = 1.0 - obj.parent.s[o][4];
		else
			_G.ColorPickerFrame.hasOpacity = nil;
			_G.ColorPickerFrame.opacityFunc = nil;
			obj.parent.s[o][4] = nil;
		end
		
		_G.ColorPickerFrame:SetColorRGB(obj.parent.s[o][1],obj.parent.s[o][2],obj.parent.s[o][3]);
		
		if not _G.ColorPickerFrame.previousValues then _G.ColorPickerFrame.previousValues = {}; end
		_G.ColorPickerFrame.previousValues[1] = obj.parent.s[o][1];
		_G.ColorPickerFrame.previousValues[2] = obj.parent.s[o][2];
		_G.ColorPickerFrame.previousValues[3] = obj.parent.s[o][3];
		_G.ColorPickerFrame.previousValues[4] = obj.parent.s[o][4];
		
		_G.ColorPickerFrame.cancelFunc = FW_ColorPickerCancel;
		ShowUIPanel(_G.ColorPickerFrame);
		
	end);

	obj:SetScript("OnEnter",function(self)
		obj.backgroundtexture:SetVertexColor(1.00,1.00,1.00);
		FW:ShowOptionsTip(self);
	end);
	obj:SetScript("OnLeave",function(self)
		obj.backgroundtexture:SetVertexColor(1.00,0.82,0.00);
		FW:HideTip(self);
	end);
	obj:SetScript("OnShow",function(self)
		obj.normaltexture:SetVertexColor(obj.parent.s[o][1],obj.parent.s[o][2],obj.parent.s[o][3],obj.parent.s[o][4] or 1);
		obj.fullalphatexture:SetVertexColor(obj.parent.s[o][1],obj.parent.s[o][2],obj.parent.s[o][3]);
	end);

	return obj;
end


local function NewButton(parent)
	local obj = CreateFrame("Button",nil,parent);
	obj.parent = parent;
	obj:SetWidth(14);
	obj:SetHeight(14);
	
	return obj;
end

local function NewDropdownShowButton(parent,dropdown)
	local obj = CreateFrame("Frame",nil,parent);
	obj.parent = parent;
	obj.dropdown = dropdown;
	
	obj:SetHeight(14);
	obj:EnableMouse(1);
	obj.text = NewTextString(obj);
	obj.text:SetJustifyH("CENTER");
	obj.text:SetAllPoints(obj);
	
	obj.background = obj:CreateTexture(nil,"BACKGROUND");
	obj.background:SetAllPoints(obj);
	obj.background:SetTexture(0,0,0,0.1);
	
	--scripts
	obj.SetText = function(self,text)
		obj.text:SetText(text);
	end
	obj.GetText = function(self)
		return obj.text:GetText();
	end
	obj.SetFont = function(self,...)
		obj.text:SetFont(...);
	end
	obj.SetEnabled = function(self,enabled)
		obj:EnableMouse(enabled);
		obj.text:SetEnabled(enabled);
	end
	obj.SetJustifyH = function(self,...)
		obj.text:SetJustifyH(...);
	end
	obj:SetScript("OnEnter",function(self)
		obj.background:SetTexture(1,1,1,0.05);
		obj.dropdown.button = self;
		obj.dropdown:Build();
		obj.dropdown:SetPoint("TOPLEFT",self, "BOTTOMLEFT",-5,0);
		obj.dropdown:Show();
	end);
	obj:SetScript("OnLeave",function(self)
		obj.background:SetTexture(0,0,0,0.1);
		if not obj.dropdown.over then
			obj.dropdown:Hide();
		end
	end);
	return obj;
end


local function NewTextButton(parent)
	local obj = NewButton(parent);
	obj.anchor = "CENTER";
	obj.text = obj:CreateFontString(nil,"ARTWORK","FWFontNormal");
	obj.text:SetPoint(obj.anchor,obj,obj.anchor,0,0);
	obj.high = obj:CreateFontString(nil,"HIGHLIGHT","FWFontHighlight");
	obj.high:SetPoint(obj.anchor,obj,obj.anchor,0,0);
	
	obj.texture = obj:CreateTexture(nil,"BACKGROUND");
	obj.texture:SetPoint("TOPLEFT",obj,"TOPLEFT",1,-1);
	obj.texture:SetPoint("BOTTOMRIGHT",obj,"BOTTOMRIGHT",-1,1);
	
	-- scripts
	obj.SetText = function(self,text)
		obj.text:SetText(text);
		text = text:gsub("%|c%x%x%x%x%x%x%x%x", "") -- remove blizzard style color tags
		text = text:gsub("%|r", "")	-- remove blizzard style return at end of line
		obj.high:SetText(text);
	end
	obj.GetText = function(self)
		return obj.text:GetText();
	end
	obj.SetFont = function(self,...)
		obj.text:SetFont(...);
		obj.high:SetFont(...);
	end
	obj.SetJustifyH = function(self,anchor)
		obj.anchor = anchor;
		obj.text:ClearAllPoints();
		obj.text:SetPoint(obj.anchor,obj,obj.anchor,0,0);
		obj.high:ClearAllPoints();
		obj.high:SetPoint(obj.anchor,obj,obj.anchor,0,0);
	end
	obj.SetEnabled = function(self,enabled)
		obj:EnableMouse(enabled);
		if enabled then
			obj.text:SetFontObject("FWFontNormal");
		else
			obj.text:SetFontObject("FWFontDisable");
		end	
	end
	obj.SetTextColor = function(self,...)
		obj.text:SetTextColor(...);
	end
	obj:SetScript("OnMouseDown",function(self)
		obj.text:SetPoint(obj.anchor,obj,obj.anchor,1,-1);
		obj.high:SetPoint(obj.anchor,obj,obj.anchor,1,-1);
		--obj.texture:SetRotation(math.pi);
		obj.texture:SetTexCoord(1,1,1,0,0,1,0,0);
	end);
	obj:SetScript("OnMouseUp",function(self)
		obj.text:SetPoint(obj.anchor,obj,obj.anchor,0,0);
		obj.high:SetPoint(obj.anchor,obj,obj.anchor,0,0);
		--obj.texture:SetRotation(0);
		obj.texture:SetTexCoord(0,0,0,1,1,0,1,1);
	end);	
	obj:SetScript("OnLeave",function(self)
		obj.text:SetPoint(obj.anchor,obj,obj.anchor,0,0);
		obj.high:SetPoint(obj.anchor,obj,obj.anchor,0,0);
		obj.text:Show();
		FW:HideTip(self);
	end);
	obj:SetScript("OnEnter",function(self)
		obj.text:Hide();
		FW:ShowOptionsTip(self);
	end);
	
	return obj;
end

local function NewDropdownListButton(parent)
	local obj = NewTextButton(parent);
	
	obj:SetScript("OnEnter",function(self)
		obj.parent:Show();
		obj.text:Hide();
	end);

	obj:SetScript("OnLeave",function(self)
		if not obj.parent.over then
			obj.parent:Hide();
		end
		obj.text:SetPoint(obj.anchor,obj,obj.anchor,0,0);
		obj.high:SetPoint(obj.anchor,obj,obj.anchor,0,0);
		obj.text:Show();
	end);
	return obj;
end

local function NewOptionsHeader(parent)
	local obj = CreateFrame("Frame",nil,parent);
	obj.texture = obj:CreateTexture(nil,"BACKGROUND");
	obj.texture:SetPoint("TOPLEFT",obj,"TOPLEFT",1,-1);
	obj.texture:SetPoint("BOTTOMRIGHT",obj,"BOTTOMRIGHT",-1,1);
	obj:SetHeight(20);
	return obj;
end

local function NewTexturedButton(parent,texture)
	local obj = NewButton(parent);

	obj:SetNormalTexture(texture);
	obj.normaltexture = obj:GetNormalTexture();
	obj:SetHighlightTexture(texture);
	obj.highlighttexture = obj:GetHighlightTexture();
	obj.highlighttexture:SetBlendMode("ADD");
	obj.highlighttexture:SetDesaturated(1);
	
	obj:SetDisabledTexture(texture);	
	obj.disabledtexture = obj:GetDisabledTexture();
	obj.disabledtexture:SetDesaturated(1);
	obj.disabledtexture:SetVertexColor(0.5,0.5,0.5);
	
	obj.SetEnabled = function(self,enabled)
		if enabled then
			self:Enable();
		else
			self:Disable();
		end
	end
	
	obj:SetScript("OnEnter",function(self)
		FW:ShowOptionsTip(self);
	end);
	obj:SetScript("OnLeave",function(self)
		FW:HideTip(self);
	end);
	
	return obj;
end

local function DefaultOnLeave(self)
	FW:HideDefault(self);
	FW:HideTip(self);
end
local function DefaultOnEnter(self)
	FW:ShowDefault(self);
	FW:ShowOptionsTip(self);
end

function FW:RefreshFields(obj)
	local fields = {
		"checkbutton","checkbutton1","checkbutton2",
		"editbox","editbox2",
		"button","overbutton","tilesize","bg","edge","inset","border",
		"colorswatch"
	};
	
	for i, field in ipairs(fields) do
		if obj[field] then
			obj[field]:Hide();
			obj[field]:Show();
		end
	end
end

function FW:ShowDefault(obj)
	local parent = obj.parent;
	if parent.s then
		local orig_s = parent.s;
		parent.s = parent.d;
		--FW:Show("ShowDefault");
		FW:RefreshFields(parent);
		parent.s = orig_s;
	end
end

function FW:HideDefault(obj)
	local parent = obj.parent;
	if parent.s then
		--FW:Show("HideDefault");
		FW:RefreshFields(parent);
	end
end

local function NewDefaultButton(parent)
	local obj = NewTexturedButton(parent,"Interface\\PVPFrame\\PVP-Banner-Emblem-2");
	obj:SetPoint("RIGHT",parent,"RIGHT",-5,0);
	obj.normaltexture:SetVertexColor(1,1,1,0.3);
	obj.disabledtexture:SetVertexColor(0.5,0.5,0.5,0.3);
	obj.title = FWL.DEFAULT;
	obj.tip = FWL.DEFAULT_TT;
	
	obj:SetScript("OnEnter",DefaultOnEnter);
	obj:SetScript("OnLeave",DefaultOnLeave);
	obj.SetEnabled = function(self,enabled)
	
		if enabled and not (self.parent.s and MatchOption( self.parent.s, self.parent.d, self.parent.o)) then
			self:Enable();
		else
			self:Disable();
		end
	end
	return obj;
end

local function NewDefaultAllButton(parent)
	local obj = NewDefaultButton(parent);
	obj.title = FWL.DEFAULT_ALL;
	obj.tip = FWL.DEFAULT_ALL_TT;
	return obj;
end

local function NewEditBox(parent)
	local obj = CreateFrame("EditBox",nil,parent);
	obj.parent = parent;
	obj:SetWidth(100);
	obj:SetHeight(14);
	obj:SetAutoFocus(false)
	obj:SetMaxLetters(64);
	obj:SetJustifyH("RIGHT");
	
	obj.background = obj:CreateTexture(nil,"BACKGROUND");
	obj.background:SetAllPoints(obj);
	obj.background:SetTexture(0,0,0,0.1);
	
	obj:SetFontObject("FWFontHighlight"); -- 
			
	obj.title = FWL.CLICK_TO_EDIT;
	obj.tip = FWL.CLICK_TO_EDIT_TT;	
	
	--scripts
	obj.SetEnabled = function(self,enabled)
		if enabled then
			obj:EnableMouse(true);
			obj:SetFontObject("FWFontHighlight");
		else
			obj:EnableMouse(false);
			obj:SetFontObject("FWFontDisable");
		end
	end
	obj:SetScript("OnEnter",function(self)
		obj.background:SetTexture(1,1,1,0.05);
		FW:ShowOptionsTip(self);
	end);
	obj:SetScript("OnLeave",function(self)
		FW:HideTip(self);
		obj.background:SetTexture(0,0,0,0.1);
	end);
	obj:SetScript("OnShow",function(self)
		self:SetText(obj.parent.s[obj.parent.o]);
	end);
	obj:SetScript("OnHide",function(self) -- fix a crazy 4.1 bug
		self.val = self:GetText(); -- currently only actively used for filter name
		self:SetText("");
	end);
	obj:SetScript("OnEscapePressed",function(self)
		self:ClearFocus();
	end);
	obj:SetScript("OnEnterPressed",function(self)
		self:ClearFocus();
	end);	
	obj:SetScript("OnEditFocusGained",function(self)
		self:HighlightText();
	end);
	obj:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
		self:SetText(obj.parent.s[obj.parent.o]);
	end);
	
	return obj;
end

local function NewTextureButton(parent,n)
	local obj = CreateFrame("Button",nil,parent);
	obj.parent = parent;
	obj.parent.items[n] = obj;
	obj:SetWidth(140);
	obj:SetHeight(16);

	obj:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar");
	obj.normaltexture = obj:GetNormalTexture();
	obj.normaltexture:SetVertexColor(1.00,0.88,0.50);
	
	--scripts
	obj:SetScript("OnClick",function(self)
		FW_TextureApply(self.val);
		texturedropdown:Hide();
	end);
	obj:SetScript("OnEnter",function(self)
		self.normaltexture:SetVertexColor(1.00,1.00,1.00);
		texturedropdown:Show();
	end);
	obj:SetScript("OnLeave",function(self)
		self.normaltexture:SetVertexColor(1.00,0.88,0.50);
		if not texturedropdown.over then
			texturedropdown:Hide();
		end
	end);
	
	return obj;
end

local function NewBackdropButton(parent,n)
	local obj = CreateFrame("Button",nil,parent);
	obj.parent = parent;
	obj.parent.items[n] = obj;
	obj:SetWidth(140);
	obj:SetHeight(32);
	
	obj:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar");
	obj.normaltexture = obj:GetNormalTexture();
	obj.normaltexture:SetVertexColor(1.00,0.88,0.50);

	--scripts
	obj:SetScript("OnClick",function(self)
		--FW_TextureApply(self.val);
		backdropdropdown:Hide();
	end);
	obj:SetScript("OnEnter",function(self)
		self:SetBackdropBorderColor(1.00,1.00,1.00);
		self:SetBackdropColor(1.00,1.00,1.00);
		backdropdropdown:Show();
	end);
	obj:SetScript("OnLeave",function(self)
		self:SetBackdropBorderColor(1.00,0.88,0.50);
		self:SetBackdropColor(1.00,0.88,0.50);
		if not backdropdropdown.over then
			backdropdropdown:Hide();
		end
	end);
	
	return obj;
end

local function NewShortcutButton(parent)
	local obj = NewTextButton(parent);
	
	obj.texture = obj:CreateTexture(nil,"BACKGROUND");
	obj.texture:SetPoint("TOPLEFT",obj,"TOPLEFT",1,-1);
	obj.texture:SetPoint("BOTTOMRIGHT",obj,"BOTTOMRIGHT",-1,1);
	
	obj:SetNormalTexture("Interface\\GossipFrame\\BinderGossipIcon");
	obj.normaltexture = obj:GetNormalTexture();
	obj.normaltexture:SetWidth(12);
	obj.normaltexture:SetHeight(12);
	obj.normaltexture:ClearAllPoints();
	obj.normaltexture:SetPoint("LEFT",obj,"LEFT",2,0);
	return obj;
end

local function NewFontButton(parent,n)
	local obj = NewDropdownListButton(parent);
	obj.parent.items[n] = obj;
	obj:SetWidth(140);
	obj:SetHeight(16);

	--scripts
	obj:SetScript("OnClick",function(self)
		FW_FontApply(self.val);
		fontdropdown:Hide();
	end);
	return obj;
end

local function NewFilterButton(parent,n)
	local obj = NewDropdownListButton(parent);
	obj.parent.items[n] = obj;
	obj:SetWidth(70);
	obj:SetHeight(16);
	
	--scripts
	obj:SetScript("OnClick",function(self)
		FW_SetFilterType(self.val);
		filterdropdown:Hide();
	end);

	return obj;
end


local function NewPlaySound(parent)
	local obj = NewTexturedButton(parent,"Interface\\Buttons\\UI-GuildButton-MOTD-Up");
	
	--scripts
	obj:SetScript("OnClick",function(self)
		if obj.parent.s and obj.parent.s[obj.parent.o] then
			for i=1,obj.parent.s[obj.parent.o][2],1 do
				PlaySoundFile( obj.parent.s[obj.parent.o][1] );
			end
		else
			PlaySoundFile( obj.parent.o );
		end
	end);

	return obj;
end

local function NewSoundButton(parent,n)
	local obj = NewDropdownListButton(parent);
	obj.parent.items[n] = obj;
	obj:SetWidth(140);
	obj:SetHeight(16);

	obj.play = NewPlaySound(obj);
	obj.play:SetPoint("LEFT",obj);
	
	--scripts
	obj:SetScript("OnClick",function(self)
		FW_SoundApply(self.o);
		sounddropdown:Hide();
	end);
	obj.play:SetScript("OnEnter",function(self)
		sounddropdown:Show();
	end);
	obj.play:SetScript("OnLeave",function(self)
		if not sounddropdown.over then
			sounddropdown:Hide();
		end
	end);

	return obj;
end

local function NewDropdown(parent,build)
	local obj = CreateFrame("Frame",nil,parent);
	obj.parent = parent;
	obj:SetWidth(110);
	obj:SetHeight(20);
	obj:SetFrameStrata("TOOLTIP");
	obj:Hide();
	obj:EnableMouse(1);

	obj.items = {};
	obj.Build = build;

	obj.NewFontButton = NewFontButton;
	obj.NewSoundButton = NewSoundButton
	obj.NewFilterButton = NewFilterButton;
	obj.NewTextureButton = NewTextureButton;
	obj.NewBackdropButton = NewBackdropButton
	
	obj.Finalize = function(self,i)
		while obj.items[i] and obj.items[i]:IsShown() do
			obj.items[i]:Hide();
			i=i+1;
		end
	end
		
	--scripts
	obj:SetScript("OnEnter",function(self)
		self:Show();
		self.over = true;
	end);
	obj:SetScript("OnLeave",function(self)
		self:Hide();
		self.over = false;
	end);
	
	return obj;
end

local function NewCheckButton(parent)
	local obj = CreateFrame("Button",nil,parent);
	obj.parent = parent;
	obj:SetWidth(20);
	obj:SetHeight(20);
	
	obj:SetNormalTexture("Interface\\AddOns\\Forte_Core\\Textures\\CheckButton");
	obj.normaltexture = obj:GetNormalTexture();
	obj.normaltexture:ClearAllPoints();
	obj.normaltexture:SetWidth(16);
	obj.normaltexture:SetHeight(16);
	obj.normaltexture:SetPoint("CENTER",obj,"CENTER",0,0);
	
	obj:SetDisabledTexture("Interface\\AddOns\\Forte_Core\\Textures\\CheckButton");	
	obj.disabledtexture = obj:GetDisabledTexture();
	obj.disabledtexture:ClearAllPoints();
	obj.disabledtexture:SetWidth(16);
	obj.disabledtexture:SetHeight(16);
	obj.disabledtexture:SetPoint("CENTER",obj,"CENTER",0,0);
	obj.disabledtexture:SetVertexColor(0.5,0.5,0.5);
	--obj.disabledtexture:SetDesaturated(1);
	
	obj.background = obj:CreateTexture(nil,"BACKGROUND");
	obj.background:SetTexture(0,0,0,0.2);
	obj.background:SetWidth(10);
	obj.background:SetHeight(10);
	obj.background:SetPoint("CENTER",obj,"CENTER",0,0);
	
	obj.texture = obj:CreateTexture(nil,"OVERLAY");
	obj.texture:SetTexture("Interface\\Buttons\\UI-CheckBox-Check");
	obj.texture:SetAllPoints(obj);
	
	obj.title = "[click to toggle]";
	obj.tip = "";
	obj.SetEnabled = function(self,enabled)
		if enabled then
			obj.texture:SetDesaturated(false);
			self:Enable();	
		else
			self:Disable();
			obj.texture:SetDesaturated(true);	
		end		
	end
	obj.SetChecked = function(self,checked)
		if checked then
			obj.texture:SetVertexColor(1,1,1,1);
		else
			obj.texture:SetVertexColor(1,1,1,0);
		end
	end
	
	obj:SetScript("OnEnter",function(self)
		obj.background:SetTexture(1,1,1,0.05);
		FW:ShowOptionsTip(self);
	end);
	obj:SetScript("OnLeave",function(self)
		FW:HideTip(self);
		obj.background:SetTexture(0,0,0,0.1);
	end);

	return obj;
end

local function ClickOption(obj,button)
	--FW:Show("poke"..tostring(button));
	--FW:Show(tostring(profile_link));
	local parent_root = obj.main_data.parent_root;
	local root = obj.main_data.root;
	local parent_link = parent_root and GetLink(parent_root.Active,parent_root);
	local link = root and GetLink(root.Active,root);
	
	local d = false;
	if IsShiftKeyDown() and (parent_root and parent_link or not parent_root and link) then
		obj.cross_profile = not obj.cross_profile;
		obj:SetLinkedOption(true,obj.cross_profile);
		d = true;
	end
	if IsControlKeyDown() and parent_root and link then
		obj.cross_clone = not obj.cross_clone;
		obj:SetLinkedOption(false,obj.cross_clone);
		d = true;
	end
	if d then
		obj:func(); -- always refreshes the option and sets the option value across linked profiles
	end
end

local function NewLinker(parent)
	local obj = CreateFrame("Frame",nil,parent);
	obj.parent = parent;
	obj:SetAllPoints(obj.parent);
	obj:EnableMouse(false);
	obj.background = obj:CreateTexture(nil,"BACKGROUND");
	obj.background:SetPoint("TOPLEFT",obj,"TOPLEFT",4,-1);
	obj.background:SetPoint("BOTTOMRIGHT",obj,"BOTTOMRIGHT",-4,1);
	obj.background:SetTexture(1,1,1);
	
	obj.line = obj:CreateTexture(nil,"BACKGROUND");
	obj.line:SetPoint("BOTTOMLEFT",obj,"BOTTOMLEFT",4,0);
	obj.line:SetPoint("BOTTOMRIGHT",obj,"BOTTOMRIGHT",-4,0);
	obj.line:SetHeight(2);
	obj.line:SetTexture(1,1,1);
	
	obj:SetScript("OnShow",function(self)
		self:SetLinked();
	end);
	obj.SetLinked = function(self)
		--if profile_link then
		obj.background:Show();
		obj.line:Show();
		
		if not obj.parent.cross_profile_match then
			if not obj.parent.cross_clone_match then
				obj.line:SetVertexColor(unpack(FW.Settings.DiffBothColor));
			else
				obj.line:SetVertexColor(unpack(FW.Settings.DiffProfileColor));
			end
		elseif not obj.parent.cross_clone_match then
			obj.line:SetVertexColor(unpack(FW.Settings.DiffCloneColor));
		elseif FW.Settings.DiffNoneColor[0] then
			obj.line:SetVertexColor(unpack(FW.Settings.DiffNoneColor));
		else
			obj.line:Hide();
		end
		if obj.parent.cross_profile then
			if obj.parent.cross_clone then
				obj.background:SetVertexColor(unpack(FW.Settings.LinkBothColor));
			else
				obj.background:SetVertexColor(unpack(FW.Settings.LinkProfileColor));
			end
		elseif obj.parent.cross_clone then
			obj.background:SetVertexColor(unpack(FW.Settings.LinkCloneColor));
		elseif FW.Settings.LinkNoneColor[0] then
			obj.background:SetVertexColor(unpack(FW.Settings.LinkNoneColor));
		else
			obj.background:Hide();
		end
		--else
		--	obj.background:Hide();
		--	obj.line:Hide();
		--end
	end
	obj.parent:SetScript("OnMouseUp",ClickOption); -- USES PARENT OPTION ONMOUSEUP !!!!
	
	return obj;
end

local function NewOption(parent,o,s,d) -- create a default option frame
	local obj = CreateFrame("Frame",nil,parent);
	obj.o = o;
	obj.s = s or FW.Settings;
	obj.d = d or FW.Default;
	--obj.orig_s =  s or FW.Settings;
	
	obj.parent = parent;
	obj.default = NewDefaultButton(obj);
	obj.linker = NewLinker(obj);
	
	return obj;
end


local function NewButtonOption(parent,o,s,d)
	local obj = CreateFrame("Frame",nil,parent);
	obj.o = o;
	obj.s = s or FW.Settings;
	obj.d = d or FW.Default;
	obj.parent = parent;

	obj:SetWidth(560);
	obj:SetHeight(20);
	
	obj.text = NewTextButton(obj);
	
	obj.text:SetNormalTexture("Interface\\GossipFrame\\BinderGossipIcon");
	obj.text:SetPoint("TOPLEFT",obj,"TOPLEFT",7,-2);
	obj.text:SetPoint("BOTTOMRIGHT",obj,"BOTTOMRIGHT",-7,2);
	obj.text.normaltexture = obj.text:GetNormalTexture();
	obj.text.normaltexture:SetWidth(12);
	obj.text.normaltexture:SetHeight(12);
	obj.text.normaltexture:ClearAllPoints();
	obj.text.normaltexture:SetPoint("LEFT",obj.text,"LEFT",2,0);
	
	obj.background = obj:CreateTexture(nil,"BACKGROUND");
	obj.background:SetPoint("TOPLEFT",obj,"TOPLEFT",7,-2);
	obj.background:SetPoint("BOTTOMRIGHT",obj,"BOTTOMRIGHT",-7,2);
	obj.background:SetTexture(0.8,0.8,0.8);
	obj.background:SetVertexColor(1.00,0.82,0.00);
	
	obj.SetEnabled = function(self,enabled)
		obj.text:SetEnabled(enabled);
		if enabled then
			obj.background:SetVertexColor(1.00,0.82,0.00);
			obj.text.normaltexture:SetDesaturated(false);
		else
			obj.background:SetVertexColor(0.5,0.5,0.5);
			obj.text.normaltexture:SetDesaturated(true);
		end
		
	end
	
	obj.text:SetScript("OnClick",function(self)
		obj:func(true);
	end);
	obj:SetScript("OnShow",function(self)
		obj:SetEnabled(obj:enabled());
	end);
	--
	obj.text:SetScript("OnEnter",function(self)
		obj.background:SetVertexColor(1,1,1);
		FW:ShowOptionsTip(obj);
	end);
	obj.text:SetScript("OnLeave",function(self)
		FW:HideTip(obj);
		obj.background:SetVertexColor(1,0.82,0);
	end);
	obj:SetScript("OnEnter",function(self)
		FW:ShowOptionsTip(obj);
	end);
	obj:SetScript("OnLeave",function(self)
		FW:HideTip(obj);
	end);
	return obj;
end

local function NewCheckOption(parent,o,s,d)
	local obj = NewOption(parent,o,s,d);
	
	obj:EnableMouse(1);	
	obj:SetWidth(560);
	obj:SetHeight(20);
	
	obj.text = NewTextString(obj);
	obj.text:SetPoint("LEFT",obj,"LEFT",28,0);
	
	obj.checkbutton = NewCheckButton(obj);
	obj.checkbutton:SetPoint("LEFT",obj,"LEFT",5,0);
		
	-- scripts
	obj.checkbutton:SetScript("OnClick",function(self)
		obj.s[obj.o] = not obj.s[obj.o];
		obj:func(true);
	end);
	obj:SetScript("OnShow",function(self)
		local enabled = obj:enabled();
		obj.text:SetEnabled(enabled);
		obj.default:SetEnabled(enabled);
		obj.checkbutton:SetEnabled(enabled);
	end);
	obj.checkbutton:SetScript("OnShow",function(self)
		self:SetChecked(obj.s[obj.o]);
	end);
	--
	obj.default:SetScript("OnClick",function(self)
		obj.s[obj.o] = obj.d[obj.o]
		obj:func(true);
	end);
	--
	obj:SetScript("OnEnter",function(self)
		FW:ShowOptionsTip(self);
	end);
	obj:SetScript("OnLeave",function(self)
		FW:HideTip(self);
	end);
	
	return obj;
end

local function NewBackdropOption(parent,o,s,d)
	local obj = NewOption(parent,o,s,d);

	obj:EnableMouse(1);	
	obj:SetWidth(560);
	obj:SetHeight(40);
	
	obj.text = obj:CreateFontString(nil,"ARTWORK","FWFontNormal");
	obj.text:SetWidth(65);
	obj.text:SetHeight(40);
	obj.text:SetJustifyH("LEFT");
	obj.text:SetPoint("LEFT",obj,"LEFT",10,0);
	
	if not backdropdropdown then
		backdropdropdown = NewDropdown(OptionsPanel,function()
			local j=0;
			local s;
			for i, texture in ipairs(FW.TextureList) do
				s = backdropdropdown.items[j] or backdropdropdown:NewBackdropButton(j);
				s:SetNormalTexture(texture);
				s.val=texture;
				s:SetPoint("TOPLEFT",backdropdropdown, "TOPLEFT",5+(j%3)*142,-5-floor(j/3)*34);
				s:Show();
				j=j+1;
			end
			backdropdropdown:SetWidth((142)*3+8);
			backdropdropdown:SetHeight(floor((j-1)/3)*34+42);
			backdropdropdown:Finalize(j+1);
		end);
	end
	
	obj.button = CreateFrame("Frame",nil,obj);
	obj.button:SetWidth(140);
	obj.button:SetHeight(34);
	obj.button:SetPoint("LEFT",obj.text,"RIGHT",5,0);
	obj.button:EnableMouse(1);
	
	obj.overbutton = CreateFrame("Frame",nil,obj.button); 
	obj.overbutton:SetWidth(120);
	obj.overbutton:SetHeight(14);
	obj.overbutton:SetPoint("CENTER",obj.button,"CENTER",0,0);
	obj.overbutton:EnableMouse(1);
	
	obj.checkbutton = NewCheckButton(obj);	
	obj.checkbutton:SetPoint("LEFT",obj.button,"RIGHT",5,10);
	obj.checkbutton:SetWidth(22);
	obj.checkbutton.title = "[tile background, click to toggle]";
	
	obj.tilesize = NewEditBox(obj);
	obj.tilesize:SetPoint("LEFT",obj.checkbutton,"RIGHT",5,0);
	obj.tilesize:SetWidth(22);
	obj.tilesize.title = "[tile size background, click to edit]";
	
	obj.bg = NewEditBox(obj);
	obj.bg:SetPoint("LEFT",obj.tilesize,"RIGHT",5,0);
	obj.bg:SetPoint("RIGHT",obj.default,"LEFT",-5,10);
	obj.bg.title = "[background, click to edit]";
	
	obj.edge = NewEditBox(obj);
	obj.edge:SetPoint("LEFT",obj.button,"RIGHT",5,-10);
	obj.edge:SetWidth(22);
	obj.edge.title = "[border size, click to edit]";
	
	obj.inset = NewEditBox(obj);
	obj.inset:SetPoint("LEFT",obj.edge,"RIGHT",5,0);
	obj.inset:SetWidth(22);
	obj.inset.title = "[edge-content spacing, click to edit]";
	
	obj.border = NewEditBox(obj);
	obj.border:SetPoint("LEFT",obj.inset,"RIGHT",5,0);
	obj.border:SetPoint("RIGHT",obj.default,"LEFT",-5,-10);
	obj.border.title = "[border, click to edit]";
	
	-- scripts
	obj.default:SetScript("OnClick",function(self)
		for k, v in ipairs(obj.d[obj.o]) do
			obj.s[obj.o][k] = v;
		end
		obj.bg:SetText(obj.s[obj.o][1]);
		obj.border:SetText(obj.s[obj.o][2]);
		obj.checkbutton:SetChecked(obj.s[obj.o][3]);
		obj.tilesize:SetText(obj.s[obj.o][4]);
		obj.edge:SetText(obj.s[obj.o][5]);
		obj.inset:SetText(obj.s[obj.o][6]);
		FW:SetBackdrop(obj.button, unpack(obj.s[obj.o]) );
		obj.button:SetBackdropBorderColor(1.00,0.88,0.50);
		obj.button:SetBackdropColor(1.00,0.88,0.50);
		obj:func();
	end);
	--
	obj:SetScript("OnShow",function(self)
		obj.default:SetEnabled(true);
	end);
	obj.button:SetScript("OnEnter",function(self)
		self:SetBackdropBorderColor(1.00,1.00,1.00);
	end);
	obj.button:SetScript("OnLeave",function(self)
		self:SetBackdropBorderColor(1.00,0.88,0.50);
		if not backdropdropdown.over then
			backdropdropdown:Hide();
		end
	end);
	obj.overbutton:SetScript("OnEnter",function(self)
		obj.button:SetBackdropColor(1.00,1.00,1.00);
	end);
	obj.overbutton:SetScript("OnLeave",function(self)
		obj.button:SetBackdropColor(1.00,0.88,0.50);
		if not backdropdropdown.over then
			backdropdropdown:Hide();
		end
	end);
	obj.button:SetScript("OnShow",function(self)
		FW:SetBackdrop(self, unpack(obj.s[obj.o]) );
		self:SetBackdropBorderColor(1.00,0.88,0.50);
		self:SetBackdropColor(1.00,0.88,0.50);
	end);
	--
	obj.checkbutton:SetScript("OnShow",function(self)
		self:SetChecked(obj.s[obj.o][3]);
	end);
	obj.checkbutton:SetScript("OnClick",function(self)
		obj.s[obj.o][3] = not obj.s[obj.o][3];
		self:SetChecked(obj.s[obj.o][3]);
		FW:SetBackdrop(obj.button, unpack(obj.s[obj.o]) );
		obj.button:SetBackdropBorderColor(1.00,0.88,0.50);
		obj.button:SetBackdropColor(1.00,0.88,0.50);
		obj:func();
	end);
	--
	obj.tilesize:SetScript("OnShow",function(self)
		self:SetText(obj.s[obj.o][4]);
	end);
	obj.tilesize:SetScript("OnEnterPressed",function(self)
		local txt = tonumber(self:GetText());
		if txt then
			obj.s[obj.o][4] = txt;
			self:SetText(txt);
			FW:SetBackdrop(obj.button, unpack(obj.s[obj.o]) );
			obj.button:SetBackdropBorderColor(1.00,0.88,0.50);
			obj.button:SetBackdropColor(1.00,0.88,0.50);
			obj:func();
		else
			self:SetText(obj.s[obj.o][4]);
		end
		self:ClearFocus();
	end);
	obj.tilesize:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
		self:SetText(obj.s[obj.o][4]);
	end);
	--
	obj.edge:SetScript("OnShow",function(self)
		self:SetText(obj.s[obj.o][5]);
	end);
	obj.edge:SetScript("OnEnterPressed",function(self)
		local txt = tonumber(self:GetText());
		if txt then
			obj.s[obj.o][5] = txt;
			self:SetText(txt);
			FW:SetBackdrop(obj.button, unpack(obj.s[obj.o]) );
			obj.button:SetBackdropBorderColor(1.00,0.88,0.50);
			obj.button:SetBackdropColor(1.00,0.88,0.50);
			obj:func();
		else
			self:SetText(obj.s[obj.o][5]);
		end
		self:ClearFocus();
	end);
	obj.edge:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
		self:SetText(obj.s[obj.o][5]);
	end);
	--
	obj.inset:SetScript("OnShow",function(self)
		self:SetText(obj.s[obj.o][6]);
	end);
	obj.inset:SetScript("OnEnterPressed",function(self)
		local txt = tonumber(self:GetText());
		if txt then
			obj.s[obj.o][6] = txt;
			self:SetText(txt);
			FW:SetBackdrop(obj.button, unpack(obj.s[obj.o]) );
			obj.button:SetBackdropBorderColor(1.00,0.88,0.50);
			obj.button:SetBackdropColor(1.00,0.88,0.50);
			obj:func();
		else
			self:SetText(obj.s[obj.o][6]);
		end
		self:ClearFocus();
	end);
	obj.inset:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
		self:SetText(obj.s[obj.o][6]);
	end);
	--
	obj.bg:SetScript("OnShow",function(self)
		self:SetText(obj.s[obj.o][1]);
	end);
	obj.bg:SetScript("OnEnterPressed",function(self)
		local txt = self:GetText();
		if txt and txt~="" then
			obj.s[obj.o][1] = txt;
			self:SetText(txt);
			FW:SetBackdrop(obj.button, unpack(obj.s[obj.o]) );
			obj.button:SetBackdropBorderColor(1.00,0.88,0.50);
			obj.button:SetBackdropColor(1.00,0.88,0.50);
			obj:func();
		else
			self:SetText(obj.s[obj.o][1]);
		end
		self:ClearFocus();
	end);
	obj.bg:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
		self:SetText(obj.s[obj.o][1]);
	end);
	--
	obj.border:SetScript("OnShow",function(self)
		self:SetText(obj.s[obj.o][2]);
	end);
	obj.border:SetScript("OnEnterPressed",function(self)
		local txt = self:GetText();
		if txt and txt~="" then
			obj.s[obj.o][2] = txt;
			self:SetText(txt);
			FW:SetBackdrop(obj.button, unpack(obj.s[obj.o]) );
			obj.button:SetBackdropBorderColor(1.00,0.88,0.50);
			obj.button:SetBackdropColor(1.00,0.88,0.50);
			obj:func();
		else
			self:SetText(obj.s[obj.o][2]);
		end
		self:ClearFocus();
	end);
	obj.border:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
		self:SetText(obj.s[obj.o][2]);
	end);

	--
	obj:SetScript("OnEnter",function(self)
		FW:ShowOptionsTip(self);
	end);
	obj:SetScript("OnLeave",function(self)
		FW:HideTip(self);
	end);

	return obj;
end

local function NewSoundOption(parent,o,s,d)
	local obj = NewOption(parent,o,s,d);

	obj:EnableMouse(1);	
	obj:SetWidth(560);
	obj:SetHeight(20);
	
	obj.text = obj:CreateFontString(nil,"ARTWORK","FWFontNormal");
	obj.text:SetWidth(65);
	obj.text:SetHeight(20);
	obj.text:SetJustifyH("LEFT");
	obj.text:SetPoint("LEFT",obj,"LEFT",45,0);
	
	obj.checkbutton = NewCheckButton(obj);	
	obj.checkbutton:SetPoint("LEFT",obj,"LEFT",5,0);	
	
	obj.play = NewPlaySound(obj);
	obj.play:SetPoint("LEFT",obj,"LEFT",25,0);
	
	if not sounddropdown then
		sounddropdown = NewDropdown(OptionsPanel,function()
		local j=0;
		local s;
		for i, data in ipairs(FW.SoundList) do
			s = sounddropdown.items[j] or sounddropdown:NewSoundButton(j);
			s:SetText(data[2]);
			s:SetFont(unpack(FW.Settings.OptionsFont));
			s.o = data[1];
			s:SetPoint("TOPLEFT",sounddropdown, "TOPLEFT",5+(j%3)*142,-5-floor(j/3)*18);
			s:Show();
			j=j+1;
		end
		sounddropdown:SetWidth((142)*3+8);
		sounddropdown:SetHeight(floor((j-1)/3)*18+26);	
		sounddropdown:Finalize(j+1);
	end);

	end
	obj.button = NewDropdownShowButton(obj,sounddropdown)
	obj.button:SetWidth(140);
	obj.button:SetPoint("LEFT",obj.text,"RIGHT",5,0);
	
	obj.editbox2 = NewEditBox(obj);
	obj.editbox2:SetWidth(22);
	obj.editbox2:SetPoint("LEFT",obj.button,"RIGHT",5,0);
	obj.editbox2.minimum = 1;
	obj.editbox2.maximum = 8;
	
	obj.editbox = NewEditBox(obj);
	obj.editbox:SetPoint("LEFT",obj.editbox2,"RIGHT",5,0);
	obj.editbox:SetPoint("RIGHT",obj.default,"LEFT",-5,0);
	
	--scripts
	--obj.title = FW.L.CLICK_TO_EDIT;
	--obj.tip= "";
	--
	obj.default:SetScript("OnClick",function(self)
		obj.s[obj.o][0] = obj.d[obj.o][0];
		obj.s[obj.o][1] = obj.d[obj.o][1];
		obj.s[obj.o][2] = obj.d[obj.o][2];
		obj:func();
	end);
	obj:SetScript("OnShow",function(self)
		obj.default:SetEnabled(true);
	end);
	--
	obj.checkbutton:SetScript("OnClick",function(self)
		obj.s[obj.o][0] = not obj.s[obj.o][0];
		obj:func();
	end);
	obj.checkbutton:SetScript("OnShow",function(self)
		self:SetChecked(obj.s[obj.o][0]);
	end);
	--
	obj.button:SetScript("OnShow",function(self)
		self:SetText(FW:SoundName(obj.s[obj.o][1]));
	end);
	--
	obj.editbox2:SetScript("OnShow",function(self)
		self:SetText(obj.s[obj.o][2]);
	end);
	obj.editbox:SetScript("OnShow",function(self)
		self:SetText(obj.s[obj.o][1]);
	end);
	obj.editbox2:SetScript("OnEnterPressed",function(self)
		local txt = FW:NumberCheck(self);
		if txt then
			obj.s[obj.o][2] = txt;
			obj:func();
		else
			self:SetText(obj.s[obj.o][2]);
		end
		self:ClearFocus();
	end);
	obj.editbox2:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
		self:SetText(obj.s[obj.o][2]);
	end);
	obj.editbox:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
		self:SetText(obj.s[obj.o][1]);
	end);
	--
	obj.editbox:SetScript("OnEnterPressed",function(self)
		local txt = self:GetText();
		if txt and txt~="" then
			obj.s[obj.o][1] = txt;
			obj:func();
		else
			self:SetText(obj.s[obj.o][1]);
		end
		self:ClearFocus();
	end);
	
	obj:SetScript("OnEnter",function(self)
		FW:ShowOptionsTip(self);
	end);
	obj:SetScript("OnLeave",function(self)
		FW:HideTip(self);
	end);
	
	return obj;
end

--[[local function NewCreateTabFrame(parent)
	local obj = CreateFrame("Frame",nil,parent);
	obj.parent = parent;
	
	obj.button = NewTextButton(obj);
	obj.button:SetPoint("TOPLEFT",obj,"TOPLEFT",0,-2);
	
	FW:SetBackdrop(obj,unpack(FW.Settings.OptionsBackdrop));
	
	obj:SetHeight(35);
	
	obj.SetText = function(self,txt)
		obj.button:SetText(txt);
		obj.button:SetWidth(obj.button.text:GetWidth()+FW.Settings.OptionsBackdrop[6]+3);
		obj:SetWidth(obj.button:GetWidth());
	end
	return obj;
end]]

local function NewTabFrame(parent)
	local obj = CreateFrame("Frame",nil,parent);
	local rightspace = 0;
	obj.parent = parent;
	obj.edit = false;
	obj.editing = false;
	
	obj.button = NewTextButton(obj);
	obj.button:SetPoint("TOPLEFT",obj,"TOPLEFT",0,-2);
	obj.button.title = FWL.SELECT_CLONE;
	obj.button.tip = "";
	
	obj.delete = NewTexturedButton(obj,"Interface\\Glues\\Login\\Glues-CheckBox-Check");
	obj.delete:SetPoint("TOPRIGHT",obj,"TOPRIGHT",-5,-5);
	obj.delete:SetHeight(10);
	obj.delete:SetWidth(10);
	obj.delete:Hide();
	obj.delete.title = FWL.DELETE_CLONE;
	obj.delete.tip = "";
	obj:SetHeight(35);
	
	obj.editbox = NewEditBox(obj);
	obj.editbox:SetJustifyH("LEFT");
	obj.editbox:SetPoint("TOPLEFT",obj,"TOPLEFT",5,-2);
	obj.editbox:Hide();
	obj.editbox.title = FWL.RENAMING_CLONE;
	obj.editbox.tip = FWL.CLICK_TO_EDIT_TT;
	
	obj.SetEditable = function(self,edit)
		if edit ~= obj.edit then
			obj.edit = edit;
			if edit then
				rightspace = 15;
				obj.delete:Show();
			else
				rightspace = 0;
				obj.delete:Hide();
			end
			obj:SetWidth(obj.button:GetWidth()+rightspace);
		end
	end
	obj.SetEditing = function(self,editing)
		if editing ~= obj.editing then
			obj.editing = editing;
			if editing then
				obj.button:Hide();
				obj.editbox:SetWidth(120);
				obj:SetWidth(128+rightspace);
				obj.editbox:Show();
				obj.editbox:SetText(obj.button.text:GetText());
				obj.editbox:SetFocus(true);
				
			else
				obj.button:SetWidth(obj.button.text:GetWidth()+8);
				obj:SetWidth(obj.button:GetWidth()+rightspace);
				obj.button:Show();
				obj.editbox:Hide();
			end
		end
	end
	
	obj.SetText = function(self,txt)
		obj.displayname = txt; -- for easier access
		obj.button:SetText(txt);
		obj.button:SetWidth(obj.button.text:GetWidth()+5+3);
		obj:SetWidth(obj.button:GetWidth()+rightspace);
		
	end
	obj.button:SetScript("OnClick",function(self)
		
		if IsShiftKeyDown() or IsControlKeyDown() then
			if obj.link_func then
				obj:link_func();
			end
		else
			if obj.index == NEW_INSTANCE_STRING then
				obj.create_func(obj);
			else
				if obj.parent.parent.root.Active == obj.index then
					if obj.edit then
						obj:SetEditing(true);
					end
				else
					obj.select_func(obj);
				end
			end
		end
	end);

	obj.delete:SetScript("OnClick",function(self)
		--if obj.delete_func then
			obj.delete_func(obj);
		--end
	end);
	obj.editbox:SetScript("OnEnterPressed",function(self)
		local txt = self:GetText();
		if txt and txt~="" then
			obj.rename_func(obj,txt);
		end
		self:ClearFocus();
	end);	
	obj.editbox:SetScript("OnShow",function(self)
	end);
	obj.editbox:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
		obj:SetEditing(false);
	end);
	return obj;
end

local function NewOptionsFrame(parent)
	local obj = CreateFrame("Frame",nil,parent);
	obj.parent = parent;
	obj.normalheader = NewOptionsHeader(obj);
	obj.frameheader = CreateFrame("Frame",nil,obj);
	obj.frameheader.parent = obj;
	
	obj.frameheader.midframe = NewOptionsHeader(obj.frameheader);
	obj.frameheader.leftframe = NewOptionsHeader(obj.frameheader);
	obj.frameheader.rightframe = NewOptionsHeader(obj.frameheader);
	obj.frameheader.rightmidframe = NewOptionsHeader(obj.frameheader);
	obj.frameheader.leftmidframe = NewOptionsHeader(obj.frameheader);
	
	obj.frameheader.default = NewDefaultAllButton(obj.frameheader);
	obj.frameheader.default:SetPoint("RIGHT",obj.frameheader,"RIGHT",-32,0);	

	obj.frameheader.position = NewTexturedButton(obj.frameheader,"Interface\\Glues\\LoadingScreens\\DynamicElements");
	obj.frameheader.position:SetPoint("RIGHT",obj.frameheader.default,"LEFT",-5,0);
	obj.frameheader.position.normaltexture:SetTexCoord(0.5,1.0,0.0,0.5);
	obj.frameheader.position.highlighttexture:SetTexCoord(0.5,1.0,0.0,0.5);
	obj.frameheader.position:SetWidth(14);
	obj.frameheader.position:SetHeight(14);
	
	obj.frameheader.coordinates = NewEditBox(obj.frameheader);
	obj.frameheader.coordinates:SetWidth(60);
	obj.frameheader.coordinates:SetHeight(12);
	obj.frameheader.coordinates:SetPoint("RIGHT",obj.frameheader.position,"LEFT",-3,0);
	
	obj.frameheader.alpharestore = NewTexturedButton(obj.frameheader,"Interface\\Icons\\Spell_Magic_LesserInvisibilty");
	obj.frameheader.alpharestore:SetPoint("RIGHT",obj.frameheader.coordinates,"LEFT",-3,0);
	obj.frameheader.alpharestore:SetWidth(12);
	obj.frameheader.alpharestore:SetHeight(12);	
	
	obj.frameheader.alpha = NewEditBox(obj.frameheader);
	obj.frameheader.alpha:SetWidth(24);
	obj.frameheader.alpha:SetHeight(12);
	obj.frameheader.alpha:SetPoint("RIGHT",obj.frameheader.alpharestore,"LEFT",-3,0);

	obj.frameheader.scalerestore = NewTexturedButton(obj.frameheader,"Interface\\Buttons\\UI-AttributeButton-Encourage-Up");
	obj.frameheader.scalerestore:SetPoint("RIGHT",obj.frameheader.alpha,"LEFT",-3,0);
	obj.frameheader.scalerestore:SetWidth(12);
	obj.frameheader.scalerestore:SetHeight(12);
	
	obj.frameheader.scale = NewEditBox(obj.frameheader);
	obj.frameheader.scale:SetWidth(24);
	obj.frameheader.scale:SetHeight(12);
	obj.frameheader.scale:SetPoint("RIGHT",obj.frameheader.scalerestore,"LEFT",-3,0);

	obj.header = CreateFrame("Frame",nil,obj);
	obj.header:SetHeight(20);
	obj.header:SetPoint("TOPLEFT",obj,"TOPLEFT",0,0);
	obj.header:SetPoint("TOPRIGHT",obj,"TOPRIGHT",0,0);

	obj.header.icon = NewTexturedButton(obj.header,"Interface\\GossipFrame\\BinderGossipIcon");
	obj.header.icon:SetPoint("LEFT",obj.header,"LEFT",2,0);
	obj.header.icon:SetWidth(16);
	obj.header.icon:SetHeight(16);
	obj.header.title = obj.header:CreateFontString(nil,"OVERLAY","FWFontHighlight");
	obj.header.title:SetPoint("CENTER",obj.header,"CENTER",0,0);
	obj.header.default = NewDefaultAllButton(obj.header);
	obj.header.default:SetPoint("RIGHT",obj.header,"RIGHT",-5,0);

	obj.frameheader.lock = NewTexturedButton(obj.frameheader,"Interface\\Glues\\CharacterSelect\\Glues-AddOn-Icons");
	obj.frameheader.lock:SetPoint("LEFT",obj.header.icon,"RIGHT",5,0);
	
	obj.frameheader.midframe:SetPoint("LEFT",obj.header.title,"LEFT",-10,0);
	obj.frameheader.midframe:SetPoint("RIGHT",obj.header.title,"RIGHT",10,0);
	obj.frameheader.leftframe:SetPoint("LEFT",obj.frameheader,"LEFT",0,0);
	obj.frameheader.leftframe:SetPoint("RIGHT",obj.frameheader,"LEFT",40,0);
	obj.frameheader.rightframe:SetPoint("RIGHT",obj.frameheader,"RIGHT",0,0);
	obj.frameheader.rightframe:SetPoint("LEFT",obj.frameheader,"RIGHT",-25,0);
	obj.frameheader.rightmidframe:SetPoint("LEFT",obj.frameheader.midframe,"RIGHT",0,0);
	obj.frameheader.rightmidframe:SetPoint("RIGHT",obj.frameheader.rightframe,"LEFT",0,0);
	obj.frameheader.leftmidframe:SetPoint("LEFT",obj.frameheader.leftframe,"RIGHT",0,0);
	obj.frameheader.leftmidframe:SetPoint("RIGHT",obj.frameheader.midframe,"LEFT",0,0);
	
	obj.frameheader:SetAllPoints(obj.header);
	obj.normalheader:SetAllPoints(obj.header);
	
	--scripts
	obj.frameheader.position.tip = FWL.POSITION_TT;
	obj.frameheader.position.title = FWL.POSITION;
	obj.frameheader.alpharestore.tip = FWL.ALPHA_TT;
	obj.frameheader.alpharestore.title = FWL.ALPHA;
	obj.frameheader.scalerestore.tip = FWL.RESTORE_SCALE_TT;
	obj.frameheader.scalerestore.title = FWL.RESTORE_SCALE;
	obj.frameheader.default.tip = FWL.DEFAULT_FRAME_TT;
	obj.frameheader.default.title = FWL.DEFAULT_FRAME;
	
	obj:SetScript("OnMouseUp",function(self)
		local parent_root = obj.main_data.parent_root;
		local root = obj.main_data.root;
		local parent_link = parent_root and GetLink(parent_root.Active,parent_root);
		local link = root and GetLink(root.Active,root);
	
		local modi = false;
		local alt = IsAltKeyDown();
		
		if IsShiftKeyDown() then
			if parent_root and parent_link or not parent_root and link then
				--FW:Show("smart toggle cross profile");
				local dolink,l,u = false,0,0;
				for sub_index, sub_data in ipairs(FW_Options[obj.index][MAIN_DATA_TABLE]) do -- SUB OPTION LEVEL
					for i, d in ipairs(sub_data[SUB_DATA_TABLE]) do -- OPTION LEVEL
						if d.option and d.option.linker then
							if d.option.cross_profile then
								l = l + 1;
							else
								u = u + 1;
							end
						end
					end
				end
				dolink = (l <= u);
				--FW:Show(tostring(dolink));
				for sub_index, sub_data in ipairs(FW_Options[obj.index][MAIN_DATA_TABLE]) do -- SUB OPTION LEVEL
					for i, d in ipairs(sub_data[SUB_DATA_TABLE]) do -- OPTION LEVEL
						if d.option and d.option.linker then
							if d.option.cross_profile ~= dolink then
								if not dolink or alt or GetOptionsMatch(d.option,true) then
									d.option.cross_profile = dolink;
									d.option:SetLinkedOption(true,d.option.cross_profile);
									if dolink and alt then
										d.option:func(); -- always refreshes the option and sets the option value across linked profiles
									end
								end
							end
						end
					end
				end
				
			end
			modi = true;
		end
		if IsControlKeyDown() then
			if parent_root and link then
				--FW:Show("smart toggle cross clone");
				local dolink,l,u = false,0,0;
				for sub_index, sub_data in ipairs(FW_Options[obj.index][MAIN_DATA_TABLE]) do -- SUB OPTION LEVEL
					for i, d in ipairs(sub_data[SUB_DATA_TABLE]) do -- OPTION LEVEL
						if d.option and d.option.linker then
							if d.option.cross_clone then
								l = l + 1;
							else
								u = u + 1;
							end
						end
					end
				end
				dolink = (l <= u);
				--FW:Show(tostring(dolink));
				for sub_index, sub_data in ipairs(FW_Options[obj.index][MAIN_DATA_TABLE]) do -- SUB OPTION LEVEL
					for i, d in ipairs(sub_data[SUB_DATA_TABLE]) do -- OPTION LEVEL
						if d.option and d.option.linker then
							if d.option.cross_clone ~= dolink then
								if not dolink or alt or GetOptionsMatch(d.option,false) then
									d.option.cross_clone = dolink;
									d.option:SetLinkedOption(false,d.option.cross_clone);
									if dolink and alt then
										d.option:func(); -- always refreshes the option and sets the option value across linked profiles
									end
								end
							end
						end
					end
				end
			end
			modi = true;
		end	
		if not modi then -- smart expand / collapse all
			local expand,e,c = false,0,0;
			for sub_index, sub_data in ipairs(FW_Options[obj.index][MAIN_DATA_TABLE]) do -- SUB OPTION LEVEL
				if sub_data.option then
					if sub_data.option.expand then
						e = e + 1;
					else
						c = c + 1;
					end
				end
			end
			expand = (e <= c);
			for sub_index, sub_data in ipairs(FW_Options[obj.index][MAIN_DATA_TABLE]) do -- SUB OPTION LEVEL
				if sub_data.option then
					sub_data.option.expand = expand;
					FW_GetSubSaveTable(sub_data.option,true).expand = expand;
				end
			end
		end
		OptionsPanel:Draw();  -- rebuild options
		OptionsPanel:Refresh();
	end);				
	
	obj.header.default:SetScript("OnClick",function(self)
		FW_RestoreDefaults(obj);
	end);
	--
	obj.frameheader.default:SetScript("OnClick",function(self)
		FW_RestoreFrameDefaults(obj);
	end);
	--
	obj.frameheader.position:SetScript("OnClick",function(self)
		FW_RestorePosition(self);
	end);
	--
	obj.frameheader.coordinates:SetScript("OnShow",function(self)
		self:SetText(FW_CoordinatesString(obj.instance));
	end);
	obj.frameheader.coordinates:SetScript("OnEnterPressed",function(self)
		local x,y = FW_StringToCoordinates(self:GetText());
		if x then
			obj.instance.s.x = x;
			obj.instance.s.y = y;
			FW:CorrectPosition(obj.instance);
			--self:GetParent():func();
		end
		self:ClearFocus();
	end);
	obj.frameheader.coordinates:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
		self:SetText(FW_CoordinatesString(obj.instance));
	end);
	--
	obj.frameheader.lock:SetScript("OnShow",function(self)
		FW_SetLockIcon(self);
	end);
	obj.frameheader.lock:SetScript("OnEnter",function(self)
		FW:ShowOptionsTip(self);
		self.over=1;
	end);
	obj.frameheader.lock:SetScript("OnLeave",function(self)
		FW:HideTip(self);
		self.over=nil;
	end);
	obj.frameheader.lock:SetScript("OnClick",function(self)
		FW_LockFrame(self);
	end);
	--
	obj.frameheader.alpha:SetScript("OnShow",function(self)
		self:SetText(strformat("%.1f",obj.instance.s.alpha));
	end);
	obj.frameheader.alpha:SetScript("OnEnterPressed",function(self)
		local num = FW:FrameAlphaCheck(self);
		if num then
			obj.instance.s.alpha = num;
		end
		FW_SetFrameAlpha(self);
		self:ClearFocus();
	end);
	obj.frameheader.alpha:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
		self:SetText(strformat("%.1f",obj.instance.s.alpha));
	end);
	--
	obj.frameheader.alpharestore:SetScript("OnClick",function(self)
		 obj.instance.s.alpha = obj.instance.instanceof and FW.InstanceDefault[ obj.instance.instanceof ].alpha or 1;
		FW_SetFrameAlpha(self);
	end);
	--
	obj.frameheader.scale:SetScript("OnShow",function(self)
		self:SetText(strformat("%.1f",obj.instance.s.scale));
	end);
	obj.frameheader.scale:SetScript("OnEnterPressed",function(self)
		local num = FW:FrameScaleCheck(self);
		if num then
			obj.instance.s.scale = num;
		end
		FW_SetFrameScale(self);
		self:ClearFocus();
	end);
	obj.frameheader.scale:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
		self:SetText(strformat("%.1f",obj.instance.s.scale));
	end);
	--
	obj.frameheader.scalerestore:SetScript("OnClick",function(self)
		 obj.instance.s.scale = obj.instance.instanceof and FW.InstanceDefault[ obj.instance.instanceof ].scale or 1;
		FW_SetFrameScale(self);
	end);
	return obj;
end

local function NewSubOptionsFrame(parent)
	local obj = CreateFrame("Frame",nil,parent);
	--obj.expand = false;
	obj.tip = "";
	obj.title = "";
	
	obj.parent = parent;
	obj:SetHeight(20);
	
	obj.header = CreateFrame("Frame",nil,obj);
	obj.header:SetHeight(20);
	obj.header:SetPoint("TOPLEFT",obj,"TOPLEFT",0,0);
	
	obj.header.texture = obj:CreateTexture(nil,"BACKGROUND");
	obj.header.texture:SetPoint("TOPLEFT",obj.header,"TOPLEFT",2,-2);
	obj.header.texture:SetPoint("BOTTOMRIGHT",obj.header,"BOTTOMRIGHT",-2,2);
	
	obj.header.icon = obj.header:CreateTexture(nil,"ARTWORK");
	obj.header.icon:SetTexture("Interface\\GossipFrame\\BinderGossipIcon");
	obj.header.icon:SetWidth(12);
	obj.header.icon:SetHeight(12);
	obj.header.icon:SetPoint("LEFT",obj.header,"LEFT",4,0);
	
	obj.header.title = obj.header:CreateFontString(nil,"ARTWORK","FWFontHighlight");
	obj.header.title:SetPoint("LEFT",obj.header,"LEFT",20,0);
	obj.header.title:SetJustifyH("LEFT");
	
	obj.default = NewDefaultAllButton(obj);
	obj.default:SetPoint("RIGHT",obj.header,"RIGHT",-5,0);
	
	-- scripts
	obj.default:SetScript("OnClick",function(self)
		FW_RestoreDefaults(obj);
	end);
	
	obj:SetScript("OnMouseUp",function(self)
		local parent_root = obj.main_data.parent_root;
		local root = obj.main_data.root;
		local parent_link = parent_root and GetLink(parent_root.Active,parent_root);
		local link = root and GetLink(root.Active,root);
	
		local modi = false;
		local alt = IsAltKeyDown();
		
		if IsShiftKeyDown() then
			if parent_root and parent_link or not parent_root and link then
				--FW:Show("smart toggle cross profile");
				local dolink,l,u = false,0,0;
				for i, d in ipairs(FW_Options[obj.parent.index][MAIN_DATA_TABLE][obj.index][SUB_DATA_TABLE]) do --
					if d.option and d.option.linker then
						if d.option.cross_profile then
							l = l + 1;
						else
							u = u + 1;
						end
					end
				end
				dolink = (l <= u);
				--FW:Show(tostring(dolink));
				for i, d in ipairs(FW_Options[obj.parent.index][MAIN_DATA_TABLE][obj.index][SUB_DATA_TABLE]) do --
					if d.option and d.option.linker then
						if d.option.cross_profile ~= dolink then
							if not dolink or alt or GetOptionsMatch(d.option,true) then
								d.option.cross_profile = dolink;
								d.option:SetLinkedOption(true,d.option.cross_profile);
								if dolink and alt then
									d.option:func(); -- always refreshes the option and sets the option value across linked profiles
								end
							end
						end
					end
			
				end
			end
			modi = true;
		end
		if IsControlKeyDown() then
			if parent_root and link then
				--FW:Show("smart toggle cross clone");
				local dolink,l,u = false,0,0;
				for i, d in ipairs(FW_Options[obj.parent.index][MAIN_DATA_TABLE][obj.index][SUB_DATA_TABLE]) do --
					if d.option and d.option.linker then
						if d.option.cross_clone then
							l = l + 1;
						else
							u = u + 1;
						end
					end
				end
				dolink = (l <= u);
				--FW:Show(tostring(dolink));
				for i, d in ipairs(FW_Options[obj.parent.index][MAIN_DATA_TABLE][obj.index][SUB_DATA_TABLE]) do --
					if d.option and d.option.linker then
						if d.option.cross_clone ~= dolink then
							if not dolink or alt or GetOptionsMatch(d.option,false) then
								d.option.cross_clone = dolink;
								d.option:SetLinkedOption(false,d.option.cross_clone);
								if dolink and alt then
									d.option:func(); -- always refreshes the option and sets the option value across linked profiles
								end
							end
						end
					end
				end
			end
			modi = true;
		end
		if not modi then
			obj.expand = not obj.expand;
			FW_GetSubSaveTable(obj,true).expand = obj.expand;
		end
		OptionsPanel:Draw();	-- rebuild options
		OptionsPanel:Refresh();
		--FW:Show("poke "..tostring(obj.expand));
	end);
	obj:SetScript("OnEnter",function(self)
		FW:ShowOptionsTip(self);
	end);
	obj:SetScript("OnLeave",function(self)
		FW:HideTip(self);
	end);
	
	return obj;
end

local function NewInfoOption(parent,o,s,d)
	local obj = CreateFrame("Frame",nil,parent); -- dont use NewOption function for this one
	obj.o = o;
	obj.s = s or FW.Settings;
	obj.d = d or FW.Default;
	obj.parent = parent;
	
	obj:EnableMouse(1);
	obj:SetWidth(560);
	obj:SetHeight(20);

	obj.text = obj:CreateFontString(nil,"ARTWORK","FWFontHighlight");
	obj.text:SetPoint("LEFT",obj,"LEFT",10,0);
	obj.text:SetJustifyH("LEFT");
	
	return obj;
end

local function NewColor2Option(parent,o,s,d)
	local obj = NewOption(parent,o,s,d);
	local o = obj.o;
	
	obj:EnableMouse(1);
	obj:SetWidth(560);
	obj:SetHeight(20);
	
	obj.text = NewTextString(obj);
	obj.text:SetPoint("LEFT",obj,"LEFT",45,0);

	obj.checkbutton = NewCheckButton(obj);	
	obj.checkbutton:SetPoint("LEFT",obj,"LEFT",5,0);	
	obj.colorswatch = NewColorSwatch(obj);
	obj.colorswatch:SetPoint("LEFT",obj,"LEFT",25,0);	
	
	obj.editbox = NewEditBox(obj);
	obj.editbox:SetPoint("LEFT",obj.text,"RIGHT",5,0);
	obj.editbox:SetPoint("RIGHT",obj.default,"LEFT",-5,0);
	
	--scripts
	obj.default:SetScript("OnClick",function(self)
		obj.s[o][0] = obj.d[o][0];
		obj.s[o][1],obj.s[o][2],obj.s[o][3],obj.s[o][4]=obj.d[o][1],obj.d[o][2],obj.d[o][3],obj.d[o][4];
		obj:func(true);
	end);

	obj.checkbutton:SetScript("OnClick",function(self)
		obj.s[o][0] = not obj.s[o][0];
		obj:func(true);
	end);
	obj.colorswatch:SetScript("OnShow",function(self)
		obj.colorswatch.normaltexture:SetVertexColor(obj.s[o][1],obj.s[o][2],obj.s[o][3],obj.s[o][4] or 1);
		obj.colorswatch.fullalphatexture:SetVertexColor(obj.s[o][1],obj.s[o][2],obj.s[o][3]);
	end);
	obj:SetScript("OnShow",function(self)
		local enabled = obj:enabled();
		obj.text:SetEnabled(enabled);
		obj.colorswatch:SetEnabled(enabled);
		obj.editbox:SetEnabled(enabled);
		obj.default:SetEnabled(enabled);
		obj.checkbutton:SetEnabled(enabled);
	end);
	obj.checkbutton:SetScript("OnShow",function(self)
		self:SetChecked(obj.s[o][0]);
	end);
	obj.editbox:SetScript("OnShow",function(self)
		self:SetText(FW_ColorString(obj.s[o]));
	end);
	obj.editbox:SetScript("OnEnterPressed",function(self)
		local c1,c2,c3,c4 = FW_StringToColor(self:GetText());
		if c1 then
			obj.s[o][1] = c1;
			obj.s[o][2] = c2;
			obj.s[o][3] = c3;
			if obj.d[o][4] then
				obj.s[o][4] = c4 or 1;
			else
				obj.s[o][4] = nil;
			end
			obj:func();
		end
		self:ClearFocus();
	end);
	obj.editbox:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
		self:SetText(FW_ColorString(obj.s[o]));
	end);
	--
	obj:SetScript("OnEnter",function(self)
		FW:ShowOptionsTip(self);
	end);
	obj:SetScript("OnLeave",function(self)
		FW:HideTip(self);
	end);
	
	return obj;
end

local function NewColorOption(parent,o,s,d)
	local obj = NewOption(parent,o,s,d);
	local o = obj.o;

	obj:EnableMouse(1);
	obj:SetWidth(560);
	obj:SetHeight(20);
	
	obj.text = obj:CreateFontString(nil,"ARTWORK","FWFontNormal");
	obj.text:SetJustifyH("LEFT");
	obj.text:SetPoint("LEFT",obj,"LEFT",28,0);
	
	obj.colorswatch = NewColorSwatch(obj);
	obj.colorswatch:SetPoint("LEFT",obj,"LEFT",6,0);	
	
	obj.editbox = NewEditBox(obj);
	obj.editbox:SetPoint("LEFT",obj.text,"RIGHT",5,0);
	obj.editbox:SetPoint("RIGHT",obj.default,"LEFT",-5,0);
	
	--scripts
	--
	obj.default:SetScript("OnClick",function(self)
		obj.s[o][1],obj.s[o][2],obj.s[o][3],obj.s[o][4]=obj.d[o][1],obj.d[o][2],obj.d[o][3],obj.d[o][4];
		obj:func();
	end);
	--
	obj.colorswatch:SetScript("OnShow",function(self)
		obj.colorswatch.normaltexture:SetVertexColor(obj.s[o][1],obj.s[o][2],obj.s[o][3],obj.s[o][4] or 1);
		obj.colorswatch.fullalphatexture:SetVertexColor(obj.s[o][1],obj.s[o][2],obj.s[o][3]);
	end);
	obj:SetScript("OnShow",function(self)
		obj.default:SetEnabled(true);
	end);
	obj.editbox:SetScript("OnShow",function(self)
		self:SetText(FW_ColorString(obj.s[o]));
	end);
	obj.editbox:SetScript("OnEnterPressed",function(self)
		local c1,c2,c3,c4 = FW_StringToColor(self:GetText());
		if c1 then
			obj.s[o][1] = c1;
			obj.s[o][2] = c2;
			obj.s[o][3] = c3;
			if obj.d[o][4] then
				obj.s[o][4] = c4 or 1;
			else
				obj.s[o][4] = nil;
			end
			obj:func();
		end
		self:ClearFocus();
	end);
	obj.editbox:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
		self:SetText(FW_ColorString(obj.s[o]));
	end);
	--
	obj:SetScript("OnEnter",function(self)
		FW:ShowOptionsTip(self);
	end);
	obj:SetScript("OnLeave",function(self)
		FW:HideTip(self);
	end);
	
	return obj;
end

local function NewFilterListItem(parent,n)
	local obj = CreateFrame("Frame",nil,parent);
	obj.parent = parent;
	obj.parent.items[n] = obj;
	
	obj:EnableMouse(1);
	obj:SetWidth(560);
	obj:SetHeight(20);
	
	obj.default = NewDefaultButton(obj);
	
	obj.expandtexture = obj:CreateTexture(nil,"BACKGROUND");
	obj.expandtexture:SetTexture("Interface\\TalentFrame\\UI-TalentBranches");
	obj.expandtexture:SetWidth(20);
	obj.expandtexture:SetHeight(20);
	obj.expandtexture:SetPoint("LEFT",obj,"LEFT",2,0);
	obj.expandtexture:SetTexCoord(0.0,0.1,0.0,0.5);
	
	obj.background = obj:CreateTexture(nil,"BACKGROUND");
	obj.background:SetPoint("TOPLEFT",obj,"TOPLEFT",16,-1);
	obj.background:SetPoint("BOTTOMRIGHT",obj,"BOTTOMRIGHT",-4,1);
	obj.background:SetTexture(0,1,0,0.2);
		
	obj.editbox2 = NewEditBox(obj);
	obj.editbox2:SetWidth(80);
	obj.editbox2:SetHeight(14);
	obj.editbox2:SetPoint("RIGHT",obj.default,"LEFT",-5,0);

	obj.colorswatch = NewButton(obj);
	obj.colorswatch:SetWidth(18);
	obj.colorswatch:SetHeight(18);
	obj.colorswatch:SetPoint("RIGHT",obj.editbox2,"LEFT",0,0);
	obj.colorswatch:SetNormalTexture("Interface\\ChatFrame\\ChatFrameColorSwatch");
	obj.colorswatch.normaltexture = obj.colorswatch:GetNormalTexture();
	obj.colorswatch.backgroundtexture = obj.colorswatch:CreateTexture(nil,"BACKGROUND");
	obj.colorswatch.backgroundtexture:SetWidth(16);
	obj.colorswatch.backgroundtexture:SetHeight(16);
	obj.colorswatch.backgroundtexture:SetPoint("CENTER",obj.colorswatch,"CENTER",0,0);	
	obj.colorswatch.backgroundtexture:SetTexture(0.8,0.8,0.8);
	obj.colorswatch.backgroundtexture:SetVertexColor(1.0,0.82,0.0);

	obj.actionbutton = NewDropdownShowButton(obj,filterdropdown);
	obj.actionbutton:SetWidth(70);
	obj.actionbutton:SetPoint("RIGHT",obj.colorswatch,"LEFT",-5,0);
	
	obj.typebutton = NewDropdownShowButton(obj,filterdropdown);
	obj.typebutton:SetWidth(70);
	obj.typebutton:SetPoint("RIGHT",obj.actionbutton,"LEFT",-5,0);
	
	obj.editbox = NewTextButton(obj);
	obj.editbox:SetPoint("LEFT",obj.expandtexture,"RIGHT",5,0);
	obj.editbox:SetPoint("RIGHT",obj.typebutton,"LEFT",-5,0);
	obj.editbox:SetJustifyH("LEFT");
	obj.editbox:SetHeight(20);
	
	-- scripts
	obj.val = 1; -- ????
	obj.actionbutton.val = 0;
	obj.typebutton.val = 1;
	
	obj.colorswatch.title = FWL.CLICK_TO_EDIT;
	obj.colorswatch.tip = FWL.CLICK_TO_EDIT_TT;
	--
	obj.default:SetScript("OnClick",function(self)
		-- list items should only reset the current spell - type pair to their default action!
		local spell = obj.editbox:GetText();		
		local typ = obj.typebutton.val or 1;
		
		if obj.d[obj.o][spell] and obj.d[obj.o][spell][typ] then
			obj.s[obj.o][spell][typ][1] = obj.d[obj.o][spell][typ][1];
			obj.s[obj.o][spell][typ][2] = obj.d[obj.o][spell][typ][2];
			obj.s[obj.o][spell][typ][3] = obj.d[obj.o][spell][typ][3];
			obj.s[obj.o][spell][typ][4] = obj.d[obj.o][spell][typ][4];									
		else
			obj.s[obj.o][spell][typ] = nil;
		end
		
		obj.parent:func();
		FW_ToggleFilterList();  -- rebuild obj.o list
		FW_FilterSpellUpdate(obj.parent)
	end);
	--
	obj.editbox2:SetScript("OnShow",function(self)
		local spell = obj.editbox:GetText();
		local typ = obj.typebutton.val or 1;
		self:SetText(FW_FilterColorString(obj.s[obj.o][spell] and obj.s[obj.o][spell][typ]));
	end);
	obj.editbox2:SetScript("OnEnterPressed",function(self)
		local spell = obj.editbox:GetText();
		local typ = obj.typebutton.val or 1;
		local c1,c2,c3 = FW_StringToColor(self:GetText());
		if c1 then
			obj.s[obj.o][spell][typ][2] = c1;
			obj.s[obj.o][spell][typ][3] = c2;
			obj.s[obj.o][spell][typ][4] = c3;
			obj.parent:func();
		end
		FW_SetFilterColor(obj.s[obj.o][spell][typ],obj.parent);
		self:SetText(FW_FilterColorString(obj.s[obj.o][spell] and obj.s[obj.o][spell][typ]));
		self:ClearFocus();
	end);
	obj.editbox2:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
		local spell = obj.editbox:GetText();
		local typ = obj.typebutton.val or 1;
		self:SetText(FW_FilterColorString(obj.s[obj.o][spell] and obj.s[obj.o][spell][typ]));
	end);
	--
	obj.colorswatch:SetScript("OnClick",function(self)
		CloseMenus();
		local spell = obj.editbox:GetText();
		local typ = obj.typebutton.val or 1;
		_G.ColorPickerFrame.func = FW_FilterColorPickerApply;
		_G.ColorPickerFrame.colorswatch = self;
		_G.ColorPickerFrame.setting = obj.s[obj.o][spell][typ];
		_G.ColorPickerFrame.hasOpacity = nil;
		
		_G.ColorPickerFrame:SetColorRGB(_G.ColorPickerFrame.setting[2],_G.ColorPickerFrame.setting[3],_G.ColorPickerFrame.setting[4]);
		
		if not _G.ColorPickerFrame.previousValues then _G.ColorPickerFrame.previousValues = {}; end
		_G.ColorPickerFrame.previousValues[1] = _G.ColorPickerFrame.setting[2];
		_G.ColorPickerFrame.previousValues[2] = _G.ColorPickerFrame.setting[3];
		_G.ColorPickerFrame.previousValues[3] = _G.ColorPickerFrame.setting[4];
		_G.ColorPickerFrame.previousValues[4] = nil;	
		_G.ColorPickerFrame.cancelFunc = FW_FilterColorPickerCancel;
		ShowUIPanel(_G.ColorPickerFrame);
	end);
	obj.colorswatch:SetScript("OnEnter",function(self)
		self.backgroundtexture:SetVertexColor(1.00,1.00,1.00);
		FW:ShowOptionsTip(self);
	end);
	obj.colorswatch:SetScript("OnLeave",function(self)
		self.backgroundtexture:SetVertexColor(1.00,0.82,0.00);
		FW:HideTip(self);
	end);
	--
	obj.typebutton:SetScript("OnShow",function(self)
		self:SetText(FW:TypeName(self.val,self.list));
	end);
	--
	obj.editbox:SetScript("OnClick",function(self)
		obj.parent.typebutton.val = obj.typebutton.val;
		obj.parent.typebutton:SetText(FW:TypeName(obj.typebutton.val,obj.typebutton.list));
		obj.parent.editbox:SetText("");
		obj.parent.editbox:SetText(self:GetText());
	end);
	--[[
	obj:SetScript("OnEnter",function(self)
		FW:ShowOptionsTip(self);
	end);
	obj:SetScript("OnLeave",function(self)
		FW:HideTip(self);
	end);]]
	
	return obj;
end

local function NewFilterOption(parent,o,s,d)
	local obj = NewOption(parent,o,s,d);
	
	local filter = obj.o;
	
	obj.items = {};
	obj.NewFilterListItem = NewFilterListItem;
	
	obj.Finalize = function(self,i)
		while obj.items[i] and obj.items[i]:IsShown() do
			obj.items[i]:Hide();
			i=i+1;
		end
	end
	
	obj:EnableMouse(1);
	obj:SetWidth(560);
	obj:SetHeight(20);
	
	obj.text = obj:CreateFontString(nil,"ARTWORK","FWFontNormal");
	obj.text:SetHeight(20);
	obj.text:SetJustifyH("LEFT");
	obj.text:SetPoint("LEFT",obj,"LEFT",24,0);
	
	obj.editbox2 = NewEditBox(obj);
	obj.editbox2:SetWidth(80);
	obj.editbox2:SetHeight(14);
	obj.editbox2:SetPoint("RIGHT",obj.default,"LEFT",-5,0);

	obj.colorswatch = NewButton(obj)
	obj.colorswatch:SetWidth(18);
	obj.colorswatch:SetHeight(18);
	obj.colorswatch:SetPoint("RIGHT",obj.editbox2,"LEFT",0,0);
	obj.colorswatch:SetNormalTexture("Interface\\ChatFrame\\ChatFrameColorSwatch");
	obj.colorswatch.normaltexture = obj.colorswatch:GetNormalTexture();
	obj.colorswatch.backgroundtexture = obj.colorswatch:CreateTexture(nil,"BACKGROUND");
	obj.colorswatch.backgroundtexture:SetWidth(16);
	obj.colorswatch.backgroundtexture:SetHeight(16);
	obj.colorswatch.backgroundtexture:SetPoint("CENTER",obj.colorswatch,"CENTER",0,0);	
	obj.colorswatch.backgroundtexture:SetTexture(0.8,0.8,0.8);
	obj.colorswatch.backgroundtexture:SetVertexColor(1.0,0.82,0.0);
	
	if not filterdropdown then
		filterdropdown = NewDropdown(OptionsPanel,function()
			filterdropdown:SetWidth(80);
			local i=0;
			local f;
			for key,val in ipairs(filterdropdown.button.list) do
				i=i+1;
				f = filterdropdown.items[i] or filterdropdown:NewFilterButton(i);
				
				f:SetPoint("TOPLEFT",filterdropdown, "TOPLEFT",5,13-i*18);
				f:SetText(val[2]);
				f:SetFont(unpack(FW.Settings.OptionsFont));
				f.val=val[1];
				f:Show();
			end
			filterdropdown:SetHeight(i*18+8);
			filterdropdown:Finalize(i+1);
		end);
	end
	
	obj.actionbutton = NewDropdownShowButton(obj,filterdropdown)
	obj.actionbutton:SetWidth(70);
	obj.actionbutton:SetPoint("RIGHT",obj.colorswatch,"LEFT",-5,0);
	
	obj.typebutton = NewDropdownShowButton(obj,filterdropdown)
	obj.typebutton:SetWidth(70);
	obj.typebutton:SetPoint("RIGHT",obj.actionbutton,"LEFT",-5,0);
	
	obj.expandbutton = NewTexturedButton(obj,"Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
	obj.expandbutton:SetWidth(16);
	obj.expandbutton:SetHeight(16);
	obj.expandbutton:SetPoint("LEFT",obj,"LEFT",7,0);
	obj.expandbutton:EnableMouse(false);
	
	obj.editbox = NewEditBox(obj);
	obj.editbox:SetPoint("LEFT",obj.text,"RIGHT",5,0);
	obj.editbox:SetPoint("RIGHT",obj.typebutton,"LEFT",-5,0);
	--obj.editbox:SetText("enter ability/spell/item name");
	obj.editbox:SetJustifyH("LEFT");

	-- scripts
	obj.val = 1; -- ????
	obj.actionbutton.val = 0;
	obj.typebutton.val = 1;
	obj.expand = false;
	
	obj.editbox.val = "enter ability/spell/item name";
	
	obj.colorswatch.title = FWL.CLICK_TO_EDIT;
	obj.colorswatch.tip = FWL.CLICK_TO_EDIT_TT;
	--obj.expandbutton.title = FWL.TOGGLE_FILTER_LIST;
	--obj.expandbutton.tip = "";
	
	--
	obj.default:SetScript("OnClick",function(self)
		-- resets als filters of this spell name!!!
		local spell = obj.editbox:GetText();
		local typ = 1;
		local action = 0;
		if obj.d[filter][spell] then
			if not obj.s[filter][spell] then
				obj.s[filter][spell] = {};
			else
				for k in pairs(obj.s[filter][spell]) do
					if not obj.d[filter][spell][k] then
						obj.s[filter][spell][k] = nil;
					end
				end
			end
			for k in pairs(obj.d[filter][spell]) do
				typ = k;
				if not obj.s[filter][spell][k] then
					obj.s[filter][spell][k] = {};
				end
				action = obj.d[filter][spell][k][1];
				obj.s[filter][spell][k][1] = obj.d[filter][spell][k][1];
				obj.s[filter][spell][k][2] = obj.d[filter][spell][k][2];
				obj.s[filter][spell][k][3] = obj.d[filter][spell][k][3];
				obj.s[filter][spell][k][4] = obj.d[filter][spell][k][4];
			end
		else
			obj.s[filter][spell]=nil;
		end
		obj:func();
		obj.actionbutton:SetText(FW:TypeName(action,obj.actionbutton.list));
		obj.typebutton:SetText(FW:TypeName(typ,obj.typebutton.list));
		FW_SetFilterColor(obj.s[filter][spell] and obj.s[filter][spell][typ],obj);
		
		FW_ToggleFilterList();  -- rebuild filter list
	end);
	--
	obj.editbox2:SetScript("OnShow",function(self)
		local spell = obj.editbox:GetText();
		local typ = obj.typebutton.val or 1;
		self:SetText(FW_FilterColorString(obj.s[filter][spell] and obj.s[filter][spell][typ]));
	end);
	obj.editbox2:SetScript("OnEnterPressed",function(self)
		local spell = obj.editbox:GetText();
		local typ = obj.typebutton.val or 1;
		local c1,c2,c3 = FW_StringToColor(self:GetText());
		if c1 then
			obj.s[filter][spell][typ][2] = c1;
			obj.s[filter][spell][typ][3] = c2;
			obj.s[filter][spell][typ][4] = c3;
			obj:func();
		end
		FW_SetFilterColor(obj.s[filter][spell][typ],obj);
		self:SetText(FW_FilterColorString(obj.s[filter][spell] and obj.s[filter][spell][typ]));
		self:ClearFocus();
	end);
	obj.editbox2:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
		local spell = obj.editbox:GetText();
		local typ = obj.typebutton.val or 1;
		self:SetText(FW_FilterColorString(obj.s[filter][spell] and obj.s[filter][spell][typ]));
	end);
	--
	obj.colorswatch:SetScript("OnClick",function(self)
		CloseMenus();
		local spell = obj.editbox:GetText();
		local typ = obj.typebutton.val or 1;
		_G.ColorPickerFrame.func = FW_FilterColorPickerApply;
		_G.ColorPickerFrame.colorswatch = self;
		_G.ColorPickerFrame.setting = obj.s[filter][spell][typ];
		_G.ColorPickerFrame.hasOpacity = nil;
		
		_G.ColorPickerFrame:SetColorRGB(_G.ColorPickerFrame.setting[2],_G.ColorPickerFrame.setting[3],_G.ColorPickerFrame.setting[4]);
		
		if not _G.ColorPickerFrame.previousValues then _G.ColorPickerFrame.previousValues = {}; end
		_G.ColorPickerFrame.previousValues[1] = _G.ColorPickerFrame.setting[2];
		_G.ColorPickerFrame.previousValues[2] = _G.ColorPickerFrame.setting[3];
		_G.ColorPickerFrame.previousValues[3] = _G.ColorPickerFrame.setting[4];
		_G.ColorPickerFrame.previousValues[4] = nil;	
		_G.ColorPickerFrame.cancelFunc = FW_FilterColorPickerCancel;
		ShowUIPanel(_G.ColorPickerFrame);
	end);
	obj.colorswatch:SetScript("OnEnter",function(self)
		self.backgroundtexture:SetVertexColor(1.00,1.00,1.00);
		FW:ShowOptionsTip(self);
	end);
	obj.colorswatch:SetScript("OnLeave",function(self)
		self.backgroundtexture:SetVertexColor(1.00,0.82,0.00);
		FW:HideTip(self);
	end);
	--
	obj.typebutton:SetScript("OnShow",function(self)
		self:SetText(FW:TypeName(self.val,self.list));
	end);
	obj:SetScript("OnMouseUp",function(self,button)
		if IsShiftKeyDown() or IsControlKeyDown() then -- link actions
			ClickOption(self,button);
		else -- normal actions
			obj.expand = not obj.expand;
			FW_ToggleFilterList();  -- rebuild filter list
		end
	end);	
	--
	obj.editbox:SetScript("OnShow",function(self)
		obj.editbox:SetText(self.val);
		FW_FilterSpellUpdate(obj);
	end);
	obj.editbox:SetScript("OnChar",function(self)
		FW_AutoComplete(self,obj.s[filter],FW.SpellInfo,FW.CooldownsPet,FW.CooldownsSpells,FW.CooldownsBuffs);
	end);
	obj.editbox:SetScript("OnTextChanged",function(self)
		FW_FilterSpellUpdate(obj);
	end);
	obj.editbox:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
	end);
	--
	obj:SetScript("OnEnter",function(self)
		FW:ShowOptionsTip(self);
		obj.expandbutton:LockHighlight();
	end);
	obj:SetScript("OnLeave",function(self)
		FW:HideTip(self);
		if not obj.expand then
			obj.expandbutton:UnlockHighlight();
		end
	end);
	return obj;
end

local function NewStringOption(parent,o,s,d)
	local obj = NewOption(parent,o,s,d);
	
	obj:EnableMouse(1);
	obj:SetWidth(560);
	obj:SetHeight(20);
	
	obj.text = NewTextString(obj);
	obj.text:SetPoint("LEFT",obj,"LEFT",10,0);
			
	obj.editbox = NewEditBox(obj);
	obj.editbox:SetWidth(70);
	obj.editbox:SetHeight(14);
	obj.editbox:SetPoint("LEFT",obj.text,"RIGHT",5,0);
	obj.editbox:SetPoint("RIGHT",obj.default,"LEFT",-5,0);
	
	-- scripts
	obj:SetScript("OnShow",function(self)
		local enabled = obj:enabled();
		obj.text:SetEnabled(enabled);
		obj.default:SetEnabled(enabled);
		obj.editbox:SetEnabled(enabled);
	end);
	
	obj.default:SetScript("OnClick",function(self)
		obj.s[obj.o] = obj.d[obj.o];
		obj:func();
	end);
	--
	obj.editbox:SetScript("OnEnterPressed",function(self)
		obj.s[obj.o] = self:GetText();
		obj:func();
		self:ClearFocus();
	end);
	--
	obj:SetScript("OnEnter",function(self)
		FW:ShowOptionsTip(self);
	end);
	obj:SetScript("OnLeave",function(self)
		FW:HideTip(self);
	end);

	return obj;
end

local function NewMessage1Option(parent,o,s,d)
	local obj = NewOption(parent,o,s,d);
	
	obj:EnableMouse(1);
	obj:SetWidth(560);
	obj:SetHeight(20);
	
	obj.text = NewTextString(obj);
	obj.text:SetPoint("LEFT",obj,"LEFT",30,0);
	
	obj.checkbutton = NewCheckButton(obj);
	obj.checkbutton:SetPoint("LEFT",obj,"LEFT",5,0);
			
	obj.editbox = NewEditBox(obj);
	obj.editbox:SetWidth(70);
	obj.editbox:SetHeight(14);
	obj.editbox:SetPoint("LEFT",obj.text,"RIGHT",5,0);
	obj.editbox:SetPoint("RIGHT",obj.default,"LEFT",-5,0);
	
	-- scripts
	obj.checkbutton:SetScript("OnClick",function(self)
		obj.s[obj.o][0] = not obj.s[obj.o][0];
		obj:func(true);
	end);
	obj:SetScript("OnShow",function(self)
		local enabled = obj:enabled();
		obj.text:SetEnabled(enabled);
		obj.editbox:SetEnabled(enabled);
		obj.default:SetEnabled(enabled);
		obj.checkbutton:SetEnabled(enabled);
	end);
	obj.checkbutton:SetScript("OnShow",function(self)
		self:SetChecked(obj.s[obj.o][0]);
	end);
	--
	obj.default:SetScript("OnClick",function(self)
		obj.s[obj.o][0] = obj.d[obj.o][0];
		obj.s[obj.o][1] = obj.d[obj.o][1];
		obj:func(true);
	end);
	--
	obj.editbox:SetScript("OnShow",function(self)
		self:SetText(obj.s[obj.o][1]);
	end);
	obj.editbox:SetScript("OnEnterPressed",function(self)
		obj.s[obj.o][1] = self:GetText();
		obj:func();
		self:ClearFocus();
	end);
	obj.editbox:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
		self:SetText(obj.s[obj.o][1]);

	end);
	--
	obj:SetScript("OnEnter",function(self)
		FW:ShowOptionsTip(self);
	end);
	obj:SetScript("OnLeave",function(self)
		FW:HideTip(self);
	end);
	
	return obj;
end

local function NewMessage2Option(parent,o,s,d)
	local obj = NewOption(parent,o,s,d);

	obj:EnableMouse(1);
	obj:SetWidth(560);
	obj:SetHeight(20);
	
	obj.text = NewTextString(obj);
	obj.text:SetPoint("LEFT",obj,"LEFT",50,0);
	
	obj.checkbutton1 = NewCheckButton(obj);
	obj.checkbutton1:SetPoint("LEFT",obj,"LEFT",5,0);

	obj.checkbutton2 = NewCheckButton(obj);
	obj.checkbutton2:SetPoint("LEFT",obj.checkbutton1,"RIGHT",0,0);
			
	obj.editbox = NewEditBox(obj);
	obj.editbox:SetWidth(70);
	obj.editbox:SetHeight(14);
	obj.editbox:SetPoint("LEFT",obj.text,"RIGHT",5,0);
	obj.editbox:SetPoint("RIGHT",obj.default,"LEFT",-5,0);
	
	-- scripts
	obj.checkbutton1:SetScript("OnClick",function(self)
		if bit.band(1,obj.s[obj.o][0]) == 0 then
			obj.s[obj.o][0] = bit.bor(obj.s[obj.o][0],1);
		else
			obj.s[obj.o][0] = bit.bxor(obj.s[obj.o][0],1);
		end
		obj:func(true);
	end);
	obj:SetScript("OnShow",function(self)
		local enabled = obj:enabled();
		obj.text:SetEnabled(enabled);
		obj.editbox:SetEnabled(enabled);
		obj.default:SetEnabled(enabled);
		obj.checkbutton1:SetEnabled(enabled);
		obj.checkbutton2:SetEnabled(enabled);
	end);
	obj.checkbutton1:SetScript("OnShow",function(self)
		self:SetChecked( bit.band(1,obj.s[obj.o][0]) ~= 0 );
	end);

	obj.checkbutton2:SetScript("OnClick",function(self)
		if bit.band(2,obj.s[obj.o][0]) == 0 then
			obj.s[obj.o][0] = bit.bor(obj.s[obj.o][0],2);
		else
			obj.s[obj.o][0] = bit.bxor(obj.s[obj.o][0],2);
		end
		obj:func(true);
	end);
	obj.checkbutton2:SetScript("OnShow",function(self)
		self:SetChecked( bit.band(2,obj.s[obj.o][0]) ~= 0 );
	end);
	--
	obj.default:SetScript("OnClick",function(self)
		obj.editbox:SetText(obj.d[obj.o][1]);
		obj.s[obj.o][1] = obj.d[obj.o][1];
		obj.s[obj.o][0] = obj.d[obj.o][0];
		obj:func(true);
	end);
	--
	obj.editbox:SetScript("OnShow",function(self)
		self:SetText(obj.s[obj.o][1]);
	end);
	obj.editbox:SetScript("OnEnterPressed",function(self)
		obj.s[obj.o][1] = self:GetText();
		obj:func();
		self:ClearFocus();
	end);
	obj.editbox:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
		self:SetText(obj.s[obj.o][1]);
	end);
	--
	obj:SetScript("OnEnter",function(self)
		FW:ShowOptionsTip(self);
	end);
	obj:SetScript("OnLeave",function(self)
		FW:HideTip(self);
	end);
	
	return obj;
end

local function NewLinkOption(parent,o,s,d)
	local obj = CreateFrame("Frame",nil,parent);
	obj.o = o;
	obj.parent = parent;
	obj.default = NewDefaultButton(obj);
	
	obj:EnableMouse(1);
	obj:SetWidth(560);
	obj:SetHeight(20);
	
	obj.text = obj:CreateFontString(nil,"ARTWORK","FWFontNormal");
	obj.text:SetJustifyH("LEFT");
	obj.text:SetPoint("LEFT",obj,"LEFT",10,0);
			
	obj.editbox = NewEditBox(obj);
	obj.editbox:SetWidth(70);
	obj.editbox:SetHeight(14);
	obj.editbox:SetPoint("LEFT",obj.text,"RIGHT",5,0);
	obj.editbox:SetPoint("RIGHT",obj.default,"LEFT",-5,0);
	obj.editbox:SetMaxLetters(128);
	
	-- scripts
	obj.editbox.title = FW.L.CLICK_TO_COPY;
	obj.editbox.tip = "";
	
	obj.default:SetScript("OnClick",function(self)
		obj.editbox:SetFocus();
		obj.editbox:HighlightText();
	end);
	--
	obj.editbox:SetScript("OnShow",function(self)
		self:SetText(obj.o);
	end);
	obj.editbox:SetScript("OnEnterPressed",function(self)
		self:ClearFocus();
	end);
	obj.editbox:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
	end);
	obj.editbox:SetScript("OnTextChanged",function(self)
		if self:GetText() ~= obj.o then
			self:SetText(obj.o);
		end
	end);
	--
	obj:SetScript("OnEnter",function(self)
		FW:ShowOptionsTip(self);
	end);
	obj:SetScript("OnLeave",function(self)
		FW:HideTip(self);
	end);
	
	return obj;
end

local function NewNumberOption(parent,o,s,d)
	local obj = NewOption(parent,o,s,d);
	
	obj:EnableMouse(1);	
	obj:SetWidth(560);
	obj:SetHeight(20);
	
	obj.text = NewTextString(obj);
	obj.text:SetPoint("LEFT",obj,"LEFT",10,0);
			
	obj.editbox = NewEditBox(obj);
	obj.editbox:SetWidth(70);
	obj.editbox:SetPoint("LEFT",obj.text,"RIGHT",5,0);
	obj.editbox:SetPoint("RIGHT",obj.default,"LEFT",-5,0);

	-- scripts
	obj:SetScript("OnShow",function(self)
		local enabled = obj:enabled();
		obj.text:SetEnabled(enabled);
		obj.editbox:SetEnabled(enabled);
		obj.default:SetEnabled(enabled);
	end);
	
	obj.default:SetScript("OnClick",function(self)
		obj.editbox:SetText(obj.d[obj.o]);
		obj.s[obj.o] = obj.d[obj.o];
		obj:func();
	end);
	--
	obj.editbox:SetScript("OnEnterPressed",function(self)
		local num = FW:NumberCheck(self);
		if num then
			obj.s[obj.o] = num;
			obj:func();
		else
			self:SetText(obj.s[obj.o]);
		end
		self:ClearFocus();
	end);
	--
	obj:SetScript("OnEnter",function(self)
		FW:ShowOptionsTip(self);
	end);
	obj:SetScript("OnLeave",function(self)
		FW:HideTip(self);
	end);
	
	return obj;
end

local function NewNumber2Option(parent,o,s,d)
	local obj = NewOption(parent,o,s,d);
	
	obj:EnableMouse(1);	
	obj:SetWidth(560);
	obj:SetHeight(20);
	
	obj.text = NewTextString(obj);
	obj.text:SetPoint("LEFT",obj,"LEFT",30,0);
	
	obj.checkbutton = NewCheckButton(obj);
	obj.checkbutton:SetPoint("LEFT",obj,"LEFT",5,0);
			
	obj.editbox = NewEditBox(obj);
	obj.editbox:SetWidth(70);
	obj.editbox:SetHeight(14);
	obj.editbox:SetPoint("LEFT",obj.text,"RIGHT",5,0);
	obj.editbox:SetPoint("RIGHT",obj.default,"LEFT",-5,0);
	
	-- scripts
	obj.checkbutton:SetScript("OnClick",function(self)
		obj.s[obj.o][0] = not obj.s[obj.o][0];
		obj:func(true);
	end);
	obj:SetScript("OnShow",function(self)
		local enabled = obj:enabled();
		obj.text:SetEnabled(enabled);
		obj.default:SetEnabled(enabled);
		obj.checkbutton:SetEnabled(enabled);
	end);
	obj.checkbutton:SetScript("OnShow",function(self)
		self:SetChecked(obj.s[obj.o][0]);
	end);
	--
	obj.default:SetScript("OnClick",function(self)
		obj.s[obj.o][0] = obj.d[obj.o][0];
		obj.s[obj.o][1] = obj.d[obj.o][1];
		obj:func(true);
	end);
	--
	obj.editbox:SetScript("OnShow",function(self)
		self:SetText(obj.s[obj.o][1]);
	end);

	obj.editbox:SetScript("OnEnterPressed",function(self)
		local num = FW:NumberCheck(self);
		if num then
			obj.s[obj.o][1] = num;
			obj:func();
		else
			self:SetText(obj.s[obj.o][1]);
		end
		self:ClearFocus();
	end);
	obj.editbox:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
		self:SetText(obj.s[obj.o][1]);
	end);
	--
	obj:SetScript("OnEnter",function(self)
		FW:ShowOptionsTip(self);
	end);
	obj:SetScript("OnLeave",function(self)
		FW:HideTip(self);
	end);
	
	return obj;
end

local function toShortFlags(flags)
	if flags then
		-- OUTLINE","THICKOUTLINE","MONOCHROME"
		flags = flags:gsub("THICKOUTLINE","T");
		flags = flags:gsub("OUTLINE","O");
		flags = flags:gsub("MONOCHROME","M");
		return (flags:gsub(",",""));
	else
		return "";
	end
end
local temp_done = {};
local allowed_flags = {T="THICKOUTLINE",O="OUTLINE",M="MONOCHROME"};
local function toNormalFlags(flags)
	local out = "";
	flags = flags:upper();
	erase(temp_done);
	local function isAllowed(char)
		if not temp_done[char] and allowed_flags[char] then
			temp_done[char] = true;
			return allowed_flags[char];
		end
	end
	for i=1,flags:len(),1 do
		local c = isAllowed(flags:sub(i,i));
		if c then
			out = out..c..",";
		end
	end
	return out:sub(1,-2);
end

local function NewFontOption(parent,o,s,d)
	local obj = NewOption(parent,o,s,d);
	
	obj:EnableMouse(1);
	obj:SetWidth(560);
	obj:SetHeight(20);
	
	obj.text = NewTextString(obj);
	obj.text:SetWidth(65);
	obj.text:SetHeight(20);
	obj.text:SetPoint("LEFT",obj,"LEFT",10,0);
	
	if not fontdropdown then
		fontdropdown = NewDropdown(OptionsPanel,function()
			local j=0;
			local f;
			for i, data in ipairs(FW.FontList) do
				f = fontdropdown.items[j] or fontdropdown:NewFontButton(j);
				f:SetText(data[2]);
				f:SetFont(data[1],11);
				f.val=data[1];
				f:SetPoint("TOPLEFT",fontdropdown, "TOPLEFT",5+(j%3)*142,-5-floor(j/3)*18);
				f:Show();
				j=j+1;
			end
			fontdropdown:SetHeight(floor((j-1)/3)*18+26);	
			fontdropdown:SetWidth((142)*3+8);
			fontdropdown:Finalize(j+1);
		end);
	end
	obj.button = NewDropdownShowButton(obj,fontdropdown)
	obj.button:SetWidth(140);
	obj.button:SetPoint("LEFT",obj.text,"RIGHT",5,0);
	
	obj.editbox2 = NewEditBox(obj);
	obj.editbox2:SetWidth(22);
	obj.editbox2:SetPoint("LEFT",obj.button,"RIGHT",5,0);
	obj.editbox2.minimum = 1;
	obj.editbox2.maximum = 64;
	
	obj.editbox3 = NewEditBox(obj);
	obj.editbox3:SetWidth(22);
	obj.editbox3:SetPoint("LEFT",obj.editbox2,"RIGHT",5,0);
	
	obj.editbox = NewEditBox(obj);
	obj.editbox:SetPoint("LEFT",obj.editbox3,"RIGHT",5,0);
	obj.editbox:SetPoint("RIGHT",obj.default,"LEFT",-5,0);

	--scripts
	obj.default:SetScript("OnClick",function(self)
		obj.s[obj.o][1] = obj.d[obj.o][1];
		obj.s[obj.o][2] = obj.d[obj.o][2];
		obj.s[obj.o][3] = obj.d[obj.o][3];
		obj:func();
	end);
	--
	obj:SetScript("OnShow",function(self)
		local enabled = obj:enabled();
		obj.text:SetEnabled(enabled);
		obj.editbox2:SetEnabled(enabled);
		obj.editbox3:SetEnabled(enabled);
		obj.editbox:SetEnabled(enabled);
		obj.button:SetEnabled(enabled);
		obj.default:SetEnabled(enabled);
	end);
	obj.button:SetScript("OnShow",function(self)
		self:SetText(FW:FontName(obj.s[obj.o][1]));
		self:SetFont(unpack(obj.s[obj.o]));
	end);
	--
	obj.editbox:SetScript("OnShow",function(self)
		self:SetText(obj.s[obj.o][1]);
	end);
	obj.editbox2:SetScript("OnShow",function(self)
		self:SetText(obj.s[obj.o][2]);
	end);
	obj.editbox2:SetScript("OnEnterPressed",function(self)
		local txt = FW:NumberCheck(self);
		if txt then
			obj.s[obj.o][2] = txt;
			obj:func();
		else
			self:SetText(obj.s[obj.o][2]);
		end
		self:ClearFocus();
	end);
	obj.editbox2:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
		self:SetText(obj.s[obj.o][2]);
	end);
	--
	obj.editbox3:SetScript("OnShow",function(self)
		self:SetText(toShortFlags(obj.s[obj.o][3]));
	end);
	obj.editbox3:SetScript("OnEnterPressed",function(self)
		obj.s[obj.o][3] = toNormalFlags(self:GetText());
		obj:func();
		self:ClearFocus();
	end);
	obj.editbox3:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
		self:SetText(toShortFlags(obj.s[obj.o][3]));
	end);
	--
	obj.editbox:SetScript("OnEnterPressed",function(self)
		local txt = self:GetText();
		if txt and txt~="" then
			obj.s[obj.o][1] = txt;
			obj:func();
		else
			self:SetText(obj.s[obj.o][1]);
		end
		self:ClearFocus();
	end);
	obj.editbox:SetScript("OnEditFocusLost",function(self)
		self:HighlightText(0,0);
		self:SetText(obj.s[obj.o][1]);
	end);
	--
	obj:SetScript("OnEnter",function(self)
		FW:ShowOptionsTip(self);
	end);
	obj:SetScript("OnLeave",function(self)
		FW:HideTip(self);
	end);
	
	return obj;
end

local function NewTextureOption(parent,o,s,d)
	local obj = NewOption(parent,o,s,d);

	obj:EnableMouse(1);
	obj:SetWidth(560);
	obj:SetHeight(20);
	
	obj.text = obj:CreateFontString(nil,"ARTWORK","FWFontNormal");
	obj.text:SetWidth(65);
	obj.text:SetHeight(20);
	obj.text:SetJustifyH("LEFT");
	obj.text:SetPoint("LEFT",obj,"LEFT",10,0);
	
	if not texturedropdown then
		texturedropdown = NewDropdown(OptionsPanel,function()
			local j=0;
			local s;
			for i, texture in ipairs(FW.TextureList) do
				s = texturedropdown.items[j] or texturedropdown:NewTextureButton(j);
				s:SetNormalTexture(texture);
				s.val=texture;
				s:SetPoint("TOPLEFT",texturedropdown, "TOPLEFT",5+(j%3)*142,-5-floor(j/3)*18);
				s:Show();
				j=j+1;
			end
			texturedropdown:SetWidth((142)*3+8);
			texturedropdown:SetHeight(floor((j-1)/3)*18+26);
			texturedropdown:Finalize(j+1);
		end);
	end
	
	obj.button = NewButton(obj)
	obj.button:SetWidth(140);
	obj.button:SetHeight(14);
	obj.button:SetPoint("LEFT",obj.text,"RIGHT",5,0);
	obj.button:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar");
	obj.button.normaltexture = obj.button:GetNormalTexture();
	obj.button.normaltexture:SetVertexColor(1.00,0.88,0.50);
	
	obj.editbox = NewEditBox(obj);
	obj.editbox:SetPoint("LEFT",obj.button,"RIGHT",5,0);
	obj.editbox:SetPoint("RIGHT",obj.default,"LEFT",-5,0);

	--scripts
	obj.default:SetScript("OnCLick",function(self)
		obj.editbox:SetText(obj.d[obj.o]);
		obj.button:SetNormalTexture(obj.d[obj.o]);
		obj.s[obj.o] = obj.d[obj.o];
		obj:func();
	end);
	--
	obj:SetScript("OnShow",function(self)
		obj.default:SetEnabled(true);
	end);
	obj.button:SetScript("OnShow",function(self)
		self:SetNormalTexture(obj.s[obj.o]);
	end);
	obj.button:SetScript("OnEnter",function(self)
		self.normaltexture:SetVertexColor(1.00,1.00,1.00);
		texturedropdown.button = self;
		texturedropdown:Build();
		texturedropdown:SetPoint("TOPLEFT",self, "BOTTOMLEFT",-5,0);
		texturedropdown:Show();
	end);
	obj.button:SetScript("OnLeave",function(self)
		self.normaltexture:SetVertexColor(1.00,0.88,0.50);
		if not texturedropdown.over then
			texturedropdown:Hide();
		end
	end);
	--
	obj.editbox:SetScript("OnEnterPressed",function(self)
		local txt = self:GetText();
		if txt and txt~="" then
		
			if string.find(txt,"\\") then
				obj.s[obj.o] = txt;
			else
				obj.s[obj.o] = "Interface\\AddOns\\Forte_Core\\Textures\\"..txt;
			end
			self:SetText(obj.s[obj.o]);
			obj.button:SetNormalTexture(obj.s[obj.o]);
			obj:func();
		else
			self:SetText(obj.s[obj.o]);
		end
		self:ClearFocus();
	end);
	--
	obj:SetScript("OnEnter",function(self)
		FW:ShowOptionsTip(self);
	end);
	obj:SetScript("OnLeave",function(self)
		FW:HideTip(self);
	end);
	
	return obj;
end

local function NewScrollFrame(parent)
	local obj = CreateFrame("ScrollFrame",nil,parent);
	obj.parent = parent;
	obj:SetWidth(560);
	obj:SetHeight(460);
	obj:SetPoint("TOPLEFT",obj.parent,"TOPLEFT",10,-30);
	
	--obj.scrollbar = CreateFrame("Slider", nil, obj.scrollframe--[[, "UIPanelScrollBarTemplate"]]);
	obj.scrollbar = CreateFrame("Slider", nil, obj, "UIPanelScrollBarTemplate");
	obj.scrollbar:SetPoint("TOPLEFT", obj, "TOPRIGHT", 4, -16);
	obj.scrollbar:SetPoint("BOTTOMLEFT", obj, "BOTTOMRIGHT", 4, 16);
	--obj.scrollbar:SetMinMaxValues(1, 200);
	--obj.scrollbar:SetValueStep(1);
	--obj.scrollbar.scrollStep = 1;
	--obj.scrollbar:SetValue(0);
	
	obj.scrollbar:SetWidth(14);
	obj.scrollbar.scrollbg = obj.scrollbar:CreateTexture(nil, "BACKGROUND");
	obj.scrollbar.scrollbg:SetAllPoints(obj.scrollbar);
	obj.scrollbar.scrollbg:SetTexture(0, 0, 0, 0.4) ;

	obj.content = CreateFrame("Frame",nil,obj);
	obj.content:SetWidth(560);
	obj.content:SetHeight(360);
	obj:SetScrollChild(obj.content);
	
	obj:SetScript("OnMouseWheel",function(self,value)
		if ( value > 0 ) then
			obj.scrollbar:SetValue(obj.scrollbar:GetValue() - (obj.scrollbar:GetHeight() / 2));
		else
			obj.scrollbar:SetValue(obj.scrollbar:GetValue() + (obj.scrollbar:GetHeight() / 2));
		end
	end);
	
	obj.scrollbar:SetScript("OnValueChanged",function (self, value) 
		obj:SetVerticalScroll(value);
	end);
	
	return obj;
end

local function NewImageOption(parent,o,s,d)
	local obj = CreateFrame("Frame",nil,parent);
	obj.parent = parent;
	
	obj.image = obj:CreateTexture(nil,"ARTWORK");
	obj.image:SetTexture(o);
	--obj.image:SetAllPoints(obj);
	obj.image:SetPoint("CENTER",obj,"CENTER");
	--obj.image:SetPoint("TOPLEFT",obj,"TOPLEFT",5,-5);
	--obj.image:SetPoint("BOTTOMRIGHT",obj,"BOTTOMRIGHT",-5,5);
	
	obj.text = obj:CreateFontString(nil,"ARTWORK","FWFontNormal");
	obj.text:SetHeight(20);
	obj.text:SetJustifyH("CENTER");
	obj.text:SetPoint("BOTTOM",obj,"BOTTOM",0,-5);
	
	return obj;
end

local createOption = {
	["CHK"] = NewCheckOption,
	["NUM"] = NewNumberOption,
	["NU2"] = NewNumber2Option,
	["STR"] = NewStringOption,
	["MSG"] = NewMessage1Option,
	["MS2"] = NewMessage2Option,
	["SND"] = NewSoundOption,
	["INF"] = NewInfoOption,
	["URL"] = NewLinkOption,
	["FNT"] = NewFontOption,
	["COL"] = NewColorOption,
	["CO2"] = NewColor2Option,
	["FIL"] = NewFilterOption,
	["TXT"] = NewTextureOption,
	["BAC"] = NewBackdropOption,
	["IMG"] = NewImageOption,
	["BTN"] = NewButtonOption,
}
------------------------------------------------------------
-- END ALL INTERFACE TEMPLATES
------------------------------------------------------------

FW.ICON.DEFAULT = "Interface\\GossipFrame\\BinderGossipIcon";
FW.ICON.PROFILE = "Interface\\Buttons\\UI-GuildButton-PublicNote-Up";
FW.ICON.HINT = "Interface\\GossipFrame\\AvailableQuestIcon";
FW.ICON.FAQ = "Interface\\GossipFrame\\ActiveQuestIcon";
FW.ICON.APPEARANCE = "Interface\\Icons\\INV_Enchant_ShardPrismaticLarge";
FW.ICON.FILTER = "Interface\\Icons\\INV_Ingot_Eternium";
FW.ICON.BASIC = "Interface\\GossipFrame\\BinderGossipIcon";
FW.ICON.SPECIFIC = "Interface\\Buttons\\UI-CheckBox-Check";
FW.ICON.SIZE = "Interface\\Minimap\\UI-Minimap-ZoomInButton-Up";
FW.ICON.GENERAL = "Interface\\QuestFrame\\UI-QuestLog-BookIcon";
FW.ICON.SOULBAG = "Interface\\Icons\\INV_Misc_Bag_CoreFelclothBag";
FW.ICON.GLOW = "Interface\\Icons\\INV_Enchant_ShardRadientSmall";
FW.ICON.TIME = "Interface\\Icons\\INV_Misc_PocketWatch_01";
FW.ICON.FADE = "Interface\\Icons\\Spell_Magic_LesserInvisibilty";
FW.ICON.UNITS = "Interface\\Icons\\Ability_Hunter_SniperShot";

FW.ICON.CD = "Interface\\Icons\\Spell_Shadow_LastingAfflictions";
FW.ICON.HS = "Interface\\AddOns\\Forte_Core\\Textures\\HS1";
FW.ICON.SS = "Interface\\AddOns\\Forte_Core\\Textures\\SS1";
FW.ICON.SH = "Interface\\AddOns\\Forte_Core\\Textures\\SH1";
FW.ICON.SU = "Interface\\AddOns\\Forte_Core\\Textures\\SU1";
FW.ICON.ST = "Interface\\AddOns\\Forte_Core\\Textures\\ST";

FW.ICON.TALENT = "Interface\\Icons\\Ability_Marksmanship";
FW.ICON.MESSAGE = "Interface\\GossipFrame\\PetitionGossipIcon";
FW.ICON.SELFMESSAGE = "Interface\\GossipFrame\\GossipGossipIcon";
FW.ICON.SOUND = "Interface\\Buttons\\UI-GuildButton-MOTD-Up";
FW.ICON.DELETE = "Interface\\Glues\\Login\\Glues-CheckBox-Check";
FW.ICON.CREATE = "Interface\\Buttons\\UI-GuildButton-PublicNote-Up";

local Anchors = {};
function FW:SetFilterName(filter,name,typ)
	local obj = Anchors[filter];
	if typ then
		obj.typebutton.val = typ;
		obj.typebutton:SetText(FW:TypeName(obj.typebutton.val,obj.typebutton.list));
	end
	obj.editbox:SetText(name);
	obj.editbox.val = name;
end

local spells = {};
function FW:ShowOptionsTip(option)
	if option.title then
		_G.GameTooltip_SetDefaultAnchor(_G.GameTooltip, option);
		_G.GameTooltip:SetText(option.title, 1.0, 1.0, 1.0);
		
		local tip = "";
		if option.tip then
			tip = option.tip;
		else
			local d = option.data;
			if d[5] then
				local c = "|cff888888";
				local ot = option.option_type;
				tip = d[5];
				
				if FW.Settings.TimerSpellsTooltip and d[11] then
					--if not options_built then
					local spell_list = "\n\n|cff00ff00Registered Spells|r|cffffffff";
					local m = 30;
					FW.ERASE(spells);
					if d[13] then -- has spell name in this column, and data is table, flag MUST be given too
						for i,data in pairs(d[11]) do
							if data[ d[12] ] == d[6] then
								tinsert(spells,data[ d[13] ] );
							end
						end
					else -- table keys are the spell names, if flag is given data is table, otherwise always add		
						for spell,data in pairs(d[11]) do
							if not d[12] or data[ d[12] ] == d[6] then
								tinsert(spells,spell);
							end
						end
					end
					sort(spells);
					for i,spell in ipairs(spells) do
						if i<=m then
							spell_list = spell_list.."\n"..spell;
						end
					end
					
					if #spells == 0 then
						spell_list = spell_list.."\nNone";
					elseif(#spells>m) then
						spell_list = spell_list.."\n...and "..(#spells-m).." more";
					end
					
					spell_list = spell_list.."|r";
					tip = tip..spell_list;
				end
				
				if ot == "NUM" or ot == "NU2" then
					if option.editbox.minimum then
						if option.editbox.maximum then
							if tip ~= "" then tip=tip.."\n\n";end
							tip = tip..c..strformat(FWL.RANGE_MAX,option.editbox.minimum ,option.editbox.maximum ).."|r";
						else
							if tip ~= "" then tip= tip.."\n\n";end
							tip = tip..c..strformat(FWL.RANGE_MIN,option.editbox.minimum).."|r";
						end
					end
				elseif ot == "SND" or ot == "FNT" then
					if tip ~= "" then tip=tip.."\n\n";end
					tip = tip..c..strformat(FWL.RANGE_MAX,option.editbox2.minimum,option.editbox2.maximum).."|r";
				end

				if ot == "COL" then
					if tip ~= "" then tip=tip.."\n\n";end
					tip = tip..c..FWL.USE_COLOR_PICKER;
				elseif ot == "CO2" then
					if tip ~= "" then tip=tip.."\n\n";end
					tip = tip..c..FWL.USE_COLOR_PICKER2;
				elseif ot == "TXT" then
					if tip ~= "" then tip=tip.."\n\n";end
					tip = tip..c..FWL.USE_TEXTURE;
				elseif ot == "FNT" then
					if tip ~= "" then tip=tip.."\n\n";end
					tip = tip..c..FWL.USE_FONT;
				elseif ot == "FIL" then
					if tip ~= "" then tip=tip.."\n\n";end
					tip = tip..c..FWL.USE_FILTER
				elseif ot == "MSG" or ot == "NUM" or ot == "NU2" then
					if tip ~= "" then tip=tip.."\n\n";end
					tip = tip..c..FWL.USE_EDITBOX;
				elseif ot == "MS2" then
					if tip ~= "" then tip=tip.."\n\n";end
					tip = tip..c..FWL.USE_MSG2;
				end
				
			end
		end
		_G.GameTooltip:AddLine(tip, _G.NORMAL_FONT_COLOR.r, _G.NORMAL_FONT_COLOR.g, _G.NORMAL_FONT_COLOR.b, 1);
		_G.GameTooltip:Show();
	end
end

do
	local maincat,mainicon,mainindex,color,frame,defaults,tab_data;
	local subcat,subicon,subindex,reduce_alpha,expand;
	local last_option;
	
	function FW:SetMainCategory(a1,a2,a3,a4,a5,a6,a7)
		maincat,mainicon,mainindex,color,frame,defaults,tab_data = a1,a2,a3,a4,a5,a6,a7;
		return self;
	end
	function FW:SetSubCategory(a1,a2,a3,a4,a5)
		if a4 then a4 = true;else a4 = false;end
		subcat,subicon,subindex,expand,reduce_alpha = a1,a2,a3,a4,a5;
		return self;
	end
	local function FW_FindCategory(t,name)
		for i, data in ipairs(t) do
			if data[1] == name then
				return i;
			end
		end
	end
	local function FW_FindOption(t,typ,name)
		for i, data in ipairs(t) do
			if data[1] == typ and data[4] == name then
				return i;
			end
		end
	end
	function FW:AddOption(typ,text,tip,option,pos)
		if not pos then pos = 0; end
		-- maincat: main category
		-- mainicon: icon for main category (nil for none)
		-- mainindex: priority index of this category
		-- frame: frame belonging to this category (nil for none)
		
		-- subcat: sub category ("" for not adding a sub category)
		-- subicon (nil for none)
		-- subindex: priority index of this sub category
		
		-- typ: the template to use
		-- width: the number of rows the option will take up (1 or 2)
		-- pos: preferred postion (0 = none)
		-- text: text for this option
		-- tip: tooltip displayed for this option (nil for none)
		-- func: function to execute after change (nil for none)
		
		local mc = FW_FindCategory(FW_Options,maincat);
		if not mc then
			mc = 1;
			while(mc<=#FW_Options and FW_Options[mc][3]<=mainindex) do
				mc=mc+1;
			end
			tinsert(FW_Options,mc,{maincat,mainicon,mainindex,color,frame,defaults,tab_data,{}});	
		end
		local sc = FW_FindCategory(FW_Options[mc][MAIN_DATA_TABLE],subcat);
		if not sc then
			sc = 1;
			while(sc<=#FW_Options[mc][MAIN_DATA_TABLE] and FW_Options[mc][MAIN_DATA_TABLE][sc][3]<=subindex) do
				sc=sc+1;
			end
			tinsert(FW_Options[mc][MAIN_DATA_TABLE],sc,{subcat,subicon,subindex,expand,reduce_alpha,{}});
		end
		local t = FW_Options[mc][MAIN_DATA_TABLE][sc][SUB_DATA_TABLE];
		local o = FW_FindOption(t,typ,text);
		if not o then
			o = 1;
			while(o<=#t and t[o][3]<=pos) do
				o=o+1;
			end
			tinsert(t,o,{typ,nil,pos,text,tip,option});
			last_option = t[o];
		end
		return self;
	end
	function FW:SetSpan(span)
		last_option[2] = span;
		return self;
	end
	function FW:SetFunc(func)
		last_option[7] = func;
		return self;
	end
	function FW:SetRange(minimum,maximum)
		last_option[8],last_option[9]= minimum,maximum;
		return self;
	end
	function FW:SetEnabled(enabled)
		last_option[10] = enabled;
		return self;
	end
	function FW:SetSpellList(source_table,flag_column,name_column)
		last_option[11] = source_table;
		last_option[12] = flag_column;
		last_option[13] = name_column;
		return self;
	end
end


--[[
local function FW_FrameEnabled(frame)
	local index = frame.index;
	for sub_index, sub_data in ipairs(FW_Options[index][MAIN_DATA_TABLE]) do -- SUB OPTION LEVEL
		for i, d in ipairs(sub_data[4]) do -- OPTION LEVEL
			if d[1] == "CHK" then
				if strfind(d[6],"Enable$") then
					if FW_Options[index][6] then -- use the clone settings
						return FW.Settings[ FW_Options[index][5] ][ d[6] ],true;
					else -- use global settings
						return FW.Settings[ d[6] ],true;
					end
				else
					return false,false;
				end
			end
		end
	end
end]]

local function OptionEnabled(obj)
	if type(obj.option_enabled) == "function" then
		return obj:option_enabled();
	elseif type(obj.option_enabled) == "string" then
		--FW:Show(obj.option_enabled);
		local _,_,dont =  strfind(obj.option_enabled,"^not (.+)$")
		if dont then
			if type(obj.s[dont])== "table" then
				return not obj.s[dont][0];
			else
				return not obj.s[dont];
			end
		else
			if type(obj.s[obj.option_enabled])== "table" then
				return obj.s[obj.option_enabled][0];
			else
				return obj.s[obj.option_enabled];
			end
		end
	elseif type(obj.option_enabled) == "boolean" then
		return obj.option_enabled;
	end
	return true;
end

local function FW_SetAllLocks()
	for f,d in pairs(Frames) do
		if f ~= "FWOptions" then
			 d.s.lock = FW.Settings.GlobalLock;
			--FW:SetLinkedOptions( d.s,"lock",f);
		end
	end
	FW:RefreshFrames();
end

local function FW_SetAllAlpha()
	for f,d in pairs(Frames) do
		if f ~= "FWOptions" then
			 d.s.alpha = FW.Settings.GlobalAlpha;
			--FW:SetLinkedOptions( d.s,"alpha",f);
		end
	end
	FW:RefreshFrames();
end

local function SetTextureFunc(index,o,root,parent_root,parent_index)
	if (parent_root or o ~= "Texture" and o~="OptionsHeaderTexture" and o~="OptionsSubHeaderTexture") and strfind(o,"Texture$") then
		root.Instances[index][o] = FW.Settings.Texture;
		FW:SetLinkedOptions(index,o,root,parent_root,parent_index); -- does not, but should SKIP SETTING LINKED CLONES, because it's done anyway
	end
end

local function FW_SetAllTextures()
	ForAllOptionsTables(FW.Saved.Profiles.Active,SetTextureFunc,FW.Saved.Profiles);
	FW:RefreshFrames();
end

local function SetFontFunc(index,o,root,parent_root,parent_index)
	if (parent_root or o ~= "Font" and o~="OptionsFont" and o~="OptionsHeaderFont") and strfind(o,"Font$") then
		root.Instances[index][o][1] = FW.Settings.Font[1];
		root.Instances[index][o][2] = FW.Settings.Font[2];
		FW:SetLinkedOptions(index,o,root,parent_root,parent_index); -- does not, but should SKIP SETTING LINKED CLONES, because it's done anyway
	end
end

local function FW_SetAllFonts()
	ForAllOptionsTables(FW.Saved.Profiles.Active,SetFontFunc,FW.Saved.Profiles);
	FW:RefreshFrames();
end

local function FW_SetAllSparks()
	FW:RefreshFrames();
end

-- the actual shared lib code is in the locale func
local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
if LSM then
	function FW:LSM_Registered(callback, media, handle)
		if media == "font" then
			FW:RegisterFont(LSM:Fetch("font", handle), handle)
		elseif media == "sound" then
			FW:RegisterSound(LSM:Fetch("sound", handle), handle)
		elseif media == "statusbar" then
			tinsert(FW.TextureList, LSM:Fetch("statusbar", handle))
		elseif media == "border" then
			FW:RegisterBorder(LSM:Fetch("border", handle), handle)
		elseif media == "background" then
			FW:RegisterBackground(LSM:Fetch("background", handle), handle)
		end
	end
	LSM.RegisterCallback(FW, "LibSharedMedia_Registered", "LSM_Registered")
end

function FW:NewOptionsPanel()
	local obj = CreateFrame("Frame",nil,UIParent);
	OptionsPanel = obj;
	
	obj.parent = UIParent;
	obj:SetWidth(600);
	obj:SetHeight(500);
	
	obj.background2 = obj:CreateTexture(nil, "BACKGROUND");
	obj.background2:SetPoint("TOPLEFT",obj,"TOPLEFT",0,0);
	obj.background2:SetPoint("BOTTOMRIGHT",obj,"BOTTOMRIGHT",0,0);
	obj.background2:SetTexture(0,0,0,0.4) ;
	
	obj.background = obj:CreateTexture(nil,"BACKGROUND");
	obj.background:SetTexture("Interface\\AddOns\\Forte_Core\\Textures\\XusLogo");
	obj.background:SetWidth(512);
	obj.background:SetHeight(256);
	obj.background:SetPoint("CENTER",obj,"CENTER",0,0);
	obj.background:SetVertexColor(1,1,1,0.3);
	
	obj.header = CreateFrame("Frame",nil,obj);
	obj.header:SetWidth(600);
	obj.header:SetHeight(20);
	obj.header:SetPoint("TOPLEFT",obj,"TOPLEFT",0,0);
	
	obj.header.icon = obj.header:CreateTexture(nil,"ARTWORK");
	obj.header.icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes");
	obj.header.icon:SetWidth(14);
	obj.header.icon:SetHeight(14);
	obj.header.icon:SetPoint("LEFT",obj.header,"LEFT",3,0);
	
	obj.header.title = obj.header:CreateFontString(nil,"ARTWORK","FWFontHighlight");
	obj.header.title:SetPoint("CENTER",obj.header,"CENTER",0,0);
	
	obj.header.background = obj.header:CreateTexture(nil,"BACKGROUND");
	obj.header.background:SetTexture("Interface\\AddOns\\Forte_Core\\Textures\\Otravi");
	obj.header.background:SetPoint("TOPLEFT",obj.header,"TOPLEFT",1,-1);
	obj.header.background:SetPoint("BOTTOMRIGHT",obj.header,"BOTTOMRIGHT",-1,1);
	
	obj.close = CreateFrame("Button",nil,obj);
	obj.close:SetWidth(20);
	obj.close:SetHeight(20);
	obj.close:SetPoint("TOPRIGHT",obj,"TOPRIGHT",0,0);
	obj.close:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up");
	obj.close:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down");
	obj.close:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight");
	obj.close.highlighttexture = obj.close:GetHighlightTexture();
	obj.close.highlighttexture:SetBlendMode("ADD");
	obj.close.highlighttexture:SetDesaturated(1);
	
	obj.scrollframe = NewScrollFrame(obj);

	--scripts
	obj.ShowMe = function(self)
		if not optionsbuilt then
			self:Draw();
		end
		self.show = 1;
	end
	obj.HideMe = function(self)
		self.show = 0;
	end
	obj.Toggle = function(self)
		if self:IsVisible() then
			self:HideMe();
		else
			self:ShowMe();
		end
	end
	do
		local bgbackdrop = {};
		obj.SetBackdrop = function(self)
			self.header.background:SetTexture(FW.Settings.OptionsHeaderTexture);
			FW:MakeBackdrop(bgbackdrop,unpack(FW.Settings.OptionsBackdrop));
			
			-- dropdowns
			texturedropdown:SetBackdrop(bgbackdrop);
			fontdropdown:SetBackdrop(bgbackdrop);
			backdropdropdown:SetBackdrop(bgbackdrop);
			if filterdropdown then
				filterdropdown:SetBackdrop(bgbackdrop);
			end
			if sounddropdown then
				sounddropdown:SetBackdrop(bgbackdrop);
			end
			
			for main_index, main_data in ipairs(FW_Options) do -- MAIN OPTION LEVEL
				
				if main_data.tabs then
					for i, t in ipairs(main_data.tabs) do
						t:SetBackdrop(bgbackdrop);
					end
				end
				main_data.option:SetBackdrop(bgbackdrop);
			
				main_data.shortcut.texture:SetTexture(FW.Settings.OptionsHeaderTexture);
				main_data.option.normalheader.texture:SetTexture(FW.Settings.OptionsHeaderTexture);
				
				main_data.option.frameheader.leftframe.texture:SetTexture(FW.Settings.OptionsHeaderTexture);
				main_data.option.frameheader.leftmidframe.texture:SetTexture(FW.Settings.OptionsHeaderTexture);
				main_data.option.frameheader.midframe.texture:SetTexture(FW.Settings.OptionsHeaderTexture);
				main_data.option.frameheader.rightmidframe.texture:SetTexture(FW.Settings.OptionsHeaderTexture);
				main_data.option.frameheader.rightframe.texture:SetTexture(FW.Settings.OptionsHeaderTexture);
				
				for sub_index, sub_data in ipairs(main_data[MAIN_DATA_TABLE]) do -- SUB OPTION LEVEL
					if sub_data[1] and sub_data[1] ~= "" then
						sub_data.option.header.texture:SetTexture(FW.Settings.OptionsSubHeaderTexture);
					end
					for i, d in ipairs(sub_data[SUB_DATA_TABLE]) do -- OPTION LEVEL
							
						if d[1] then
							if d[1] == "BTN" then
								d.option.text.texture:SetTexture(FW.Settings.OptionsHeaderTexture);
							end
						end
					end
				end
			end
			if self.extrabutton then
				self.extrabutton.texture:SetTexture(FW.Settings.OptionsHeaderTexture);
			end
			self:SetColor();
		end
	end
	obj.SetColor = function(self)
		local r,g,b,a = unpack(FW.Settings.OptionHeaderColor);
		if FW.Settings.OptionsModuleColor then
			r,g,b = FW:MixColors2(0.5,FW.OPTION_COLOR.CLASS[1],FW.OPTION_COLOR.CLASS[2],FW.OPTION_COLOR.CLASS[3],r,g,b);
		end
		self.header.background:SetVertexColor(r,g,b,a);
		
		-- dropdowns
		texturedropdown:SetBackdropBorderColor(r,g,b,a);
		fontdropdown:SetBackdropBorderColor(r,g,b,a);
		backdropdropdown:SetBackdropBorderColor(r,g,b,a);
		if filterdropdown then
			filterdropdown:SetBackdropBorderColor(r,g,b,a);
		end
		if sounddropdown then
			sounddropdown:SetBackdropBorderColor(r,g,b,a);
		end
		for main_index, main_data in ipairs(FW_Options) do -- MAIN OPTION LEVEL
			main_data.option:SetBackdropColor(unpack(FW.Settings.OptionBackgroundColor));
			main_data.option:SetBackdropBorderColor(unpack(FW.Settings.OptionBackgroundColor));
			if FW.Settings.OptionsModuleColor then
				if FW.OPTION_COLOR[ main_data[4] ] then
					r,g,b = FW:MixColors(0.5,FW.OPTION_COLOR[ main_data[4] ],FW.Settings.OptionHeaderColor);
				else
					r,g,b = FW:MixColors(0.5,FW.OPTION_COLOR.CLASS,FW.Settings.OptionHeaderColor);
				end
			else
				r,g,b = unpack(FW.Settings.OptionHeaderColor);
			end
			
			if main_data.tabs then
				for i, t in ipairs(main_data.tabs) do
					if main_data.root.Active == t.index then -- selected tab
						t:SetBackdropColor(r,g,b);
						t:SetBackdropBorderColor(r,g,b);
					else
						t:SetBackdropColor(unpack(FW.Settings.OptionBackgroundColor));
						local link = GetLink(main_data.root.Active,main_data.root);
						if link and link == t.link then -- linked tab
							t:SetBackdropBorderColor(r,g,b);
						else
							t:SetBackdropBorderColor(unpack(FW.Settings.OptionBackgroundColor));
						end
					end
				end
			end

			main_data.shortcut.texture:SetVertexColor(r,g,b,1);
			main_data.option.normalheader.texture:SetVertexColor(r,g,b,a);
			
			main_data.option.frameheader.leftframe.texture:SetVertexColor(r,g,b,a);
			main_data.option.frameheader.leftmidframe.texture:SetVertexColor(r,g,b,a);
			main_data.option.frameheader.midframe.texture:SetVertexColor(r,g,b,a);
			main_data.option.frameheader.rightmidframe.texture:SetVertexColor(r,g,b,a);
			main_data.option.frameheader.rightframe.texture:SetVertexColor(r,g,b,a);
			
			for sub_index, sub_data in ipairs(main_data[MAIN_DATA_TABLE]) do -- SUB OPTION LEVEL
				if sub_data[1] and sub_data[1] ~= "" then
					sub_data.option.header.texture:SetVertexColor(r,g,b,(sub_data[5] and (a or 1)*sub_data[5]) or a or 1);
				end
				
				for i, d in ipairs(sub_data[SUB_DATA_TABLE]) do -- OPTION LEVEL
					local ot = d[1];
					if ot then
						if ot == "CHK" or ot == "NU2" or ot == "MSG" or ot == "SND" or ot == "CO2" or ot == "BAC" then
							d.option.checkbutton.normaltexture:SetVertexColor(r,g,b);		
						elseif ot == "MS2" then
							d.option.checkbutton1.normaltexture:SetVertexColor(r,g,b);	
							d.option.checkbutton2.normaltexture:SetVertexColor(r,g,b);
						elseif ot == "BTN" then
							d.option.text.texture:SetVertexColor(r,g,b);
						end
					end
				end
			end
		end
		if obj.extrabutton then
			obj.extrabutton.texture:SetVertexColor(r,g,b,1);
		end
		a = 0.8;
		
		r,g,b = unpack(FW.Settings.OptionBackgroundColor);

		texturedropdown:SetBackdropColor(r,g,b,a);
		fontdropdown:SetBackdropColor(r,g,b,a);
		backdropdropdown:SetBackdropColor(r,g,b,a);
		if filterdropdown then filterdropdown:SetBackdropColor(r,g,b,a); end
		if sounddropdown then sounddropdown:SetBackdropColor(r,g,b,a); end
	end
	obj.SetFont = function(self)
		local fo,si,fl = unpack(FW.Settings.OptionsFont);
		local ss = si-2;
		local foh,sih,flh = unpack(FW.Settings.OptionsHeaderFont);
		
		self.header.title:SetFont(foh,sih,flh);

		for main_index, main_data in ipairs(FW_Options) do -- MAIN OPTION LEVEL
		
			if main_data.tabs then
				for i, t in ipairs(main_data.tabs) do
					t.button:SetFont(fo,ss,fl);
					t.editbox:SetFont(fo,ss,fl);
					t:SetText(t.button.text:GetText()); -- do this to update tab sizes
				end
			end
			
			main_data.shortcut:SetFont(fo,si,fl);
			main_data.option.header.title:SetFont(foh,sih,flh);
			main_data.option.frameheader.coordinates:SetFont(fo,ss,fl);
			main_data.option.frameheader.alpha:SetFont(fo,ss,fl);
			main_data.option.frameheader.scale:SetFont(fo,ss,fl);

			for sub_index, sub_data in ipairs(main_data[MAIN_DATA_TABLE]) do -- SUB OPTION LEVEL
				
				if sub_data[1] and sub_data[1] ~= "" then
					sub_data.option.header.title:SetFont(foh,sih,flh);
				end
				
				for i, d in ipairs(sub_data[SUB_DATA_TABLE]) do -- OPTION LEVEL
					local ot = d[1];
					if ot and ot ~= "" then
						
						d.option.text:SetFont(fo,si,fl);
						
						if ot == "URL" or ot == "FIL" or ot == "MSG" or ot == "NUM" or ot == "MS2" or ot == "NU2" then
							d.option.editbox:SetFont(fo,si,fl);
						end
						
						if ot == "COL" or ot == "CO2" or ot == "SND" or ot == "TXT" or ot == "FNT" then 
							d.option.editbox:SetFont(fo,ss,fl);
						end
						if ot == "FNT" or ot == "SND" then
							d.option.editbox2:SetFont(fo,si,fl);
						end
						if ot == "SND" then
							d.option.button:SetFont(fo,si,fl);
						end
						if ot == "FIL" then
							d.option.actionbutton:SetFont(fo,si,fl);
							d.option.typebutton:SetFont(fo,si,fl);
							d.option.editbox2:SetFont(fo,ss,fl);
							
							FC_BuildFilterList(d.option); -- calling this because the font apply is embedded here
						end
						if ot == "BAC" then
							d.option.bg:SetFont(fo,ss,fl);
							d.option.border:SetFont(fo,ss,fl);
							d.option.tilesize:SetFont(fo,si,fl);
							d.option.edge:SetFont(fo,si,fl);
							d.option.inset:SetFont(fo,si,fl);
						end
						if ot == "FNT" then
							d.option.editbox3:SetFont(fo,ss,fl);
						end
					end
				end
			end
		end
	end
	
	obj.RefreshNoStyle = function(self)
		if optionsbuilt then
			if self:IsVisible() then self:Hide();self:Show();self.show = 1; end
			--FW:Show("refresh nostyle");
		end
	end
	obj.Refresh = function(self)
		if optionsbuilt then
			if self:IsVisible() then
				self:Hide();
				self:Show();
				self.show = 1;
			end
			self:SetFont();
			self:SetBackdrop(); -- includes colors
			--FW:Show("refresh");
		end
	end
	obj.Reset = function(self)
		self:ClearAllPoints();
		self:SetPoint("CENTER",self.parent, "CENTER",0,0);
		self.s.x,self.s.y = FW:GetCenter(self);
		self.s.alpha = 1.0;
		self.s.lock = false;
		self.s.scale = 1.0;
		
		FW.Settings.OptionsColums = 2;

		self:Draw();
		self:Update();
		self:Refresh();
	end
	obj.Update = function(self)
		FW:InitFrameVars(self);
		self:SetScale(self.s.scale);
		self:SetAlpha(self.s.alpha);
		FW:CorrectPosition(self);
	end;

	local function ScrollTo(button)
		obj:ScrollTo(button.title,1);
	end
	local function GetSpan(d)
		if d then
			if d[2] then
				return d[2];
			else
				local ot = d[1];
				if not ot or ot =="" then
					return 0;
				elseif ot == "TXT" or ot == "SND" or ot == "FNT" or ot == "BAC" or ot == "MS2" or ot == "FIL" or ot == "INF" or ot == "URL" then
					return 2;
				else
					return 1;
				end
			end
		else
			return 0;
		end
	end

	obj.Draw = function(self)
		
		local f,s,sub;
		local offset = 0;
		local x,y = 0,0;
		local columns = FW.Settings.OptionsColums;
		local w = 280;
		local width = w*columns;--total option space width
		local height = FW.Settings.OptionsHeight;--440
		local h = 20;--height of one option
		local ow = width+40;
		local oh = height+60;
		local vis = false;
		local r,g,b,a = unpack(FW.Settings.OptionHeaderColor);
		-- build main options
		self:SetWidth(ow);
		self:SetHeight(oh);
		self.header:SetWidth(ow);
		self.scrollframe:SetWidth(width);
		self.header.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[FW.CLASS]));
		self.header.title:SetText(FW:Title());

		for main_index, main_data in ipairs(FW_Options) do -- MAIN OPTION LEVEL
			x,y = 0,-h;
			local tabs = 0; -- TAB CODE
			local tabsx = 0;
			local frame = main_data[5];
			local instanceof = main_data[6];
			local tab_actions = main_data[7];
			local root = instanceof and FW.Settings[instanceof] or FW.Saved.Profiles;
			main_data.root = root;
			main_data.parent_root = instanceof and FW.Saved.Profiles;
			
			if tab_actions ~= nil then -- has tabs enabled!
				if not main_data.tabs then
					main_data.tabs = {};
					main_data.tabs_frame = CreateFrame("Frame",nil,self.scrollframe.content);
					main_data.tabs_frame.parent = main_data;
				end
				main_data.tabs_frame:SetWidth(width);
				main_data.tabs_frame:SetPoint("TOPLEFT", self.scrollframe.content, "TOPLEFT",0,offset);
				local t;
				local n = 1;
				for i, v in ipairs(root.Data) do
					t =  main_data.tabs[n] or NewTabFrame(main_data.tabs_frame);
					t:ClearAllPoints();
					main_data.tabs[n] = t;
				
					t.link_func = InstanceLink;
					t:SetEditable(true);
					t:SetEditing(false);
					t.delete:SetEnabled( #root.Data > 1 );
					t.delete_func,t.rename_func,t.select_func = tab_actions[2],tab_actions[3],tab_actions[4];
					t.index = i;	
					t.link = GetLink(t.index,root);
					if i == root.Active then
						t:SetText(v.name);
						t.button.title = FWL.RENAME_CLONE;
					else
						t:SetText("|cFFCCCCCC"..v.name.."|r");
						t.button.title = FWL.SELECT_CLONE;
					end
					t.button.tip = "table index: "..t.index;
					
					tabsx=tabsx+t:GetWidth();
					if n==1 or (tabsx > width) then
						t:SetPoint("TOPLEFT", main_data.tabs_frame, "TOPLEFT",0,-tabs);
						tabs = tabs + 15; -- size of one tab line
						tabsx=t:GetWidth();
					else
						t:SetPoint("TOPLEFT",main_data.tabs[n-1], "TOPRIGHT",0,0);
					end
					t:Show();
					n=n+1;
				end
				t =  main_data.tabs[n] or NewTabFrame(main_data.tabs_frame); -- create 'create' tab
				t:ClearAllPoints();
				main_data.tabs[n] = t;
				
				t:SetEditable(false);
				t:SetEditing(false);
				t:SetText(NEW_INSTANCE_STRING);
				t.index = NEW_INSTANCE_STRING;
				t.link = nil;
				t.create_func = tab_actions[1];
				t.button.title = FWL.CREATE_CLONE;
				t.button.tip = "";
				tabsx=tabsx+t:GetWidth();
				if tabsx > width then
					t:SetPoint("TOPLEFT", main_data.tabs_frame, "TOPLEFT",0,-tabs);
					tabs = tabs + 15; -- size of one tab line
					tabsx=t:GetWidth();
				else
					t:SetPoint("TOPLEFT", main_data.tabs[n-1], "TOPRIGHT",0,0);
				end			
				t:Show();
				n=n+1;
				for i=n,#main_data.tabs,1 do
					main_data.tabs[i]:Hide();
				end
				main_data.tabs_frame:SetHeight(tabs);
				offset=offset-tabs;
			end --END TAB CODE
			
			if not main_data.option then
				main_data.option = NewOptionsFrame(self.scrollframe.content);
			end
			f = main_data.option;
			f.main_data = main_data;
			f.header.title:SetText(main_data[1]);
			f.header.icon.normaltexture:SetTexture(main_data[2]);
			f.header.icon.highlighttexture:SetTexture(main_data[2]);
			
			f:SetWidth(width);
			f.frame = frame or instanceof and "FX_"..instanceof..root.Active; -- set associated frame name
			if f.frame then
				f.frameheader:Show();
				f.normalheader:Hide();
				f.instance = Frames[f.frame];
			else
				f.frameheader:Hide();
				f.normalheader:Show();
				f.instance = nil;
			end
			f:ClearAllPoints();
			f:SetPoint("TOPLEFT", self.scrollframe.content, "TOPLEFT",0,offset);
			f.index = main_index;
			
			for sub_index, sub_data in ipairs(main_data[MAIN_DATA_TABLE]) do -- SUB OPTION LEVEL
				if sub_data[1] and sub_data[1] ~= "" then
					if x>0 then
						x = 0;
						if vis then
							y = y -s:GetHeight();
						end
					end
					if not sub_data.option then
						sub_data.option = NewSubOptionsFrame(f);
					end
					sub = sub_data.option;
					
					sub.sub_data = sub_data;
					sub.main_data = main_data;
					local st = FW.Settings.LoadExpandSubcats and FW_GetSubSaveTable(sub);
					if st and st.expand ~= nil then
						sub.expand = st.expand;
					elseif sub.expand == nil then
						sub.expand = sub_data[4] or FW.Settings.ExpandSubcats;		
					end
					
					sub:SetWidth(width);
					sub.header:SetWidth(width);
					sub:ClearAllPoints();
					sub:SetPoint("TOPLEFT",sub.parent,"TOPLEFT",x,y);
					sub.header.title:SetText(sub_data[1]);
					sub.header.icon:SetTexture(sub_data[2]);
					
					if sub_data[1] == FWL.COLORING_FILTERING then
						Anchors[main_data[1].." Color"] = sub; --save anchor for filters too!
					end
					sub.index = sub_index;
					sub.top = -offset - y;
					sub.bottom = sub.top+sub:GetHeight();
					y = y -sub:GetHeight();
					vis = sub.expand;
					sub.title = "Click to toggle '"..sub_data[1].."'";
					sub.tip = "";
				else
					vis = true;
				end
				for i, d in ipairs(sub_data[SUB_DATA_TABLE]) do -- OPTION LEVEL
					local ot,span = d[1],GetSpan(d);

					if ot and ot ~= "" then
						if  d.option then
							if instanceof then
								d.option.s = root.Instances[root.Active];
								d.option.d = FW.InstanceDefault[instanceof];
							else
								d.option.s = FW.Settings; -- also update settings table
								d.option.d = FW.Default; -- also update defaults table
							end
						else
							if instanceof then
								d.option = createOption[ot](f, d[6], root.Instances[root.Active], FW.InstanceDefault[instanceof]);
							else
								d.option = createOption[ot](f, d[6], FW.Settings, FW.Default);
							end
						end
						s = d.option;
						s.data = d;
						s.main_data = main_data;
						s.sub_data = sub_data;
						s.option_type = ot;
						s.title = d[4] or "";
						
						if ot == "NUM" or ot == "NU2" then
							s.editbox.minimum = d[8];
							s.editbox.maximum = d[9];
						elseif ot == "FIL" then
							s.title = s.title..FWL._CLICK_FILTER;
							Anchors[main_data[1].." Filter"] = s; --save anchor for filters too!
							s.actionbutton.list = d[8];
							s.typebutton.list = d[9];
						end
						
						if sub.tip == "" then
							sub.tip = s.title;
						else
							sub.tip = sub.tip.."\n"..s.title;
						end
						
						s.instance = f.instance;
						--s.instanceof = f.instanceof;
						s.func = OptionFunction;
						s.option_func = d[7];
						s.enabled = OptionEnabled;
						s.option_enabled = d[10];
						 
						if s.linker then
							s.cross_profile = GetLinkedOption(s,true);
							s.cross_clone = GetLinkedOption(s,false);
							s.cross_profile_match = GetOptionsMatch(s,true);
							s.cross_clone_match = GetOptionsMatch(s,false);
							s.SetLinkedOption = SetLinkedOption;
						end

						s:SetWidth(span*w);
						s:ClearAllPoints();
						s.top = -offset-y;
						s:SetPoint("TOPLEFT",s.parent, "TOPLEFT",x,y);
						s.text:SetText(d[4]);
						if ot == "FIL" then 
							if vis then
								y = y + FC_BuildFilterList(s);
							end
						elseif ot == "IMG" then
							--d[7]; aspect	--d[8]; pref width	--d[9]; pref height
							if d[9] then
								s:SetHeight(d[9]);
								s.image:SetHeight(d[9]-20);
								s.image:SetWidth(d[7]*s.image:GetHeight());
							end
						end

					end
					s.bottom = -offset-y+s:GetHeight();
					x = x + span*w;

					if x + GetSpan(sub_data[SUB_DATA_TABLE][i+1])*w > width then
						x = 0;
						if vis then
							y = y -s:GetHeight();
						end
					end
				end		
			end
			if x>0 then
				x = 0;
				if vis then
					y = y -s:GetHeight();
				end
			end
			Anchors[main_data[1]] = f;
			
			f.top = -offset-tabs;
			offset = offset + y;
			f.bottom = -offset;
			
			offset = offset - 10;
			f:SetHeight(-y+5);
			--f:Show();
		end
		
		-- build shortcuts
		columns = columns*2;
		w = (ow)/columns;
		h=16;
		y = h*math.ceil(#FW_Options/columns-1);
		x = 0;

		self.scrollframe:SetHeight(height-y);
		--FW:Show(FW_Options[1].tabs_frame:GetTop());
		--FW:Show(FW_Options[1].tabs_frame:GetTop()-FW_Options[#FW_Options].option:GetBottom());
		--FW:Show(offset);
		
		self.scrollframe.maxscroll = -offset-self.scrollframe:GetHeight()-5;
		self.scrollframe.scrollbar:SetMinMaxValues(0, self.scrollframe.maxscroll);

		width = width + 40;
		for main_index, main_data in ipairs(FW_Options) do -- MAIN OPTION LEVEL
			if not main_data.shortcut then
				main_data.shortcut = NewShortcutButton(self);
			end
			s = main_data.shortcut;
			s:ClearAllPoints();
			s:SetPoint("BOTTOMLEFT",self, "BOTTOMLEFT",x,y);
			s:SetWidth(w);
			s:SetHeight(h);
			s:SetText(main_data[1]);
			s.tip = FWL.SCROLL_TO_..main_data[1];
			s.title = main_data[1];
			s:SetNormalTexture(main_data[2]);
		
			s:SetScript("OnClick",ScrollTo);

			x=x+w;
			if x >= width-0.1 then -- stupid shit
				x=0;y=y-h;
			end		
		end
		if x ~= 0 then
			self.extrabutton = self.extrabutton or NewOptionsHeader(self);
			self.extrabutton:SetPoint("BOTTOMLEFT",self, "BOTTOMLEFT",x,y);
			self.extrabutton:SetWidth(width - x);
			self.extrabutton:SetHeight(h);
		end
		-- SET BACKGROUND IMAGE
		local w = self:GetWidth()-10;
		local h = self:GetHeight()-10;
		local ar = 1; -- aspect ratio of my image
		local a = w/h; -- aspect ratio of frame
		self.background:SetWidth(w);
		self.background:SetHeight(h);
		if ar >= a then
			-- change height textcoords
			self.background:SetTexCoord(0.5*(1-a/ar),1-0.5*(1-a/ar),0,1);
		else
			-- change width textcoords
			self.background:SetTexCoord(0,1,0.5*(1-ar/a),1-0.5*(1-ar/a));
		end

		--[[
		if a >= ar then
			self.background:SetWidth(h*ar);
			self.background:SetHeight(h);
		else
			self.background:SetWidth(w);
			self.background:SetHeight(w/ar);
		end
		]]
		self:HideUnneeded();
		
		if not optionsbuilt then
			optionsbuilt = true;
			self:SetFont();
			self:SetBackdrop(); -- includes colors
		end
	end

	obj.close:SetScript("OnClick",function(self)
		obj.show = 0;
	end);
	
	local maxd = 0.5;-- AUTOSCROLL CODE
	obj:SetScript("OnUpdate",function(self)
		if self.scrollto then
			if FW.Settings.AnimateScroll then
				local val = self.scrollframe.scrollbar:GetValue();
				local d = self.scrollto - val;
				if abs(d)<maxd or self.newval and abs(self.newval-val)>maxd then -- newval is used to stop autoscrolling if user scrolls himself
					self.scrollframe.scrollbar:SetValue(self.scrollto);
					self.scrollframe:UpdateScrollChildRect();
					self.scrollto=nil;
					self.newval=nil;
				else
					self.newval = val+d/8;
					self.scrollframe.scrollbar:SetValue(self.newval);
					self.scrollframe:UpdateScrollChildRect();
				end	
			else
				self.scrollframe.scrollbar:SetValue(self.scrollto);
				self.scrollframe:UpdateScrollChildRect();
				if abs(self.scrollframe.scrollbar:GetValue() - self.scrollto)<maxd then
					self.scrollto=nil;
				end
			end
		end
	end);
	
	do
		local vis = 0;
		local function EditboxFix() -- fixes 4.1 editbox problem on show
			local current = obj.show;
			obj:Hide();
			obj:Show();
			obj.show = current;
		end
		local function AutoShow()
			if obj.show == 1 then
				if FW.Settings.AnimateScroll then
					if not obj:IsShown() then
						obj:Show();
					end
					if vis<1 then
						vis = vis+0.25;
						obj:SetAlpha( FW.Settings.FWOptions.alpha*vis );
						obj:SetScale( FW.Settings.FWOptions.scale*(0.75+0.25*vis) );
						FW:CorrectPosition(obj);
					else
						obj.show=nil;
					end
				else
					obj:Show();
					obj.show=nil;
				end
				FW:RegisterThrottle(EditboxFix);
			elseif obj.show == 0 then
				if FW.Settings.AnimateScroll then
					if vis>0.25 then
						if not obj:IsShown() then -- looks silly, but its to still be able to close on ESC
							obj:Show();
						end
						vis = vis-0.25;
						obj:SetAlpha( FW.Settings.FWOptions.alpha*vis );
						obj:SetScale( FW.Settings.FWOptions.scale*(0.75+0.25*vis) );
						FW:CorrectPosition(obj);
					else
						obj.show=nil;
						obj:Hide();
					end
				else
					obj:Hide();
					obj.show=nil;
				end
			end
		end
		FW:RegisterUpdatedEvent(AutoShow);
	end
	obj.HideUnneeded = function(self)
		-- fixes 4.1 editbox problem on scroll
		for main_index, main_data in ipairs(FW_Options) do -- MAIN OPTION LEVEL
		
			if main_data.option then
				main_data.option:Hide(); -- also contains the options as children
				
				for sub_index, sub_data in ipairs(main_data[MAIN_DATA_TABLE]) do -- SUB OPTION LEVEL
					for i, d in ipairs(sub_data[SUB_DATA_TABLE]) do -- OPTION LEVEL
						if d.option then
							d.option:Hide();
						end
					end					
					if sub_data.option then
						sub_data.option:Hide();
					end
				end
			end
		end
		-- the actual code to hide/show the options
		local top = self.scrollframe.scrollbar:GetValue();
		local bottom = self.scrollframe:GetHeight()+top;
		-- 1 extra margin for error
		top=top-1;
		bottom=bottom+1;
		--if not FW.Saved.BLOCK then
		for main_index, main_data in ipairs(FW_Options) do -- MAIN OPTION LEVEL
		
			if main_data.option then
				if main_data.option.bottom<top or main_data.option.top>bottom then
					if main_data.option:IsShown() then
						main_data.option:Hide(); -- also contains the options as children
					end
				else
					for sub_index, sub_data in ipairs(main_data[MAIN_DATA_TABLE]) do -- SUB OPTION LEVEL
						for i, d in ipairs(sub_data[SUB_DATA_TABLE]) do -- OPTION LEVEL
							if d.option then
								if not sub_data.option or sub_data.option.expand then
									if d.option.bottom<top or d.option.top>bottom then
										if d.option:IsShown() then
											d.option:Hide();
										end
									else
										if not d.option:IsShown() then
											d.option:Show();
										end
									end
								else
									if d.option:IsShown() then
										d.option:Hide();
									end
								end
							end
						end					
						if sub_data.option then
							if sub_data.option.bottom<top or sub_data.option.top>bottom then
								if sub_data.option:IsShown() then
									sub_data.option:Hide();
								end
							else
								if not sub_data.option:IsShown() then
									sub_data.option:Show();
								end
							end
						end

					end
					if not main_data.option:IsShown() then
						main_data.option:Show();
					end
				end
			end
		end
	end

	obj.ScrollTo = function(self,v,fo,instance)
		--FW:Show(v..":"..tostring(fo)..":"..tostring(instance));
		if not FW.Settings then
			return;
		end
		if not optionsbuilt then
			self:Draw();
		end
		if Anchors[v] then
			local refresh = false;
			local scrollto = Anchors[v].top or 0;
			if Anchors[v].expand == false then
				Anchors[v].expand = true;
				FW_GetSubSaveTable(Anchors[v],true).expand = Anchors[v].expand;
				refresh = true;
			end
			if not fo and self:IsVisible() and (abs(self.scrollframe.scrollbar:GetValue() - scrollto)<1 or self.scrollto and abs(self.scrollto - scrollto)<1 ) then
				if not instance or instance == Anchors[v].main_data.root.Active then -- only hide if instance is also the same
					self:HideMe();
				end
			elseif FW.Settings.RightClickOptions or fo then
				if self.scrollframe.maxscroll < scrollto then scrollto=self.scrollframe.maxscroll end
				self.scrollto = scrollto;
				self:ShowMe();
			end
			if instance and Anchors[v].main_data.root.Active ~= instance then -- switch tab if needed
				Anchors[v].main_data.root.Active = instance;
				refresh = true;
			end		
			if refresh then
				self:Draw();
				self:Refresh(); -- for tab color only
			end
		end
	end
	
	obj.scrollframe:HookScript("OnVerticalScroll", function() obj:HideUnneeded(); end);
	--
	obj:SetScript("OnMouseDown",function(self,button)
		FW:StartMoving(self,button);
	end);
	--
	obj:SetScript("OnMouseUp",function(self)
		FW:StopMoving(self);
	end);
	obj:SetScript("OnHide",function(self)
		obj.show = 0;
	end);

	obj:Hide();
	return obj;
end

function FW:LocalizedData()

	if LSM then -- doing this here because of chinese fonts
		--FW:Show("Shared Media Detected!");
		-- shared sound
		for i, data in ipairs(FW.SoundList) do
			LSM:Register("sound", data[2], data[1]);
		end
		erase(FW.SoundList);
		for i, name in pairs(LSM:List("sound")) do
			FW:RegisterSound(LSM:Fetch("sound", name), name)
		end
		-- shared borders
		for i, data in ipairs(FW.BorderList) do
			LSM:Register("border", data[2], data[1]);
		end
		erase(FW.BorderList);
		for i, name in pairs(LSM:List("border")) do
			FW:RegisterBorder(LSM:Fetch("border", name), name)
		end
		--shared backgrounds
		for i, data in ipairs(FW.BackgroundList) do
			LSM:Register("background", data[2], data[1]);
		end
		erase(FW.BackgroundList);
		for i, name in pairs(LSM:List("background")) do
			FW:RegisterBackground(LSM:Fetch("background", name), name)
		end
		-- shared textures
		for i, path in ipairs(FW.TextureList) do
			local name = select(3,strfind(path,"^Interface\\AddOns\\Forte_Core\\Textures\\(.-)$"));
			if name then
				LSM:Register("statusbar", name, path)
			end
		end
		erase(FW.TextureList);
		for i, name in ipairs(LSM:List("statusbar")) do
			tinsert(FW.TextureList,LSM:Fetch("statusbar", name))
		end
		-- shared fonts
		for i, data in ipairs(FW.FontList) do
			LSM:Register("font", data[2], data[1]);
		end
		erase(FW.FontList);
		for i, name in pairs(LSM:List("font")) do
			FW:RegisterFont(LSM:Fetch("font", name), name)
		end
	end

	FW.Exceptions = {
		[FWL.HELLFIRE_CHANNELER] = 0,
		[FWL.GRAND_ASTROMANCER_CAPERNIAN] = 1,
		[FWL.MASTER_ENGINEER_TELONICUS] = 1,
		[FWL.FATHOM_GUARD_SHARKKIS] = 1,
		[FWL.THALADRED_THE_DARKENER] = 1,
		[FWL.LORD_SANGUINAR] = 1,
		[FWL.FATHOM_GUARD_CARIBDIS] = 1,
		[FWL.FATHOM_GUARD_TIDALVESS] = 1,
	};
	FW.FilterListOptions = {
		{ 0,FWL.FILTER_NONE},
		{ 1,FWL.FILTER_NORMAL},
		{ 2,FWL.FILTER_SHOW_COLOR},
		{-2,FWL.FILTER_COLOR},
		{-1,FWL.FILTER_IGNORE},
	}
	FW.STFilterListOptions = {
		{ 1,FWL.FILTER_ALL},
		{ 2,FWL.FILTER_OTHERS},
		{ 4,FWL.FILTER_COOLDOWNS},
		{ 5,FWL.FILTER_DEBUFFS_ON_ME},
		{ 3,FWL.FILTER_MINE},
	}
	FW.CDFilterListOptions = {
		{ 1,FWL.FILTER_ALL},
		{ 2,FWL.FILTER_BUFF_DEBUFF},
		{ 3,FWL.FILTER_OTHER},
	}

	FW.ClassModules = FWL.MODULE_NONE;
	
	local tab_actions = {
		function(obj) -- create
			FW:UseProfile( FW:InstanceCreate(FW:FullName(),FW.Saved.Profiles,FW.Settings) );
		end,
		function(obj) -- remove
			_G.StaticPopup_Show("FX_CONFIRM_DELETE_PROFILE",obj.displayname,obj.index,obj);
		end,
		function(obj,txt) -- rename
			FW:InstanceRename(obj.index,txt,FW.Saved.Profiles);
			OptionsPanel:Draw();
			--OptionsPanel:Refresh();
		end,
		function(obj) -- select func
			FW:UseProfile(obj.index)
		end,
	};

	_G.StaticPopupDialogs["FX_CONFIRM_DELETE_PROFILE"] = {
		text = FWL.CONFIRM_DELETE_PROFILE,
		button1 = _G.ACCEPT,
		button2 = _G.CANCEL,
		OnAccept = function(self,data)
			local index, root = data.index,FW.Saved.Profiles;
			local done, curr = FW:InstanceDelete(index,root);
			if done then
				-- fix character -> profile index mapping
				for c, pi in ipairs(root.Characters) do
					if pi == index then
						root.Characters[c] = 1;
					elseif pi > index then
						root.Characters[c] = pi - 1;
					end
				end
				if curr then
					FW:UseProfile(1);
				else
					OptionsPanel:Draw();
					OptionsPanel:Refresh();
				end
			end
		end,
		showAlert = 1,
		timeout = 0,
		whileDead = true,
		hideOnEscape = 1
	};
	
	_G.StaticPopupDialogs["FX_CONFIRM_DELETE_CLONE"] = {
		text = FWL.CONFIRM_DELETE_CLONE,
		button1 = _G.ACCEPT,
		button2 = _G.CANCEL,
		showAlert = 1,
		timeout = 0,
		whileDead = true,
		hideOnEscape = 1
	};
	
	_G.StaticPopupDialogs["FX_MULTI_PURPOSE"] = {
		text = "%s",
		button1 = _G.ACCEPT,
		button2 = _G.CANCEL,
		showAlert = 1,
		timeout = 0,
		whileDead = true,
		hideOnEscape = 1,
		closeButton = 1,
	};

	local function FC_SetOptionsFont()
		OptionsPanel:SetFont();
	end
	local function FC_SetOptionsColor()
		OptionsPanel:SetColor();
	end
	local function FC_SetOptionsBackdrop()
		OptionsPanel:SetBackdrop();
	end
	local function FW_ClearBackup()
		FC_Saved = {};
		FW_RefreshOptionsNoStyleThrottle();
	end
	FW:SetMainCategory(FWL.GENERAL,FW.ICON.DEFAULT,1,"DEFAULT","FWOptions",nil,tab_actions)

		:SetSubCategory(FWL.GENERAL_TIPS,FW.ICON.HINT,1)
			:AddOption("INF",	FWL.GENERAL_TIPS3)
			:AddOption("INF",	FWL.GENERAL_TIPS5)
			:AddOption("INF",	FWL.GENERAL_TIPS4)
			:AddOption("INF",	FWL.GENERAL_TIPS6)
			:AddOption("INF",	FWL.GENERAL_TIPS7)
			
		:SetSubCategory(FWL.GENERAL_MO,FW.ICON.DEFAULT,2,FW.EXPAND)
			:AddOption("CHK",FWL.GENERAL_MO1,	FWL.GENERAL_MO1_TT,	"RightClickOptions")
			:AddOption("CHK",FWL.GENERAL_MO6,	FWL.GENERAL_MO6_TT,	"RightClickIconOptions")
			:AddOption("CHK",FWL.GENERAL_MO2,	FWL.GENERAL_MO2_TT,	"TimeFormat")
			:AddOption("CHK",FWL.GLOBAL_LOCK,	FWL.GLOBAL_LOCK_TT,	"GlobalLock"):SetFunc(FW_SetAllLocks)
			:AddOption("NUM",FWL.GLOBAL_ALPHA,	FWL.GLOBAL_ALPHA_TT,"GlobalAlpha"):SetRange(0.1,1.0):SetFunc(FW_SetAllAlpha)

		:SetSubCategory(FWL.GENERAL_MA,FW.ICON.APPEARANCE,3,FW.EXPAND)
			:AddOption("CHK",FWL.TIPS,			FWL.TIPS_TT,		"Tips")
			--:AddOption("CO2",FWL.SPARK_COLOR,	FWL.SPARK_COLOR_TT,	"Spark",			FW_SetAllSparks)
			:AddOption("NU2",FWL.SHOW_SPARK ,	FWL.SHOW_SPARK_TT..FWL._EDITBOX_TRANSPARENCY,	"GlobalSpark"):SetRange(0.1,1.0):SetFunc(FW_SetAllSparks)
			:AddOption("FNT",FWL.BAR_FONT,		FWL.GENERAL_MA1_TT,	"Font"):SetFunc(FW_SetAllFonts)
			:AddOption("TXT",FWL.BAR_TEXTURE,	FWL.GENERAL_MA2_TT,	"Texture"):SetFunc(FW_SetAllTextures)

	:SetMainCategory(FWL.RAID_MESSAGES,FW.ICON.MESSAGE,10,"RAIDMESSAGES")
		:SetSubCategory(FWL.GENERAL_TIPS,FW.ICON.HINT,1)
			:AddOption("INF",FWL.RAID_MESSAGES_HINT1)
			:AddOption("INF",FWL.RAID_MESSAGES_HINT2)
		:SetSubCategory(FWL.WHERE_TO_SHOW,FW.ICON.DEFAULT,1)
			:AddOption("CHK",FWL.SHOW_IN_RAID,	FWL.SHOW_IN_RAID_TT,	"OutputRaid"):SetSpan(2)
			:AddOption("MSG",FWL.SHOW_IN_CHANNEL,FWL.SHOW_IN_CHANNEL_TT,"Output"):SetSpan(2)
	
	:SetMainCategory(FWL.SELF_MESSAGES,FW.ICON.SELFMESSAGE,11,"SELFMESSAGES")
		:SetSubCategory(FWL.GENERAL_TIPS,FW.ICON.HINT,1)
			:AddOption("INF",FWL.SELF_MESSAGES_HINT1)

	:SetMainCategory(FWL.SOUND,FW.ICON.SOUND,12,"SOUND")
		:SetSubCategory(FWL.GENERAL_TIPS,FW.ICON.HINT,1)
			:AddOption("INF",FWL.SOUND_HINT1)
			
	:SetMainCategory(FWL.ADVANCED,FW.ICON.DEFAULT,99,"DEFAULT")

		:SetSubCategory(FWL.GENERAL_TIPS,FW.ICON.HINT,1)
			:AddOption("INF",FWL.ADVANCED_HINT1)
			:AddOption("INF",FWL.ADVANCED_HINT2)
			
		:SetSubCategory(FWL.GENERAL_MO,FW.ICON.DEFAULT,1)
			:AddOption("CHK",FWL.GENERAL_MO3,	FWL.GENERAL_MO3_TT,	"FrameSnap")
			:AddOption("NUM",FWL.GENERAL_MO4,	FWL.GENERAL_MO4_TT,	"FrameSnapDistance"):SetEnabled("FrameSnap")
			:AddOption("NUM",FWL.GENERAL_MO5,	FWL.GENERAL_MO5_TT,	"FrameDistance"):SetEnabled("FrameSnap")
			:AddOption("CHK",FWL.SHOW_STARTUP,FWL.SHOW_STARTUP_TT,	"ShowStartupText")
			:AddOption("CHK",FWL.GLOBAL_FRAME_NAMES,FWL.GLOBAL_FRAME_NAMES_TT,	"GlobalFrameNames")
		
		:SetSubCategory(FWL.OPTIONS_BEHAVIOR,FW.ICON.DEFAULT,1)
			:AddOption("NUM",FWL.OPTIONS_COLUMNS,FWL.OPTIONS_COLUMNS_TT,	"OptionsColums"):SetRange(2,4):SetFunc(FW.BuildOptions)
			:AddOption("NUM",FWL.OPTIONS_HEIGHT,	FWL.OPTIONS_HEIGHT_TT,	"OptionsHeight"):SetRange(200):SetFunc(FW.BuildOptions)
			:AddOption("CHK",FWL.EXPAND_ALL,		FWL.EXPAND_ALL_TT,		"ExpandSubcats"):SetFunc(ResetExpanded)
			:AddOption("CHK",FWL.LOAD_EXPANDED,		FWL.LOAD_EXPANDED_TT,	"LoadExpandSubcats"):SetFunc(ResetExpanded)
			:AddOption("CHK",FWL.ANIMATE_SCROLL,	FWL.ANIMATE_SCROLL_TT,	"AnimateScroll")
			:AddOption("CHK","List spells on mouse-over","View all spells that belong to the spell type group by mousing over the option label.",		"TimerSpellsTooltip"):SetFunc(FW.BuildOptions)

		:SetSubCategory(FWL.OPTIONS_LINKING,FW.ICON.DEFAULT,1)
			:AddOption("INF",	FWL.LINK_HINT1)
			:AddOption("INF",	FWL.LINK_HINT2)
			
			:AddOption("CO2",FWL.LINKED_NONE,"",	"LinkNoneColor"):SetFunc(FW_RefreshOptionsNoStyleThrottle)
			:AddOption("COL",FWL.LINKED_PROFILES,"","LinkProfileColor"):SetFunc(FW_RefreshOptionsNoStyleThrottle)
			:AddOption("COL",FWL.LINKED_CLONES,"",	"LinkCloneColor"):SetFunc(FW_RefreshOptionsNoStyleThrottle)
			:AddOption("COL",FWL.LINKED_BOTH,"",	"LinkBothColor"):SetFunc(FW_RefreshOptionsNoStyleThrottle)
			:AddOption("BTN",FWL.CROSS_PROFILE_LINK,FWL.CROSS_PROFILE_LINK_TT,""):SetFunc(AutoLinkProfiles)
			:AddOption("BTN",FWL.CROSS_CLONE_LINK,	FWL.CROSS_CLONE_LINK_TT,""):SetFunc(AutoLinkClones)
			
			:AddOption("CO2",FWL.DIFFERS_NONE,"",	"DiffNoneColor"):SetFunc(FW_RefreshOptionsNoStyleThrottle)
			:AddOption("COL",FWL.DIFFERS_PROFILES,"","DiffProfileColor"):SetFunc(FW_RefreshOptionsNoStyleThrottle)
			:AddOption("COL",FWL.DIFFERS_CLONES,"",	"DiffCloneColor"):SetFunc(FW_RefreshOptionsNoStyleThrottle)
			:AddOption("COL",FWL.DIFFERS_BOTH,"",	"DiffBothColor"):SetFunc(FW_RefreshOptionsNoStyleThrottle)
			--:AddOption("BTN",FWL.CROSS_PROFILE_CORRECT,FWL.CROSS_PROFILE_CORRECT_TT,	"",	AutoFixProfiles)
			--:AddOption("BTN",FWL.CROSS_CLONE_CORRECT,	FWL.CROSS_CLONE_CORRECT_TT,		"",	AutoFixClones)
			
			:AddOption("CHK",FWL.ALWAYS_LINK_PROFILE,FWL.ALWAYS_LINK_PROFILE_TT,	"LinkProfile")
			:AddOption("CHK",FWL.ALWAYS_LINK_CLONE,	FWL.ALWAYS_LINK_CLONE_TT,	"LinkClone")

		:SetSubCategory(FWL.GENERAL_OA,FW.ICON.APPEARANCE,1)
			:AddOption("COL",FWL.GENERAL_OA1,	FWL.GENERAL_OA1_TT,	"OptionHeaderColor"):SetFunc(FC_SetOptionsColor)
			:AddOption("COL",FWL.GENERAL_OA2,	FWL.GENERAL_OA2_TT,	"OptionBackgroundColor"):SetFunc(FC_SetOptionsColor)
			:AddOption("CHK",FWL.MODULE_COLORS,	FWL.MODULE_COLORS_TT,"OptionsModuleColor"):SetFunc(FC_SetOptionsColor)
			:AddOption("FNT",FWL.GENERAL_OA3,	FWL.GENERAL_OA3_TT,	"OptionsHeaderFont"):SetFunc(FC_SetOptionsFont)
			:AddOption("FNT",FWL.GENERAL_OA4,	FWL.GENERAL_OA4_TT,	"OptionsFont"):SetFunc(FC_SetOptionsFont)
			:AddOption("TXT",FWL.GENERAL_OA3,	"",					"OptionsHeaderTexture",99):SetFunc(FC_SetOptionsBackdrop)
			:AddOption("TXT",FWL.SUB_HEADERS,	"",					"OptionsSubHeaderTexture",99):SetFunc(FC_SetOptionsBackdrop)
			:AddOption("BAC",FWL.BACK_GROUND,	"",					"OptionsBackdrop" ,99):SetFunc(FC_SetOptionsBackdrop)

		:SetSubCategory(FWL.CORE,FW.ICON.DEFAULT,1)
			:AddOption("NUM",FWL.LOADING_DELAY,				"",	"LoadDelay"):SetRange(1,10)
			:AddOption("NUM",FWL.UPDATE_INTERVAL_CORE,		"",	"UpdateInterval"):SetRange(0.01,1)
			:AddOption("NUM",FWL.UPDATE_INTERVAL_ANIMATIONS,	"",	"AnimationInterval"):SetRange(0.01,0.1)
			:AddOption("BTN",FWL.REMOVE_BACKUP,	FWL.REMOVE_BACKUP_TT,	""):SetFunc(FW_ClearBackup):SetEnabled(function() return FW:Size(FC_Saved) > 0; end)
			:AddOption("NUM",FWL.CHILL_SPEED,				"",	"Chill"):SetRange(0.01,0.1)

	:SetMainCategory(FWL.ABOUT,FW.ICON.HINT,100,"DEFAULT")
		:SetSubCategory("","",1)
			:AddOption("IMG","Copyright (C) 2006-2012 Xus (xuswow@hotmail.com)","","Interface\\AddOns\\Forte_Core\\Textures\\ForteXorcist",4,nil,100)
		:SetSubCategory("ForteXorcist on the Web",FW.ICON.HINT,1)
			:AddOption("INF","You can find additional documentation and news at my ForteXorcist portal.")
			:AddOption("INF","Please post bugs and suggestions on this portal as well.")
			:AddOption("URL","Portal","ForteXorcist Portal","http://www.wowinterface.com/portal.php?&uid=65900")
			:AddOption("INF","")
			:AddOption("INF","You can update this addon from WoWInterface and Curse.")
			:AddOption("URL","WoWI","Download at WoWInterface","http://www.wowinterface.com/downloads/info7532.html")
			:AddOption("URL","Curse","Download at Curse","http://wow.curse.com/downloads/wow-addons/details/fortexorcist.aspx")
			:AddOption("INF"," ")
			:AddOption("INF","If you want to donate anything for the work on this addon, feel free to use PayPal. Thanks! :)")
			:AddOption("URL","PayPal","Donate using PayPal","https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=2083371")
		
		:SetSubCategory("Special Thanks",FW.ICON.HINT,2)
			:AddOption("INF","I would like to thank the following people:")
			:AddOption("INF","   Everyone in Forte in its last years. Forte was the perfect AddOn testing playground ;)")
			:AddOption("INF","   Its (ex-)warlocks for their suggestions and being my guinea pigs :p")
			:AddOption("INF","   Everyone that gave me cool suggestions for the AddOn!")
		:SetSubCategory("Modules",FW.ICON.HINT,3)
			:AddOption("INF","I would like to curse the following people for making this suck up even more time: <3")
			:AddOption("INF","   Phanx for helping me add shared media support.")
			:AddOption("INF","   Eoy for starting the Priest module.")
			:AddOption("INF","   Exuro & Aeco for starting the Warrior module.")
			:AddOption("INF","   Lurosara for starting the Druid module.")
			:AddOption("INF","   Destard for starting the Hunter module.")
			:AddOption("INF","   Amros for starting the Mage module.")
			:AddOption("INF","   Arono of Skywall for starting the Paladin module.")
		:SetSubCategory("Translations",FW.ICON.HINT,4)
			:AddOption("INF","And finally thanks to the following people that helped translate the AddOn:")
			:AddOption("INF","   Papo & Shantara for Russian translations.")
			:AddOption("INF","   Rabbitcookie for Chinese translations.")
 			:AddOption("INF","   Sylrias & Boute for French translations.")
			:AddOption("INF","   DeaTHCorE & Haity & Stempi & Pannonica & Norrax for German translations.")
			:AddOption("INF","   Intxixu for Spanish translations.")
			:AddOption("INF","   ynetwork for Korean translations.")
		:SetSubCategory("FAQ",FW.ICON.FAQ,5)
			:AddOption("INF","   To come...")
			:AddOption("URL","","FAQ at ForteXorcist Portal","http://www.wowinterface.com/portal.php?id=513&a=faq")
		:SetSubCategory("Future",FW.ICON.HINT,7)
			:AddOption("INF","- Finish the About ;)")
			:AddOption("INF","- Spell Range/Usability Indicator")
			:AddOption("INF","- Rewrite really old code")
			:AddOption("INF","- Diminishing returns tracking @ spell timer")
			:AddOption("INF","- Some pet summon buttons etc so you can dump necrosis? :p")
			:AddOption("INF","- Docking with Fubar?")
			
	BINDING_HEADER_FORTEXORCIST = FW.TITLE;
	BINDING_NAME_FX_OPTIONS = FWL.TOGGLE_OPTIONS;
end

function FW:RefreshOptionsNoStyle()
	OptionsPanel:RefreshNoStyle();
end
function FW:RefreshOptions()
	OptionsPanel:Refresh();
end
function FW:ToggleOptions()
	OptionsPanel:Toggle();
end
function FW:ScrollTo(v,fo,instance)
	OptionsPanel:ScrollTo(v,fo,instance);
end
function FW:BuildOptions()
	OptionsPanel:Draw();
end