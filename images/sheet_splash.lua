--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:f8d07f544cc3e395fa0adc6ff0c601cb$
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
            -- bola_frame01
            x=209,
            y=138,
            width=32,
            height=32,

        },
        {
            -- bola_frame02
            x=175,
            y=138,
            width=32,
            height=32,

        },
        {
            -- bola_frame03
            x=209,
            y=104,
            width=32,
            height=32,

        },
        {
            -- bola_frame04
            x=175,
            y=104,
            width=32,
            height=32,

        },
        {
            -- bola_frame05
            x=209,
            y=70,
            width=32,
            height=32,

        },
        {
            -- bola_frame06
            x=175,
            y=70,
            width=32,
            height=32,

        },
        {
            -- bola_frame07
            x=209,
            y=36,
            width=32,
            height=32,

        },
        {
            -- bola_frame08
            x=175,
            y=36,
            width=32,
            height=32,

        },
        {
            -- bola_frame09
            x=209,
            y=2,
            width=32,
            height=32,

        },
        {
            -- bola_frame10
            x=175,
            y=2,
            width=32,
            height=32,

        },
        {
            -- escudo
            x=2,
            y=2,
            width=171,
            height=151,

            sourceX = 0,
            sourceY = 1,
            sourceWidth = 172,
            sourceHeight = 153
        },
    },
    
    sheetContentWidth = 256,
    sheetContentHeight = 256
}

SheetInfo.frameIndex =
{

    ["bola_frame01"] = 1,
    ["bola_frame02"] = 2,
    ["bola_frame03"] = 3,
    ["bola_frame04"] = 4,
    ["bola_frame05"] = 5,
    ["bola_frame06"] = 6,
    ["bola_frame07"] = 7,
    ["bola_frame08"] = 8,
    ["bola_frame09"] = 9,
    ["bola_frame10"] = 10,
    ["escudo"] = 11,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
