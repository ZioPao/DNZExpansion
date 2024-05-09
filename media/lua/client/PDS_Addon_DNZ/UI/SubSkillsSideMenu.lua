if not getActivatedMods():contains("PandemoniumDiceSystem") then return end

-- Caching stuff
local playerBase = __classmetatables[IsoPlayer.class].__index
local getNum = playerBase.getPlayerNum

local PlayerHandler = require("DiceSystem_PlayerHandling")
local CommonUI = require("UI/DiceSystem_CommonUI")


------------------
---@class SubSkillsSubMenu : ISCollapsableWindow
SubSkillsSubMenu = ISCollapsableWindow:derive("SubSkillsSubMenu")



--- Toggle the sub skill panel on the left of the dice menu
---@param pl IsoPlayer
---@param username string
---@param skill string
---@param parent ISPanel
function SubSkillsSubMenu.Toggle(parent, skill, pl, username)
    -- Check if side panel is already open
    if parent.openedPanel then
        if parent.openedPanel:getIsVisible() then
            parent.openedPanel:close()

            -- check if skill is the same, if it is then return here since we're toggling it
            if parent.openedPanel.skill == skill then return end
        end
    end

    local width = parent:getWidth()
    local height = parent:getHeight()


    local x = parent:getAbsoluteX() - width
    local y = parent:getBottom() - height

    local sidePanel = SubSkillsSubMenu:new(x,y, width, height)
    sidePanel:initialise()
    sidePanel:bringToTop()

    parent.openedPanel = sidePanel

end

--************************************--

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
    ISCollapsableWindow.initialise(self)
    self:addToUIManager()
end

function SubSkillsSubMenu:createChildren()
    ISCollapsableWindow.createChildren(self)
end

function SubSkillsSubMenu:update()
    ISCollapsableWindow.update(self)
end

function SubSkillsSubMenu:prerender()
    ISCollapsableWindow.prerender(self)
end

function SubSkillsSubMenu:render()
    ISCollapsableWindow.render(self)
end

function SubSkillsSubMenu:close()
    ISCollapsableWindow.close(self)
end


