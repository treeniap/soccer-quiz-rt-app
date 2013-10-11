--[[==============
== We Love Quiz
== Date: 13/08/13
== Time: 12:33
==============]]--
AnalyticsManager = {}

----///////////////////////////////
---///////-- Screen:Home --///////
--///////////////////////////////
local function numberOfPlayNow()
    local matches = MatchManager:getNextEightMatches()
    local currentDate = getCurrentDate()
    local num = 0
    for i, match in pairs(matches) do
        local c = date.diff(currentDate, match.starts_at)
        local minutesToMatch = c:spanminutes()
        if minutesToMatch >= -5 then
            num = num + 1
        end
    end
    return num
end

local function checkMatchManager(_listener)
    if not MatchManager.initialized then
        MatchManager:addListener(_listener)
        return false
    end
    return true
end

function AnalyticsManager.enteredHomeScreen()
    if not checkMatchManager(AnalyticsManager.enteredHomeScreen) then
        return
    end
    analytics.logEvent("Screen:Home", {
        ChosenTeam     = MatchManager:getTeamName(UserData.attributes.favorite_team_id),
        CoinsInStash   = UserData.inventory.coins,
        SessionCounter = UserData.session,
        DemoModeOn     = UserData.demoModeOn and "true" or "false",
        PlayNowNumber  = numberOfPlayNow()
    })
end

----//////////////////////////////
---/////-- Screen:Ranking --/////
--//////////////////////////////
function AnalyticsManager.enteredRankingScreen()
    if not checkMatchManager(AnalyticsManager.enteredRankingScreen) then
        return
    end
    local numFriends = -1
    if UserData.info and UserData.info.friendsIds then
        numFriends = #UserData.info.friendsIds
    end
    analytics.logEvent("Screen:Ranking", {
        ChosenTeam      = MatchManager:getTeamName(UserData.attributes.favorite_team_id),
        NumberOfFriends = numFriends,
        SessionCounter  = UserData.session
    })
end

----//////////////////////////////
---/////-- Screen:Options --/////
--//////////////////////////////
function AnalyticsManager.OpenedSideMenu()
    analytics.logEvent("Screen:Options", {SessionCounter  = UserData.session})
end

----/////////////////////////////
---/////-- Screen:InGame --/////
--/////////////////////////////
local matchEnteredCounter = {}
local fromScreen = ""

function AnalyticsManager.setFromScreen(screenName)
    fromScreen = screenName
end

function AnalyticsManager.enteredInGameScreen()
    local enteredMatchId = MatchManager:getMatchId()
    if matchEnteredCounter[enteredMatchId] then
        matchEnteredCounter[enteredMatchId] = matchEnteredCounter[enteredMatchId] + 1
    else
        matchEnteredCounter[enteredMatchId] = 1
    end
    local numFriends = -1
    if UserData.info and UserData.info.friendsIds then
        numFriends = #UserData.info.friendsIds
    end
    analytics.logEvent("Screen:InGame", {
        SessionCounter  = UserData.session,
        NumberOfFriends = numFriends,
        SameGameCounter = matchEnteredCounter[enteredMatchId],
        From = fromScreen
    })
end

function AnalyticsManager.enteredInGameForStats()
    analytics.logEvent("EnteredInGameForStats")
end

----/////////////////////////////
---////-- Screen:Tutorial --////
--/////////////////////////////
function AnalyticsManager.enteredTutorialScreen()
    analytics.logEvent("Screen:Tutorial")
end

function AnalyticsManager.chosenMode(demoMode)
    analytics.logEvent("TutorialChosenMode", {Mode = demoMode and "Demo" or "Logged"})
end

----/////////////////////////////
---///-- Screen:ChooseMatch --//
--/////////////////////////////
function AnalyticsManager.enteredSelectMatchScreen()
    analytics.logEvent("Screen:ChooseMatch", {
        SessionCounter = UserData.session,
        PlayNowNumber  = numberOfPlayNow()
    })
end

----/////////////////////////
---///-- Screen:Tables --///
--/////////////////////////
function AnalyticsManager.enteredTablesScreen()
    analytics.logEvent("Screen:Tables", {
        SessionCounter = UserData.session
    })
end

----/////////////////////////
---///-- Screen:Videos --///
--/////////////////////////
function AnalyticsManager.enteredVideosScreen()
    analytics.logEvent("Screen:Videos", {
        SessionCounter = UserData.session
    })
end

function AnalyticsManager.watchedAVideo()
    analytics.logEvent("WatchedAVideo")
end

function AnalyticsManager.touchedAVideo()
    analytics.logEvent("TouchedAVideo")
end

----/////////////////////////////
---//////-- Monetization --/////
--/////////////////////////////
function AnalyticsManager.clickedMoreCoins(_screen)
    analytics.logEvent("MoreCoins", {
        SessionCounter = UserData.session,
        Screen = _screen
    })
end

local hasBetEverything
function AnalyticsManager.emptyCoins(_hasBetEverything, _lostItAll)
    if not hasBetEverything and _hasBetEverything then
        hasBetEverything = _hasBetEverything
    elseif hasBetEverything then
        analytics.logEvent("EmptyCoins", {LostItAll = tostring(_lostItAll)})
        hasBetEverything = false
    end
end

function AnalyticsManager.offerCoins()
    analytics.logEvent("OfferCoins")
end

----/////////////////////////////
---////////-- Settings --///////
--/////////////////////////////
function AnalyticsManager.clickedAudioSetting(eventName)
    analytics.logEvent(eventName)
end

function AnalyticsManager.clickedUsefulLink(paramName)
    analytics.logEvent("UsefulLink", {LinkName = paramName})
end

----/////////////////////////////
---//-- Actions in the Game --//
--/////////////////////////////
local eventTimeInSeconds
function AnalyticsManager.question(type, _result, _betValue, _answer)
    analytics.logEvent(type .. "Question", {
        Result   = _result,
        BetValue = _betValue,
        Answer   = _answer,
        TimeInSeconds = eventTimeInSeconds or 0
    })
end

local periods = {
    first_half = "SawStartMatch",
    half_time = "SawEndOf1stHalf",
    second_half = "SawStartOf2ndHalf",
    match_over = "SawEndOfMatch"
}

function AnalyticsManager.changedGamePeriod(period)
    if periods[period] then
        analytics.logEvent(periods[period])
    end
end

function AnalyticsManager.selectedInGameScreen(_screenName)
    analytics.logEvent("SelectInGameScreen", {ScreenName = _screenName})
end

----/////////////////////////////
---///////-- Engagement --//////
--/////////////////////////////
local facebookWritePermission = "false"
local tutorialScreenSaw = {true, false, false, false, false}

function AnalyticsManager.changeTutorialScreen(_tutorialScreen)
    if _tutorialScreen and not tutorialScreenSaw[_tutorialScreen] then
        tutorialScreenSaw[_tutorialScreen] = true
        analytics.logEvent("TutorialScreen" .. _tutorialScreen)
    end
end

function AnalyticsManager.acceptedFacebookWritePermission()
    facebookWritePermission = "true"
end

function AnalyticsManager.finishedTutorial()
    if not checkMatchManager(AnalyticsManager.finishedTutorial) then
        return
    end
    local chosenTeam = "none"
    if UserData.attributes and UserData.attributes.favorite_team_id then
        chosenTeam = MatchManager:getTeamName(UserData.attributes.favorite_team_id)
    end
    analytics.logEvent("TutorialCompletion", {
        FacebookWritePermission = facebookWritePermission,
        ChosenTeam              = chosenTeam
    })
end

function AnalyticsManager.rating(_rateClick)
    analytics.logEvent("Rating", {
        SessionCounter   = UserData.session,
        TentativeCounter = UserData.rating,
        RateClick        = tostring(_rateClick)
    })
end

----/////////////////////////////
---//////-- Sociability --//////
--/////////////////////////////
function AnalyticsManager.inviteFriends(_inviteFriendsClick, _numberOfFriends)
    analytics.logEvent("InviteFriendsClick", {
        InviteFriendsClick = _inviteFriendsClick,
        NumberOfFriends    = _numberOfFriends
    })
end

function AnalyticsManager.post(eventName)
    analytics.logEvent(eventName)
end

function AnalyticsManager.postFacebook(eventName)
    analytics.logEvent("PostFacebook", {
        Type           = eventName,
        SessionCounter = UserData.session,
        ChosenTeam     = MatchManager:getTeamName(UserData.attributes.favorite_team_id)
    })
end

function AnalyticsManager.postTwitter(eventName)
    analytics.logEvent("PostTwitter", {
        Type           = eventName,
        SessionCounter = UserData.session,
        ChosenTeam     = MatchManager:getTeamName(UserData.attributes.favorite_team_id)
    })
end

function AnalyticsManager.TweetLinkClick()
    analytics.logEvent("TweetLinkClick", {
        SessionCounter = UserData.session,
        ChosenTeam     = MatchManager:getTeamName(UserData.attributes.favorite_team_id)
    })
end

----/////////////////////////////
---//////-- Conectivity --//////
--/////////////////////////////
function AnalyticsManager.eventToDisplay(_timeInSeconds, MIN_USER_BET_TIME)
    local connectionType = Server.connectionName
    eventTimeInSeconds = _timeInSeconds
    if _timeInSeconds < 0 then
        analytics.logEvent("EventNotDisplayedAppSuspended", {
            ConnectionType = connectionType
        })
    else
        local eventName = "EventDisplayed"
        if _timeInSeconds < 6 then
            eventName = "EventNotDisplayedPoorConnectivity"
        end
        analytics.logEvent(eventName, {
            ConnectionType = connectionType,
            TimeInSeconds = _timeInSeconds
        })
    end
end

function AnalyticsManager.conectivity(eventName)
    if analytics then
        analytics.logEvent(eventName, {ConnectionType = Server.connectionName})
    end
end

function AnalyticsManager.serverError(_requestName)
    analytics.logEvent("ServerError", {
        ConnectionType = Server.connectionName,
        RequestName    = _requestName
    })
end

----//////////////////////////////
---//////////-- Init --//////////
--//////////////////////////////
function AnalyticsManager.init()
    if IS_SIMULATOR then -- test: analytics
        analytics = {
            init = function() end,
            logEvent = function(eventName, params)
                print("ANALYTICS - " .. eventName)
                if params then
                    for k, v in pairs(params) do
                        print("", k, v)
                    end
                end
            end
        }
    else
        analytics = require "analytics"
        analytics.init(Params.flurryId)
    end
end

return AnalyticsManager