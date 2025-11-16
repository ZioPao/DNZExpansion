local ServerCommands = {}
local PlayerHandler = require("PDS_Addon_DNZ/PlayerHandler")


function ServerCommands.ReceiveLevelUp(args)

    -- TODO Notify player that a level up has been received

    -- TODO Trigger level up in PlayerHandler
    local plUsername = getPlayer():getUsername()
    local playerHandler = PlayerHandler:instantiate(plUsername)

    playerHandler:triggerLevelUp()

end


-----------------------------------

local function OnServerCommand(module, command, args)
    if module ~= DICE_SYSTEM_ADDON_DNZ_MOD_STRING then return end
    if ServerCommands[command] then
        ServerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)
