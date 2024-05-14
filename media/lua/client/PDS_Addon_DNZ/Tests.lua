--!!! DEBUG ONLY
if not getActivatedMods():contains("TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")


TestFramework.registerTestModule("Functionality Tests", "Leveling", function()
    local Tests = {}

    local PlayerHandler = require("PDS_Addon_DNZ/PlayerHandler")
    local o = PlayerHandler:instantiate(getPlayer():getUsername())

    function Tests.StartLevelUp()
        o:triggerLevelUp()
    end

    return Tests
end)


