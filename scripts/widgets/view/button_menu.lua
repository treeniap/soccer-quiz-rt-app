--[[==============
== We Love Quiz
== Date: 09/05/13
== Time: 11:15
==============]]--
BtnMenu = {}

function BtnMenu:createView()
    self.default = TextureManager.newImageRect(self, "images/stru_buttonmenu.png", 40, 49)
    self.default.x = 0
    self.default.y = 0
    self.over = TextureManager.newImageRect(self, "images/stru_buttonmenu.png", 38, 45)
    self.over.x = 0
    self.over.y = 0
    self.over:setFillColor(255, 255)
    self.over.blendMode = "screen"
    self.over.isVisible = false
    self.symbol = TextureManager.newImage("stru_buttonmenu_icon", self)
    self.symbol.x = -self.symbol.width*0.25
    self.symbol.y = -self.symbol.height*0.5
end

function BtnMenu:new(onRelease)
    local backBtnGroup = PressRelease:new(BtnMenu, onRelease)
    backBtnGroup.touch = TouchHandler.pressPushHandler
    return backBtnGroup
end

return BtnMenu