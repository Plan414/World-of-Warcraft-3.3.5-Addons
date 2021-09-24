-- English localization file for enUS and enGB.
local L = ElvUI[1].Libs.ACL:NewLocale("ElvUI", "enUS", true, true)
if not L then return; end

L["DTBars2_DESC"] = "This plugin allows you to create and customize additional datatext panels"
L["Show additional options."] = true
L["Set the name for the new datatext panel."] = true
L["Slots"] = true
L["Sets number of datatext slots for the panel"] = true
L["Hide panel background"] = true
L["Don't show this panel, only datatexts assinged to it"] = true
L["Anchor"] = true
L["Panel anchors itself on the parent frame with this point."] = true
L["Panel anchors itself to this point on the parent frame."] = true
L["Strata"] = true
L["Defines on what layer of the UI your panel will be: higher layer/number allows the panel to overlap more other frames. If you are not sure, leave this option at \"2. Low\""] = true
L["DT_Slot_Change_Text"] = "You are going to set slots from |cff1784d1%s|r to |cff1784d1%s|r. Changing this option will reset datatexts' for the panel to default values. Continue?"
L["Deleting the panel will erase all it's setting and you'll not be able to restore them. Continue?"] = true
L["Are you sure you want to create a panel with those parameters?\nThis action will require a reload."] = true
L["farleft"] = "Far Left"
L["farright"] = "Far Right"
L["Sets width of the panel"] = true
L["Sets height of the panel (height of each individual datatext)"] = true
L["Panel with the name %s already exist. Please choose another one."] = true