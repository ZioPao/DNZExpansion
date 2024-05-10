if not getActivatedMods():contains("PandemoniumDiceSystem") then return end

-- Caching stuff
local playerBase = __classmetatables[IsoPlayer.class].__index
local getNum = playerBase.getPlayerNum

local PlayerHandler = require("DiceSystem_PlayerHandling")
local CommonUI = require("UI/DiceSystem_CommonUI")


------------------
---@class SubSkillsSubMenu : ISCollapsableWindow
SubSkillsSubMenu = ISPanel:derive("SubSkillsSubMenu")



--- Toggle the sub skill panel on the left of the dice menu
---@param pl IsoPlayer
---@param username string
---@param skill string
---@param parent ISPanel
function SubSkillsSubMenu.Toggle(parent, skill, pl, username)
    --print("Toggling side panel for skill " .. skill)
    -- Check if side panel is already open
    if parent.openedPanel then

        --print("opened panel already exists")
        if parent.openedPanel:getIsVisible() then
            --print("closing it")
            parent.openedPanel:close()

            -- check if skill is the same, if it is then return here since we're toggling it
            if parent.openedPanel.skill == skill then
                --print("toggle, returning")
                return
            end
        end
    end

    local width = parent:getWidth()
    local height = parent:getHeight()


    local x = parent:getAbsoluteX() - width
    local y = parent:getBottom() - height

    local sidePanel = SubSkillsSubMenu:new(x,y, width, height, skill)
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
---@return ISCollapsableWindow
function SubSkillsSubMenu:new(x, y, width, height, skill)
    local o = {}
    o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.width = width
    o.height = height
    o.resizable = false

    o.skill = skill

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

    -- Add sub skills related to that specific skill

    local subSkills = PLAYER_DICE_VALUES.SUB_SKILLS[self.skill]
    --local y = 0
    local frameHeight = 40
    local skillsAmount = #subSkills

    local y = self:getHeight()/2 - (skillsAmount*frameHeight/2)

    -- TODO Make it work
    local isInitialized = false
    local plUsername = getPlayer():getUsername()

    for i=1, #subSkills do
        local subSkill = subSkills[i]
        local skillPanel = CommonUI.CreateBaseSingleSkillPanel(self, subSkill, i % 2 ~= 0, y, frameHeight)

        local xOffset = 10
        CommonUI.AddSkillPanelLabel(self, skillPanel, subSkill, xOffset, frameHeight)
        CommonUI.AddSkillPanelButtons(self, skillPanel, subSkill, isInitialized, frameHeight, plUsername)
        CommonUI.AddSkillPanelPoints(self, skillPanel, subSkill)

        y = y + frameHeight

        self:addChild(skillPanel)
        --self:setHeight(self:getHeight() + frameHeight)
    end

end

function SubSkillsSubMenu:update()
    ISPanel.update(self)
end

function SubSkillsSubMenu:prerender()
    ISPanel.prerender(self)
end

function SubSkillsSubMenu:render()
    ISPanel.render(self)
end

function SubSkillsSubMenu:close()
    ISPanel.close(self)
end


