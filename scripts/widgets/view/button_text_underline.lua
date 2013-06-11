--[[==============
== We Love Quiz
== Date: 11/06/13
== Time: 12:39
==============]]--
BtnTextUnderline = {}

function BtnTextUnderline:createView(text)
    self.default = display.newText(self, text, 0, 0, "MyriadPro-BoldCond", 12)
    self.default:setTextColor(135)
    self.underline = display.newLine(self,
        self.default.x - self.default.width*0.5, self.default.y + self.default.height*0.3,
        self.default.x + self.default.width*0.5, self.default.y + self.default.height*0.3)
    self.underline:setColor(135)
end

function BtnTextUnderline:new(text, onPress)
    local textUnderlineBtnGroup = display.newGroup()
    for k, v in pairs(BtnTextUnderline) do
        textUnderlineBtnGroup[k] = v
    end

    textUnderlineBtnGroup:createView(text)
    textUnderlineBtnGroup:setReferencePoint(display.CenterReferencePoint)

    textUnderlineBtnGroup.onPress = onPress
    textUnderlineBtnGroup.touch = TouchHandler.touchBeganHandler
    textUnderlineBtnGroup:addEventListener("touch", textUnderlineBtnGroup)

    return textUnderlineBtnGroup
end

return BtnTextUnderline