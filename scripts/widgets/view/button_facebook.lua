--[[==============
== We Love Quiz
== Date: 06/05/13
== Time: 11:31
==============]]--
BtnFacebook = {}

function BtnFacebook:createView()
    self.default = TextureManager.newImage("stru_buttonfacebook", self)
    self.default.x = 0
    self.default.y = 0
    self.over = TextureManager.newImage("stru_buttonfacebook", self)
    self.over.x = 0
    self.over.y = 1
    self.over.xScale = 0.98
    self.over.yScale = 0.95
    self.over:setFillColor(255, 255)
    self.over.blendMode = "screen"
    self.over.isVisible = false
end

function BtnFacebook:new(onRelease)
    local backBtnGroup = PressRelease:new(BtnFacebook, onRelease)
    return backBtnGroup
end

return BtnFacebook
