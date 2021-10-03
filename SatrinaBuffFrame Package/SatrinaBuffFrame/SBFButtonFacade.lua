-- ButtonFacade support

if IsAddOnLoaded("ButtonFacade") and (ButtonFacade ~= nil) then
  local bf = LibStub("AceAddon-3.0"):GetAddon("ButtonFacade")
  local lbf = LibStub("LibButtonFacade")
  local SBFBF = {}

  SBFBF.SetupGroups = function(self)
    for k,v in pairs(SBF.frames) do
      self:SetupGroup("SBF", v._var.general.frameName)
    end
  end
  
  -- arg,SkinID,Gloss,Backdrop,Group,Button,Colors
  SBFBF.SkinCallback = function(self, skin, gloss, backdrop, frameName, _, colours)
    if not frameName then 
      return 
    end
    db[frameName].skin = skin
    db[frameName].gloss = gloss
    db[frameName].backdrop = backdrop
    db[frameName].colours = colours
    SBF:ForceAll()
  end

  SBFBF.SetupGroup = function(self, frameName, vars)
    local btndata
    local bfGroup = lbf:Group("SBF", frameName)
    local f = SBF:FindFrame(frameName)
    if f.slots then
      for index,slot in ipairs(f.slots) do
        if slot and slot.icon then
          if not slot.icon.bfBtndata then
            slot.icon.bfBtndata = {}
          end
          bfGroup:AddButton(slot.icon, slot.icon.bfBtndata)
        end
      end
    end
    if not db[frameName] then
      if not vars then
        db[frameName] = { skin = "Blizzard", gloss = 0, backdrop = false, colours = {}, }
      else
        db[frameName] = { skin = vars.skin, gloss = vars.gloss, backdrop = vars.backdrop, colours = vars.colours, }
      end
    end
    bfGroup:Skin(db[frameName].skin, db[frameName].gloss, db[frameName].backdrop, db[frameName].colours)
  end

  SBFBF.UndoGroup = function(self, frameName, delete)
    local bfGroup = lbf:Group("SBF", frameName)
    if bfGroup then
      local f = SBF:FindFrame(frameName)
      if f.slots then
        for index,slot in ipairs(f.slots) do
          if slot and slot.icon then
            bfGroup:RemoveButton(slot.icon)
          end
        end
      end
    end
    if delete then
      db[frameName] = nil
      lbf:DeleteGroup("SBF", frameName)
    end
  end
  
  SBFBF.HasGroups = function(self)
    local g = lbf:Group("SBF")
    if g and g.SubList then
        return (#g.SubList > 0)
    end
    return false
  end
  
  SBFBFLoad = function()
    if not SBF.db.global.disableBF then
      if not SBF.db.profile.buttonFacade then
        SBF.db.profile.buttonFacade = {}
      end
      db = SBF.db.profile.buttonFacade
      SBFBF.db = db
      lbf:RegisterSkinCallback("SBF", SBFBF.SkinCallback, SBFBF)
      SBFBF.skins = lbf:GetSkins()
      return SBFBF
    end
    return nil
  end
else
  SBFBFLoad = function() return nil end
end

