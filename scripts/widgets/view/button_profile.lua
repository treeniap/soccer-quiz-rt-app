--[[==============
== We Love Quiz
== Date: 11/06/13
== Time: 10:40
==============]]--
BtnProfile = {}

function BtnProfile:createView()
end

local function createView(button, params)
    button.default = TextureManager.newImage(params.bg, button)
    button.default.x = 0
    button.default.y = 0
    button.over = TextureManager.newImage(params.bg, button)
    button.over.x = 0
    button.over.y = 1
    button.over.xScale = 0.99
    button.over.yScale = 0.99
    button.over:setFillColor(255, 255)
    button.over.blendMode = "screen"
    button.over.isVisible = false

    if params.text then
        local text = display.newEmbossedText(button, params.text, 0, 0, "MyriadPro-BoldCond", params.textSize or 22)
        text:setEmbossColor({
            highlight = {r =128, g = 128, b = 128, a = 128},
            shadow = {r = 32, g = 32, b = 32, a = 128}
        })
        text:setTextColor(255)
        text.x = params.textX or 30
        text.y = 0
    end

    button.off = TextureManager.newImage(params.bg, button)
    button.off:setFillColor(128, 192)
    button.off.blendMode = "multiply"
    button.off.x = 0
    button.off.y = 0
    button.off.isVisible = false

    return button
end

function BtnProfile:lock(isLock)
    self.off.isVisible = isLock
    self.isLocked = isLock
end

function BtnProfile:new(onRelease, params)
    local profileBtnGroup = PressRelease:new(BtnProfile, onRelease)

    return createView(profileBtnGroup, params)
end

return BtnProfile