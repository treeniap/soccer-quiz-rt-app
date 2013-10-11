--[[==============
== We Love Quiz
== Date: 09/10/13
== Time: 10:22
==============]]--
BtnConfig = {}

function BtnConfig:createView()
    self.default = TextureManager.newImage("subscription_icon", self)
    self.default.x = 0
    self.default.y = 0
    self.over = display.newRoundedRect(self, 0, 0, self.default.width + 16, self.default.height + 12, 8)
    self.over.x = 0
    self.over.y = 0
    self.over:setFillColor(255, 32)
    self.over.blendMode = "add"
    self.over.isVisible = false
    self.touchHandler = display.newRoundedRect(self, 0, 0, self.default.width + 16, self.default.height + 12, 8)
    self.touchHandler.x = 0
    self.touchHandler.y = 0
    self.touchHandler:setFillColor(255, 1)
end

function BtnConfig:new(listener)
    local backBtnGroup = PressRelease:new(BtnConfig, listener)
    return backBtnGroup
end

return BtnConfig