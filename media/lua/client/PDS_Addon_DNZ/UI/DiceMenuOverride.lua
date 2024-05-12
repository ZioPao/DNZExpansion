if not getActivatedMods():contains("PandemoniumDiceSystem") then return end

local DiceMenu = require("UI/DiceSystem_PlayerUI")
local CommonUI = require("UI/DiceSystem_CommonUI")
require("PDS_Addon_DNZ/PlayerHandler") -- To make sure that we're loading the modifications
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
    --  Use isInitialized for levelingup thing
    local showAssignButtons = isInitialized or self.playerHandler:getIsLevelingUp()
    og_DiceMenu_addSkillPanelButtons(self, container, skill, showAssignButtons, frameHeight, plUsername)

    -- Adding Side Panel Toggle button
    local btnWidth = CommonUI.BUTTON_WIDTH / 2
    local btnSubSkills = ISButton:new(0, 0, btnWidth, frameHeight, "<", self,
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
    if btn.internal == "SAVE" then
        -- disable level up now that it's done
        self.playerHandler:setIsLevelingUp(false)
    end
    if btn.internal == "SUB_SKILLS_PANEL" then
        --TODO Open Sub Skills Panel for that skill
        local skill = btn.skill

        SubSkillsSubMenu.Toggle(self, skill, getPlayer(), "")
    end

    og_DiceMenu_onOptionMouseDown(self, btn)
end

----------------------

--* Level up modifications *--

local og_DiceMenu_addNameLabel = DiceMenu.addNameLabel
function DiceMenu:addNameLabel(playerName, y)
    y = og_DiceMenu_addNameLabel(self, playerName, y)

    -- Add level under the name
    y = y - 10 -- Removes the padding
    local levelLabelId = "levelLabel"

    -- TODO Add Translation
    local levelString = "LEVEL: " .. self.playerHandler:getLevel()
    local x = (self.width - getTextManager():MeasureStringX(UIFont.Medium, levelString)) / 2
    local height = 25

    self[levelLabelId] = ISLabel:new(x, y, height, levelString, 1, 1, 1, 1, UIFont.Medium, true)
    self[levelLabelId]:initialise()
    self[levelLabelId]:instantiate()
    self:addChild(self[levelLabelId])

    return y + height + 10
end

------------------------------------
--* MORALE *--

local og_DiceMenu_createChildren = DiceMenu.createChildren
function DiceMenu:createChildren()
    og_DiceMenu_createChildren(self)
    local frameHeight = 40 * CommonUI.FONT_SCALE

    --* Morale Line *--
    local y = self.panelMovement:getY() + frameHeight
    self:createPanelLine("Morale", y, frameHeight)


    -- TODO labelSkillpointsAllocated must be moved too
    self.labelSkillPointsAllocated:setY(self.labelSkillPointsAllocated:getY() + frameHeight)



    -- Move the skillPanelContainer a bit more down
    local finalY = y + frameHeight * 2
    self.skillsPanelContainer:setY(finalY)
    self:calculateHeight(finalY)

    -- We need to move the bottom buttons a bit to align them correctly again

    if self.btnConfirm then
        self.btnConfirm:setY(self.height - 35)
    end

    self.btnClose:setY(self.height - 35)
end

-----------------------------------------

---Updates label for the level, under player's name
function DiceMenu:updateLevelLabel()
    local level = self.playerHandler:getLevel()
    local levelString = "LEVEL: " .. tostring(level)

    ---@type ISLabel
    local levelLabel = self['levelLabel']
    levelLabel:setName(levelString)
end

function DiceMenu:updateBtnModifierSkill(skill, skillPoints, allocatedPoints)
    self["btnMinus" .. skill]:setEnable(skillPoints ~= 0) -- FIX Should depend on current level for that skill, not 0
    self["btnPlus" .. skill]:setEnable(skillPoints ~= PLAYER_DICE_VALUES.MAX_PER_SKILL_ALLOCATED_POINTS and
    allocatedPoints < self.playerHandler:getLevel())
end

---Full replace since we need to keep account of the level
---@param isEditing boolean
---@param allocatedPoints number
function DiceMenu:updateAllocatedSkillPointsPanel(isEditing, allocatedPoints)
    --isEditing = isEditing or self.playerHandler:getIsLevelingUp()

    if isEditing then
        local pointsAllocatedString = getText("IGUI_SkillPointsAllocated") ..
            string.format(" %d/%d", allocatedPoints, self.playerHandler:getLevel())
        self.labelSkillPointsAllocated:setName(pointsAllocatedString)
    else
        self.labelSkillPointsAllocated:setName("")
    end
end

local og_DiceMenu_update = DiceMenu.update

---@param isEditing boolean
function DiceMenu:update(isEditing)
    isEditing = not self.playerHandler:isPlayerInitialized() or self:getIsAdminMode() or self.playerHandler:getIsLevelingUp()

    og_DiceMenu_update(self, isEditing)
    self:updateLevelLabel()

    -- TODO Replace placeholders
    local currentMorale = 1
    local maxMorale = 1

    self:updatePanelLine("Morale", currentMorale, maxMorale)
end

local og_DiceMenu_close = DiceMenu.close
function DiceMenu:close()
    -- To close side panels when the main one closes
    if self.openedPanel and self.openedPanel:getIsVisible() then
        self.openedPanel:close()
    end
    og_DiceMenu_close(self)
end
