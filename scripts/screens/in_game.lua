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

local function getUserPhotoUrl(user)
    local url
    if user.facebook_profile then
        local imageSize = getImagePrefix()
        if imageSize == "default" then
            imageSize = ""
        else
            imageSize = imageSize .. "_"
        end
        if user.facebook_profile["picture_" .. imageSize .. "url"] then
            url = user.facebook_profile["picture_" .. imageSize .. "url"]
        else
            if user.facebook_profile["picture_url"] then
                url = user.facebook_profile["picture_url"]
            elseif user.facebook_profile["picture_2x_url"] then
                url = user.facebook_profile["picture_2x_url"]
            else
                url = user.facebook_profile["picture_4x_url"]
            end
        end
    end
    return url
end

local function getUsersPhotoRanking(ids, players, ranking, _listener)
    Server:getUsers(ids, false, function(response, status)
        local count = 0
        for i, ranker in ipairs(ranking) do
            for k, user in pairs(response.users) do
                if ranker.user_id == user.id then
                    --printTable(user)
                    local photoUrl = getUserPhotoUrl(user)
                    if photoUrl and count < 5 then
                        players[user.id].photoUrl = photoUrl
                        players[user.id].photo = getPictureFileName(user.id)
                        count = count + 1
                    else
                        players[user.id] = nil
                    end
                end
            end
        end
        _listener(players)
    end)
end

local function getMatchTopRanking(_listener)
    Server:getTopRanking(MatchManager:getMatchId(), function(response, status)
        local ranking
        local players = {}
        local playersIds = {}
        if status == 200 and response then
            ranking = response.scores
            for i, player in ipairs(ranking) do
                players[player.user_id] = {id = player.user_id, score = player.score}
                if UserData.info.user_id == player.user_id then
                    players[player.user_id].isPlayer = true
                end
                playersIds[#playersIds + 1] = player.user_id
            end
            getUsersPhotoRanking(playersIds, players, ranking, function(_players)
                _listener(_players)
            end)
        else
            _listener(players)
        end
    end)
end

local function getUserAndFriendsRanking(_listener)
    Facebook:requestFriends(function()
        if not UserData.info.friendsIds then
            UserData.info.friendsIds = {}
        end
        local userAndFriendsIds = table.copy({UserData.info.user_id}, UserData.info.friendsIds)
        Server:getPlayersRank(userAndFriendsIds, MatchManager:getMatchId(), function(response, status)
            local ranking
            local players = {}
            if status == 200 and response then
                ranking = response.scores
                for i, player in ipairs(ranking) do
                    players[player.user_id] = {id = player.user_id, score = player.score, photo = getPictureFileName(player.user_id) }
                    if UserData.info.user_id == player.user_id then
                        players[player.user_id].isPlayer = true
                    end
                end
            end
            if not players[UserData.info.user_id] then
                players[UserData.info.user_id] = {isPlayer = true, id = UserData.info.user_id, score = 0, photo = getPictureFileName(UserData.info.user_id)}
            end
            _listener(players)
        end)
    end)
end

local function setTeams(players, _listener)
    local playersIds = {}
    for k, v in pairs(players) do
        playersIds[#playersIds + 1] = k
    end

    Server:getPlayersInventories(playersIds, function(response)
        if response then
            for k, v in pairs(response) do
                players[k].teamBadge = getLogoFileName(v.favorite_team_id, 1)
            end
        else
            for k, v in pairs(players) do
                players[k].teamBadge = "none"
            end
        end
        _listener(players)
    end)
end

local function mountRanking(_listener)
    getMatchTopRanking(function(topPlayers)

        getUserAndFriendsRanking(function(userAndFriends)

            local bottomRankingPlayers = topPlayers
            for k, _userOrFriend in pairs(userAndFriends) do
                if #topPlayers == 0 or not table.indexOf(topPlayers, k) then
                    bottomRankingPlayers[k] = _userOrFriend
                end
            end
            setTeams(bottomRankingPlayers, _listener)
        end)
    end)
end

function InGameScreen:updateBottomRanking(listener)
    mountRanking(function(players)
        local ranking = {}
        for k, player in pairs(players) do
            if #ranking == 0 then
                ranking[#ranking + 1] = player
            else
                local addedToRanking
                for i = #ranking, 1, -1 do
                    local ranker = ranking[i]
                    if ranker.score > player.score then
                        table.insert(ranking, i + 1, player)
                        addedToRanking = true
                        break
                    end
                end
                if not addedToRanking then
                    table.insert(ranking, 1, player)
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
    if inGameGroup.eventRolling then
        return
    end
    inGameGroup.eventRolling = true
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
    InGameScreen:updateBottomRanking()
    if eventView then
        eventView:showResult(resultInfo, {}, function()
            questionsBar:onEventResult()
            topBar:updateTotalCoins(resultInfo.totalCoins)
            UserData:setTotalCoins(resultInfo.totalCoins)
            timer.performWithDelay(2000, function() inGameGroup.eventRolling = false end)
        end)
    end
    --Server:getPlayerRanking(nil, checkScore)
end

function InGameScreen:onGameOver(finalResultInfo, enteredAfterMatchEnd)
    display.getCurrentStage():setFocus(nil)
    if eventView then
        Server:getUserInventory(nil, function()
            questionsBar:onGame()
            eventView:hide(function()
                eventView:removeSelf()
                eventView = nil

                InGameScreen:updateTotalCoins()
                native.showAlert("", "O evento que estavamos aguardando foi cancelado e suas fichas apostadas foram devolvidas.", { "Ok" })
                InGameScreen:onGameOver(finalResultInfo, enteredAfterMatchEnd)
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
        if enteredAfterMatchEnd then
            AnalyticsManager.enteredInGameForStats()
        else
            AnalyticsManager.changedGamePeriod("match_over")
        end
    end, enteredAfterMatchEnd)
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

function InGameScreen:updateTime()
    if topBar then
        topBar:updateTime()
    end
end

function InGameScreen:showUp(onComplete)
    bottomRanking:showUp(function()
        InGameScreen:updateBottomRanking()
        topBar:showUp()
        onComplete()
    end)
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

    bottomRanking = BottomRanking:new()

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