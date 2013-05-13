--[[==============
== We Love Quiz
== Date: 03/05/13
== Time: 16:05
==============]]--
BtnBack = {}

function BtnBack:createView()
    self.default = TextureManager.newImage("stru_buttonback", self)
    self.default.x = 0
    self.default.y = 0
    self.over = TextureManager.newImage("stru_buttonback", self)
    self.over.x = 0
    self.over.y = 0
    self.over.xScale = 0.98
    self.over.yScale = 0.95
    self.over:setFillColor(255, 255)
    self.over.blendMode = "screen"
    self.over.isVisible = false
end

function BtnBack:new(onRelease)
    local backBtnGroup = PressRelease:new(BtnBack, onRelease)
    return backBtnGroup
end

return BtnBack