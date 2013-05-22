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

function TopBar:createView()
    local bg = TextureManager.newImage("stru_header", self)
    bg.x = display.contentCenterX
    bg.y = 0

    --- More coins
    local moreCoinsBtn = BtnMoreCoins:new(function() end)
    moreCoinsBtn.x = 300
    moreCoinsBtn.y = -3
    self:insert(moreCoinsBtn)

    --- Total coins
    totalCoins = TotalCoinsView:new()
    totalCoins.x = 211
    totalCoins.y = -32
    self:insert(totalCoins)

    --- Match Teams
    matchTeams = createMatchViewer()
    matchTeams.x = 85
    matchTeams.y = -8
    self:insert(matchTeams)

    --- Menu
    menuFoilGroup = SideMenu:new()
    menuFoilGroup.y = menuFoilGroup.height*0.5 - bg.height*0.5 - 1
    menuFoilGroup.isVisible = false
    --self:insert(menuFoilGroup)
end

function TopBar:updateTotalCoins(coins)
    totalCoins:update(coins)
end

function TopBar:updateMatchTeams(team1BadgeDir, team2BadgeDir)
    if matchTeams.team1Badge then
        matchTeams.team1Badge:removeSelf()
    end
    if matchTeams.team2Badge then
        matchTeams.team2Badge:removeSelf()
    end
    local BADGE_SIZE = 24
    matchTeams.team1Badge = TextureManager.newImageRect(team1BadgeDir, BADGE_SIZE, BADGE_SIZE, matchTeams)
    matchTeams.team1Badge.x = -BADGE_SIZE
    matchTeams.team1Badge.y = -4
    matchTeams.team2Badge = TextureManager.newImageRect(team2BadgeDir, BADGE_SIZE, BADGE_SIZE, matchTeams)
    matchTeams.team2Badge.x = BADGE_SIZE
    matchTeams.team2Badge.y = -4
end

function TopBar:showUp(onComplete)
    transition.to(self, {delay = 400, time = 400, y = SCREEN_TOP + self.height*0.5 - 1, transition = easeOutQuint, onComplete = function()
        menuFoilGroup.isVisible = true
        self:insert(menuFoilGroup)
        transition.from(menuFoilGroup, {time = 1000, x = menuFoilGroup.x - menuFoilGroup.width})
        if onComplete then
            onComplete()
        end
    end})
end

function TopBar:hide(onComplete)
end

function TopBar:new()
    if topBarGroup then
        return topBarGroup
    end
    topBarGroup = display.newGroup()
    for k, v in pairs(TopBar) do
        topBarGroup[k] = v
    end

    topBarGroup:createView()
    topBarGroup:setReferencePoint(display.CenterReferencePoint)
    topBarGroup.y = SCREEN_TOP - topBarGroup.height*0.5 - 1

    return topBarGroup
end

return TopBar