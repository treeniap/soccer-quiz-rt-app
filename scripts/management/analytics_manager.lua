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
    local matches = MatchManager:getNextSevenMatches()
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

function AnalyticsManager.enteredHomeScreen()
    analytics.logEvent("Screen:Home", {
        ChosenTeam     = MatchManager:getTeamName(UserData.attributes.favorite_team_id),
        CoinsInStash   = UserData.inventory.coins,
        SessionCounter = UserData.session,
        PlayNowNumber  = numberOfPlayNow()
    })
end

----//////////////////////////////
---/////-- Screen:Ranking --/////
--//////////////////////////////
function AnalyticsManager.enteredRankingScreen()
    analytics.logEvent("Screen:Ranking", {
        ChosenTeam      = MatchManager:getTeamName(UserData.attributes.favorite_team_id),
        NumberOfFriends = #UserData.info.friendsIds,
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

function AnalyticsManager.enteredInGameScreen()
    local enteredMatchId = MatchManager:getMatchId()
    if matchEnteredCounter[enteredMatchId] then
        matchEnteredCounter[enteredMatchId] = matchEnteredCounter[enteredMatchId] + 1
    else
        matchEnteredCounter[enteredMatchId] = 1
    end
    analytics.logEvent("Screen:InGame", {
        SessionCounter  = UserData.session,
        NumberOfFriends = #UserData.info.friendsIds,
        SameGameCounter = matchEnteredCounter[enteredMatchId]
    })
end

----/////////////////////////////
---////-- Screen:Tutorial --////
--/////////////////////////////
function AnalyticsManager.enteredTutorialScreen()
    analytics.logEvent("Screen:Tutorial")
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

----/////////////////////////////
---//////-- Monetization --/////
--/////////////////////////////
function AnalyticsManager.clickedMoreCoins(_screen)
    analytics.logEvent("MoreCoins", {Screen = _screen})
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
function AnalyticsManager.question(_result, _betValue, _answer)
    analytics.logEvent("Question", {
        Result   = _result,
        BetValue = _betValue,
        Answer   = _answer
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
    local chosenTeam = "none"
    if UserData.attributes and UserData.attributes.favorite_team_id then
        chosenTeam = MatchManager:getTeamName(UserData.attributes.favorite_team_id)
    end
    analytics.logEvent("TutorialCompletion", {
        FacebookWritePermission = facebookWritePermission,
        ChosenTeam              = chosenTeam
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

----/////////////////////////////
---//////-- Conectivity --//////
--/////////////////////////////
function AnalyticsManager.eventToDisplay(_timeInSeconds, MIN_USER_BET_TIME)
    local connectionType = Server.connectionName
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
    analytics.logEvent(eventName, {ConnectionType = Server.connectionName})
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
    --TODO test analytics
    if IS_SIMULATOR then
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