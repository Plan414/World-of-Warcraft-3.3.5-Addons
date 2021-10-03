--[[-------------------------------------------------------------------------
--  Options and configuration
-------------------------------------------------------------------------]]--

local function CreatePanel(panel)
    panel.title, panel.subtitle = panel:MakeTitleTextAndSubText(
        "LightHeaded Options", "These options allow you to configure various aspects of LightHeaded.")

    local function makeToggle(name, desc, varname)
        return panel:MakeToggle(
            "name", name, 
            "description", desc, 
            "default", LightHeaded.defaults.profile[varname], 
            "getFunc", function() return LightHeaded.db.profile[varname] end, 
            "setFunc", function(value) LightHeaded.db.profile[varname] = value end
        )
    end

    panel.tomtom = makeToggle("Send waypoints to TomTom", "Waypoints that are clicked in LightHeaded will be sent to TomTom, if installed.", "wp_tomtom")

    panel.cart2 = makeToggle("Send waypoints to Cartographer 2", "Waypoints that are clicked in LightHeaded will be sent to Cartographer 2, if installed.", "wp_cart2")

    panel.cart3 = makeToggle("Send waypoints to Cartographer 3", "Waypoints that are clicked in LightHeaded will be sent to Cartographer 3, if installed.", "wp_cart3")

    panel.mapnotes = makeToggle("Send waypoints to MapNotes", "Waypoints that are clicked in LightHeaded will be sent to MapNotes, if installed.", "wp_mapnotes")

    panel.sound = makeToggle("Play open/close sound", "Enable or disable the playing of an open/close sound when opening or closing the LightHeaded window.", "sound")

    panel.descs = makeToggle("Show english quest descriptions", "This option is really only useful for english speakers who are playing in a non-english locate", "descs")

    panel.page = makeToggle("Show comments on a single page", "Shows comments on a single page, rather than one page per comment", "singlepage")

    panel.debug = makeToggle("Show debug messages", "Displays periodic debug messages about the operations of LightHeaded", "debug")

    panel.fixmodel = makeToggle("Fix Quest Log NPC Model", "Fixes the NPC model that is shown for certain quests when they are viewed in the Quest Log.", "fixmodel")

    panel.attach = panel:MakeButton("name", "Attach", "description", "Attach the LH window to the quest log", "func", function() LightHeaded:AttachFrame() end)

    panel.detach = panel:MakeButton("name", "Detach", "description", "Detaches the LH window from the quest log", "func", function() LightHeaded:DetachFrame() end)
    panel.detach:SetPoint("LEFT", panel.attach, "RIGHT", 10, 0)

    panel.bgalpha = panel:MakeSlider(
        "name", "Background alpha",
        "description", "The alpha transparency of the LightHeaded window",
        "minText", "0",
        "maxText", "100",
        "minValue", 0,
        "maxValue", 1,
        "step", 0.01,
        "default", LightHeaded.defaults.profile.bgalpha,
        "current", LightHeaded.db.profile.bgalpha,
        "setFunc", function(value) 
            LightHeaded.db.profile.bgalpha = value
            LightHeaded:ChangeBGAlpha(value)
        end,
        "currentTextFunc", function(value) return ("%.0f%%"):format(value * 100) end
    )

    panel.fontsize = panel:MakeSlider(
        "name", "Font Size",
        "description", "The font size used in the LightHeaded window",
        "minText", "4",
        "maxText", "24",
        "minValue", 4,
        "maxValue", 24,
        "step", 1.0,
        "default", LightHeaded.defaults.profile.fontsize,
        "current", LightHeaded.db.profile.fontsize,
        "setFunc", function(value) 
            LightHeaded.db.profile.fontsize = value
            LightHeaded:ChangeFontSize(value)
        end,
        "currentTextFunc", function(value) return ("%d"):format(value) end
    )
    local options = {}
    table.insert(options, panel.tomtom)
    table.insert(options, panel.cart2)
    table.insert(options, panel.cart3)
    table.insert(options, panel.mapnotes)
    table.insert(options, panel.sound)
    table.insert(options, panel.descs)
    table.insert(options, panel.page)
    table.insert(options, panel.debug)
    table.insert(options, panel.fixmodel)
    table.insert(options, panel.attach)

    for idx,frame in ipairs(options) do
        if idx == 1 then
            frame:SetPoint("TOPLEFT", panel.subtitle, "BOTTOMLEFT", 0, -10)
        else
            frame:SetPoint("TOPLEFT", options[idx-1], "BOTTOMLEFT", 0, -5)
        end
    end

    panel.bgalpha:SetPoint("TOPLEFT", options[#options], "BOTTOMLEFT", 0, -20)
    panel.fontsize:SetPoint("TOPLEFT", panel.bgalpha, "BOTTOMLEFT", 0, -20)
end

function LightHeaded:CreateConfig()
    local simple = LibStub("LibSimpleOptions-1.0").AddOptionsPanel("LightHeaded", CreatePanel)
end
