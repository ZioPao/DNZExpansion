if not getActivatedMods():contains("PandemoniumDiceSystem") then return end

local DiceMenu = require("UI/DiceSystem_PlayerUI")
local CommonUI = require("UI/DiceSystem_CommonUI")
-----------------

local og_DiceMenu_addSkillPanelLabel = DiceMenu.addSkillPanelLabel
---@diagnostic disable-next-line: duplicate-set-field
function DiceMenu:addSkillPanelLabel(container, skill, x, frameHeight)
    -- Moves the Label a bit to the right to make space for the Side Btn
    x = CommonUI.BUTTON_WIDTH / 2 + 10
    og_DiceMenu_addSkillPanelLabel(self, container, skill, x, frameHeight)
end

local og_DiceMenu_addSkillPanelButtons = DiceMenu.addSkillPanelButtons
---@diagnostic disable-next-line: duplicate-set-field
function DiceMenu:addSkillPanelButtons(container, skill, isInitialized, frameHeight, plUsername)
    og_DiceMenu_addSkillPanelButtons(self, container, skill, isInitialized, frameHeight, plUsername)

    -- Adding Side Panel Toggle button
    local btnWidth = CommonUI.BUTTON_WIDTH / 2
    local btnSubSkills = ISButton:new(0, 0, btnWidth, frameHeight - 2, "<", self,
        self.onOptionMouseDown)
    btnSubSkills.internal = "SUB_SKILLS_PANEL"
    btnSubSkills.skill = skill
    btnSubSkills:initialise()
    btnSubSkills:instantiate()
    btnSubSkills:setEnable(true)
    self["btnSubSkills" .. skill] = btnSubSkills
    container:addChild(btnSubSkills)
end

---@diagnostic disable-next-line: duplicate-set-field
function DiceMenu:render()
    ISCollapsableWindow.render(self)

    -- Functionality to have side panel move with the rest of the menu
    if self.openedPanel then
        -- Needs to be on the left side
        local x = self:getAbsoluteX() - self:getWidth()
        local y = self:getBottom() - self:getHeight()

        self.openedPanel:setX(x)
        self.openedPanel:setY(y)
    end
end

local og_DiceMenu_onOptionMouseDown = DiceMenu.onOptionMouseDown

---@param btn ISButton
---@diagnostic disable-next-line: duplicate-set-field
function DiceMenu:onOptionMouseDown(btn)
    og_DiceMenu_onOptionMouseDown(self, btn)

    if btn.internal == "SUB_SKILLS_PANEL" then
        --TODO Open Sub Skills Panel for that skill
        local skill = btn.skill

        SubSkillsSubMenu.Toggle(self, skill, getPlayer(), "")
    end
end

----------------------

--* Level up modifications *--

local og_DiceMenu_addNameLabel = DiceMenu.addNameLabel
function DiceMenu:addNameLabel(playerName, y)
    y = og_DiceMenu_addNameLabel(self, playerName, y)

    -- Add level under the name
    y = y - 10      -- Removes the padding
    local levelLabelId = "levelLabel"
    local levelString = "LEVEL: 123"        -- TODO Placeholder

    local x = (self.width - getTextManager():MeasureStringX(UIFont.Medium, levelString)) / 2
    local height = 25

    self[levelLabelId] = ISLabel:new(x, y, height, levelString, 1, 1, 1, 1, UIFont.Medium, true)
    self[levelLabelId]:initialise()
    self[levelLabelId]:instantiate()
    self:addChild(self[levelLabelId])

    return y + height + 10

end
