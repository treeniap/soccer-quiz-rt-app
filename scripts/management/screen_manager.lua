--[[==============
== We Love Quiz
== Date: 13/05/13
== Time: 15:49
==============]]--
require "scripts.widgets.controller.button_press_release"
require "scripts.widgets.controller.button_touch_handler"
require "scripts.widgets.view.top_bar"
require "scripts.widgets.view.bottom_ranking"
require "util.utf8"

ScreenManager = {}

local currentScreen
local previousScreen
local answer
local tutorial

local challengeInfo = {
    name = "DESAFIO DO PRÉ-JOGO",
    matchTime = {hour = 19, min = 15, sec = 0},
    questions = {
        "Marcelo Caramelo receberá i cartão amarelo na partida? o cartão amarelo na partida?",
        "Muricy Ramalho fará substituições no itervalo?",
        "Ademar fará algum gol no segundo tempo da partida?",
        "Bragantines fará gol no primeiro tempo?",
    }
}

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
    currentScreen:showUp(function()
        currentScreen:onGame()
        unlockScreen()
    end)
end

local function prepareMatch()
    currentScreen = require("scripts.screens.in_game")
    currentScreen:new()
    MatchManager:downloadTeamsLogos({sizes = {1, 2, 3}, listener = showMatch})
end

local function getBetTimeoutInMilliseconds(userBetTimeout)
    --TODO usar lua date
    local timeoutInSec = dateTimeStringToSeconds(userBetTimeout) + getTimezoneOffset(os.time())
    return timeoutInSec
end

local function matchServerListener(message)
    --printTable(message)
    if message.state and message.state == "cancelled" then
        timer.performWithDelay(2000, ScreenManager.callNext)
        InGameScreen:updateTotalCoins()
        return
    end
    local _eventInfo = eventsInfo[message.template.key]
    _eventInfo.alternatives = message.template.alternatives

    _eventInfo.teamName = string.utf8upper(MatchManager:getTeamName(message.team_id))
    _eventInfo.teamBadge = getLogoFileName(message.team_id, 3)
    _eventInfo.userBetTimeout = getBetTimeoutInMilliseconds(message.user_bet_timeout)
    currentScreen:onEventStart(_eventInfo)
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
    Server.pubnubSubscribe(UserData.info.user_id, require("scripts.screens.in_game_event").betResultListener)
    currentScreen:hide(prepareMatch)
    lockScreen()
end

function ScreenManager:exitMatch()
    Server.pubnubUnsubscribe(MatchManager:getMatchId())
    ScreenManager:show("initial")
end

function ScreenManager:init()
    if not tutorial then
        MatchManager:init(function()
            TextureManager.loadMainSheet()
            local bg = TextureManager.newSpriteRect("stru_bg01", 360, 570) --1520 x 2280
            bg.x = display.contentCenterX
            bg.y = display.contentCenterY
            display.getCurrentStage():insert(1, bg)

            ScreenManager:show("initial")
            LoadingBall:dismissScreen()
        end)
    end
    tutorial = nil
end

function ScreenManager:startTutorial()
    --TODO download logos
    local teamsList = {
        {name = "Botafogo",      badge = "pictures/botafogo_fr.png"},
        {name = "Corinthians",   badge = "pictures/sc_corinthians_paulista.png"},
        {name = "Cruzeiro",      badge = "pictures/cruzeiro_ec.png"},
        {name = "Atlético-MG",   badge = "pictures/ca_mineiro.png"},
        {name = "Santos",        badge = "pictures/santos_fc.png"},
        {name = "Coritiba",      badge = "pictures/coritiba_fc.png"},
        {name = "São Paulo",     badge = "pictures/sao_paulo_fc.png"},
        {name = "Flamengo",      badge = "pictures/cr_flamengo.png"},
        {name = "Vasco",         badge = "pictures/cr_vasco_g.png"},
        {name = "Fluminense",    badge = "pictures/fluminense_fc.png"},
        {name = "Grêmio",        badge = "pictures/gremio_fbpa.png"},
        {name = "Internacional", badge = "pictures/sc_internacional.png"},
    }
    require "scripts.screens.tutorial"
    TutorialScreen:new(teamsList)
    tutorial = true
end

return ScreenManager