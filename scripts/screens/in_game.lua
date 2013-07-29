--[[==============
== We Love Quiz
== Date: 13/05/13
== Time: 12:23
==============]]--
require "scripts.widgets.view.button_undo_vote"
require "scripts.widgets.view.button_back"
require "scripts.widgets.view.button_facebook"
require "scripts.widgets.view.button_twitter"
require "scripts.widgets.view.chronometer"
require "scripts.widgets.view.questions_bar"
require "scripts.screens.in_game_questions"
require "scripts.screens.in_game_score"
require "scripts.screens.in_game_event"
require "scripts.screens.in_game_end"

InGameScreen = {}

local inGameGroup
local topBar, questionsBar, bottomRanking

local scoreView, eventView, endView

local function updateBottomRanking()
    local userAndFriendsIds = table.copy({UserData.info.user_id}, UserData.info.friendsIds)
    Server:getPlayersRank(userAndFriendsIds, MatchManager:getMatchId(), function(response, status)
        --printTable(response)
        local ranking
        if status == 200 then
            ranking = response.scores
            --check if all friends and the user are in the rank otherwise add then
            for i, id in ipairs(userAndFriendsIds) do
                local isInTheRanking
                for i, player in ipairs(ranking) do
                    if player.user_id == id then
                        isInTheRanking = true
                    end
                end
                if not isInTheRanking then
                    ranking[#ranking + 1] = {
                        user_id = id,
                        score = 0
                    }
                end
            end
        elseif status == 404 then
            ranking = {}
            for i, id in ipairs(userAndFriendsIds) do
                ranking[#ranking + 1] = {
                    user_id = id,
                    score = 0
                }
            end
        else
            return
        end
        for i, player in ipairs(ranking) do
            if player.user_id == UserData.info.user_id then
                player.isPlayer = true
                player.photo = UserData:getUserPicture()
            else
                player.photo = getPictureFileName(player.user_id)
            end
        end

        bottomRanking:updateRankingPositions(ranking)
    end)
end

function InGameScreen:onPreKickOffQuestions(challengeInfo)
    questionsBar.isVisible = false
    bottomRanking.isVisible = false

    inGameGroup:insert(1, InGameQuestions:create(challengeInfo))
end

function InGameScreen:onGame()
    display.getCurrentStage():setFocus(nil)
    questionsBar:onGame()
    if not scoreView then
        scoreView = InGameScore:create()
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
    if eventView then
        questionsBar:onGame()
        local oldEventView = eventView
        oldEventView:hide(function()
            oldEventView:removeSelf()
            oldEventView = nil
        end)
        eventView = nil
    end
    eventView = InGameEvent:create(eventInfo)
    inGameGroup:insert(2, eventView)
    eventView:showUp(function()
        questionsBar:onEventBet(eventView.onTimeUp, eventInfo.userBetTimeout)
    end)
    questionsBar:lock()
end

function InGameScreen:onEventEnd(resultInfo)
    display.getCurrentStage():setFocus(nil)
    eventView:showResult(resultInfo, function()
        questionsBar:onEventResult()
        topBar:updateTotalCoins(resultInfo.totalCoins)
        UserData:setTotalCoins(resultInfo.totalCoins)
        updateBottomRanking()
    end)
end

function InGameScreen:onGameOver(finalResultInfo)
    display.getCurrentStage():setFocus(nil)
    scoreView:hide()
    endView = InGameEnd:create(finalResultInfo)
    inGameGroup:insert(2, endView)
    questionsBar:lock()
    endView:showUp(function() questionsBar:onGameOver() end)
end

function InGameScreen:callNext()
    if endView then
        return false
    else
        self:onGame()
    end
    return true
end

function InGameScreen:updateTotalCoins()
    topBar:updateTotalCoins(UserData.inventory.coins)
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
    --local ranking = {}
    --for i, friendId in ipairs(UserData.info.facebook_profile.friends_ids) do
    --    ranking[i] = {}
    --    ranking[i].photo = getPictureFileName(friendId)
    --    --ranking[i].team_badge = "pictures/clubes_" .. teams[i] .. "_p.png"
    --    ranking[i].score = (14 - i)*999
    --end
    --
    --local playerPos = #UserData.info.facebook_profile.friends_ids + 1
    --ranking[playerPos] = {}
    --ranking[playerPos].photo = getPictureFileName(UserData.info.facebook_profile.id)
    ----ranking[playerPos].team_badge = "pictures/clubes_" .. teams[i] .. "_p.png"
    --ranking[playerPos].score = (14 - playerPos)*999
    --ranking[playerPos].isPlayer = true

    bottomRanking:showUp(function()
        updateBottomRanking()
        topBar:showUp()
        onComplete()
    end)

    topBar:updateMatchTeams(MatchManager:getTeamLogoImg(true, 1), MatchManager:getTeamLogoImg(false, 1))
end

function InGameScreen:hide(onComplete)
    questionsBar:hide()
    local function onHiding()
        topBar:hide()
        bottomRanking:hide(function()
            InGameScreen:destroy()
            onComplete()
        end)
    end

    if endView then
        endView:hide(onHiding)
    else
        scoreView:hide(onHiding)
    end
end

function InGameScreen:new()
    inGameGroup = display.newGroup()

    questionsBar = QuestionsBar:new()
    --questionsBar:setQuestions(questions)
    inGameGroup:insert(questionsBar)

    bottomRanking = BottomRanking:new(UserData:getUserPicture())

    inGameGroup:insert(bottomRanking)

    topBar = TopBar:new()
    topBar:updateTotalCoins(UserData.inventory.coins)
    inGameGroup:insert(topBar)

    return inGameGroup
end

function InGameScreen:destroy()
    if scoreView.timer then
        timer.cancel(scoreView.timer)
    end
    scoreView:removeSelf()
    if eventView then
        eventView:removeSelf()
    end
    if endView then
        endView:removeSelf()
    end
    topBar:destroy()
    questionsBar:destroy()
    bottomRanking:destroy()
    if inGameGroup and inGameGroup.removeSelf then
        inGameGroup:removeSelf()
    end
    inGameGroup = nil
    topBar, questionsBar, bottomRanking = nil, nil, nil
    scoreView, eventView, endView = nil, nil, nil
end

return InGameScreen