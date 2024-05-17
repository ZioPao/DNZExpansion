if not getActivatedMods():contains("PandemoniumDiceSystem") then return end

local CommonUI = require("UI/DiceSystem_CommonUI")



--------------
local SKILL_LABEL_HEIGHT = 25
local Y_PADDING = 10

------------------
---@class SubSkillsSubMenu : ISCollapsableWindow
---@field playerHandler PlayerHandler
---@field parent DiceMenu
---@field startingBtn ISButton
local SubSkillsSubMenu = ISPanel:derive("SubSkillsSubMenu")

--- Toggle the sub skill panel on the left of the dice menu
---@param skill string
---@param startingBtn ISButton
---@param parent DiceMenu
function SubSkillsSubMenu.Toggle(parent, startingBtn, skill)
    --DiceSystem_Common.DebugWriteLog"Toggling side panel for skill " .. skill)
    -- Check if side panel is already open
    if parent.openedPanel then
        --DiceSystem_Common.DebugWriteLog"opened panel already exists")
        if parent.openedPanel:getIsVisible() then
            --DiceSystem_Common.DebugWriteLog"closing it")
            parent.openedPanel:close()

            -- check if skill is the same, if it is then return here since we're toggling it
            if parent.openedPanel.skill == skill then
                --DiceSystem_Common.DebugWriteLog"toggle, returning")
                return
            end
        end
    end

    local subSkills = PLAYER_DICE_VALUES.SUB_SKILLS[skill]
    local skillsAmount = #subSkills

    local width = parent:getWidth()
    local height = CommonUI.FRAME_HEIGHT * skillsAmount + SKILL_LABEL_HEIGHT + Y_PADDING*2

    local x =  parent:getAbsoluteX() - parent:getWidth()
    local y = startingBtn:getAbsoluteY() + startingBtn:getHeight() - height


    local sidePanel = SubSkillsSubMenu:new(x, y, width, height, skill, parent, startingBtn)
    sidePanel:initialise()
    sidePanel:bringToTop()

    parent.openedPanel = sidePanel
end

--************************************--


---@param x number
---@param y number
---@param width number
---@param height number
---@param skill string
---@param parent DiceMenu
---@param startingBtn ISButton
---@return ISCollapsableWindow
function SubSkillsSubMenu:new(x, y, width, height, skill, parent, startingBtn)
    local o = {}
    o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.width = width
    o.height = height
    o.resizable = false

    o.skill = skill
    o.parent = parent
    o.startingBtn = startingBtn

    return o
end

--************************************--
---Initialization
function SubSkillsSubMenu:initialise()
    ISPanel.initialise(self)
    self:addToUIManager()
end

function SubSkillsSubMenu:createChildren()
    ISPanel.createChildren(self)


    self["skillLabel"] = ISLabel:new(10, 2, SKILL_LABEL_HEIGHT, self.skill, 1, 1, 1, 1, UIFont.Large, true)
    self["skillLabel"]:initialise()
    self["skillLabel"]:instantiate()
    self:addChild(self["skillLabel"])


    -- Add sub skills related to that specific skill
    local frameHeight = CommonUI.FRAME_HEIGHT
    local y = SKILL_LABEL_HEIGHT + Y_PADDING


    ---@type DiceMenu
    local parent = self.parent -- just to have a reference
    local isEditing = not parent.playerHandler:isPlayerInitialized() or parent:getIsAdminMode() or
    parent.playerHandler:getIsLevelingUp()
    local plUsername = getPlayer():getUsername()
    local subSkills = PLAYER_DICE_VALUES.SUB_SKILLS[self.skill]

    for i = 1, #subSkills do
        local subSkill = subSkills[i]
        local skillPanel = CommonUI.CreateBaseSingleSkillPanel(self, subSkill, i % 2 ~= 0, y, frameHeight)
        --DiceSystem_Common.DebugWriteLogsubSkill)

        local xOffset = 10
        CommonUI.AddSkillPanelLabel(self, skillPanel, subSkill, xOffset, frameHeight)
        CommonUI.AddSkillPanelButtons(self, skillPanel, parent.playerHandler, subSkill, isEditing, frameHeight,
            plUsername)


        CommonUI.AddSkillPanelPointsLabel(self, skillPanel, subSkill)

        y = y + frameHeight

        self:addChild(skillPanel)
    end
end

function SubSkillsSubMenu:update()
    ISPanel.update(self)

    ---@type DiceMenu
    local parent = self.parent -- just to have a reference

    local allocatedPoints = parent.playerHandler:getAllocatedSkillPoints()
    local isEditing = not parent.playerHandler:isPlayerInitialized() or parent:getIsAdminMode() or
    parent.playerHandler:getIsLevelingUp()

    for i = 1, #PLAYER_DICE_VALUES.SUB_SKILLS[self.skill] do
        local subSkill = PLAYER_DICE_VALUES.SUB_SKILLS[self.skill][i]
        local subSkillPoints = parent.playerHandler:getSubSkillPoints(self.skill, subSkill)
        local bonusSubSkillPoints = parent.playerHandler:getBonusSkillPoints(subSkill)
        local subSkillPointsString = " <RIGHT> " .. string.format("%d", subSkillPoints)
        if bonusSubSkillPoints and bonusSubSkillPoints ~= 0 then
            subSkillPointsString = subSkillPointsString ..
                string.format(" <RGB:0.94,0.82,0.09> <SPACE> %s <SPACE> %d", CommonUI.GetSign(bonusSubSkillPoints), bonusSubSkillPoints)
        end


        --DiceSystem_Common.DebugWriteLogsubSkill)
        self["labelSkillPoints" .. subSkill]:setText(subSkillPointsString)
        self["labelSkillPoints" .. subSkill].textDirty = true


        -- Handles buttons to assign skill points
        if isEditing then
            -- TODO Dirty, since we're copying and pasting code from DiceMenu.
            local enableMinus = subSkillPoints ~= parent.oldSkills[subSkill]
            local enablePlus = subSkillPoints ~= PLAYER_DICE_VALUES.MAX_PER_SKILL_ALLOCATED_POINTS and
                allocatedPoints < parent.playerHandler:getLevel()
            CommonUI.UpdateBtnSkillModifier(self, subSkill, enableMinus, enablePlus)
        end
    end
end

function SubSkillsSubMenu:onOptionMouseDown(btn)
    ---@type PlayerHandler
    local ph = self.parent.playerHandler

    -- TODO This is really confusing
    -- self.skill = CORE SKILL
    -- btn.skill = SUB SKILL
    local coreSkill = self.skill
    local subSkill = btn.skill
    if btn.internal == 'PLUS_SKILL' then
        ph:handleSubSkillPoint(coreSkill, subSkill, "+")
    elseif btn.internal == 'MINUS_SKILL' then
        ph:handleSubSkillPoint(coreSkill, subSkill, "-")
    elseif btn.internal == 'SKILL_ROLL' then
        local points = ph:getFullSubSkillPoints(coreSkill, subSkill)
        DiceSystem_Common.Roll(btn.skill, points)
    end
end

function SubSkillsSubMenu:prerender()
    ISPanel.prerender(self)
end

function SubSkillsSubMenu:render()
    ISPanel.render(self)
    -- Functionality to have side panel move with the rest of the menu
    local x = self.parent:getAbsoluteX() - self.parent:getWidth()
    local y = self.startingBtn:getAbsoluteY() - self:getHeight() + self.startingBtn:getHeight()

    self:setX(x)
    self:setY(y)
end

function SubSkillsSubMenu:close()
    ISPanel.close(self)
    self:removeFromUIManager()
end


return SubSkillsSubMenu