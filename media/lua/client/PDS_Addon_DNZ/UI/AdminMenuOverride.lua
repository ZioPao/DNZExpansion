require("UI/DiceSystem_AdminUI")


-- TODO Add a level up indicator on the list?


--Level up button

local og_DiceMenuAdminViewer_createChildren = DiceMenuAdminViewer.createChildren

function DiceMenuAdminViewer:createChildren()
    og_DiceMenuAdminViewer_createChildren(self)

    local top = 50


    local btnWidth = (self:getWidth() - self.panel:getWidth()) - 30 -- You must account for the padding, 10 and -20
    local btnHeight =  btnWidth / 1.5

    local btnY = (self.panel:getHeight() / 2 - top) - btnHeight*2 - 10*2
    local btnX = self.panel:getRight() + 10

    -- https://www.flaticon.com/free-icon/up-arrow_
    local upArrowIco = getTexture("media/ui/upArrowIcon.png")

    self.btnLevelUp = ISButton:new(btnX, btnY, btnWidth, btnHeight, "", self,
        DiceMenuAdminViewer.onClick)
    self.btnLevelUp.internal = "LEVEL_UP"
    self.btnLevelUp:setTooltip(getText("IGUI_Dice_LevelUpTooltip"))
    self.btnLevelUp:setImage(upArrowIco)
    self.btnLevelUp.anchorTop = false
    self.btnLevelUp.anchorBottom = true
    self.btnLevelUp:initialise()
    self.btnLevelUp:instantiate()
    self.btnLevelUp.borderColor = { r = 1, g = 1, b = 1, a = 0.5 }
    self:addChild(self.btnLevelUp)

end


local og_DiceMenuAdminViewer_onClick = DiceMenuAdminViewer.onClick


---@param button ISButton
---@diagnostic disable-next-line: duplicate-set-field
function DiceMenuAdminViewer:onClick(button)
    og_DiceMenuAdminViewer_onClick(self, button)

    if button.internal == "LEVEL_UP" then
        local text = getText("IGUI_Dice_ConfirmAction")
        local confY = self:getY() + self:getHeight() + 20

        local ConfirmationPanel = require("UI/DiceSystem_ConfirmationPanel")
        self.confirmationPanel = ConfirmationPanel.Open(text, self:getX(), confY, self, function()

            ---@type IsoPlayer
            local selectedPlayer = self:getSelectedPlayer()
            local playerID = selectedPlayer:getOnlineID()

            print("level up for selected player")
            sendClientCommand(DICE_SYSTEM_ADDON_DNZ_MOD_STRING, "RelayLevelUp", {userID = playerID})

        end)
    end
end

local og_DiceMenuAdminViewer_update = DiceMenuAdminViewer.update
function DiceMenuAdminViewer:update()
    og_DiceMenuAdminViewer_update(self)

    -- TODO We need to re-run these two checks, not optimal
    local selection = self.mainCategory.datas.selected
    local isBtnActive = self.mainCategory.datas:size() > 0 and selection ~= 0
    self.btnLevelUp:setEnable(isBtnActive)
end