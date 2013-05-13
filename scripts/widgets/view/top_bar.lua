--[[==============
== We Love Quiz
== Date: 06/05/13
== Time: 12:23
==============]]--
TopBar = {}

require "scripts.widgets.view.button_more_coins"
require "scripts.widgets.view.button_menu"
require "scripts.widgets.view.total_coins"

local function showHideMenu(btn, event)
    if ((btn.hasMoved and btn.group.x ~= btn.group.visibleX) or not btn.hasMoved) and btn.isOpen then
        transition.to(btn.group, {time = 300, x = btn.group.hideX, transition = easeOutBack, onComplete = function()
            btn.isLocked = false
        end})
        btn.touchBlocker.isVisible = false
        btn.isOpen = false
        btn.isLocked = true
    else
        transition.to(btn.group, {time = 300, x = btn.group.visibleX, transition = easeInSine, onComplete = function()
            btn.isLocked = false
        end})
        btn.touchBlocker.isVisible = true
        btn.isOpen = true
        btn.isLocked = true
    end
    return true
end

function TopBar:createView()
    local bg = TextureManager.newImage("stru_bartop", self)
    bg.x = display.contentCenterX
    bg.y = 0

    --- More coins
    local moreCoinsBtn = BtnMoreCoins:new(function() end)
    moreCoinsBtn.x = 300
    moreCoinsBtn.y = 0
    self:insert(moreCoinsBtn)

    --- Total coins
    local totalCoins = TotalCoinsView:new()
    totalCoins.x = 211
    totalCoins.y = -26
    TotalCoinsView:update(0)
    timer.performWithDelay(2000, function() TotalCoinsView:update(1000) end)
    self:insert(totalCoins)

    --- Menu
    local menuFoilGroup = display.newGroup()

    --scalable menu background
    local menuFoilCenter = TextureManager.newImageRect(menuFoilGroup, "images/stru_menufoil_center.png", 140 + display.screenOriginX*-2, 570)
    menuFoilCenter.x = SCREEN_LEFT + menuFoilCenter.width*0.5
    menuFoilCenter.y = menuFoilCenter.height*0.5 - bg.height*0.5
    menuFoilCenter:addEventListener("touch", function() return true end)

    -- menu background border
    local menuFoilBorda = TextureManager.newImageRect(menuFoilGroup, "images/stru_menufoil_borda.png", 142, 570)
    menuFoilBorda.x = menuFoilCenter.x + menuFoilCenter.width*0.5 + menuFoilBorda.width*0.5
    menuFoilBorda.y = menuFoilBorda.height*0.5 - bg.height*0.5
    menuFoilBorda:addEventListener("touch", function() return true end)

    -- menu open/close button
    local menuFoilBtn = BtnMenu:new(showHideMenu)
    menuFoilBtn.x = menuFoilBorda.x + menuFoilBorda.width*0.5 + menuFoilBtn.width*0.5
    menuFoilBtn.y = -7.5
    menuFoilGroup:insert(menuFoilBtn)

    -- menu touch blocker for objects behind
    local touchBlocker = display.newRect(0, -bg.height*0.5, 384, 572)
    touchBlocker:addEventListener("touch", menuFoilBtn)
    touchBlocker.alpha = 0.01
    touchBlocker.isVisible = false
    local mask = graphics.newMask("images/stru_menufoil_touch_mask.png")
    touchBlocker:setMask(mask)
    touchBlocker.isHitTestMasked = true
    touchBlocker.maskX = -50 - display.screenOriginX
    touchBlocker.maskY = -20
    menuFoilGroup:insert(touchBlocker)

    -- set menu button pointers
    menuFoilBtn.group = menuFoilGroup
    menuFoilBtn.touchBlocker = touchBlocker
    -- set menu state
    menuFoilBtn.isOpen = false
    --set menu x position properties
    menuFoilGroup.hideX = -menuFoilCenter.width - menuFoilBorda.width
    menuFoilGroup.visibleX = 0
    function menuFoilGroup:setX(x)
        self.x = x
        if self.x < self.hideX then
            self.x = self.hideX
        elseif self.x > self.visibleX then
            self.x = self.visibleX
        end
    end
    menuFoilGroup:setX(menuFoilGroup.hideX)

    self:insert(menuFoilGroup)
end

function TopBar:new()
    local topBarGroup = display.newGroup()
    for k, v in pairs(TopBar) do
        topBarGroup[k] = v
    end

    topBarGroup:createView()
    topBarGroup:setReferencePoint(display.CenterReferencePoint)
    topBarGroup.y = SCREEN_TOP + topBarGroup.height*0.5

    return topBarGroup
end

return TopBar