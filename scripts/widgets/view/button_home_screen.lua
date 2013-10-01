--[[==============
== We Love Quiz
== Date: 06/05/13
== Time: 11:33
==============]]--
BtnHomeScreen = {}

function BtnHomeScreen:createView()
    self:insert(TextureManager.newHorizontalLine(-10, 24, CONTENT_WIDTH*0.65))
    self:insert(TextureManager.newHorizontalLine(-10, -23, CONTENT_WIDTH*0.65))
    if self.gold then
        self.default = TextureManager.newImageRect("images/stretchable/stru_bar_gold_mid.png", CONTENT_WIDTH*0.7, 47, self)
        self.over = TextureManager.newImageRect("images/stretchable/stru_bar_gold_mid.png", CONTENT_WIDTH*0.7, 47, self)
        self.over:setFillColor(255, 255)
        self.over.blendMode = "screen"
    else
        self.default = display.newRect(self, 0, 0, 1, 1)
        self.default.alpha = 0
        self.over = display.newRect(self, 0, 0, CONTENT_WIDTH*0.7, 47)
        self.over:setFillColor(255, 96)
    end
    self.default.x = 0
    self.default.y = 0
    self.over.x = 0
    self.over.y = 0
    self.over.xScale = 0.98
    self.over.yScale = 0.95
    self.over.isVisible = false
    local buttonTxt = display.newText(self, self.title, 0, 0, "MyriadPro-BoldCond", 28)
    buttonTxt.x = -10
    buttonTxt.y = 3
    buttonTxt:setTextColor(0)
    self.txt = buttonTxt

    self.isVisible = false
end

function BtnHomeScreen:showUp(onComplete)
    timer.performWithDelay(1000, function()
        self.isVisible = true
        self.yScale = 1
        transition.from(self, {time = 200, yScale = 0.1, onComplete = onComplete})
        if onComplete then
            AudioManager.playAudio("showPlayBtn")
        end
    end)
end

function BtnHomeScreen:hide(onComplete)
    transition.to(self, {time = 200, yScale = 0.1, onComplete = function()
        self.isVisible = false
        if onComplete then
            onComplete()
        end
    end})
end

function BtnHomeScreen:lock(isLock)
    if isLock then
        self.txt:setTextColor(128, 96)
    else
        self.txt:setTextColor(0)
    end
    self.isLocked = isLock
end

function BtnHomeScreen:new(y, title, gold, onRelease)
    BtnHomeScreen.gold = gold
    BtnHomeScreen.title = title
    BtnHomeScreen.noAudio = true
    local homeScreenBtnGroup = PressRelease:new(BtnHomeScreen, onRelease)
    homeScreenBtnGroup.x = SCREEN_LEFT + homeScreenBtnGroup.width*0.5 - 2
    homeScreenBtnGroup.y = y
    return homeScreenBtnGroup
end

return BtnHomeScreen