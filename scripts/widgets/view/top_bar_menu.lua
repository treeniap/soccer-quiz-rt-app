--[[==============
== We Love Quiz
== Date: 23/05/13
== Time: 15:47
==============]]--
TopBarMenu = {}

require "scripts.widgets.view.button_back"

MENU_TITLE_BAR_HEIGHT = 43

local function createView(title, listener)
    local topBarGroup = display.newGroup()
    local bar = TextureManager.newImageRect("images/stretchable/stru_bar_top.png", CONTENT_WIDTH, MENU_TITLE_BAR_HEIGHT, topBarGroup)
    local title = display.newEmbossedText(topBarGroup, title, 0, 0, "MyriadPro-BoldCond", 28)
    title.x = 0
    title.y = 4
    title:setTextColor(255)
    local btnBack = BtnBack:new(listener)
    btnBack.x = -bar.width*0.5 + btnBack.width*0.5
    btnBack.y = -2
    topBarGroup:insert(btnBack)
    topBarGroup:setReferencePoint(display.TopLeftReferencePoint)
    topBarGroup.x = SCREEN_LEFT
    topBarGroup.y = SCREEN_TOP
    return topBarGroup
end

function TopBarMenu:new(title, listener)
    return createView(title, listener)
end

return TopBarMenu