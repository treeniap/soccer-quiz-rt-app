--[[==============
== We Love Quiz
== Date: 14/05/13
== Time: 12:13
==============]]--
BtnOpenQuestions = {}

function BtnOpenQuestions:createView()
    self.notch = TextureManager.newImage("stru_notchsilveropen", self)
    self.notch.x = 0
    self.notch.y = 0

    self.toOpen = TextureManager.newImage("stru_toopen", self)
    self.toOpen.x = 0
    self.toOpen.y = 6
    self.toClose = TextureManager.newImage("stru_toclose", self)
    self.toClose.x = 0
    self.toClose.y = 6
    self.toClose.isVisible = false

    self.toOpenPressed = TextureManager.newImage("stru_toopen", self)
    self.toOpenPressed.x = 0
    self.toOpenPressed.y = 6
    self.toOpenPressed.xScale = 0.98
    self.toOpenPressed.yScale = 0.95
    self.toOpenPressed:setFillColor(255, 255)
    self.toOpenPressed.blendMode = "screen"
    self.toOpenPressed.isVisible = false
    self.toClosePressed = TextureManager.newImage("stru_toclose", self)
    self.toClosePressed.x = 0
    self.toClosePressed.y = 6
    self.toClosePressed.xScale = 0.98
    self.toClosePressed.yScale = 0.95
    self.toClosePressed:setFillColor(255, 255)
    self.toClosePressed.blendMode = "screen"
    self.toClosePressed.isVisible = false
end

function BtnOpenQuestions:changeState(isPressed)
    if self.isOpen then
        if isPressed then
            self.toClosePressed.isVisible = true
            self.toClose.isVisible = true
            self.toOpenPressed.isVisible = false
            self.toOpen.isVisible = false
        else
            self.toClosePressed.isVisible = false
            self.toClose.isVisible = true
            self.toOpenPressed.isVisible = false
            self.toOpen.isVisible = false
        end
    else
        if isPressed then
            self.toClosePressed.isVisible = false
            self.toClose.isVisible = false
            self.toOpenPressed.isVisible = true
            self.toOpen.isVisible = true
        else
            self.toClosePressed.isVisible = false
            self.toClose.isVisible = false
            self.toOpenPressed.isVisible = false
            self.toOpen.isVisible = true
        end
    end
end

function BtnOpenQuestions:onPressed()
    if self.isPressed then
        return
    end
    self:changeState(true)
    self.isPressed = true
end

function BtnOpenQuestions:onReleased()
    if not self.isPressed then
        return
    end
    self:changeState(false)
    self.isPressed = false
end

function BtnOpenQuestions:lock(isLock)
    self.isLocked = isLock
end

function BtnOpenQuestions:new(onRelease)
    local openQuestionsBtnGroup = PressRelease:new(BtnOpenQuestions, onRelease)
    return openQuestionsBtnGroup
end

return BtnOpenQuestions