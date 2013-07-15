--[[==============
== We Love Quiz
== Date: 14/06/13
== Time: 18:08
==============]]--
ButtonOpenMenu = {}

function ButtonOpenMenu:createView()
    self.over = display.newRect(self, 0, 0, CONTENT_WIDTH, 50)
    self.over.x = 0
    self.over.y = 0
    self.over:setFillColor(graphics.newGradient({255, 128}, {128, 96}, "down"))
    --self.over.blendMode = "add"
    self.over.alpha = 0.01
    self.default = TextureManager.newImage("stru_iconarrow", self)
    self.default.x = CONTENT_WIDTH*0.5 - self.default.width*0.5 - 8
    self.default.y = 0
end

function ButtonOpenMenu:open()
    if self.trans then
        transition.cancel(self.trans)
    end
    self.trans = transition.to(self.default, {time = 100, rotation = 90, onComplete = function() self.trans = nil end})
end

function ButtonOpenMenu:close()
    if self.trans then
        transition.cancel(self.trans)
    end
    self.trans = transition.to(self.default, {time = 100, rotation = 0, onComplete = function() self.trans = nil end})
end

function ButtonOpenMenu:onPressed()
    if self.isPressed then
        return
    end
    self.isPressed = true
    self.over.alpha = 1
end

function ButtonOpenMenu:onReleased()
    if not self.isPressed then
        return
    end
    self.isPressed = false
    self.over.alpha = 0.01
end

function ButtonOpenMenu:lock(isLock)
    if isLock then
        self.touch = nil
    else
        self.touch = TouchHandler.pressReleaseHandler
    end
end

function ButtonOpenMenu:new(onRelease)
    local arrowBtnGroup = PressRelease:new(ButtonOpenMenu, onRelease)
    arrowBtnGroup.touch = TouchHandler.pressReleaseHandler
    arrowBtnGroup.isOpen = false
    return arrowBtnGroup
end

return ButtonOpenMenu