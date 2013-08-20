--[[==============
== We Love Quiz
== Date: 06/08/13
== Time: 14:11
==============]]--
InGamePeriod = {}

local periods = {
    first_half = "1° TEMPO",
    ["break"] = "INTERVALO",
    second_half = "2° TEMPO",
    draw_break = "INTERVALO - PRORROGAÇÃO",
    extra_first_half = "1° TEMPO - PRORROGAÇÃO",
    extra_break = "INTERVALO - PRORROGAÇÃO",
    extra_second_half = "2° TEMPO - PRORROGAÇÃO",
}

local function createLeftFoil(periodName)
    local foilGroup = display.newGroup()
    -- scalable menu background
    local menuFoilCenter = TextureManager.newImageRect("images/stru_foil_center.png", 185 + display.screenOriginX*-2 + display.screenOriginY*-0.25, 450, foilGroup)
    menuFoilCenter.x = 0
    menuFoilCenter.y = 0

    -- menu background border
    local menuFoilBorder = TextureManager.newSpriteRect("stru_foil_border", 100, 450, foilGroup)
    menuFoilBorder.x = menuFoilCenter.width*0.5 + menuFoilBorder.width*0.5
    menuFoilBorder.y = 0

    -- title
    if periods[periodName] then
        local eventNameTxt = display.newEmbossedText(foilGroup, periods[periodName], 0, 0, "MyriadPro-BoldCond", 24)
        eventNameTxt.x = 28
        eventNameTxt.y = -150 + (display.screenOriginY*-0.75)
        eventNameTxt:setTextColor(0)
        foilGroup.title = eventNameTxt
    end
    foilGroup:insert(TextureManager.newHorizontalLine(20, -135 + (display.screenOriginY*-0.75), 180))

    local whistle = TextureManager.newImage("stru_whistle", foilGroup)
    whistle.x = 20
    whistle.y = 24 + (display.screenOriginY*-0.75)

    foilGroup:setReferencePoint(display.CenterLeftReferencePoint)
    foilGroup.x = SCREEN_LEFT
    foilGroup.y = SCREEN_TOP + 240

    return foilGroup
end

function InGamePeriod:showUp(onComplete)
    self.isVisible = true
    transition.from(self.leftSideView, {time = 300, x = SCREEN_LEFT - self.leftSideView.width, transition = easeOutExpo, onComplete = onComplete})
    AudioManager.playAudio("showEvent")
end

function InGamePeriod:hide(onComplete)
    transition.to(self.leftSideView, {time = 300, x = SCREEN_LEFT - self.leftSideView.width, transition = easeOutExpo, onComplete = onComplete})
end

function InGamePeriod:create(periodName)
    local periodGroup = display.newGroup()
    for k, v in pairs(InGamePeriod) do
        periodGroup[k] = v
    end

    periodGroup.leftSideView = createLeftFoil(periodName)
    periodGroup:insert(periodGroup.leftSideView)

    periodGroup.isVisible = false

    return periodGroup
end

return InGamePeriod