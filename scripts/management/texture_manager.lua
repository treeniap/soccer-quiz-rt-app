--[[==============
== Pocket World
== Date: 26/04/13
== Time: 10:52
==============]]--
TextureManager = {}

local lastTotalMemoryUsed = 0
local function printTextMem(sheetName)
    local spriteMemoryUsed = system.getInfo("textureMemoryUsed")/1048576 - lastTotalMemoryUsed
    lastTotalMemoryUsed = system.getInfo("textureMemoryUsed")/1048576
    for i = 1, 30 - sheetName:len() do
        sheetName = sheetName .. " "
    end
    -- TMU = Texture Memory Usage
    print(sheetName, string.format("TMU = %.1f MB", spriteMemoryUsed), string.format("totalTMU = %.1f MB", lastTotalMemoryUsed))
end

printTextMem(" ")
local sheetInfo = require("images.sheet_main") -- lua file that Texture packer published
local imageSheet = graphics.newImageSheet("images/sheet_main.png", sheetInfo:getSheet())
printTextMem("sheet_main")

function TextureManager.newImage(frameName, group)
    --print(frameName)
    return display.newImage(group, imageSheet, sheetInfo:getFrameIndex(frameName))
end

function TextureManager.newImageRect(imageName, width, height, group)
    local img
    if group then
        img = display.newImageRect(group, imageName, width, height)
    else
        img = display.newImageRect(imageName, width, height)
    end
    printTextMem(imageName)
    return img
end

function TextureManager.newSpriteRect(frameName, width, height, group)
    local img
    if group then
        img = display.newImageRect(group, imageSheet, sheetInfo:getFrameIndex(frameName), width, height)
    else
        img = display.newImageRect(imageSheet, sheetInfo:getFrameIndex(frameName), width, height)
    end
    --printTextMem(frameName)
    return img
end

function TextureManager.newHorizontalLine(x, y, lineWidth)
    local lineGroup = display.newGroup()
    local horLine = display.newRect(lineGroup, 0, 0, lineWidth*0.1, 1)
    horLine:setFillColor(graphics.newGradient({135, 0}, {135, 255}, "left" ))
    local horLine = display.newRect(lineGroup, lineWidth*0.1, 0, lineWidth*0.7, 1)
    horLine:setFillColor(135, 220)
    local horLine = display.newRect(lineGroup, lineWidth*0.8, 0, lineWidth*0.1, 1)
    horLine:setFillColor(graphics.newGradient({135, 0}, {135, 255}, "right" ))

    local horLine = display.newRect(lineGroup, 0, 1, lineWidth*0.1, 1)
    horLine:setFillColor(graphics.newGradient({230, 0}, {230, 255}, "left" ))
    local horLine = display.newRect(lineGroup, lineWidth*0.1, 1, lineWidth*0.7, 1)
    horLine:setFillColor(230)
    local horLine = display.newRect(lineGroup, lineWidth*0.8, 1, lineWidth*0.1, 1)
    horLine:setFillColor(graphics.newGradient({230, 0}, {230, 255}, "right" ))

    lineGroup:setReferencePoint(display.CenterReferencePoint)
    lineGroup.x = x
    lineGroup.y = y

    return lineGroup
end

function TextureManager.newVerticalLine(x, y, lineHeight)
    local blackLineGroup = display.newGroup()
    local verLine = display.newRect(blackLineGroup, 0, 0, 1, lineHeight*0.1)
    verLine:setFillColor(graphics.newGradient({135, 0}, {135, 255}, "down" ))
    local verLine = display.newRect(blackLineGroup, 0, lineHeight*0.1, 1, lineHeight*0.7)
    verLine:setFillColor(135, 220)
    local verLine = display.newRect(blackLineGroup, 0, lineHeight*0.8, 1, lineHeight*0.1)
    verLine:setFillColor(graphics.newGradient({135, 0}, {135, 255}, "up" ))

    blackLineGroup:setReferencePoint(display.CenterReferencePoint)
    blackLineGroup.x = x
    blackLineGroup.y = y

    local whiteLineGroup = display.newGroup()
    local verLine = display.newRect(whiteLineGroup, 0, 0, 1, lineHeight*0.1)
    verLine:setFillColor(graphics.newGradient({230, 0}, {230, 255}, "down" ))
    local verLine = display.newRect(whiteLineGroup, 0, lineHeight*0.1, 1, lineHeight*0.7)
    verLine:setFillColor(230)
    local verLine = display.newRect(whiteLineGroup, 0, lineHeight*0.8, 1, lineHeight*0.1)
    verLine:setFillColor(graphics.newGradient({230, 0}, {230, 255}, "up" ))

    whiteLineGroup:setReferencePoint(display.CenterReferencePoint)
    whiteLineGroup.x = x + 1
    whiteLineGroup.y = y

    return blackLineGroup, whiteLineGroup
end

return TextureManager