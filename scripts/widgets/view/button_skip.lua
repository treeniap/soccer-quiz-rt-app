--[[==============
== We Love Quiz
== Date: 16/05/13
== Time: 18:39
==============]]--
BtnSkip = {}

function BtnSkip:createView()
    self.default = TextureManager.newImage("stru_button_votepass", self)
    self.default.x = 0
    self.default.y = 0
    self.over = TextureManager.newImage("stru_button_votepass", self)
    self.over.x = 0
    self.over.y = 0
    self.over:setFillColor(255, 255)
    self.over.blendMode = "screen"
    self.over.isVisible = false
    self.textPular = display.newText(self, "PULAR", 0, 0, "MyriadPro-BoldCond", 15)
    self.textPular.x = 0
    self.textPular.y = 2
end

function BtnSkip:new(onRelease)
    local skipBtnGroup = PressRelease:new(BtnSkip, onRelease)
    return skipBtnGroup
end

return BtnSkip