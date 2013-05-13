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

printTextMem("")
local sheetInfo = require("images.sheet_main") -- lua file that Texture packer published
local imageSheet = graphics.newImageSheet("images/sheet_main.png", sheetInfo:getSheet())
printTextMem("sheet_main")

function TextureManager.newImage(frameName, group)
    return display.newImage(group, imageSheet, sheetInfo:getFrameIndex(frameName))
end

function TextureManager.newImageRect(arg1, arg2, arg3, arg4)
    local img
    if type(arg1) == "string" then
        img = display.newImageRect(arg1, arg2, arg3)
        printTextMem(arg1)
    else
        img = display.newImageRect(arg1, arg2, arg3, arg4)
        printTextMem(arg2)
    end
    return img
end

return TextureManager