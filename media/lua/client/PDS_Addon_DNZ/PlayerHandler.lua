
---@class PlayerHandler
local PlayerHandler = require("DiceSystem_PlayerHandling")


---@alias diceDataType_DNZ {isInitialized : boolean, occupation : string, statusEffects : statusEffectsType, currentHealth : number, maxHealth : number, healthBonus : number, armorBonus : number, currentMovement : number, maxMovement : number, movementBonus : number, currentMorale : number, maxMorale : number, moraleBonus : number, allocatedPoints : number, skills : skillsTabType, skillsBonus : skillsBonusTabType}


---@cast DICE_CLIENT_MOD_DATA table<string, diceDataType_DNZ>

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
    DICE_CLIENT_MOD_DATA[self.username].healthBonus = bonus
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
        -- Every 2 points in Body grants +1 in Morale
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
function PlayerHandler:getCurrentLevel()
    -- TODO Should return the max amount, not the allocated one
    return self:getAllocatedSkillPoints()
end

function PlayerHandler:triggerLevelUp()
    -- check current level
    if self:getCurrentLevel() > PLAYER_DICE_VALUES.MAX_LEVELS then
        print("Max level reached")
        return
    end



end


-- TODO Players should be able to accept or not a level up?


-- Returns the modified PlayerHandler for DNZ

return PlayerHandler