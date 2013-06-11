--[[==============
== We Love Quiz
== Date: 13/05/13
== Time: 12:23
==============]]--
require "scripts.widgets.view.button_hexa_vote"
require "scripts.widgets.view.button_undo_vote"
require "scripts.widgets.view.button_back"
require "scripts.widgets.view.button_facebook"
require "scripts.widgets.view.button_twitter"
require "scripts.widgets.view.chronometer"
require "scripts.widgets.view.bottom_ranking"
require "scripts.widgets.view.questions_bar"
require "scripts.screens.in_game_questions"
require "scripts.screens.in_game_score"
require "scripts.screens.in_game_event"
require "scripts.screens.in_game_end"

InGameScreen = {}

local inGameGroup
local topBar, questionsBar, bottomRanking

local scoreView, eventView, endView

function InGameScreen:onPreKickOffQuestions(challengeInfo)
    questionsBar.isVisible = false
    bottomRanking.isVisible = false

    inGameGroup:insert(1, InGameQuestions:create(challengeInfo))
end

function InGameScreen:onGame(gameInfo)
    display.getCurrentStage():setFocus(nil)
    questionsBar:onGame()
    if not scoreView then
        scoreView = InGameScore:create(gameInfo)
        inGameGroup:insert(1, scoreView)
    end
    if eventView then
        local oldEventView = eventView
        oldEventView:hide(function()
            oldEventView:removeSelf()
            oldEventView = nil
        end)
        eventView = nil
    end
    scoreView:showUp()
end

function InGameScreen:onEventStart(eventInfo)
    display.getCurrentStage():setFocus(nil)
    scoreView:hide()
    local onTimeUp
    if eventView then
        questionsBar:onGame()
        local oldEventView = eventView
        oldEventView:hide(function()
            oldEventView:removeSelf()
            oldEventView = nil
        end)
        eventView = nil
    end
    eventView, onTimeUp = InGameEvent:create(eventInfo)
    inGameGroup:insert(2, eventView)
    eventView:showUp(function()
        questionsBar:onEventBet(onTimeUp, eventInfo.userBetTimeout)
    end)
    questionsBar:lock()
end

function InGameScreen:onEventEnd(resultInfo)
    display.getCurrentStage():setFocus(nil)
    eventView:showResult(resultInfo, function() questionsBar:onEventResult() end)
end

function InGameScreen:onGameOver(finalResultInfo)
    display.getCurrentStage():setFocus(nil)
    scoreView:hide()
    endView = InGameEnd:create(finalResultInfo)
    inGameGroup:insert(2, endView)
    questionsBar:lock()
    endView:showUp(function() questionsBar:onGameOver() end)
end

local questions = {
    {id = "00", text = "Bragantines fará gol no primeiro tempo?",               answer = "SIM", prize = 5, result = "right",   wasSaw = true},
    {id = "01", text = "Ademar fará algum gol no segundo tempo da partida?",    answer = "NÃO", prize = 9, result = "wrong",   wasSaw = true},
    {id = "02", text = "Muricy Ramalho fará substituições no itervalo?",        answer = "NÃO", prize = 3, result = "waiting", wasSaw = true},
    {id = "03", text = "Marcelo Caramelo receberá cartão amarelo na partida?",  answer = "",    prize = 4, result = "waiting", wasSaw = true},
    {id = "04", text = "Bragantines fará gol no primeiro tempo?",               answer = "SIM", prize = 5, result = "right",   wasSaw = false},
    {id = "05", text = "Ademar fará algum gol no segundo tempo da partida?",    answer = "NÃO", prize = 9, result = "wrong",   wasSaw = false},
    {id = "06", text = "Muricy Ramalho fará substituições no itervalo?",        answer = "NÃO", prize = 3, result = "waiting", wasSaw = false},
    {id = "07", text = "Marcelo Caramelo receberá cartão amarelo na partida?",  answer = "",    prize = 4, result = "waiting", wasSaw = false}
}

function InGameScreen:showUp(onComplete)
    local teams = {
        "spaulo",
        "spaulo",
        "spaulo",
        "scaetano",
        "bragantino",
        "scaetano",
        "spaulo",
        "santos",
        "spaulo",
        "portuguesa",
        "bragantino",
        "palmeiras",
        "corinthians"
    }
    local ranking = {}
    for i = 1, 13 do
        ranking[i] = {}
        ranking[i].photo = "pictures/pic_" .. i .. ".png"
        ranking[i].team_badge = "pictures/clubes_" .. teams[i] .. "_p.png"
        ranking[i].score = (14 - i)*123
    end
    ranking[3].isPlayer = true
    bottomRanking:showUp(function()
        bottomRanking:updateRankingPositions(ranking)
        topBar:showUp()
        onComplete()
    end)

end

function InGameScreen:new()
    inGameGroup = display.newGroup()

    questionsBar = QuestionsBar:new()
    questionsBar:setQuestions(questions)
    inGameGroup:insert(questionsBar)

    bottomRanking = BottomRanking:new("pictures/pic_3.png")

    inGameGroup:insert(bottomRanking)

    topBar = TopBar:new()
    topBar:updateTotalCoins(99999)
    topBar:updateMatchTeams("pictures/clubes_bragantino_p.png", "pictures/clubes_scaetano_p.png")
    inGameGroup:insert(topBar)

    return inGameGroup
end

return InGameScreen