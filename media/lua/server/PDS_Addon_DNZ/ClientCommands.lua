local ClientCommands = {}


--* ADMIN COMMANDS *--
---Send level up from an admin to another user
---@param args {userID : number}
function ClientCommands.RelayLevelUp(_, args)
	local receivingPl = getPlayerByOnlineID(args.userID)
    local username = receivingPl:getUsername()

    -- set isLevelUp on that player's table
    local data = ModData.get(DICE_SYSTEM_MOD_STRING)
    ---@type diceDataType_DNZ
    local userData =  data[username]
    userData.isLevelingUp = true

    ModData.add(DICE_SYSTEM_MOD_STRING, data)

    sendServerCommand(receivingPl, DICE_SYSTEM_ADDON_DNZ_MOD_STRING, "ReceiveLevelUp", {})
end




--* SETTERS *--

local function OnClientCommand(module, command, playerObj, args)
	if module ~= DICE_SYSTEM_ADDON_DNZ_MOD_STRING then return end
	--print("Received ModData command " .. command)
	if ClientCommands[command] and ClientCommands ~= nil then
		ClientCommands[command](playerObj, args)
		ModData.add(DICE_SYSTEM_MOD_STRING, ClientCommands)
	end
end

Events.OnClientCommand.Add(OnClientCommand)