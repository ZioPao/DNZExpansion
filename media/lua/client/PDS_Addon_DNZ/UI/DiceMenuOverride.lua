if not getActivatedMods():contains("PandemoniumDiceSystem") then return end

require("PDS_Addon_DNZ/PlayerHandler") -- To make sure that we're loading the modifications
local DiceMenu = require("UI/DiceSystem_PlayerUI")
local CommonUI = require("UI/DiceSystem_CommonUI")
local SubSkillsSubMenu = require("PDS_Addon_DNZ/UI/SubSkillsSideMenu")
-----------------

--* LAYOUT OVERRIDES *--

local og_DiceMenu_createChildren = DiceMenu.createChildren
---@diagnostic disable-next-line: duplicate-set-field
function DiceMenu:createChildren()
    og_DiceMenu_createChildren(self)
    local frameHeight = 40 * CommonUI.FONT_SCALE

    -- Destroy armor bonus panel, make mov bonus at the center
    ---@type ISRichTextPanel
    local panelArmorBonus = self.panelArmorBonus
    panelArmorBonus:close()

    ---@type ISRichTextPanel
    local panelMovementBonus = self.panelMovementBonus
    panelMovementBonus:setX(0)
    panelMovementBonus:setWidth(self.width)

    --* Armor Line *--
    local y = self.panelMovement:getY() + frameHeight
    self:createPanelLine("Armor", y, frameHeight)

    y = y + frameHeight

    --* Morale Line *--
    self:createPanelLine("Morale", y, frameHeight)
    y = y + frameHeight

    self.labelSkillPointsAllocated:setY(y)

    y = y + frameHeight + frameHeight/2

    -- Move the skillPanelContainer a bit more down
    self.skillsPanelContainer:setY(y)
    self:calculateHeight(y)

    -- We need to move the bottom buttons a bit to align them correctly again
    if self.btnConfirm then
        self.btnConfirm:setY(self.height - 35)
    end

    self.btnClose:setY(self.height - 35)
end

local og_DiceMenu_addNameLabel = DiceMenu.addNameLabel
---@diagnostic disable-next-line: duplicate-set-field
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

--* ISEDITING OVERRIDE

---@diagnostic disable-next-line: duplicate-set-field
function DiceMenu:initialise()
    ISCollapsableWindow.initialise(self)

    -- isEditing needs to account for the leveling up stuff
    self.isEditing = not self.playerHandler:isPlayerInitialized() or self:getIsAdminMode() or self.playerHandler:getIsLevelingUp()

    if self.isEditing then
        -- Saves a reference of the old skills values to have a bottom val instead of 0

        self.oldSkills = {}
        -- cycle through skills
        for i = 1, #PLAYER_DICE_VALUES.SKILLS do
            local skill = PLAYER_DICE_VALUES.SKILLS[i]
            self.oldSkills[skill] = self.playerHandler:getSkillPoints(skill)

            for j=1, #PLAYER_DICE_VALUES.SUB_SKILLS[skill] do
                local subSkill = PLAYER_DICE_VALUES.SUB_SKILLS[skill][j]
                self.oldSkills[subSkill] = self.playerHandler:getSubSkillPoints(skill, subSkill)
            end

        end
    end
end


--* BUTTONS HANDLING TO ACCOUNT FOR SIDEMENU AND LEVELS*--

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


        if #PLAYER_DICE_VALUES.SUB_SKILLS[skill] > 0 then
            SubSkillsSubMenu.Toggle(self, btn, skill)
        else
            btn.enabled = false     -- todo test it
        end

    end

    og_DiceMenu_onOptionMouseDown(self, btn)
end

----------------------

--* UPDATE LOOP HANDLING *--


--- Edited to enable the save button ONLY when we match the level
---@param allocatedPoints number
---@diagnostic disable-next-line: duplicate-set-field
function DiceMenu:updateBottomPanelButtons(allocatedPoints)
    if self.isEditing then
        -- Save button
        self.btnConfirm:setEnable(allocatedPoints == self.playerHandler:getLevel())
    end
end


---@param skill string      could be a subskill or a core skill
---@param skillPoints number
---@param allocatedPoints number
---@diagnostic disable-next-line: duplicate-set-field
function DiceMenu:updateBtnModifierSkill(skill, skillPoints, allocatedPoints)
    local enableMinus = skillPoints ~= self.oldSkills[skill]
    local enablePlus = skillPoints ~= PLAYER_DICE_VALUES.MAX_PER_SKILL_ALLOCATED_POINTS and allocatedPoints < self.playerHandler:getLevel()

    CommonUI.UpdateBtnSkillModifier(self, skill, enableMinus, enablePlus)
end

---Full replace since we need to keep account of the level
---@param allocatedPoints number
---@diagnostic disable-next-line: duplicate-set-field
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
---@diagnostic disable-next-line: duplicate-set-field
function DiceMenu:update()
    og_DiceMenu_update(self)
    self:updateLevelLabel()

    ---@type PlayerHandler
    local ph = self.playerHandler

    local currentMorale = ph:getCurrentMorale()
    local totalMorale = ph:getTotalMorale()
    self:updatePanelLine("Morale", currentMorale, totalMorale)

    local currentArmor = ph:getCurrentArmor()
    local totalArmor = ph:getMaxArmor()     -- no bonuses technically
    self:updatePanelLine("Armor", currentArmor, totalArmor)
end

---Updates label for the level, under player's name
function DiceMenu:updateLevelLabel()
    ---@type ISLabel
    local levelLabel = self['levelLabel']
    local x
    local string

    local level = self.playerHandler:getLevel() + 1     -- 0 internally, add 1 for display

    if self.playerHandler:getIsLevelingUp() then
        string = getText("IGUI_Dice_NewLevel",level)
        levelLabel:setColor(0, 1, 0)  -- Green color for leveling up
    else
        string = getText("IGUI_Dice_Level", level)
        levelLabel:setColor(1,1,1)
    end

    x = (self.width - getTextManager():MeasureStringX(UIFont.Medium, string)) / 2
    levelLabel:setX(x)
    levelLabel:setName(string)

end

-- Just movementBonus
function DiceMenu:updateBonusValues()
    local movementBonus = self.playerHandler:getMovementBonus()
    local correctedMovBonus = movementBonus - self.playerHandler:getCurrentArmor()
    self.panelMovementBonus:setText(getText("IGUI_PlayerUI_MovementBonus", CommonUI.GetSign(correctedMovBonus), correctedMovBonus))
    self.panelMovementBonus.textDirty = true
end
-----------------------------------------------


local og_DiceMenu_close = DiceMenu.close
---@diagnostic disable-next-line: duplicate-set-field
function DiceMenu:close()
    -- To close side panels when the main one closes
    if self.openedPanel and self.openedPanel:getIsVisible() then
        self.openedPanel:close()
    end
    og_DiceMenu_close(self)
end
