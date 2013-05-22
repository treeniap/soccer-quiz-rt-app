--[[==============
== We Love Quiz
== Date: 13/05/13
== Time: 15:49
==============]]--
require "scripts.widgets.controller.button_press_release"
require "scripts.widgets.controller.button_touch_handler"
require "scripts.widgets.view.top_bar"

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

local eventInfo = {
    eventName = "ESCANTEIO!",
    teamBadge = "pictures/clubes_bragantino.png",
    teamName  = "LINGUIÇA MECÂNICA"
}
--resultInfo.type, resultInfo.betCoins, resultInfo.valueMult, resultInfo.friend
local resultInfo = {
    type        = "clear",
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

    currentScreen:showUp(function() currentScreen:onGame(gameInfo) end)
    timer.performWithDelay(3000, function()
        currentScreen:onGameOver(finalResultInfo)
    end)
end

return ScreenManager
