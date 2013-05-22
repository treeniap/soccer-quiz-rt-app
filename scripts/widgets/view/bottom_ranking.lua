--[[==============
== We Love Quiz
== Date: 30/04/13
== Time: 16:49
==============]]--
BottomRanking = {}

local function getPlayerPosition(ranking)
    for i, v in ipairs(ranking) do
        if v.isPlayer then
            return i
        end
    end
end

local function createPlayerView(player, position, isGoldenPlayer)
    local photoSize = isGoldenPlayer and 67 or 57
    local badgeSize = 16
    local playerGroup = display.newGroup()
    --playerGroup:setReferencePoint(display.CenterReferencePoint)
    local notch
    if player.isPlayer and not isGoldenPlayer then
        local userBar = TextureManager.newImage("stru_userframe", playerGroup)
        userBar.x = 0
        userBar.y = -6
        notch = TextureManager.newImage("stru_notchsilver", playerGroup)
    elseif isGoldenPlayer then
        notch = TextureManager.newImage("stru_notchgolden", playerGroup)
    else
        notch = TextureManager.newImage("stru_notchsilver", playerGroup)
    end
    notch.x = 0
    notch.y = 0
    local photo = TextureManager.newImageRect(player.photo, photoSize, photoSize, playerGroup)
    photo.x = -0.5
    photo.y = -0.5
    local score = display.newText(playerGroup, player.score .. " pts", 0, 0, "MyriadPro-BoldCond", 16)
    score.x = photo.x + photo.width*0.5 - score.width*0.5
    score.y = photo.y - photo.height*0.5 - score.height*0.35
    score:setTextColor(0)

    if isGoldenPlayer then
        local positionStru = TextureManager.newImage("stru_position", playerGroup)
        positionStru.x = photo.x + photo.width*0.5 - positionStru.width*0.5 + 2
        positionStru.y = photo.y + photo.height*0.5 - positionStru.height*0.5 + 2
        local positionTxt = display.newText(playerGroup, position .. "°", 0, 0, "MyriadPro-BoldCond", 16)
        positionTxt.x = positionStru.x + 3
        positionTxt.y = positionStru.y + 3
        positionTxt:setTextColor(0)
    else
        local teamBadge = TextureManager.newImageRect(player.team_badge, badgeSize, badgeSize, playerGroup)
        teamBadge.x = photo.x + photo.width*0.5 - teamBadge.width*0.5 + 2
        teamBadge.y = photo.y + photo.height*0.5 - teamBadge.height*0.5 + 2
    end
    return playerGroup
end

local function createPlayerOneView(playerPhoto)
    local PHOTO_SIZE = 67

    local playerGroup = display.newGroup()

    local bg = TextureManager.newImage("stru_ranking_gold", playerGroup)
    bg.x = 0
    bg.y = 0

    local notch = TextureManager.newImage("stru_notchgolden", playerGroup)
    notch.x = -12
    notch.y = 9

    local photo = TextureManager.newImageRect(playerPhoto, PHOTO_SIZE, PHOTO_SIZE, playerGroup)
    photo.x = notch.x - 0.5
    photo.y = notch.y - 0.5

    local score = display.newText(playerGroup, " ", 0, 0, "MyriadPro-BoldCond", 16)
    score:setReferencePoint(display.CenterRightReferencePoint)
    score.x = photo.x + photo.width*0.5
    score.y = photo.y - photo.height*0.5 - 8
    score:setTextColor(0)

    local positionStru = TextureManager.newImage("stru_position", playerGroup)
    positionStru.x = photo.x + photo.width*0.5 - positionStru.width*0.5 + 2
    positionStru.y = photo.y + photo.height*0.5 - positionStru.height*0.5 + 2

    local positionTxt = display.newText(playerGroup, " ", 0, 0, "MyriadPro-BoldCond", 16)
    positionTxt.x = positionStru.x + 3
    positionTxt.y = positionStru.y + 3
    positionTxt:setTextColor(0)

    function playerGroup:setPointsAndPosition(pts, pos)
        score.text = pts .. " pts"
        score:setReferencePoint(display.CenterRightReferencePoint)
        score.x = photo.x + photo.width*0.5
        score.y = photo.y - photo.height*0.5 - 8
        positionTxt.text = pos .. "°"
        positionTxt:setReferencePoint(display.CenterReferencePoint)
        positionTxt.x = positionStru.x + 3
        positionTxt.y = positionStru.y + 3
    end

    return playerGroup
end

function BottomRanking:showUp(onComplete)
    transition.to(self.bg, {delay = 500, time = 750, x = display.contentCenterX, xScale = 1, onComplete = onComplete})
    transition.to(self.leftBar, {time = 750, x = SCREEN_LEFT + self.leftBar.width*0.5, transition = easeOutCirc})
    transition.to(self.rightBar, {time = 750, x = SCREEN_RIGHT - self.rightBar.width*0.5 + 1, transition = easeOutCirc})
end

function BottomRanking:hide(onComplete)
end

function BottomRanking:createView(playerPhoto)
    self.bg = TextureManager.newImageRect("images/stru_ranking_silver.png", CONTENT_WIDTH, 86, self)
    self.bg.x = SCREEN_LEFT - self.bg.width*0.5
    self.bg.y = 0
    self.bg.xScale = 0.1

    self.leftBar = createPlayerOneView(playerPhoto)
    self:insert(self.leftBar)
    self.leftBar.x = SCREEN_LEFT - self.leftBar.width*0.5
    self.leftBar.y = -7
    self.leftBar:addEventListener("touch", function() return true end)

    --local trophy = TextureManager.newImage("stru_icontrophy", self)
    --trophy.x = SCREEN_LEFT + trophy.width
    --trophy.y = leftBar.y - leftBar.height*0.35
    self.rightBar = TextureManager.newImage("stru_ranking_red", self)
    self.rightBar.x = SCREEN_RIGHT + self.rightBar.width*0.5 + 1
    self.rightBar.y = -5
    self.rightBar:addEventListener("touch", function() return true end)
end

function BottomRanking:updateRankingPositions(ranking)
    local playerPosition = getPlayerPosition(ranking)
    local player = ranking[playerPosition]
    self.leftBar:setPointsAndPosition(player.score, playerPosition)

    local playersRankingGroup = display.newGroup()
    --playersRankingGroup:setReferencePoint(display.CenterLeftReferencePoint)
    playersRankingGroup.x = self.leftBar.x + self.leftBar.width*0.5 + 24
    playersRankingGroup.y = 6
    for i, _player in ipairs(ranking) do
        local playerView = createPlayerView(_player, i, false)
        playersRankingGroup:insert(playerView)
        playerView.x = (i - 1)*74
        playerView.y = 2
    end
    self:insert(2, playersRankingGroup)
    local rectTouchHandler = display.newRect(playersRankingGroup, 0, 0, playersRankingGroup.width, playersRankingGroup.height)
    rectTouchHandler.x = rectTouchHandler.width*0.5 - 32
    rectTouchHandler.y = 0
    rectTouchHandler.alpha = 0.01
    rectTouchHandler.group = playersRankingGroup
    TouchHandler.setSlideListener(rectTouchHandler, 458)
end

function BottomRanking:new(playerPhoto)
    local bottomRankingGroup = display.newGroup()
    for k, v in pairs(BottomRanking) do
        bottomRankingGroup[k] = v
    end

    bottomRankingGroup:createView(playerPhoto)
    bottomRankingGroup:setReferencePoint(display.CenterReferencePoint)
    bottomRankingGroup.y = SCREEN_BOTTOM - bottomRankingGroup.height*0.5 + 1

    return bottomRankingGroup
end

return BottomRanking