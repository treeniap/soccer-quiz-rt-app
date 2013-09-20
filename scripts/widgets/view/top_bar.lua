--[[==============
== We Love Quiz
== Date: 06/05/13
== Time: 12:23
==============]]--
TopBar = {}

require "scripts.widgets.view.button_more_coins"
require "scripts.widgets.view.button_side_menu"
require "scripts.widgets.view.total_coins"
require "scripts.widgets.view.side_menu"

local topBarGroup, menuFoilGroup
local totalCoins
local matchTeams

local function createMatchViewer()
    local matchTeamsGroup = display.newGroup()
    local vsText = display.newText(matchTeamsGroup, "VS", 0, 0, "MyriadPro-BoldCond", 16)
    vsText.x = 0
    vsText.y = 0
    return matchTeamsGroup
end

function TopBar:createView(isMenu)
    local bg = TextureManager.newImage("stru_header", self)
    bg.x = display.contentCenterX
    bg.y = 0

    --- More coins
    local moreCoinsBtn
    moreCoinsBtn = BtnMoreCoins:new(function()
        moreCoinsBtn:lock(true)
        StoreManager.buyThis("com.ffgfriends.chutepremiado.pacotedemoedas", function()
            moreCoinsBtn:lock(false)
        end)

        AnalyticsManager.clickedMoreCoins(isMenu and "Home" or "InGame")
    end)
    moreCoinsBtn.x = 300
    moreCoinsBtn.y = -3
    self:insert(moreCoinsBtn)

    --- Total coins
    totalCoins = TotalCoinsView:new()
    totalCoins.x = 211
    totalCoins.y = -32
    self:insert(totalCoins)

    --- Menu
    menuFoilGroup = SideMenu:new(isMenu)
    menuFoilGroup.y = menuFoilGroup.height*0.5 - bg.height*0.5 - 1
    menuFoilGroup.isVisible = false
    --self:insert(menuFoilGroup)
end

function TopBar:updateTotalCoins(coins)
    totalCoins:update(coins)
end

function TopBar:updateMatchTeams(team1BadgeDir, team2BadgeDir)
    if not matchTeams then
        matchTeams = createMatchViewer()
        matchTeams.x = 85
        matchTeams.y = -8
        self:insert(matchTeams)
    else
        if matchTeams.team1Badge then
            matchTeams.team1Badge:removeSelf()
        end
        if matchTeams.team2Badge then
            matchTeams.team2Badge:removeSelf()
        end
    end
    local BADGE_SIZE = 32
    matchTeams.team1Badge = TextureManager.newLogo(team1BadgeDir, BADGE_SIZE, matchTeams)
    matchTeams.team1Badge.x = -BADGE_SIZE
    matchTeams.team1Badge.y = -4
    matchTeams.team2Badge = TextureManager.newLogo(team2BadgeDir, BADGE_SIZE, matchTeams)
    matchTeams.team2Badge.x = BADGE_SIZE
    matchTeams.team2Badge.y = -4
end

function TopBar:showUp(onComplete)
    transition.to(self, {delay = 150, time = 150, y = SCREEN_TOP + self.height*0.5 - 1, transition = easeOutQuint, onComplete = function()
        menuFoilGroup.isVisible = true
        self:insert(menuFoilGroup)
        transition.from(menuFoilGroup, {time = 1000, x = menuFoilGroup.x - menuFoilGroup.width})
        if onComplete then
            onComplete()
        end
        AudioManager.playAudio("showSideMenuBtn", 900)
    end})
end

function TopBar:hide(onComplete)
    transition.to(self, {delay = 150, time = 150, y = SCREEN_TOP - topBarGroup.height*0.5 - 1, transition = easeInQuint, onComplete = onComplete})
end

function TopBar:new(isMenu)
    if topBarGroup and topBarGroup.removeSelf then
        topBarGroup:removeSelf()
    end
    topBarGroup = display.newGroup()
    for k, v in pairs(TopBar) do
        topBarGroup[k] = v
    end

    topBarGroup:createView(isMenu)
    topBarGroup:setReferencePoint(display.CenterReferencePoint)
    topBarGroup.y = SCREEN_TOP - topBarGroup.height*0.5 - 1
    topBarGroup.touch = function() return true end
    topBarGroup:addEventListener("touch", topBarGroup)

    return topBarGroup
end

function TopBar:destroy()
    topBarGroup:removeEventListener("touch", topBarGroup)
    totalCoins:destroy()
    if matchTeams then
        matchTeams:removeSelf()
    end
    menuFoilGroup:destroy()
    topBarGroup:removeSelf()

    topBarGroup, menuFoilGroup = nil, nil
    totalCoins = nil
    matchTeams = nil
end

return TopBar