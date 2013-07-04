--[[==============
== We Love Quiz
== Date: 09/05/13
== Time: 11:15
==============]]--
BtnSideMenu = {}

function BtnSideMenu:createView()
    self.default = TextureManager.newImage("stru_buttonmenu", self)
    self.default.x = 0
    self.default.y = 0
    self.over = TextureManager.newImage("stru_buttonmenu", self)
    self.over.x = 0
    self.over.y = 0
    self.over:setFillColor(255, 255)
    self.over.blendMode = "screen"
    self.over.isVisible = false
end

function BtnSideMenu:new(onRelease, isMenu)
    local backBtnGroup = PressRelease:new(BtnSideMenu, onRelease)
    backBtnGroup.touch = TouchHandler.pressPushHandler
    if isMenu then
        backBtnGroup.symbol = TextureManager.newImage("stru_buttonmenu_icon_config", backBtnGroup)
    else
        backBtnGroup.symbol = TextureManager.newImage("stru_buttonmenu_icon", backBtnGroup)
    end
    backBtnGroup.symbol.x = -backBtnGroup.symbol.width*0.25
    backBtnGroup.symbol.y = -backBtnGroup.symbol.height*0.5
    return backBtnGroup
end

return BtnSideMenu