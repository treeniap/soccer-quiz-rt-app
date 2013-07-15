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

local gameInfo = {
    championshipBadge = "pictures/cbf.png",
    championshipName  = "CAMPEONATO BRASILEIRO 2013",
    championshipRound = "5ª RODADA",
    homeTeamScore     = 3,
    homeTeamName      = "CLUBE ATLÉTICO BRAGANTINO",
    awayTeamScore     = 3,
    awayTeamName      = "ASSOCIAÇÃO DESPORTIVA SÃO CAETANO",
    matchMinutes      = 32,
    matchTime         = 2,
}

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

local finalResultInfo = {
    rightGuesses       = {number = 8, points = 7000},
    challengesOvercome = {number = 3, points = 100},
    giftsGiven         = {number = 6, points = 200},
    friendsDefeated    = {number = 9, points = 282},
    couponsEarned      = 100,
    totalCoupons       = 1100,
    championshipName   = "PAULISTA",
    position           = "12345º"
}

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
end

function ScreenManager:callNext()
    currentScreen:onGame()
end

local function showMatch()
    currentScreen:showUp(function()
        currentScreen:onGame(gameInfo)
        unlockScreen()
    end)
end

local function prepareMatch()
    currentScreen = require("scripts.screens.in_game")
    currentScreen:new()

    gameInfo.homeTeamScore = MatchManager:getTeamScore(true)
    gameInfo.awayTeamScore = MatchManager:getTeamScore(false)
    gameInfo.homeTeamName = string.utf8upper(MatchManager:getTeamName(MatchManager:getTeamId(true)))
    gameInfo.awayTeamName = string.utf8upper(MatchManager:getTeamName(MatchManager:getTeamId(false)))
    MatchManager:downloadTeamsLogos({sizes = {1, 2, 3}, listener = showMatch})
end

local function getBetTimeoutInMilliseconds(userBetTimeout)
    --TODO usar lua date
    local timeoutInSec = dateTimeStringToSeconds(userBetTimeout) + getTimezoneOffset(os.time())
    return timeoutInSec
end

local function matchServerListener(message)
    --printTable(message)
    local _eventInfo = eventsInfo[message.template.key]
    _eventInfo.alternatives = message.template.alternatives

    _eventInfo.teamName = string.utf8upper(MatchManager:getTeamName(message.team_id))
    _eventInfo.teamBadge = getLogoFileName(message.team_id, 3)
    _eventInfo.userBetTimeout = getBetTimeoutInMilliseconds(message.user_bet_timeout)
    currentScreen:onEventStart(_eventInfo)
end

function ScreenManager:enterMatch(channel)
    Server.pubnubSubscribe(channel, matchServerListener)
    Server.pubnubSubscribe(UserData.info.user_id, require("scripts.screens.in_game_event").betResultListener) --TODO usar id do usuario
    currentScreen:hide(prepareMatch)
    lockScreen()
end

function ScreenManager:init()
    if not tutorial then
        MatchManager:requestMatches(function()
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
        {name = "Bragantino", badge = "pictures/clubes_bragantino.png"},
        {name = "Corinthians", badge = "pictures/clubes_corinthians.png"},
        {name = "Palmeiras", badge = "pictures/clubes_palmeiras.png"},
        {name = "Portuguesa", badge = "pictures/clubes_portuguesa.png"},
        {name = "Santos", badge = "pictures/clubes_santos.png"},
        {name = "São Caetano", badge = "pictures/clubes_scaetano.png"},
        {name = "São Paulo", badge = "pictures/clubes_spaulo.png"},
        {name = "Criciuma", badge = "pictures/criciuma_esporte_clube.png"},
        {name = "Vitória", badge = "pictures/ec_vitoria.png"},
        {name = "Fluminense", badge = "pictures/fluminense_fc.png"},
        {name = "Salgueiro", badge = "pictures/salgueiro_atletico_clube.png"},
        {name = "Internacional", badge = "pictures/sc_internacional.png"},
    }
    require "scripts.screens.tutorial"
    TutorialScreen:new(teamsList)
    tutorial = true
end

return ScreenManager