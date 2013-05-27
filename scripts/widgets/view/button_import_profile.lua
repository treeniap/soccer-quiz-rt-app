--[[==============
== We Love Quiz
== Date: 23/05/13
== Time: 16:47
==============]]--
BtnImportProfile = {}

function BtnImportProfile:createView()
    self.default = TextureManager.newImage("stru_button_import", self)
    self.default.x = 0
    self.default.y = 0
    self.over = TextureManager.newImage("stru_button_import", self)
    self.over.x = 1
    self.over.y = 1
    --self.over.xScale = 0.99
    --self.over.yScale = 0.99
    self.over:setFillColor(255, 255)
    self.over.blendMode = "screen"
    self.over.isVisible = false
end

function BtnImportProfile:new(onRelease)
    local importProfileBtnGroup = PressRelease:new(BtnImportProfile, onRelease)
    return importProfileBtnGroup
end

return BtnImportProfile