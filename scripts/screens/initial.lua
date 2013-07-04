--[[==============
== We Love Quiz
== Date: 21/06/13
== Time: 17:28
==============]]--
InitialScreen = {}

require "scripts.widgets.view.button_home_screen"

local initialScreenGroup
local bottomRanking
local topBar
local matchesFoil
local logo
local playBtn
local adjustScale
local matchesGroup

local function createLogo()
    logo = TextureManager.newImage("stru_logotipo", initialScreenGroup)
    logo.x = logo.width*0.5 + 8
    logo.y = SCREEN_TOP + 130
    logo.isVisible = false
    function logo:showUp()
        self.isVisible = true
        transition.from(self, {time = 500, x = SCREEN_LEFT - self.width, transition = easeOutQuad})
    end
    function logo:hide()
        self.isVisible = true
        transition.to(self, {time = 500, x = SCREEN_LEFT - self.width, transition = easeInQuad})
    end
    return logo
end

local function createButtons()
    local buttonGroup = display.newGroup()

    local buttonBg = TextureManager.newImageRect("images/stru_bar_gold_mid.png", CONTENT_WIDTH, 47, buttonGroup)
    buttonBg.x = display.contentCenterX
    buttonBg.y = display.contentCenterY

    local buttonTxt = display.newText(buttonGroup, "JOGAR", 0, 0, "MyriadPro-BoldCond", 28)
    buttonTxt.x = 96 + display.screenOriginX*0.5
    buttonTxt.y = display.contentCenterY
    buttonTxt:setTextColor(0)

    return buttonGroup
end

local function createFoilLine(x, y, lineWidth)
    local lineGroup = display.newGroup()
    --local horLine = display.newLine(lineGroup, 0, 0, 1, 0)
    --horLine:setColor(102, 16, 19, 64)
    local horLine = display.newLine(lineGroup, 0, 0, lineWidth, 0)
    horLine:setColor(102, 16, 19)

    --local horLine = display.newLine(lineGroup, -1, 1, 0, 1)
    --horLine:setColor(242, 155, 158, 64)
    local horLine = display.newLine(lineGroup, 0, 1, lineWidth, 1)
    horLine:setColor(242, 155, 158)

    lineGroup:setReferencePoint(display.CenterRightReferencePoint)
    lineGroup.x = x
    lineGroup.y = y
    lineGroup.baseY = y

    return lineGroup
end

local function createMatchView(match, y)
    local matchGroup = display.newGroup()

    local time = display.newText(string.utf8upper(match.starts_at:fmt("%a %d %b %Y - %H:%M")), 0, 0, "MyriadPro-BoldCond", 16)
    time:setReferencePoint(display.TopRightReferencePoint)
    time.x = 0
    time.y = 0

    local vs = display.newText("VS", 0, 0, "MyriadPro-BoldCond", 16)
    vs:setReferencePoint(display.TopRightReferencePoint)
    vs.x = -59
    vs.y = 48

    local homeTeamBadge = TextureManager.newLogo("logos/medium_" .. match.home_team.id .. ".png", 64)
    homeTeamBadge.x = -108
    homeTeamBadge.y = 50
    local awayTeamBadge = TextureManager.newLogo("logos/medium_" .. match.guest_team.id .. ".png", 64)
    awayTeamBadge.x = -27
    awayTeamBadge.y = 50

    matchGroup:insert(time)
    matchGroup:insert(vs)
    matchGroup:insert(homeTeamBadge)
    matchGroup:insert(awayTeamBadge)

    matchGroup:setReferencePoint(display.TopRightReferencePoint)
    matchGroup.x = (160 + (-display.screenOriginX))*0.5 - 4 + display.screenOriginX*0.5
    matchGroup.y = y + 4
    matchGroup.baseY = y + 4
    return matchGroup
end

local function createMatchesView(x, y)
    local widget = require "widget"
    -- Create a ScrollView
    local _maskFile = "images/matches_foil/matchesfoil_mask"
    if display.screenOriginY < 0 then
        _maskFile = _maskFile .. "_iphone5"
    end
    _maskFile = _maskFile .. ".png"

    local matches = MatchManager:getMatchesOfTheDay()[1].matches --TODO change championship
    --local scrollHeight = #matches*96 + (-display.screenOriginY)
    --scrollHeight = 1*96 + (-display.screenOriginY)
    matchesGroup = widget.newScrollView
        {
            width = 160 + (-display.screenOriginX),
            height = 376 + (-display.screenOriginY),
            --scrollHeight = scrollHeight,
            topPadding = 100 + display.screenOriginY,
            bottomPadding = 40, -- -1550 - display.screenOriginY*5.5,
            maskFile = _maskFile,
            hideBackground = true,
            horizontalScrollDisabled = true,
            verticalScrollDisabled = #matches < 4,
            friction = 0.7,
            --listener = adjustScale,
        }

    matchesGroup.lines = {}
    matchesGroup.matches = {}
    local yPos = 0
    for i, match in ipairs(matches) do
        --if i > 1 then
        --    break
        --end
        matchesGroup.lines[#matchesGroup.lines + 1] = createFoilLine(80 + (-display.screenOriginX), yPos,  160 + (-display.screenOriginX))
        matchesGroup:insert(matchesGroup.lines[#matchesGroup.lines])
        matchesGroup.matches[#matchesGroup.matches + 1] = createMatchView(match, yPos)
        matchesGroup:insert(matchesGroup.matches[#matchesGroup.matches])
        yPos = yPos + 84 --(120*(((yPos)*1.4 + 500)/1000))
    end

    matchesGroup.x = x + 3
    matchesGroup.y = y
    matchesGroup.maskX = 14 + display.screenOriginX*0.5 + display.screenOriginY*0.1

    local lastContY
    function adjustScale()
        if not initialScreenGroup then
            return
        end
        if matchesGroup.getContentPosition then
            local contX, contY = matchesGroup:getContentPosition()
            if lastContY ~= contY then
                lastContY = contY
                --local yPos = 0
                --print(contY)
                for i, _obj in ipairs(matchesGroup.matches) do
                    --print(_obj.baseY, contY)
                    local scale = ((_obj.y + contY)*1.4 + 500)/1000
                    --print(scale)
                    if scale < 0.1 then
                        scale = 0.1
                    elseif scale > 1 then
                        scale = 1
                    end
                    _obj.xScale = scale
                    _obj.yScale = scale
                    --_obj.y = yPos + 4
                    --matchesGroup.lines[i].y = yPos
                    --print(yPos)
                    --yPos = yPos + (120*(((_obj.y + contY)*1.4 + 500)/1000))
                    --print(_obj.y, _obj.baseY)
                end
            end
        end
    end
    Runtime:addEventListener("enterFrame", adjustScale)

    return matchesGroup
end

local function createMatchesFoil()
    matchesFoil = display.newGroup()
    local matchesFoilCenter = TextureManager.newImageRect("images/matches_foil/stru_mainfoil_center.png", 72 + (-display.screenOriginX), 421, matchesFoil) --88 420
    matchesFoilCenter.x = SCREEN_RIGHT - matchesFoilCenter.width*0.5
    matchesFoilCenter.y = display.contentCenterY
    local matchesFoilBorder = TextureManager.newImageRect("images/matches_foil/stru_mainfoil_border.png", 88, 421, matchesFoil) --88 420
    matchesFoilBorder.x = matchesFoilCenter.x - matchesFoilCenter.width*0.5 - matchesFoilBorder.width*0.5
    matchesFoilBorder.y = display.contentCenterY
    local matchesGroup = createMatchesView(SCREEN_RIGHT - (160 + (-display.screenOriginX))*0.5, display.contentCenterY - 210)
    matchesFoil:insert(matchesGroup)
    matchesFoil.isVisible = false
    function matchesFoil:showUp(onComplete)
        self.isVisible = true
        transition.from(self, {time = 1000, x = SCREEN_RIGHT + self.width, transition = easeOutQuad, onComplete = function()
            matchesGroup:scrollTo("bottom", {time = 1000})
            onComplete()
        end})
    end
    function matchesFoil:hide(onComplete)
        transition.to(self, {time = 300, x = SCREEN_RIGHT + self.width, transition = easeInQuad, onComplete = function()
            self.isVisible = false
            onComplete()
        end})
    end
    matchesFoil:showUp(function() playBtn:showUp() end)
    return matchesFoil
end

function InitialScreen:showUp()
    bottomRanking:showUp(function()
        topBar:showUp()
        logo:showUp()
        initialScreenGroup:insert(3, createMatchesFoil())
    end)
end

function InitialScreen:new()
    initialScreenGroup = display.newGroup()

    createLogo()

    playBtn = BtnHomeScreen:new(function() ScreenManager:show("select_match") end)
    initialScreenGroup:insert(playBtn)

    bottomRanking = BottomRanking:new("pictures/pic_8.png", true)
    initialScreenGroup:insert(bottomRanking)

    topBar = TopBar:new(true)
    initialScreenGroup:insert(topBar)

    return initialScreenGroup
end

function InitialScreen:hide(onComplete)
    playBtn:hide(function()
        logo:hide()
        matchesFoil:hide(function()
            topBar:hide()
            bottomRanking:hide(function()
                InitialScreen:destroy()
                onComplete()
            end)
        end)
    end)
end

function InitialScreen:destroy()
    Runtime:removeEventListener("enterFrame", adjustScale)
    bottomRanking:destroy()
    topBar:destroy()
    matchesFoil:removeSelf()
    logo:removeSelf()
    playBtn:removeSelf()
    if matchesGroup and matchesGroup.removeSelf then
        matchesGroup:removeSelf()
    end
    if initialScreenGroup and initialScreenGroup.removeSelf then
        initialScreenGroup:removeSelf()
    end
    matchesGroup = nil
    initialScreenGroup = nil
    bottomRanking = nil
    topBar = nil
    matchesFoil = nil
    logo = nil
    playBtn = nil
end

return InitialScreen