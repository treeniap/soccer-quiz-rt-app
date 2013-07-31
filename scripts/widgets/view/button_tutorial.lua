--[[==============
== We Love Quiz
== Date: 02/07/13
== Time: 10:51
==============]]--
BtnTutorial = {}

function BtnTutorial:createView()
end

local function createView(button, tutorialSheetImage, tutorialSheetInfo, params)
    button.default = display.newImage(button, tutorialSheetImage, tutorialSheetInfo:getFrameIndex(params.bg))
    button.default.x = 0
    button.default.y = 0
    button.over = display.newImage(button, tutorialSheetImage, tutorialSheetInfo:getFrameIndex(params.bg))
    button.over.x = 0
    button.over.y = 1
    button.over.xScale = 0.99
    button.over.yScale = 0.99
    button.over:setFillColor(255, 255)
    button.over.blendMode = "screen"
    button.over.isVisible = false

    if params.topText then
        local topText = display.newEmbossedText(button, "PRESSIONE PARA CONFIRMAR", 0, 0, "MyriadPro-BoldCond", 14)
        topText:setEmbossColor({
            highlight = {r =0, g = 0, b = 0, a = 255},
            shadow = {r = 0, g = 0, b = 0, a = 255}
        })
        topText:setTextColor(255)
        topText.x = 0
        topText.y = -button.default.height*0.35
    end
    if params.bottomText then
        local bottomText = display.newEmbossedText(button, "Não publicaremos nada sem a sua autorização.", 0, 0, "MyriadPro-BoldCond", 12)
        bottomText:setEmbossColor({
            highlight = {r =0, g = 0, b = 0, a = 255},
            shadow = {r = 0, g = 0, b = 0, a = 255}
        })
        bottomText:setTextColor(255)
        bottomText.x = 0
        bottomText.y = button.default.height*0.3
    end
    if params.text then
        local text = display.newEmbossedText(button, params.text, 0, 0, "MyriadPro-BoldCond", 22)
        text:setEmbossColor({
            highlight = {r =128, g = 128, b = 128, a = 128},
            shadow = {r = 32, g = 32, b = 32, a = 128}
        })
        text:setTextColor(255)
        text.x = 30
        text.y = 0
    end
    if params.icon then
        local icon = display.newImage(button, tutorialSheetImage, tutorialSheetInfo:getFrameIndex(params.icon))
        icon.x = -109
        icon.y = -4
    end

    button.off = display.newImage(button, tutorialSheetImage, tutorialSheetInfo:getFrameIndex(params.bg))
    button.off:setFillColor(128, 192)
    button.off.blendMode = "multiply"
    button.off.x = 0
    button.off.y = 0
    button.off.isVisible = false

    return button
end

function BtnTutorial:lock(isLock)
    self.off.isVisible = isLock
    self.isLocked = isLock
end

function BtnTutorial:new(onRelease, tutorialSheetImage, tutorialSheetInfo, params)
    local tutorialBtnGroup = PressRelease:new(BtnTutorial, onRelease)

    return createView(tutorialBtnGroup, tutorialSheetImage, tutorialSheetInfo, params)
end

return BtnTutorial