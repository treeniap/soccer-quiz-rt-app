--[[==============
== We Love Quiz
== Date: 03/05/13
== Time: 16:05
==============]]--
BtnBack = {}

function BtnBack:createView()
    self.default = TextureManager.newImage("stru_button_back", self)
    self.default.x = 0
    self.default.y = 0
    self.over = display.newRoundedRect(self, 0, 0, self.default.width + 8, self.default.height + 16, 8)
    self.over.x = 0
    self.over.y = 0
    self.over:setFillColor(255, 32)
    self.over.blendMode = "add"
    self.over.isVisible = false
end

function BtnBack:new(onRelease)
    local backBtnGroup = PressRelease:new(BtnBack, onRelease)
    return backBtnGroup
end

return BtnBack