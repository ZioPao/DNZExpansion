require("DiceSystem_CommonMethods")



local og_DiceSystem_Common_GetSkillName = DiceSystem_Common.GetSkillName

---@param skill string
---@return any
function DiceSystem_Common.GetSkillName(skill)
    -- todo case for special

    if luautils.stringStarts(skill, 'Special') then
        local spId = tonumber(string.sub(skill, #skill))
        local PlayerHandler = require("PDS_Addon_DNZ/PlayerHandler")
        local ph = PlayerHandler:instantiate(getPlayer():getUsername())     -- todo make it better and aligned pls
        return ph:getSpecialSubSkill(spId)
    end


    return og_DiceSystem_Common_GetSkillName(skill)
end
