--[[==============
== We Love Quiz
== Date: 06/05/13
== Time: 11:33
==============]]--
BtnTwitter = {}

function BtnTwitter:createView()
    self.default = TextureManager.newImage("stru_buttontwitter", self)
    self.default.x = 0
    self.default.y = 0
    self.over = TextureManager.newImage("stru_buttontwitter", self)
    self.over.x = 0
    self.over.y = 1
    self.over.xScale = 0.98
    self.over.yScale = 0.95
    self.over:setFillColor(255, 255)
    self.over.blendMode = "screen"
    self.over.isVisible = false
end

function BtnTwitter:new(onRelease)
    local backBtnGroup = PressRelease:new(BtnTwitter, onRelease)
    return backBtnGroup
end

return BtnTwitter