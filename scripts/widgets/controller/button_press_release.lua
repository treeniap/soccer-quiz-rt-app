--[[==============
== We Love Quiz
== Date: 06/05/13
== Time: 10:43
==============]]--
PressRelease = {}

function PressRelease:onPressed()
    if self.isPressed then
        return
    end
    self.over.isVisible = true
    self.isPressed = true
end

function PressRelease:onReleased()
    if not self.isPressed then
        return
    end
    self.over.isVisible = false
    self.isPressed = false
end

function PressRelease:lock(isLock)
    print("Warning: Can't lock")
end

function PressRelease:new(button, onRelease)
    local btnGroup = display.newGroup()
    for k, v in pairs(PressRelease) do
        btnGroup[k] = v
    end
    for k, v in pairs(button) do
        btnGroup[k] = v
    end

    btnGroup:createView()
    btnGroup:setReferencePoint(display.CenterReferencePoint)

    btnGroup.onRelease = onRelease
    btnGroup.touch = TouchHandler.pressReleaseHandler
    btnGroup:addEventListener("touch", btnGroup)

    btnGroup._removeSelf = btnGroup.removeSelf
    function btnGroup:removeSelf()
        self:removeEventListener("touch", self)
        self:_removeSelf()
    end

    return btnGroup
end

return PressRelease