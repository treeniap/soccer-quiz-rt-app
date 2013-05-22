--[[==============
== We Love Quiz
== Date: 13/05/13
== Time: 16:55
==============]]--
SideMenu = {}

local menuFoilGroup

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

local function createView()
    --scalable menu background
    local menuFoilCenter = TextureManager.newImageRect("images/stru_menufoil_center.png", 140 + display.screenOriginX*-2, 570, menuFoilGroup)
    menuFoilCenter.x = SCREEN_LEFT + menuFoilCenter.width*0.5
    menuFoilCenter.y = 0
    menuFoilCenter:addEventListener("touch", function() return true end)

    -- menu background border
    local menuFoilBorda = TextureManager.newImage("stru_menufoil_borda", menuFoilGroup)
    menuFoilBorda.x = menuFoilCenter.x + menuFoilCenter.width*0.5 + menuFoilBorda.width*0.5
    menuFoilBorda.y = 0
    menuFoilBorda:addEventListener("touch", function() return true end)

    -- menu open/close button
    local menuFoilBtn = BtnSideMenu:new(showHideMenu)
    menuFoilBtn.x = menuFoilBorda.x + menuFoilBorda.width*0.5 + menuFoilBtn.width*0.5 - 1
    menuFoilBtn.y = -menuFoilBorda.height*0.5 + menuFoilBtn.height*0.5 + 3.6
    menuFoilGroup:insert(menuFoilBtn)

    -- menu touch blocker for objects behind
    local touchBlocker = display.newRect(0, 0, 384, 572)
    touchBlocker.y = 0
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
end

function SideMenu:new()
    if menuFoilGroup then
        return menuFoilGroup
    end
    menuFoilGroup = display.newGroup()
    for k, v in pairs(SideMenu) do
        menuFoilGroup[k] = v
    end
    createView()
    return menuFoilGroup
end

return SideMenu