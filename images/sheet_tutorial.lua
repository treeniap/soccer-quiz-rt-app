--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:4298aca353ed40e060f843295967d27a:1/1$
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
            -- stru_button_save
            x=444,
            y=2,
            width=60,
            height=60,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 59,
            sourceHeight = 59
        },
        {
            -- stru_progress_bar
            x=416,
            y=124,
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
            y=77,
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
            y=64,
            width=10,
            height=11,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 10,
            sourceHeight = 10
        },
        {
            -- stru_textbox01
            x=314,
            y=124,
            width=100,
            height=13,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 100,
            sourceHeight = 13
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
            -- tuto_bt_grey
            x=314,
            y=157,
            width=159,
            height=44,

            sourceX = 0,
            sourceY = 0,
            sourceWidth = 159,
            sourceHeight = 44
        },
        {
            -- tuto_icon01
            x=314,
            y=203,
            width=49,
            height=29,

        },
        {
            -- tuto_icon02
            x=444,
            y=102,
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
            y=64,
            width=54,
            height=36,

        },
    },
    
    sheetContentWidth = 512,
    sheetContentHeight = 256
}

SheetInfo.frameIndex =
{

    ["stru_button_save"] = 1,
    ["stru_progress_bar"] = 2,
    ["stru_progress_grey"] = 3,
    ["stru_progress_red"] = 4,
    ["stru_textbox01"] = 5,
    ["stru_tutorial_box"] = 6,
    ["tuto_bt_fb"] = 7,
    ["tuto_bt_gold"] = 8,
    ["tuto_bt_grey"] = 9,
    ["tuto_icon01"] = 10,
    ["tuto_icon02"] = 11,
    ["tuto_icon03"] = 12,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
