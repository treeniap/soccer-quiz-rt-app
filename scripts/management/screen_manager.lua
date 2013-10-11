--[[==============
== We Love Quiz
== Date: 13/05/13
== Time: 15:49
==============]]--
require "scripts.widgets.controller.button_press_release"
require "scripts.widgets.controller.button_touch_handler"
require "scripts.widgets.view.top_bar"
require "scripts.widgets.view.top_bar_menu"
require "scripts.widgets.view.bottom_ranking"
require "scripts.widgets.view.goal"
require "util.utf8"

ScreenManager = {}

local mainBackground
local currentScreen
local previousScreen
local answer
local tutorial
local MIN_USER_BET_TIME = 4

local eventsInfo = {
    penalty = {
        title = "PÊNALTI!",
    },
    foul = {
        title = "FALTA!",
    },
    corner_kick = {
        title = "ESCANTEIO!",
    },
}
--resultInfo.type, resultInfo.betCoins, resultInfo.valueMult, resultInfo.friend

local function showScreen(screenName)
    currentScreen = require("scripts.screens." .. screenName)
    display.getCurrentStage():insert(2, currentScreen:new())
    currentScreen:showUp(unlockScreen)
end

function ScreenManager:show(screenName)
    if currentScreen then
        currentScreen:hide(function() showScreen(screenName) end)
        previousScreen = currentScreen
    else
        showScreen(screenName)
    end
    lockScreen()
end

function ScreenManager:hideCurrentScreen(listener)
    if currentScreen then
        currentScreen:hide(function()
            currentScreen = nil
            if listener then
                listener()
            end
        end)
    end
    lockScreen()
end

function ScreenManager:callPrevious()
    if previousScreen then
        currentScreen:hide(function()
            display.getCurrentStage():insert(2, previousScreen:new())
            previousScreen:showUp(unlockScreen)
            currentScreen = previousScreen
            previousScreen = nil
        end)
        lockScreen()
    end
    return true
end

function ScreenManager:callNext()
    if not currentScreen:callNext() then
        ScreenManager:exitMatch()
    end
end

local function showMatch()
    local error, result = pcall(function()
        currentScreen:showUp(function()
            currentScreen:onGame()
            unlockScreen()
        end)
    end)
    --print(result)
    if not error then
        currentScreen = nil
        ScreenManager:show("initial")
    end
end

local function prepareMatch()
    local error, result = pcall(function()
        currentScreen = require("scripts.screens.in_game")
        display.getCurrentStage():insert(2, currentScreen:new())
        Server:downloadTeamsLogos({sizes = {1, 2, 3}, listener = showMatch})
    end)
    --print(result)
    if not error then
        currentScreen = nil
        ScreenManager:show("initial")
    end
end

local function matchServerListener(message)
    --printTable(message)
    if message.state and message.state == "cancelled" then
        timer.performWithDelay(2000, ScreenManager.callNext)
        InGameScreen:updateTotalCoins()
        native.showAlert("", "O evento que estavamos aguardando foi cancelado e suas fichas apostadas foram devolvidas.", { "Ok" })
        return
    end
    local _eventInfo = eventsInfo[message.template.key]
    _eventInfo.key = message.template.key
    _eventInfo.alternatives = message.template.alternatives

    _eventInfo.teamName = string.utf8upper(MatchManager:getTeamName(message.team_id))
    _eventInfo.teamBadge = getLogoFileName(message.team_id, 3)
    _eventInfo.userBetTimeout = date(message.user_bet_timeout):tolocal()
    local secondsToEvent = date.diff(_eventInfo.userBetTimeout, date(os.date("*t"))):spanseconds()

    if secondsToEvent >= MIN_USER_BET_TIME then
        currentScreen:onEventStart(_eventInfo)
    end
    AnalyticsManager.eventToDisplay(secondsToEvent, MIN_USER_BET_TIME)
end

function ScreenManager:updateTotalCoin()
    if currentScreen and currentScreen.updateTotalCoins then
        currentScreen:updateTotalCoins()
    end
end

function ScreenManager:showWebView(link)
    local function listener( event )
        --printTable(event)
        if event.errorCode then
            -- Error loading page
            print( "Error: " .. event.errorCode .. tostring( event.errorMessage ) )
            return false
        end
        return true
    end
    local currentScreenGroup = currentScreen.group
    local webView = native.newWebView(CONTENT_WIDTH,
        display.screenOriginY + (MENU_TITLE_BAR_HEIGHT + display.topStatusBarContentHeight) - 2,
        CONTENT_WIDTH,
        CONTENT_HEIGHT - (MENU_TITLE_BAR_HEIGHT + display.topStatusBarContentHeight) + 2)
    webView:request(link)
    webView:addEventListener("urlRequest", listener)
    webView:setReferencePoint(display.TopLeftReferencePoint)
    local topBar
    topBar = TopBarMenu:new(" ", function()
        if currentScreenGroup then
            transition.to(currentScreenGroup, {time = 500, x = currentScreenGroup.x + CONTENT_WIDTH, transition = easeOutExpo, onComplete = unlockScreen})
        end
        transition.to(webView, {time = 500, x = CONTENT_WIDTH, transition = easeOutExpo, onComplete = function()
            webView:removeEventListener("urlRequest", listener)
            webView:removeSelf()
            webView = nil
        end})
        transition.to(topBar, {time = 500, x = CONTENT_WIDTH, transition = easeOutExpo, onComplete = function()
            topBar:removeSelf()
            topBar = nil
        end})
        lockScreen()

        return true
    end)
    topBar.x = CONTENT_WIDTH
    if currentScreenGroup then
        transition.to(currentScreenGroup, {time = 500, x = currentScreenGroup.x - CONTENT_WIDTH, transition = easeOutExpo, onComplete = unlockScreen})
    end
    transition.to(webView, {time = 500, x = display.screenOriginX, transition = easeOutExpo})
    transition.to(topBar, {time = 500, x = display.screenOriginX, transition = easeOutExpo})
    lockScreen()
end

function ScreenManager.onAppResume()
    if currentScreen and currentScreen.onAppResume then
        currentScreen.onAppResume()
    end
end

function ScreenManager:enterMatch(channel)
    Server.pubnubSubscribe(channel, matchServerListener)
    currentScreen:hide(prepareMatch)
    lockScreen()
    BrightnessManager.onEnterMatch()
end

function ScreenManager:exitMatch()
    Server.pubnubUnsubscribe(MatchManager:getMatchId())
    ScreenManager:show("initial")
    AudioManager.playStopBetAnswerWait()
    MatchManager:onExitMatch()
end

function ScreenManager.init()
    if not tutorial then
        LoadingBall:newStage() --- 5
        MatchManager:init()
        TextureManager.loadMainSheet()
        if not mainBackground then
            mainBackground = TextureManager.newSpriteRect("stru_bg01", 360, 570) --1520 x 2280
            mainBackground.x = display.contentCenterX
            mainBackground.y = display.contentCenterY
            display.getCurrentStage():insert(1, mainBackground)
        end

        ScreenManager:show("initial")
        LoadingBall:dismissScreen()
    end
    tutorial = nil
    -- White Status Bar for iOS7
    local statusBarBg = display.newRect(display.screenOriginX, display.screenOriginY, CONTENT_WIDTH, display.topStatusBarContentHeight)
    statusBarBg:setFillColor(0)
    display.getCurrentStage():insert(3, statusBarBg)
    display.setStatusBar(display.DarkStatusBar)
end

function ScreenManager:startTutorial()
    MatchManager:loadTeamsList(function()
        require "scripts.screens.tutorial"
        TutorialScreen:new()
        tutorial = true
    end)
end

return ScreenManager