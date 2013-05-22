--[[==============
== We Love Quiz
== Date: 16/05/13
== Time: 18:46
==============]]--
BtnConfirmAnswer = {}

function BtnConfirmAnswer:createView()
    self.default = TextureManager.newImage("stru_button_voteconfirm", self)
    self.default.x = 0
    self.default.y = 0
    self.over = TextureManager.newImage("stru_button_voteconfirm", self)
    self.over.x = 0
    self.over.y = 0
    self.over:setFillColor(255, 255)
    self.over.blendMode = "screen"
    self.over.isVisible = false
    self.textPular = display.newText(self, "CONFIRMAR RESPOSTA", 0, 0, "MyriadPro-BoldCond", 15)
    self.textPular.x = 0
    self.textPular.y = 2
end

function BtnConfirmAnswer:new(onRelease)
    local confirmAnswerBtnGroup = PressRelease:new(BtnConfirmAnswer, onRelease)
    return confirmAnswerBtnGroup
end

return BtnConfirmAnswer