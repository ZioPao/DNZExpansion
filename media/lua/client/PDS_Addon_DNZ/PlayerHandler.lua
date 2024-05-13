
---@class PlayerHandler
---@field handlers table
---@field username string
---@field diceData diceDataType_DNZ
local PlayerHandler = require("DiceSystem_PlayerHandling")

---@cast DICE_CLIENT_MOD_DATA table<string, diceDataType_DNZ>

--* MORALE *--

---@return integer
function PlayerHandler:getCurrentMorale()
    if DICE_CLIENT_MOD_DATA and self.username and DICE_CLIENT_MOD_DATA[self.username] then
        return DICE_CLIENT_MOD_DATA[self.username].currentMorale
    end

    return -1
end


---@return integer
function PlayerHandler:getMaxMorale()
    if DICE_CLIENT_MOD_DATA and self.username and DICE_CLIENT_MOD_DATA[self.username] then
        return DICE_CLIENT_MOD_DATA[self.username].maxMorale
    end

    return -1
end



--******************************--




---@param points number
---@param bonusPoints number
function PlayerHandler:applyMoraleBonus(points, bonusPoints)
    local bonus = math.floor((points + bonusPoints) / 2)
    DICE_CLIENT_MOD_DATA[self.username].moraleBonus = bonus
end

---@param points number
---@param bonusPoints number
function PlayerHandler:applyHealthBonus(points, bonusPoints)
    local bonus = math.floor((points + bonusPoints) / 2)
    DICE_CLIENT_MOD_DATA[self.username].healthBonus = bonus     -- TODO What is this? Health Bonus? what
end









-- Override since we have different skills
function PlayerHandler:handleSkillPointSpecialCases(skill)

    local actualPoints = self:getSkillPoints(skill)
    local bonusPoints = self:getBonusSkillPoints(skill)

    if skill == 'Reflex' then
        self:applyMovementBonus(actualPoints, bonusPoints)
        return
    end

    if skill == "Willpower" then
        -- Every 2 points in Willpower grants +1 in Morale
        self:applyMoraleBonus(actualPoints, bonusPoints)
        return
    end

    if skill == "Body" then
        -- Every 2 points in Body grants +1 in Health
        self:applyHealthBonus(actualPoints, bonusPoints)
        return
    end

end



-----------------------
--* Level up *--
--[[
    Basically similiar idea as the whole isInitialized thing, but we need
    to:
    1) Save the values we have BEFORE starting the level up, such as all the skill points and sub skill points
    2) Increment the amount of available skill points to +1
    3) Set that the minus button should be available ONLY if the value of the skill point is higher than the starting amount (the old value before the level up)
]]

--------------------------
--* IMPORTANT NOTE

--[[
    For simplicity sake, allocatedPoints is gonna be the value that we will use
    to track levels, since it's gonna functiona basically the same.

    So we're gonna wrap it up in another function just for readibility and ease of ease of use
]]

-----------------------

---@param isLevelingUp boolean
function PlayerHandler:setIsLevelingUp(isLevelingUp)
    -- Syncs it with server
    DICE_CLIENT_MOD_DATA[self.username].isLevelingUp = isLevelingUp
end

---@return boolean
function PlayerHandler:getIsLevelingUp()
    if DICE_CLIENT_MOD_DATA[self.username] == nil then
        error("Couldn't find player dice data!")
        return false
    end

    return DICE_CLIENT_MOD_DATA[self.username].isLevelingUp
end


function PlayerHandler:getLevel()
    return DICE_CLIENT_MOD_DATA[self.username].level
end


---@param level number
function PlayerHandler:setLevel(level)
    DICE_CLIENT_MOD_DATA[self.username].level = level

end
-- local PH = require("DiceSystem_PlayerHandling")
-- print(PH:instantiate(getPlayer():getUsername()):isPlayerInitialized())

function PlayerHandler:triggerLevelUp()
    -- check current level
    if self:getLevel() > PLAYER_DICE_VALUES.MAX_LEVELS then
        print("Max level reached")
        return
    end

    if self:getIsLevelingUp() then
        print("Already leveling up")
        return
    end

    self:setIsLevelingUp(true)

    -- Set new max amount of allocable points
    local level = self:getLevel() + 1
    self:setLevel(level)


    -- Force close and reopen menu
    local DiceMenu = require("UI/DiceSystem_PlayerUI")
    DiceMenu.ClosePanel()
    DiceMenu.OpenPanel(false, self.username)

end

---Increment a specific skillpoint
---@param skill string
---@return boolean
function PlayerHandler:incrementSkillPoint(skill)
    local result = false

    -- TODO Make this customizable from DATA
    if self.diceData.allocatedPoints < self.diceData.level and self.diceData.skills[skill] < PLAYER_DICE_VALUES.MAX_PER_SKILL_ALLOCATED_POINTS then
        self.diceData.skills[skill] = self.diceData.skills[skill] + 1
        self.diceData.allocatedPoints = self.diceData.allocatedPoints + 1
        result = true
    end

    return result
end

---Decrement a specific skillpoint
---@param skill string
---@return boolean
function PlayerHandler:decrementSkillPoint(skill)
    local result = false

    -- TODO Make this customizable from DATA

    if self.diceData.skills[skill] > 0 then
        self.diceData.skills[skill] = self.diceData.skills[skill] - 1
        self.diceData.allocatedPoints = self.diceData.allocatedPoints - 1
        result = true
    end

    return result
end
-- TODO Players should be able to accept or not a level up?


-- Returns the modified PlayerHandler for DNZ


return PlayerHandler