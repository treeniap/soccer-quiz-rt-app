--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:4fdef73931503fd3f3319a44ec466435:1/1$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- bt_gold
            x=129,
            y=2,
            width=125,
            height=23,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 125,
            sourceHeight = 23
        },
        {
            -- bt_vermelho
            x=2,
            y=2,
            width=125,
            height=23,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 125,
            sourceHeight = 23
        },
    },
    
    sheetContentWidth = 256,
    sheetContentHeight = 32
}

SheetInfo.frameIndex =
{

    ["bt_gold"] = 1,
    ["bt_vermelho"] = 2,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
