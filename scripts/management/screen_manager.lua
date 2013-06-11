--[[==============
== We Love Quiz
== Date: 13/05/13
== Time: 15:49
==============]]--
require "scripts.widgets.controller.button_press_release"
require "scripts.widgets.controller.button_touch_handler"
require "scripts.widgets.view.top_bar"
require "util.utf8"

ScreenManager = {}

local bg = TextureManager.newSpriteRect("stru_bg01", 360, 570) --1520 x 2280
bg.x = display.contentCenterX
bg.y = display.contentCenterY

local currentScreen

local gameInfo = {
    championshipBadge = "pictures/fpf.png",
    championshipName  = "CAMPEONATO PAULISTA",
    championshipRound = "15ª RODADA",
    homeTeamBadge     = "pictures/clubes_bragantino.png",
    homeTeamScore     = 3,
    homeTeamName      = "CLUBE ATLÉTICO BRAGANTINO",
    awayTeamBadge     = "pictures/clubes_scaetano.png",
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
        eventName = "PÊNALTI!",
        teamBadge = "pictures/clubes_bragantino.png",
    },
    foul = {
        eventName = "FALTA!",
        teamBadge = "pictures/clubes_scaetano.png",
    },
    corner_kick = {
        eventName = "ESCANTEIO!",
        teamBadge = "pictures/clubes_bragantino.png",
    },
}
--resultInfo.type, resultInfo.betCoins, resultInfo.valueMult, resultInfo.friend
local resultInfo = {
    type        = "cleared",
    resultTitle = "AFAAAAASTA A ZAGA!",
    isRight     = true,
    prize       = 8,
    betCoins    = 4,
    valueMult   = 2,
    friend      = {coins = 3, photo = "pictures/pic_4.png"},
}

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

function ScreenManager:show(screenName)
    currentScreen = require("scripts.screens." .. screenName)
    currentScreen:new()
    currentScreen:showUp()

    --currentScreen:onPreKickOffQuestions(challengeInfo)

    --currentScreen:showUp(function() currentScreen:onGame(gameInfo) end)
    --timer.performWithDelay(5000, function()
    --    currentScreen:onEventStart(eventInfo)
    --    timer.performWithDelay(11000, function()
    --        currentScreen:onEventEnd(resultInfo)
    --        timer.performWithDelay(5000, function()
    --            currentScreen:onGame()
    --        end)
    --    end)
    --end)

    --currentScreen:showUp(function() currentScreen:onGame(gameInfo) end)
    --timer.performWithDelay(3000, function()
    --    currentScreen:onGameOver(finalResultInfo)
    --end)
end

function ScreenManager:callNext()
    currentScreen:onGame()
end

local function showMatch()
    currentScreen = require("scripts.screens.in_game")
    currentScreen:new()

    currentScreen:showUp(function() currentScreen:onGame(gameInfo) end)
end

local function getBetTimeoutInMilliseconds(userBetTimeout)
    local timeoutInSec = dateTimeStringToSeconds(userBetTimeout) + getTimezoneOffset(os.time())
    return (timeoutInSec - os.time())*1000
end

local function matchServerListener(message)
    printTable(message)
    local _eventInfo = eventsInfo[message.template.key]
    _eventInfo.alternatives = message.template.alternatives

    _eventInfo.teamName = string.utf8upper(MatchManager:getTeamName(message.team_id))
    _eventInfo.userBetTimeout = getBetTimeoutInMilliseconds(message.user_bet_timeout)
    currentScreen:onEventStart(_eventInfo)

    timer.performWithDelay(_eventInfo.userBetTimeout + 7000, function()
        currentScreen:onEventEnd(resultInfo)
        --timer.performWithDelay(8000, function()
        --    matchServerListener({key = "corner_kick", alternatives = {goal = {multiplier = 4}, saved = {multiplier = 2}, cleared = {multiplier = 1}, missed = {multiplier = 10} }})
        --end)
    end)
end

function ScreenManager:enterMatch(channel)
    Server.pubnubSubscribe(channel, matchServerListener)
    --timer.performWithDelay(5000, function()
    --    matchServerListener({key = "penalty", alternatives = {goal = {multiplier = 3}, saved = {multiplier = 2}, cleared = {multiplier = 1}, missed = {multiplier = 1} }})
    --end)
    showMatch()
end

return ScreenManager