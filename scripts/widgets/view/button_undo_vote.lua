--[[==============
== Pocket World
== Date: 26/04/13
== Time: 10:47
==============]]--
BtnUndoVote = {}

function BtnUndoVote:createView()
    self.notch = TextureManager.newImage("stru_notchsilverundo", self)
    self.notch.x = 0
    self.notch.y = 0
    self.on = TextureManager.newImage("stru_arrowundo_on", self)
    self.on.x = 0
    self.on.y = 6
    self.over = TextureManager.newImage("stru_arrowundo_on", self)
    self.over.x = 0
    self.over.y = 6
    self.over.xScale = 0.98
    self.over.yScale = 0.95
    self.over:setFillColor(255, 255)
    self.over.blendMode = "screen"
    self.over.isVisible = false
    self.off = TextureManager.newImage("stru_arrowundo_off", self)
    self.off.x = 0
    self.off.y = 6
    self.off.isVisible = false
end

function BtnUndoVote:lock(isLock)
    self.off.isVisible = isLock
    self.isLocked = isLock
end

function BtnUndoVote:new(onRelease)
    local undoBtnGroup = PressRelease:new(BtnUndoVote, onRelease)
    return undoBtnGroup
end

return BtnUndoVote