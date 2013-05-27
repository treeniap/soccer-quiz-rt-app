--[[==============
== We Love Quiz
== Date: 23/05/13
== Time: 11:35
==============]]--
BtnLink = {}

function BtnLink:createView()
    self.default = display.newText(self, " ", 0, 0, "MyriadPro-BoldCond", 14)
    self.default:setTextColor(0)
    self.over = display.newText(self, " ", 0, 0, "MyriadPro-BoldCond", 14)
    self.over:setTextColor(0, 0, 255)
    self.over.isVisible = false
end

function BtnLink:new(text, leftX, topY, onRelease)
    local linkBtnGroup = PressRelease:new(BtnLink, onRelease)
    linkBtnGroup.default.text = text
    linkBtnGroup.over.text = text
    linkBtnGroup:setReferencePoint(display.TopLeftReferencePoint)
    linkBtnGroup.x = leftX
    linkBtnGroup.y = topY
    return linkBtnGroup
end

return BtnLink