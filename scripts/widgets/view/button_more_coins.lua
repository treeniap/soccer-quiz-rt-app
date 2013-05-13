--[[==============
== We Love Quiz
== Date: 07/05/13
== Time: 17:53
==============]]--
BtnMoreCoins = {}

function BtnMoreCoins:createView()
    --TODO Art tirar botão da barra
    self.default = TextureManager.newImage("stru_buttoncoin_on", self)
    self.default.x = 0
    self.default.y = 0
    self.default.alpha = 0.01
    self.over = TextureManager.newImage("stru_buttoncoin_on", self)
    self.over.x = 0
    self.over.y = 0
    self.over:setFillColor(255, 255)
    self.over.blendMode = "screen"
    self.over.isVisible = false
    self.textMais   = display.newText(self, "MAIS",   -20 + (display.screenOriginX*-0.5), -22, "MyriadPro-BoldCond", 18)
    self.textFichas = display.newText(self, "FICHAS", -28 + (display.screenOriginX*-0.5), -4, "MyriadPro-BoldCond", 18)
end

function BtnMoreCoins:new(onRelease)
    local moreCoinsBtnGroup = PressRelease:new(BtnMoreCoins, onRelease)
    return moreCoinsBtnGroup
end

return BtnMoreCoins