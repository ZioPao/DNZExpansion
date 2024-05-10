
---@class PlayerHandler
local PlayerHandler = require("DiceSystem_PlayerHandling")


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