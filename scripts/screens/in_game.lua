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
require "scripts.screens.in_game_event"
require "scripts.screens.in_game_end"
require "scripts.screens.in_game_period"
require "scripts.management.in_game_manager"

InGameScreen = {}

local inGameGroup
local topBar, questionsBar, bottomRanking

local stateManager, eventView, endView
local friendsIdBadgesNames

local lastScore

local function updateBottomRanking(listener)
    local userAndFriendsIds = table.copy({UserData.info.user_id}, UserData.info.friendsIds)
    Server:getPlayersRank(userAndFriendsIds, MatchManager:getMatchId(), function(response, status)
        --printTable(response)
        local ranking
        if status == 200 and response then
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
            if listener then
                listener()
            end
            return
        end
        if not friendsIdBadgesNames then
            friendsIdBadgesNames = {}
        end
        for i, player in ipairs(ranking) do
            if player.user_id == UserData.info.user_id then
                player.isPlayer = true
                player.photo = UserData:getUserPicture()
                player.teamBadge = getLogoFileName(UserData.attributes.favorite_team_id, 1)
            else
                player.photo = getPictureFileName(player.user_id)
                if friendsIdBadgesNames[player.user_id] then
                    player.teamBadge = friendsIdBadgesNames[player.user_id]
                else
                    Server:getInventory(player.user_id, function(response)
                        if not response then
                            player.teamBadge = "none"
                        else
                            friendsIdBadgesNames[player.user_id] = getLogoFileName(response.inventory.attributes.favorite_team_id, 1)
                            player.teamBadge = friendsIdBadgesNames[player.user_id]
                        end
                    end)
                end
            end
        end

        if listener then
            listener(ranking)
        end
        if bottomRanking then
            bottomRanking:updateRankingPositions(ranking)
        end
    end)
end

local function checkScore(response, status)
    if status == 200 then
        if lastScore and lastScore ~= response.user_ranking.score then
            lastScore = response.user_ranking.score
            Facebook:postFacebookScore(lastScore)
        end
    end
end

function InGameScreen:onPreKickOffQuestions(challengeInfo)
    questionsBar.isVisible = false
    bottomRanking.isVisible = false

    inGameGroup:insert(1, InGameQuestions:create(challengeInfo))
end

function InGameScreen:onGame()
    display.getCurrentStage():setFocus(nil)
    questionsBar:onGame()
    if eventView then
        local oldEventView = eventView
        oldEventView:hide(function()
            oldEventView:removeSelf()
            oldEventView = nil
        end)
        AudioManager.playAudio("showLogo")

        eventView = nil
    end
    stateManager:showUp()
end

function InGameScreen:onEventStart(eventInfo)
    display.getCurrentStage():setFocus(nil)
    stateManager:hide()
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
    updateBottomRanking(function(ranking)
        if eventView then
            eventView:showResult(resultInfo, ranking, function()
                questionsBar:onEventResult()
                topBar:updateTotalCoins(resultInfo.totalCoins)
                UserData:setTotalCoins(resultInfo.totalCoins)
            end)
        end
    end)
    Server:getPlayerRanking(nil, checkScore)
end

function InGameScreen:onGameOver(finalResultInfo)
    display.getCurrentStage():setFocus(nil)
    if eventView then
        Server:getUserInventory(nil, function()
            questionsBar:onGame()
            eventView:hide(function()
                eventView:removeSelf()
                eventView = nil

                InGameScreen:updateTotalCoins()
                native.showAlert("", "O evento que estavamos aguardando foi cancelado e suas fichas apostadas foram devolvidas.", { "Ok" })
                InGameScreen:onGameOver(finalResultInfo)
            end)
        end)
        return
    end
    endView = InGameEnd:create(finalResultInfo)
    stateManager:onGameOver(endView)
    inGameGroup:insert(2, endView)
    questionsBar:lock()
    endView:showUp(function()
        questionsBar:onGameOver()
        stateManager.canChange = true
        AnalyticsManager.changedGamePeriod("match_over")
    end)
end

function InGameScreen:onPeriodChange(period)
    --print("InGameScreen:onPeriodChange")
    if eventView then
        if eventView.phase == "ended" then
            questionsBar:onGame()
            local oldEventView = eventView
            oldEventView:hide(function()
                oldEventView:removeSelf()
                oldEventView = nil
            end)
            eventView = nil
        else
            timer.performWithDelay(500, function()
                InGameScreen:onPeriodChange(period)
            end)
            return
        end
    end
    display.getCurrentStage():setFocus(nil)
    stateManager:hide()
    local periodView = InGamePeriod:create(period)
    inGameGroup:insert(2, periodView)
    questionsBar:lock()
    periodView:showUp(function()
        timer.performWithDelay(4000, function()
            periodView:hide(function()
                stateManager:showUp()
                periodView:removeSelf()
                AnalyticsManager.changedGamePeriod(period)
            end)
            AudioManager.playAudio("showLogo")
        end)
    end)
end

function InGameScreen:callNext()
    if endView then
        return false
    else
        self:onGame()
    end
    return true
end

function InGameScreen:getStateManager()
    return stateManager
end

function InGameScreen:updateTotalCoins()
    topBar:updateTotalCoins(UserData.inventory.coins)
end

function InGameScreen:goal()
    --questionsBar:addEvent()
end

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
    Server:getPlayerRanking(nil, checkScore)
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
    elseif eventView then
        eventView:hide(onHiding)
    else
        stateManager:hide(onHiding)
    end
end

function InGameScreen:onAppResume()
    if stateManager then
        stateManager:onResumeUpdate()
    end
end

function InGameScreen:new()
    inGameGroup = display.newGroup()

    stateManager = InGameState:init()
    inGameGroup:insert(stateManager)

    questionsBar = QuestionsBar:new()
    inGameGroup:insert(questionsBar)

    bottomRanking = BottomRanking:new(UserData:getUserPicture())

    inGameGroup:insert(bottomRanking)

    topBar = TopBar:new()
    topBar:updateTotalCoins(UserData.inventory.coins)
    inGameGroup:insert(topBar)

    AnalyticsManager.enteredInGameScreen()

    InGameScreen.group = inGameGroup

    return inGameGroup
end

function InGameScreen:destroy()
    stateManager:stop()
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
    stateManager, eventView, endView = nil, nil, nil
end

return InGameScreen