--[[==============
== We Love Quiz
== Date: 30/04/13
== Time: 16:49
==============]]--
BottomRanking = {}

require "scripts.widgets.view.top_bar_menu"

local function getPlayerPosition(ranking)
    for i, v in ipairs(ranking) do
        if v.isPlayer then
            return i
        end
    end
end

local function createPlayerView(player, position, isGoldenPlayer)
    local photoSize = isGoldenPlayer and 67 or 57
    local badgeSize = 24
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

    if player.photo then
        local noError, photo = pcall(TextureManager.newImageRect, player.photo, photoSize, photoSize, playerGroup, system.DocumentsDirectory)
        if noError and photo then
            photo.x = -0.5
            photo.y = -0.5
        end
    end

    local score = display.newText(playerGroup, player.score .. " Pts", 0, 0, "MyriadPro-BoldCond", 16)
    score:setReferencePoint(display.BottomRightReferencePoint)
    score.x = notch.x + notch.width*0.5
    score.y = notch.y - notch.height*0.5 + 4
    score:setTextColor(0)

    if isGoldenPlayer then
        local positionStru = TextureManager.newImage("stru_position", playerGroup)
        positionStru.x = notch.x + notch.width*0.5 - positionStru.width*0.5
        positionStru.y = notch.y + notch.height*0.5 - positionStru.height*0.5
        local positionTxt = display.newText(playerGroup, position .. "°", 0, 0, "MyriadPro-BoldCond", 16)
        positionTxt.x = positionStru.x + 3
        positionTxt.y = positionStru.y + 3
        positionTxt:setTextColor(0)
    else
        local function createBadge()
            if not playerGroup or not playerGroup.insert then
                return
            end
            if not player.teamBadge then
                timer.performWithDelay(500, createBadge)
            elseif player.teamBadge ~= "none" then
                local noError, badge = pcall(TextureManager.newImageRect, player.teamBadge, badgeSize, badgeSize, playerGroup, system.DocumentsDirectory)
                if noError and badge then
                    badge.x = notch.x + notch.width*0.5 - badgeSize*0.5
                    badge.y = notch.y + notch.height*0.5 - badgeSize*0.5
                end
            end
        end
        createBadge()
    end
    return playerGroup
end

local function createInviteFriends()
    local photoSize = 57
    local badgeSize = 16
    local playerGroup = display.newGroup()

    local notch = TextureManager.newImage("stru_notchsilver", playerGroup)
    notch.x = 0
    notch.y = 0
    local photo = TextureManager.newSpriteRect("stru_buttoninvite", photoSize, photoSize, playerGroup)
    photo.x = -0.5
    photo.y = -0.5

    local inviteTxt = display.newText(playerGroup, "CONVIDE AMIGOS", 0, 0, "MyriadPro-BoldCond", 10)
    inviteTxt:setReferencePoint(display.BottomRightReferencePoint)
    inviteTxt.x = notch.x + notch.width*0.5 + 1
    inviteTxt.y = notch.y - notch.height*0.5 - 1
    inviteTxt:setTextColor(0)

    playerGroup.onRelease = function()
        local status = MatchManager:getMatchTimeStatus()
        if status == "AQUECIMENTO" then
            status = "Vai começar "
        else
            status = "Começou "
        end
        Facebook:invite(status .. MatchManager:getTeamName(true) .. " x " ..
                MatchManager:getTeamName(false) ..
                ", venha jogar comigo!")
    end

    return playerGroup
end

local function createPlayerOneView(playerPhoto, isInitialScreen)
    local PHOTO_SIZE = 67

    local playerGroup = display.newGroup()

    local bg = TextureManager.newImage("stru_ranking_gold", playerGroup)
    bg.x = 0
    bg.y = 0

    local notch = TextureManager.newImage("stru_notchgolden", playerGroup)
    notch.x = -12
    notch.y = 9

    if playerPhoto then
        local noError, photo = pcall(TextureManager.newImageRect, playerPhoto, PHOTO_SIZE, PHOTO_SIZE, playerGroup, system.DocumentsDirectory)
        if noError and photo then
            photo.x = notch.x - 0.5
            photo.y = notch.y - 0.5
        end
    end

    if not isInitialScreen then
        local score = display.newText(playerGroup, " ", 0, 0, "MyriadPro-BoldCond", 16)
        score:setReferencePoint(display.CenterRightReferencePoint)
        score.x = notch.x + notch.width*0.5
        score.y = notch.y - notch.height*0.5 - 8
        score:setTextColor(0)

        local positionStru = TextureManager.newImage("stru_position", playerGroup)
        positionStru.x = notch.x + notch.width*0.5 - positionStru.width*0.5 + 2
        positionStru.y = notch.y + notch.height*0.5 - positionStru.height*0.5 + 2

        local positionTxt = display.newText(playerGroup, " ", 0, 0, "MyriadPro-BoldCond", 16)
        positionTxt.x = positionStru.x + 3
        positionTxt.y = positionStru.y + 3
        positionTxt:setTextColor(0)

        function playerGroup:setPointsAndPosition(pts, pos)
            score.text = pts .. " Pts"
            score:setReferencePoint(display.CenterRightReferencePoint)
            score.x = notch.x + notch.width*0.5
            score.y = notch.y - notch.height*0.5 - 6
            positionTxt.text = pos .. "°"
            positionTxt:setReferencePoint(display.CenterReferencePoint)
            positionTxt.x = positionStru.x + 3
            positionTxt.y = positionStru.y + 3
        end
    end

    return playerGroup
end

local function createTweetsBar()
    local screenName = MatchManager:getUserTeamTwitter()
    if not screenName then
        return
    end
    local tweetsGroup = display.newGroup()
    tweetsGroup.x = display.contentCenterX + 43 - (display.screenOriginX*-0.5)
    tweetsGroup.y = 5

    local tweetMask = graphics.newMask("images/tweets_bar_mask.png")
    tweetsGroup:setMask(tweetMask)

    local function onTweetsTouch(self, event)
        if event.phase == "began" then
            display.getCurrentStage():setFocus(self)
            self.isFocus = true
            if tweetsGroup.links[tweetsGroup.showing] then
                AudioManager.playAudio("onOffBtn")
            end
        elseif self.isFocus and (event.phase == "ended" or event.phase == "cancelled") then
            display.getCurrentStage():setFocus(nil)
            if tweetsGroup.links[tweetsGroup.showing] then
                ScreenManager:showWebView(tweetsGroup.links[tweetsGroup.showing])
                AnalyticsManager.TweetLinkClick()
            end
        end
        return true
    end
    tweetsGroup.touch = onTweetsTouch
    tweetsGroup:addEventListener("touch", tweetsGroup)

    local postCallback = function( status, result )
        local response = require("json").decode( result )
        tweetsGroup.links = {}
        for i, v in ipairs(response) do
            --print("--" .. fixhtml(v.text))
            --printTable(v)
            local txt = display.newText("@" .. screenName .. ": " .. fixhtml(v.text), 0, 0, 200 + (-display.screenOriginX), 0, "MyriadPro-BoldCond", 14)
            txt.x = (i - 1)*CONTENT_WIDTH
            txt.y = 0
            txt:setTextColor(32)
            tweetsGroup:insert(txt)

            local linkStart, linkEnd = findLink(v.text)
            if linkStart and linkEnd then
                tweetsGroup.links[i] = v.text:sub(linkStart, linkEnd)
            else
                tweetsGroup.links[i] = nil
            end
            --return
        end
        tweetsGroup.showing = 0
        local function rollTweets()
            tweetsGroup.showing = tweetsGroup.showing + 1
            if not tweetsGroup.numChildren then
                return
            end
            if tweetsGroup.showing > tweetsGroup.numChildren then
                tweetsGroup.showing = 1
            end
            if tweetsGroup.showing == tweetsGroup.numChildren then
                tweetsGroup.trans = transition.to(tweetsGroup, {delay = 6000, time = 200, x = tweetsGroup.x - CONTENT_WIDTH*0.5, maskX = tweetsGroup.maskX + CONTENT_WIDTH*0.5, onComplete = function()
                    tweetsGroup.x = display.contentCenterX + 43 - (display.screenOriginX*-0.5) + CONTENT_WIDTH*0.5
                    tweetsGroup.maskX = -CONTENT_WIDTH*0.5
                    tweetsGroup.trans = transition.to(tweetsGroup, {time = 300, x = tweetsGroup.x - CONTENT_WIDTH*0.5, maskX = tweetsGroup.maskX + CONTENT_WIDTH*0.5, transition = easeOutExpo, onComplete = rollTweets})
                end})
            else
                tweetsGroup.trans = transition.to(tweetsGroup, {delay = 6000, time = 500, x = tweetsGroup.x - CONTENT_WIDTH, maskX = tweetsGroup.maskX + CONTENT_WIDTH, transition = easeOutExpo, onComplete = rollTweets})
            end
        end
        rollTweets()
    end

    local params = {
        {
            key = 'screen_name',
            value = screenName
        },
        {
            key = 'exclude_replies',
            value = 'true'
        },
        {
            key = 'count',
            value = "5"
        },
        {
            key = 'include_rts',
            value = "true"
        }
    }
    local oAuth = require( "util.oAuth" )
    oAuth.makeRequest( "https://api.twitter.com/1.1/statuses/user_timeline.json", params, "kaO6n7jMhgyNzx9lXhLg",
        "126425377-qJYON7WKPNGymfhsq2qSjUXICb6B1t9VfpGRq8tl",
        "OY0PBfVKizWKfUutKjwh1gt3W99YOmlqbYtgqzg81I",
        "AqSOtqEmlX8lGij0Ci2uynIjjL50uLyRum5lWuEv1o",
        "GET", postCallback )

    return tweetsGroup
end

function BottomRanking:showUp(onComplete)
    transition.to(self.bg, {delay = 300, time = 300, x = display.contentCenterX, xScale = 1, onComplete = onComplete})
    AudioManager.playAudio("showBottomRanking", 500)
    transition.to(self.leftBar, {time = 300, x = SCREEN_LEFT + self.leftBar.width*0.5, transition = easeOutCirc})
    transition.to(self.rightBar, {time = 300, x = SCREEN_RIGHT - self.rightBar.width*0.5 + 1, transition = easeOutCirc})
    AudioManager.playAudio("showBottomRL")
    if self.tweets then
        transition.from(self.tweets, {delay = 600, time = 300, alpha = 0})
    end
end

function BottomRanking:hide(onComplete)
    transition.to(self.bg, {delay = 300, time = 300, x = SCREEN_LEFT - self.bg.width*0.5, xScale = 0.1, onComplete = onComplete})
    transition.to(self.leftBar, {time = 300, x = SCREEN_LEFT - self.leftBar.width*0.5, transition = easeInCirc})
    transition.to(self.rightBar, {time = 300, x = SCREEN_RIGHT + self.rightBar.width*0.5 + 1, transition = easeInCirc})
    if self.ranking then
        transition.to(self.ranking, {delay = 300, time = 300, x = SCREEN_LEFT - self.ranking.width*0.5, xScale = 0.1})
    end
    if self.tweets and self.tweets.trans then
        transition.cancel(self.tweets.trans)
        self.tweets.trans = nil
        transition.to(self.tweets, {time = 300, alpha = 0})
    end
end

function BottomRanking:createView(playerPhoto, isInitialScreen)
    self.bg = TextureManager.newImageRect("images/stru_ranking_silver.png", CONTENT_WIDTH, 86, self)
    self.bg.x = SCREEN_LEFT - self.bg.width*0.5
    self.bg.y = 0
    self.bg.xScale = 0.1

    if isInitialScreen then
        self.tweets = createTweetsBar()
        if self.tweets then
            self:insert(2, self.tweets)
        end
    end

    self.leftBar = createPlayerOneView(playerPhoto, isInitialScreen)
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
    if self.rectTouchHandler then
        self.rectTouchHandler:removeEventListener("touch", self.rectTouchHandler)
    end
    if self.ranking then
        self.ranking:removeSelf()
    end

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

    local inviteBtn = createInviteFriends()
    playersRankingGroup:insert(inviteBtn)
    inviteBtn.x = #ranking*74
    inviteBtn.y = 2

    self:insert(2, playersRankingGroup)
    self.ranking = playersRankingGroup
    if playersRankingGroup.numChildren > 3 then
        local rectTouchHandler = display.newRect(playersRankingGroup, 0, 0, playersRankingGroup.width, playersRankingGroup.height)
        rectTouchHandler.x = rectTouchHandler.width*0.5 - 32
        rectTouchHandler.y = 0
        rectTouchHandler.alpha = 0.01
        rectTouchHandler.group = playersRankingGroup
        TouchHandler.setSlideListener(rectTouchHandler, 458)
        self.rectTouchHandler = rectTouchHandler
    else
        inviteBtn.touch = function(button, event)
            local phase = event.phase
            if "began" == phase then
                -- Subsequent touch events will target button even if they are outside the stageBounds of button
                display.getCurrentStage():setFocus(button)
                button.isFocus = true
            elseif button.isFocus then
                if "ended" == phase or "cancelled" == phase then
                    button.onRelease()
                    -- Allow touch events to be sent normally to the objects they "hit"
                    display.getCurrentStage():setFocus(button, nil)
                    button.isFocus = false
                end
            end
        end
        inviteBtn:addEventListener("touch", inviteBtn)
    end
end

function BottomRanking:new(playerPhoto, isInitialScreen)
    local bottomRankingGroup = display.newGroup()
    for k, v in pairs(BottomRanking) do
        bottomRankingGroup[k] = v
    end

    bottomRankingGroup:createView(playerPhoto, isInitialScreen)
    bottomRankingGroup:setReferencePoint(display.CenterReferencePoint)
    bottomRankingGroup.y = SCREEN_BOTTOM - bottomRankingGroup.height*0.5 + 1

    return bottomRankingGroup
end

function BottomRanking:destroy()
    self.leftBar:removeEventListener("touch", self.leftBar)
    self.rightBar:removeEventListener("touch", self.rightBar)
    if self.rectTouchHandler then
        self.rectTouchHandler:removeEventListener("touch", self.rectTouchHandler)
    end
    self:removeSelf()
end

return BottomRanking