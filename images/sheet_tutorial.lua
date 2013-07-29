--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:3deb9e915ba413882088e1d3124380f4:1/1$
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
            -- stru_progress_bar
            x=314,
            y=126,
            width=16,
            height=31,

            sourceX = 0,
            sourceY = 1,
            sourceWidth = 16,
            sourceHeight = 32
        },
        {
            -- stru_progress_grey
            x=500,
            y=15,
            width=10,
            height=11,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 10,
            sourceHeight = 10
        },
        {
            -- stru_progress_red
            x=500,
            y=2,
            width=10,
            height=11,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 10,
            sourceHeight = 10
        },
        {
            -- stru_tutorial_box
            x=2,
            y=2,
            width=128,
            height=126,

            sourceX = 0,
            sourceY = 1,
            sourceWidth = 128,
            sourceHeight = 128
        },
        {
            -- tuto_bt_fb
            x=132,
            y=2,
            width=310,
            height=120,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 310,
            sourceHeight = 120
        },
        {
            -- tuto_bt_gold
            x=2,
            y=130,
            width=310,
            height=120,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 310,
            sourceHeight = 120
        },
        {
            -- tuto_icon01
            x=444,
            y=95,
            width=49,
            height=29,

        },
        {
            -- tuto_icon02
            x=444,
            y=40,
            width=53,
            height=53,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 53,
            sourceHeight = 53
        },
        {
            -- tuto_icon03
            x=444,
            y=2,
            width=54,
            height=36,

        },
    },
    
    sheetContentWidth = 512,
    sheetContentHeight = 256
}

SheetInfo.frameIndex =
{

    ["stru_progress_bar"] = 1,
    ["stru_progress_grey"] = 2,
    ["stru_progress_red"] = 3,
    ["stru_tutorial_box"] = 4,
    ["tuto_bt_fb"] = 5,
    ["tuto_bt_gold"] = 6,
    ["tuto_icon01"] = 7,
    ["tuto_icon02"] = 8,
    ["tuto_icon03"] = 9,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
