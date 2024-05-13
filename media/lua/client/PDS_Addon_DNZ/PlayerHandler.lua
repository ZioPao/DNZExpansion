
---@class PlayerHandler
---@field handlers table
---@field username string
---@field diceData diceDataType_DNZ
local PlayerHandler = require("DiceSystem_PlayerHandling")

---@cast DICE_CLIENT_MOD_DATA table<string, diceDataType_DNZ>


--* SUBSKILLS *--

local og_PlayerHandler_setupModDataTable = PlayerHandler.setupModDataTable

---@return table
function PlayerHandler:setupModDataTable()
    local tempTable = og_PlayerHandler_setupModDataTable(self)

    -- Setup subskills
    for skill, subSkillTable in pairs(PLAYER_DICE_VALUES.SUB_SKILLS) do
        tempTable.subSkills[skill] = {}
        tempTable.subSkillsBonus[skill] = {}
        for i=1, #subSkillTable do
            local subSkill = subSkillTable[i]
            tempTable.subSkills[skill][subSkill] = 0
            tempTable.subSkillsBonus[skill][subSkill] = 0

        end
    end

    return tempTable
end

---@param skill string
---@param subSkill string
---@return integer
function PlayerHandler:getSubSkillPoints(skill, subSkill)
    if not self:checkDiceDataValidity() then return -1 end
    return self.diceData.subSkills[skill][subSkill]
end


---@param skill string
---@param subSkill string
---@return integer
function PlayerHandler:getSubSkillBonusPoints(skill, subSkill)
    if not self:checkDiceDataValidity() then return -1 end
    return self.diceData.subSkillsBonus[skill][subSkill]
end


---@param coreSkill string
---@param subSkill string
---@return integer
function PlayerHandler:getFullSubSkillPoints(coreSkill, subSkill)
    return self:getSubSkillPoints(coreSkill, subSkill) + self:getSubSkillBonusPoints(coreSkill, subSkill)
end

---Increment a specific sub skillpoint
---@param coreSkill string
---@param subSkill string
---@return boolean
function PlayerHandler:increaseSubSkillPoint(coreSkill, subSkill)
    local result = false
    if self.diceData.allocatedPoints < self.diceData.level and self.diceData.subSkills[coreSkill][subSkill] < PLAYER_DICE_VALUES.MAX_PER_SKILL_ALLOCATED_POINTS then
        self.diceData.subSkills[coreSkill][subSkill] = self.diceData.subSkills[coreSkill][subSkill] + 1
        self.diceData.allocatedPoints = self.diceData.allocatedPoints + 1
        result = true
    end

    return result
end

---Decrement a specific skillpoint
---@param coreSkill string
---@param subSkill string
---@return boolean
function PlayerHandler:decreaseSubSkillPoint(coreSkill, subSkill)
    local result = false
    if self.diceData.subSkills[coreSkill][subSkill] > 0 then
        self.diceData.subSkills[coreSkill][subSkill] = self.diceData.subSkills[coreSkill][subSkill] - 1
        self.diceData.allocatedPoints = self.diceData.allocatedPoints - 1
        result = true
    end

    return result
end



---Add or subtract to any subskill point for this user
---@param coreSkill string
---@param subSkill string
---@param operation string
---@return boolean
function PlayerHandler:handleSubSkillPoint(coreSkill, subSkill, operation)
    local result = false

    if operation == "+" then
        result = self:increaseSubSkillPoint(coreSkill, subSkill)
    elseif operation == "-" then
        result = self:decreaseSubSkillPoint(coreSkill, subSkill)
    end

    -- In case of failure, just return.
    if not result then return false end

    return result
end





--* MORALE *--

---@return integer
function PlayerHandler:getCurrentMorale()
    return self:getCurrentStat("Morale")
end

---@return integer
function PlayerHandler:getMaxMorale()
    return self:getMaxStat("Morale")
end

---Get the morale bonus
---@return number
function PlayerHandler:getMoraleBonus()
    return self:getBonusStat("Morale")
end

---@param points number
---@param bonusPoints number
function PlayerHandler:setMoraleBonus(points, bonusPoints)
    local bonus = math.floor((points + bonusPoints) / 2)
    self:setBonusStat("Morale", bonus)
end

--******************************--

--* HEALTH BONUS *--

---Get the health bonus
---@return number
function PlayerHandler:getHealthBonus()
    return self:getBonusStat("Health")
end



---@param points number
---@param bonusPoints number
function PlayerHandler:setHealthBonus(points, bonusPoints)
    local bonus = math.floor((points + bonusPoints) / 2)
    self:setBonusStat("Health", bonus)
end






-- Override since we have different skills
function PlayerHandler:handleSkillPointSpecialCases(skill)

    local actualPoints = self:getSkillPoints(skill)
    local bonusPoints = self:getBonusSkillPoints(skill)

    if skill == 'Reflex' then
        self:setMovementBonus(actualPoints, bonusPoints)
        return
    end

    if skill == "Willpower" then
        -- Every 2 points in Willpower grants +1 in Morale
        self:setMoraleBonus(actualPoints, bonusPoints)
        return
    end

    if skill == "Body" then
        -- Every 2 points in Body grants +1 in Health
        self:setHealthBonus(actualPoints, bonusPoints)
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

--*****************--
--* IMPORTANT NOTE
--*****************--
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
function PlayerHandler:increaseSkillPoint(skill)
    local result = false
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
function PlayerHandler:decreaseSkillPoint(skill)
    local result = false
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