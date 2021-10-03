
local OneBag3 = LibStub('AceAddon-3.0'):GetAddon('OneBag3')
local OneRing3 = LibStub('AceAddon-3.0'):NewAddon('OneRing3', 'OneCore-1.0', 'OneFrame-1.0', 'OneConfig-1.0', 'OnePlugin-1.0', 'AceHook-3.0', 'AceEvent-3.0', 'AceConsole-3.0')   
local AceDB3 = LibStub('AceDB-3.0')
local L = LibStub("AceLocale-3.0"):GetLocale("OneRing3")  

OneRing3:InitializePluginSystem()                         
     
--- Handles the do once configuration, including db, frames and configuration
function OneRing3:OnInitialize()      
	self.db = OneBag3.db
	self.displayName = "OneRing3"
	
	self.bagIndexes = {-2}
	self.forcedCols = 4
	self.bottomBorder = 5
	self.topBorder = -5
	
	self.frame = self:CreateMainFrame("OneRingFrame")
	self.frame.handler = self
	
    table.insert(OneBag3.frame.childrenFrames, self.frame)
	                                                     
	self.frame:SetPosition(self.db.profile.position)
	self.frame:CustomizeFrame(self.db.profile)
	
	self.frame.moneyframe:Hide()
	self.frame.sidebarButton:Hide()
	self.frame.configButton:Hide()      
	
	self.frame.name:ClearAllPoints()
	self.frame.name:SetPoint("TOPLEFT", "OneRingFrame", "TOPLEFT", 10, -15)
	
	self.frame:SetScript("OnShow", function()
        if not self.frame.slots then
            self.frame.slots = {}
        end
        
        self:BuildFrame()
        self:OrganizeFrame()
        self:UpdateFrame()
        
        local UpdateBag = function(event, bag) 
			self:UpdateBag(bag)
		end

		self:RegisterEvent("BAG_UPDATE", UpdateBag)
		self:RegisterEvent("BAG_UPDATE_COOLDOWN", UpdateBag)
		self:RegisterEvent("UPDATE_INVENTORY_ALERTS", "UpdateFrame")     
		self:RegisterEvent("ITEM_LOCK_CHANGED", "UpdateItemLock")
		
		self.frame.name:SetText(L["%s's KeyRing"]:format(UnitName("player"))) 

        self.frame:ClearAllPoints()   		
		if not OneBag3.frame:IsVisible() then 
            self.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0) 
        else 
            self.frame:SetPoint("BOTTOMLEFT", OneBag3.frame, "TOPLEFT", 0, 8) 
        end
	end)
	             
	self.frame:SetScript("OnHide", function()
	    self:UnregisterEvent("BAG_UPDATE")
	    self:UnregisterEvent("BAG_UPDATE_COOLDOWN")
	    self:UnregisterEvent("UPDATE_INVENTORY_ALERTS")  
	    self:UnregisterEvent("ITEM_LOCK_CHANGED")
	end)
end

--- Sets up hooks and registers events
function OneRing3:OnEnable()
    self:SecureHook("ToggleKeyRing", function()
        if self.frame:IsVisible() then
            self.frame:Hide()
        else
            self.frame:Show()
        end
        
        local shownContainerID = IsBagOpen(KEYRING_CONTAINER)
        if ( shownContainerID ) then
            local frame = getglobal("ContainerFrame"..shownContainerID)
            frame:Hide()
        end
    end)
end
    