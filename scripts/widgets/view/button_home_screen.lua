--[[==============
== We Love Quiz
== Date: 06/05/13
== Time: 11:33
==============]]--
BtnHomeScreen = {}

function BtnHomeScreen:createView()
    self.default = TextureManager.newImageRect("images/stru_bar_gold_mid.png", CONTENT_WIDTH*0.7, 47, self)
    self.default.x = 0
    self.default.y = 0
    self.over = TextureManager.newImageRect("images/stru_bar_gold_mid.png", CONTENT_WIDTH*0.7, 47, self)
    self.over.x = 0
    self.over.y = 0
    self.over.xScale = 0.98
    self.over.yScale = 0.95
    self.over:setFillColor(255, 255)
    self.over.blendMode = "screen"
    self.over.isVisible = false
    local buttonTxt = display.newText(self, "JOGAR", 0, 0, "MyriadPro-BoldCond", 28)
    buttonTxt.x = -10
    buttonTxt.y = 0
    buttonTxt:setTextColor(0)

    self.isVisible = false
end

function BtnHomeScreen:showUp(onComplete)
    timer.performWithDelay(1000, function()
        self.isVisible = true
        self.yScale = 1
        transition.from(self, {time = 200, yScale = 0.1, onComplete = onComplete})
    end)
end

function BtnHomeScreen:hide(onComplete)
    transition.to(self, {time = 200, yScale = 0.1, onComplete = function()
        self.isVisible = false
        onComplete()
    end})
end

function BtnHomeScreen:new(onRelease)
    local homeScreenBtnGroup = PressRelease:new(BtnHomeScreen, onRelease)
    homeScreenBtnGroup.x = SCREEN_LEFT + homeScreenBtnGroup.width*0.5 - 2
    homeScreenBtnGroup.y = display.contentCenterY
    return homeScreenBtnGroup
end

return BtnHomeScreen