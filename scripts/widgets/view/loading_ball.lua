--[[==============
== We Love Quiz
== Date: 27/06/13
== Time: 18:14
==============]] --
LoadingBall = {}

local screenGroup
local sequenceData =
{
    name="roll",
    frames= { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, -- frame indexes of animation, in image sheet
    time = 500,           -- Optional. In ms.  If not supplied, then sprite is frame-based.
    loopCount = 0        -- Optional. Default is 0.
}

local function getBallFrames(sheetInfo)
    local frames = {}
    for i = 1, 10 do
        frames[#frames + 1] = sheetInfo:getFrameIndex("bola_frame" .. string.format("%02d", i))
    end
    return frames
end

function LoadingBall:newScreen()
    screenGroup = display.newGroup()
    local bgTop = TextureManager.newImageRect("images/stretchable/stru_menu_bg.png", display.contentWidth + (display.screenOriginX*-2), display.contentHeight + (display.screenOriginY*-2))
    bgTop.x = display.contentCenterX
    bgTop.y = display.contentCenterY
    local sheetSplashInfo, splashSheet = TextureManager.loadSplashSheet()
    local badge = display.newImage(splashSheet, sheetSplashInfo:getFrameIndex("escudo"))
    badge.x = display.contentCenterX
    badge.y = display.contentCenterY
    sequenceData.frames = getBallFrames(sheetSplashInfo)
    local ball = display.newSprite(splashSheet, sequenceData)
    ball:setSequence("roll")
    --ball:setFrame(10)
    ball:play()
    ball.x = display.contentCenterX
    ball.y = display.contentCenterY - 14
    ball.xScale = 2
    ball.yScale = 2
    local loadingTxt = display.newText("", 0, 0, "MyriadPro-BoldCond", 14)
    loadingTxt:setTextColor(32)
    screenGroup:insert(bgTop)
    screenGroup:insert(badge)
    screenGroup:insert(ball)
    screenGroup:insert(loadingTxt)

    local txts = {
        "Vestindo uniforme...",
        "Amarrando as chuteiras...",
        "Fazendo alongamentos...",
        "Aquecimento com bola...",
        "Revisando esquema tático...",
        "Discurso motivacional...",
        "Rezando uma prece...",
        "Subindo ao gramado..."
    }
    local txtNum = 1

    function screenGroup:changeTxt(last)
        if screenGroup.timer then
            timer.cancel(screenGroup.timer)
        end
        --print(txts[txtNum], txtNum)
        if last then
            loadingTxt.text = txts[#txts]
        else
            loadingTxt.text = txts[txtNum]
            txtNum = txtNum + 1
            if txtNum > #txts then
                txtNum = #txts
            end
        end
        loadingTxt:setReferencePoint(display.CenterReferencePoint)
        loadingTxt.x = display.contentCenterX
        loadingTxt.y = display.contentCenterY + 128
        screenGroup.timer = timer.performWithDelay(7500, function() screenGroup:changeTxt() screenGroup.timer = nil end)
    end
    function screenGroup:kickBall()
        transition.to(ball, {time = 300, xScale = 6, yScale = 6, x = display.contentWidth + (display.screenOriginX*-2), y = -100})
        transition.to(badge, {time = 300, xScale = 2, yScale = 2})
    end
    function screenGroup:hideBg()
        transition.to(screenGroup, {time = 500, alpha = 0, onComplete = function()
            if screenGroup.timer then
                timer.cancel(screenGroup.timer)
            end
            screenGroup:removeSelf()
            screenGroup = nil
            splashSheet = nil
            TextureManager.disposeSplashSheet()
        end})
    end
end

function LoadingBall:newStage()
    if screenGroup then
        screenGroup:changeTxt()
    end
end

function LoadingBall:dismissScreen()
    screenGroup:kickBall()
    screenGroup:hideBg()
end

function LoadingBall:createBall(x, y)
    local ball = TextureManager.newAnimatedSprite(sequenceData, getBallFrames)
    ball:setSequence("roll")
    ball:play()
    ball.x = x
    ball.y = y
    return ball
end

return LoadingBall