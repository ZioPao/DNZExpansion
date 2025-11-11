local SpecialSkillUI  = {}

local PANEL_HEIGHT = 25

---@param container ISPanel
---@param specialId number
---@param x number
---@param frameHeight number
---@param visible boolean
function SpecialSkillUI.AddEditableSkillPanelLabel(parent, container, specialSkillText, specialId, x, frameHeight, visible)

    -- todo ideally we would get the name of the special skill from global mod data
    local box = ISTextEntryBox:new(specialSkillText, x, frameHeight / 2 - PANEL_HEIGHT/2, container.width/3, PANEL_HEIGHT)
    parent["editSpecial"..specialId] = box        -- Reference for later
    box:initialise()
    box:instantiate()
    box:setVisible(visible, nil)
    container:addChild(box)
end

---@param parent ISPanel
---@param container ISPanel
---@param specialSkillText string
---@param specialId number
---@param x number
---@param frameHeight number
---@param visible boolean
function SpecialSkillUI.AddSpecialSkillPanelLabel(parent, container, specialSkillText, specialId, x, frameHeight, visible)

    local label = ISLabel:new(x, frameHeight / 2 - PANEL_HEIGHT/2, PANEL_HEIGHT, specialSkillText, 1, 1, 1, 1, UIFont.Small, true)

    -- todo reference should be based on id of special sub skill, not name
    parent["labelSpecial"..specialId] = label        -- Reference for later
    label:initialise()
    label:instantiate()
    label:setVisible(visible)
    container:addChild(label)
end


return SpecialSkillUI