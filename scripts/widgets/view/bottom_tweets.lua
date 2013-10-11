--[[==============
== We Love Quiz
== Date: 10/10/13
== Time: 11:21
==============]]--
BottomTweets = {}

local UPDATE_TIME = 3*60*1000
local function createTweetsBar(bottomTweets)
    local screenName = MatchManager:getUserTeamTwitter()
    if not screenName then
        return
    end
    local tweetsGroup = display.newGroup()
    tweetsGroup.x = 130 + (-display.screenOriginX)
    tweetsGroup.y = 8
    bottomTweets.replyAccount = screenName

    local function checkTwitter()
        local postCallback = function( status, result )
            if not tweetsGroup or not tweetsGroup.insert then
                return
            end
            local response = require("json").decode( result )
            --printTable(response)
            for i, v in ipairs(response) do
                if v.id_str == tweetsGroup.last_id_str then
                    break
                end
                local txt = display.newText("@" .. screenName .. ": " .. fixhtml(v.text), 0, 0, 215 + (display.screenOriginX*-2), 0, "MyriadPro-Cond", 13)
                txt.x = 0
                if txt.height > 79 then
                    txt.y = (txt.height - 79)*0.5
                else
                    txt.y = 0
                end
                txt:setTextColor(0)
                if tweetsGroup.txt then
                    tweetsGroup.txt:removeSelf()
                end
                tweetsGroup:insert(txt)
                tweetsGroup.txt = txt
                bottomTweets.tweet = txt.text

                if tweetsGroup.last_id_str and not bottomTweets.isOpened then
                    bottomTweets.touch(bottomTweets, {phase = "ended"})
                    timer.performWithDelay(8000, function()
                        if bottomTweets.isOpened then
                            bottomTweets.touch(bottomTweets, {phase = "ended"})
                        end
                    end)
                end
                tweetsGroup.last_id_str = v.id_str
            end
            timer.performWithDelay(UPDATE_TIME, checkTwitter)
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
                value = "1"
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
    end
    checkTwitter()

    return tweetsGroup
end

local function createReplyBtn(bottomTweets)
    local BtnReply = {}

    function BtnReply:createView()
        self.default = TextureManager.newImage("bt_reply", self)
        self.default.x = 0
        self.default.y = 0
        self.over = display.newRect(self, 0, 0, 50, 40)
        self.over.x = 0
        self.over.y = 0
        self.over:setFillColor(255, 32)
        self.over.blendMode = "add"
        self.over.isVisible = false
        self.touchHandler = display.newRect(self, 0, 0, 50, 40)
        self.touchHandler.x = 0
        self.touchHandler.y = 0
        self.touchHandler:setFillColor(255, 1)
    end

    return PressRelease:new(BtnReply, function()
        local twitter
        local function post()
            twitter:showPopup("@" .. bottomTweets.replyAccount, "@chutepremiado")
        end
        local listener = function( event )
            if event.phase == "authorised" then
                post()
            else
                AnalyticsManager.postTwitter("RepliedOnTwitter")
                --native.showAlert("Twitter", "Pontuação postada.", {"Ok"})
            end
        end
        twitter = TwitterObject
        twitter.listener = listener
        if twitter:isAuthorised() then
            post()
        else
            twitter:authorise()
        end
        return true
    end)
end

local function createRetweetBtn(bottomTweets)
    local BtnRetweet = {}

    function BtnRetweet:createView()
        self.default = TextureManager.newImage("bt_retweet", self)
        self.default.x = 0
        self.default.y = 0
        self.over = display.newRect(self, 0, 0, 50, 40)
        self.over.x = 0
        self.over.y = 0
        self.over:setFillColor(255, 32)
        self.over.blendMode = "add"
        self.over.isVisible = false
        self.touchHandler = display.newRect(self, 0, 0, 50, 40)
        self.touchHandler.x = 0
        self.touchHandler.y = 0
        self.touchHandler:setFillColor(255, 1)
    end

    return PressRelease:new(BtnRetweet, function()
        local twitter
        local function post()
            local retweetedPost = bottomTweets.tweet
            if bottomTweets.tweet:len() > 140 then
                retweetedPost = bottomTweets.tweet:sub(1, 137)
                retweetedPost = retweetedPost .. "..."
            end
            twitter:showPopup(retweetedPost)
        end
        local listener = function( event )
            if event.phase == "authorised" then
                post()
            else
                AnalyticsManager.postTwitter("RetweetedOnTwitter")
                --native.showAlert("Twitter", "Pontuação postada.", {"Ok"})
            end
        end
        twitter = TwitterObject
        twitter.listener = listener
        if twitter:isAuthorised() then
            post()
        else
            twitter:authorise()
        end
        return true
    end)
end

function BottomTweets:open()
    self.arrow.xScale = 1
    self.arrow.x = -2
    transition.to(self, {time = 300, x = SCREEN_LEFT + 2, transition = easeInCirc})
end

function BottomTweets:close()
    self.arrow.xScale = -1
    self.arrow.x = -6
    transition.to(self, {time = 300, x = self.xDest, transition = easeOutCirc})
end

function BottomTweets:createView(isInitialScreen)
    local bg = TextureManager.newImageRect("images/stretchable/stru_ranking_silver.png", CONTENT_WIDTH, 86, self)
    bg.x = bg.width*0.5
    bg.y = 5

    self.tweets = createTweetsBar(self)
    if self.tweets then
        self:insert(2, self.tweets)
    end

    local opener = TextureManager.newImage("bt_red_twitter", self)
    opener.x = 0
    opener.y = 0

    self.arrow = TextureManager.newImage("bt_seta", self)
    self.arrow.xScale = -1
    self.arrow.x = -6
    self.arrow.y = 8

    local lineBlack, lineWhite = TextureManager.newVerticalLine(bg.width*0.75 + (display.screenOriginX*-.5), 7, 70)
    self:insert(lineBlack)
    self:insert(lineWhite)

    local replyBtn = createReplyBtn(self)
    replyBtn.x = lineBlack.x + replyBtn.width*0.5
    replyBtn.y = lineBlack.y - replyBtn.height*0.5
    self:insert(replyBtn)
    local retweetBtn = createRetweetBtn(self)
    retweetBtn.x = lineBlack.x + retweetBtn.width*0.5
    retweetBtn.y = lineBlack.y + retweetBtn.height*0.5
    self:insert(retweetBtn)
end

function BottomTweets:new()
    local bottomTweetsGroup = display.newGroup()
    for k, v in pairs(BottomTweets) do
        bottomTweetsGroup[k] = v
    end

    bottomTweetsGroup:createView()
    bottomTweetsGroup:setReferencePoint(display.CenterLeftReferencePoint)

    return bottomTweetsGroup
end

return BottomTweets