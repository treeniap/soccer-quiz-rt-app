--[[==============
== We Love Quiz
== Date: 13/05/13
== Time: 16:55
==============]]--
SideMenu = {}

require "scripts.widgets.view.button_link"

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
        AnalyticsManager.OpenedSideMenu()
    end
    return true
end

local function createOptions()
    local widget = require("widget")

    local optionsGroup = display.newGroup()

    local lineX = 8
    local lineY = -240

    local color =
    {
        highlight =
        {
            r =255, g = 255, b = 255, a = 128
        },
        shadow =
        {
            r = 0, g = 0, b = 0, a = 128
        }
    }
    -- Handle press events for the switches
    local function onSwitchPress( event )
        local switch = event.target
        --print( switch.id, "is on?:", switch.isOn )
        AudioManager.playAudio("onOffBtn")
        UserData:switchSound(switch.isOn)
        AnalyticsManager.clickedAudioSetting(UserData.soundOn and "AudioOn" or "AudioOff")
    end

    -- AUDIO TITLE
    local audioTitleTxt = display.newEmbossedText(optionsGroup, "ÁUDIO", lineX, lineY, "MyriadPro-BoldCond", 14)
    audioTitleTxt:setTextColor(192)
    audioTitleTxt:setEmbossColor(color)
    optionsGroup:insert(TextureManager.newHorizontalLine(104, lineY + 18, 220 + display.screenOriginX*-2))

    -- SONS
    lineY = lineY + 28
    local sonsTxt = display.newText(optionsGroup, "SONS", lineX, lineY, "MyriadPro-BoldCond", 18)
    sonsTxt:setTextColor(0)
    -- SONS on/off switch
    local soundsOnOffSwitch = widget.newSwitch
        {
            left = 120,
            top = lineY - 8,
            initialSwitchState = UserData.soundOn,
            onPress = onSwitchPress,
            onRelease = onSwitchPress,
        }
    optionsGroup:insert(soundsOnOffSwitch)

    -- MUSICA
    lineY = lineY + 36
    --local musicaTxt = display.newText(optionsGroup, "MÚSICA", lineX, lineY, "MyriadPro-BoldCond", 18)
    --musicaTxt:setTextColor(0)
    ---- MUSICA on/off switch
    --local musicOnOffSwitch = widget.newSwitch
    --    {
    --        left = 120,
    --        top = lineY - 8,
    --        initialSwitchState = true,
    --        onPress = onSwitchPress,
    --        onRelease = onSwitchPress,
    --    }
    --optionsGroup:insert(musicOnOffSwitch)

    ---- NOTIFICACOES TITLE
    --lineY = lineY + 44 + (display.screenOriginY*-0.5)
    --local notificacoesTitleTxt = display.newEmbossedText(optionsGroup, "NOTIFICAÇÕES", lineX, lineY, "MyriadPro-BoldCond", 14)
    --notificacoesTitleTxt:setTextColor(192)
    --notificacoesTitleTxt:setEmbossColor(color)
    --optionsGroup:insert(TextureManager.newHorizontalLine(104, lineY + 18, 220 + display.screenOriginX*-2))
    --
    ---- MEU TIME
    --lineY = lineY + 28
    --local meutimeTxt = display.newText(optionsGroup, "MEU TIME", lineX, lineY, "MyriadPro-BoldCond", 18)
    --meutimeTxt:setTextColor(0)
    ---- MEU TIME on/off switch
    --local function onSwitchNotificationPress(event)
    --    UserData:updateAttributes(event.target.isOn, UserData.attributes.favorite_team_id)
    --    AudioManager.playAudio("onOffBtn")
    --    AnalyticsManager.clickedSettings(eventName)
    --end
    --local myTeamOnOffSwitch = widget.newSwitch
    --    {
    --        left = 120,
    --        top = lineY - 8,
    --        initialSwitchState = UserData.attributes.push_notifications_enabled,
    --        onPress = onSwitchNotificationPress,
    --        onRelease = onSwitchNotificationPress,
    --    }
    --optionsGroup:insert(myTeamOnOffSwitch)
    --
    ---- TODOS OS TIMES
    --lineY = lineY + 36
    --local todosostimesTxt = display.newText(optionsGroup, "TODOS OS TIMES", lineX, lineY, "MyriadPro-BoldCond", 18)
    --todosostimesTxt:setTextColor(0)
    ---- TODOS OS TIMES on/off switch
    --local allTeamsOnOffSwitch = widget.newSwitch
    --    {
    --        left = 120,
    --        top = lineY - 8,
    --        initialSwitchState = true,
    --        onPress = onSwitchPress,
    --        onRelease = onSwitchPress,
    --    }
    --optionsGroup:insert(allTeamsOnOffSwitch)

    -- LINKS UTEIS TITLE
    lineY = lineY + 44 + (display.screenOriginY*-0.5)
    local linksuteisTitleTxt = display.newEmbossedText(optionsGroup, "LINKS ÚTEIS", lineX, lineY, "MyriadPro-BoldCond", 14)
    linksuteisTitleTxt:setTextColor(192)
    linksuteisTitleTxt:setEmbossColor(color)
    optionsGroup:insert(TextureManager.newHorizontalLine(104, lineY + 18, 220 + display.screenOriginX*-2))

    local function onLinksReceived(response, status)
        --printTable(response)
        if status == 200 then
            for i, link in ipairs(response) do
                lineY = lineY + 28
                local fanpageLink = BtnLink:new(link.label, lineX, lineY, function()
                    system.openURL(link.url)
                    AnalyticsManager.clickedUsefulLink(link.label)
                end)
                optionsGroup:insert(fanpageLink)
            end
        else
            Server:getUsefulLinks(onLinksReceived)
        end
    end
    Server:getUsefulLinks(onLinksReceived)

    return optionsGroup
end

local function createMenuOptions()
    local widget = require( "widget" )

    local optionsGroup = display.newGroup()

    local lineX = 8
    local lineY = -240

    local color =
    {
        highlight =
        {
            r =255, g = 255, b = 255, a = 128
        },
        shadow =
        {
            r = 0, g = 0, b = 0, a = 128
        }
    }
    -- Handle press events for the switches
    local function onSwitchPress( event )
        local switch = event.target
        --print( switch.id, "is on?:", switch.isOn )
        AudioManager.playAudio("onOffBtn")
        UserData:switchSound(switch.isOn)
    end

    -- AUDIO TITLE
    local audioTitleTxt = display.newEmbossedText(optionsGroup, "ÁUDIO", lineX, lineY, "MyriadPro-BoldCond", 14)
    audioTitleTxt:setTextColor(192)
    audioTitleTxt:setEmbossColor(color)
    optionsGroup:insert(TextureManager.newHorizontalLine(104, lineY + 18, 220 + display.screenOriginX*-2))

    -- SONS
    lineY = lineY + 28
    local sonsTxt = display.newText(optionsGroup, "SONS", lineX, lineY, "MyriadPro-BoldCond", 18)
    sonsTxt:setTextColor(0)
    -- SONS on/off switch
    local soundsOnOffSwitch = widget.newSwitch
        {
            left = 120,
            top = lineY - 8,
            initialSwitchState = UserData.soundOn,
            onPress = onSwitchPress,
            onRelease = onSwitchPress,
        }
    optionsGroup:insert(soundsOnOffSwitch)

    -- RECURSOS E MENUS
    lineY = lineY + 44 + (display.screenOriginY*-0.5)
    local recursosTitleTxt = display.newEmbossedText(optionsGroup, "RECURSOS E MENUS", lineX, lineY, "MyriadPro-BoldCond", 14)
    recursosTitleTxt:setTextColor(192)
    recursosTitleTxt:setEmbossColor(color)
    optionsGroup:insert(TextureManager.newHorizontalLine(104, lineY + 18, 220 + display.screenOriginX*-2))
    -- SAIR
    lineY = lineY + 28
    local sairLink = BtnLink:new("SAIR", lineX, lineY, function()
        transition.to(menuFoilGroup, {time = 300, x = menuFoilGroup.hideX, transition = easeOutBack, onComplete = function()
            ScreenManager:exitMatch()
        end})
    end)
    sairLink.xScale = 1.5
    sairLink.yScale = 1.5
    optionsGroup:insert(sairLink)

    return optionsGroup
end

local function createView(isMenu)
    local function blockTouch()
        return true
    end
    --scalable menu background
    local menuFoilCenter = TextureManager.newImageRect("images/stru_menufoil_center.png", 140 + display.screenOriginX*-2, 570, menuFoilGroup)
    menuFoilCenter.x = SCREEN_LEFT + menuFoilCenter.width*0.5
    menuFoilCenter.y = 0
    menuFoilCenter:addEventListener("touch", blockTouch)

    -- menu background border
    local menuFoilBorda = TextureManager.newImage("stru_menufoil_borda", menuFoilGroup)
    menuFoilBorda.x = menuFoilCenter.x + menuFoilCenter.width*0.5 + menuFoilBorda.width*0.5
    menuFoilBorda.y = 0
    menuFoilBorda:addEventListener("touch", blockTouch)

    -- menu open/close button
    local menuFoilBtn = BtnSideMenu:new(showHideMenu, isMenu)
    menuFoilBtn.x = menuFoilBorda.x + menuFoilBorda.width*0.5 + menuFoilBtn.width*0.5 - 1
    menuFoilBtn.y = -menuFoilBorda.height*0.5 + menuFoilBtn.height*0.5 + 3.6
    menuFoilGroup:insert(menuFoilBtn)

    -- menu title
    local title = display.newEmbossedText(menuFoilGroup, isMenu and "CONFIGURAÇÕES" or "MENU DA PARTIDA",
        display.contentCenterX - 96, -menuFoilCenter.height*0.5 + 4,
        "MyriadPro-BoldCond", 24)
    title:setTextColor(255)

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

    function menuFoilGroup:removeEventListeners()
        menuFoilCenter:removeEventListener("touch", blockTouch)
        menuFoilBorda:removeEventListener("touch", blockTouch)
        touchBlocker:removeEventListener("touch", menuFoilBtn)
    end

    if isMenu then
        menuFoilGroup:insert(createOptions())
    else
        menuFoilGroup:insert(createMenuOptions())
    end
end

function SideMenu:new(isMenu)
    menuFoilGroup = display.newGroup()
    for k, v in pairs(SideMenu) do
        menuFoilGroup[k] = v
    end
    createView(isMenu)
    return menuFoilGroup
end

function SideMenu:destroy()
    menuFoilGroup:removeEventListeners()
    menuFoilGroup:removeSelf()
    menuFoilGroup = nil
end

return SideMenu