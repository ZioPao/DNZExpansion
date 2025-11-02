local SpecialSkillUI  = {}

---@param container ISPanel
---@param specialId number
---@param x number
---@param frameHeight number
function SpecialSkillUI.AddEditableSkillPanelLabel(parent, container, specialId, x, frameHeight, visible)


    -- todo ideally we would get the name of the special skill from global mod data
    local box = ISTextEntryBox:new("Skill "..specialId, x, frameHeight / 4, container.width/3, 25)
    parent["editSpecial"..specialId] = box        -- Reference for later
    box:initialise()
    box:instantiate()
    box:setVisible(visible, nil)
    container:addChild(box)
end


return SpecialSkillUI