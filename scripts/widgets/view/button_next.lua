--[[==============
== We Love Quiz
== Date: 15/05/13
== Time: 16:38
==============]]--
BtnNext = {}

function BtnNext:createView()
    self.default = TextureManager.newImage("stru_button_foward", self)
    self.default.x = 0
    self.default.y = 0
    self.over = TextureManager.newImage("stru_button_foward", self)
    self.over.x = 0
    self.over.y = 0
    self.over.xScale = 0.98
    self.over.yScale = 0.95
    self.over:setFillColor(255, 255)
    self.over.blendMode = "screen"
    self.over.isVisible = false
end

function BtnNext:new(onRelease)
    local backBtnGroup = PressRelease:new(BtnNext, onRelease)
    return backBtnGroup
end

return BtnNext
