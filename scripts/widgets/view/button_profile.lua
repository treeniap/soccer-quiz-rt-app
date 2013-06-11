--[[==============
== We Love Quiz
== Date: 11/06/13
== Time: 10:40
==============]]--
BtnProfile = {}

function BtnProfile:createView()
    self.default = TextureManager.newSpriteRect("stru_button_profile", 60, 60, self)
    self.default.x = 0
    self.default.y = 0
    self.over = TextureManager.newSpriteRect("stru_button_profile", 60, 60, self)
    self.over.x = 1
    self.over.y = 1
    --self.over.xScale = 0.99
    --self.over.yScale = 0.99
    self.over:setFillColor(255, 255)
    self.over.blendMode = "screen"
    self.over.isVisible = false

    self.label1 = display.newEmbossedText(self, " ", 0, 0, 49, 21, "MyriadPro-BoldCond", 18)
    self.label1:setTextColor(255)
    self.label2 = display.newEmbossedText(self, " ", 0, 0, 49, 21, "MyriadPro-BoldCond", 18)
    self.label2:setTextColor(255)
    local color =
    {
        highlight =
        {
            r =255, g = 171, b = 173, a = 128
        },
        shadow =
        {
            r = 111, g = 30, b = 33, a = 128
        }
    }
    self.label1:setEmbossColor(color)
    self.label2:setEmbossColor(color)
end

function BtnProfile:setLabel(label1, label2)
    self.label1:setText(label1)
    self.label1:setReferencePoint(display.BottomCenterReferencePoint)
    self.label1.x = 0
    self.label1.y = 4
    self.label2:setText(label2)
    self.label2:setReferencePoint(display.TopCenterReferencePoint)
    self.label2.x = 2
    self.label2.y = -2
end

function BtnProfile:new(label1, label2, onRelease)
    local profileBtnGroup = PressRelease:new(BtnProfile, onRelease)
    profileBtnGroup:setLabel(label1, label2)
    return profileBtnGroup
end

return BtnProfile