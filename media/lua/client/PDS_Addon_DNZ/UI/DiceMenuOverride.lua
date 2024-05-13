if not getActivatedMods():contains("PandemoniumDiceSystem") then return end

local DiceMenu = require("UI/DiceSystem_PlayerUI")
local CommonUI = require("UI/DiceSystem_CommonUI")
require("PDS_Addon_DNZ/PlayerHandler") -- To make sure that we're loading the modifications
-----------------




--* ISEDITING OVERRIDE


function DiceMenu:initialise()
    ISCollapsableWindow.initialise(self)
    self.isEditing = not self.playerHandler:isPlayerInitialized() or self:getIsAdminMode() or self.playerHandler:getIsLevelingUp()
end
















local og_DiceMenu_addSkillPanelLabel = DiceMenu.addSkillPanelLabel
---@diagnostic disable-next-line: duplicate-set-field
function DiceMenu:addSkillPanelLabel(container, skill, x, frameHeight)
    -- Moves the Label a bit to the right to make space for the Side Btn
    x = CommonUI.BUTTON_WIDTH / 2 + 10
    og_DiceMenu_addSkillPanelLabel(self, container, skill, x, frameHeight)
end

local og_DiceMenu_addSkillPanelButtons = DiceMenu.addSkillPanelButtons
---@diagnostic disable-next-line: duplicate-set-field
function DiceMenu:addSkillPanelButtons(container, skill, isEditing, frameHeight, plUsername)
    --  Use isInitialized for levelingup thing
    og_DiceMenu_addSkillPanelButtons(self, container, skill, isEditing, frameHeight, plUsername)

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
        local skill = btn.skill


        -- center point is gonna be the button itself
        local centerY = btn:getAbsoluteY() - btn:getHeight()/2
        SubSkillsSubMenu.Toggle(self, btn, skill)
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

    local levelString = getText("IGUI_Dice_Level", self.playerHandler:getLevel())
    local x = (self.width - getTextManager():MeasureStringX(UIFont.Medium, levelString)) / 2
    local height = 25

    self[levelLabelId] = ISLabel:new(x, y, height, levelString, 1, 1, 1, 1, UIFont.Medium, true)
    self[levelLabelId]:initialise()
    self[levelLabelId]:instantiate()
    self:addChild(self[levelLabelId])

    return y + height + 10
end

--- Edited to enable the save button ONLY when we match the level
---@param allocatedPoints number
function DiceMenu:updateBottomPanelButtons(allocatedPoints)
    if self.isEditing then
        -- Save button
        self.btnConfirm:setEnable(allocatedPoints == self.playerHandler:getLevel())
    end
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
    ---@type ISLabel
    local levelLabel = self['levelLabel']
    levelLabel:setName(getText("IGUI_Dice_Level", self.playerHandler:getLevel()))
end

function DiceMenu:updateBtnModifierSkill(skill, skillPoints, allocatedPoints)
    local enableMinus = skillPoints ~= 0    -- FIX Should depend on current level for that skill, not 0
    local enablePlus = skillPoints ~= PLAYER_DICE_VALUES.MAX_PER_SKILL_ALLOCATED_POINTS and allocatedPoints < self.playerHandler:getLevel()

    CommonUI.UpdateBtnSkillModifier(self, skill, enableMinus, enablePlus)
end

---Full replace since we need to keep account of the level
---@param allocatedPoints number
function DiceMenu:updateAllocatedSkillPointsPanel(allocatedPoints)

    if self.isEditing then
        local pointsAllocatedString = getText("IGUI_SkillPointsAllocated") ..
            string.format(" %d/%d", allocatedPoints, self.playerHandler:getLevel())
        self.labelSkillPointsAllocated:setName(pointsAllocatedString)
    else
        self.labelSkillPointsAllocated:setName("")
    end
end

local og_DiceMenu_update = DiceMenu.update

function DiceMenu:update()
    og_DiceMenu_update(self)
    self:updateLevelLabel()

    local currentMorale = self.playerHandler:getCurrentMorale()
    local maxMorale = self.playerHandler:getMaxMorale()

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
