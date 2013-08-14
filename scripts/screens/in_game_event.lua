--[[==============
== We Love Quiz
== Date: 17/05/13
== Time: 18:14
==============]]--
InGameEvent = {}

local TextureManager = TextureManager
local BtnHexaVote = require "scripts.widgets.view.button_hexa_vote"
local SCREEN_TOP = SCREEN_TOP
local SCREEN_BOTTOM = SCREEN_BOTTOM
local SCREEN_RIGHT = SCREEN_RIGHT
local SCREEN_LEFT = SCREEN_LEFT

local easeOutQuad = easeOutQuad
local easeInQuad = easeInQuad

local currentAnswer
local currentBet
local lastRanking

local VOTE_BUTTONS_POSITIONS_Y = {
    display.contentCenterY - 92,
    display.contentCenterY - 62,
    display.contentCenterY + 28,
    display.contentCenterY + 58
}

local VOTE_BUTTONS_START_POSITIONS_X = {
    SCREEN_LEFT - 128,
    SCREEN_RIGHT + 128,
    SCREEN_LEFT - 128,
    SCREEN_RIGHT + 128
}

local function createEventFoil(eventName, teamBadge, teamName)
    local foilGroup = display.newGroup()
    --scalable menu background
    local menuFoilCenter = TextureManager.newImageRect("images/stru_foil_center.png", 141 + display.screenOriginX*-2, 450, foilGroup)
    menuFoilCenter.x = 0
    menuFoilCenter.y = 0

    -- menu background border
    local menuFoilBorder = TextureManager.newSpriteRect("stru_foil_border", 100, 450, foilGroup)
    menuFoilBorder.x = menuFoilCenter.width*0.5 + menuFoilBorder.width*0.5
    menuFoilBorder.y = 0

    local eventNameTxt = display.newEmbossedText(foilGroup, eventName, 0, 0, "MyriadPro-BoldCond", 24)
    eventNameTxt.x = 30
    eventNameTxt.y = -150 + (display.screenOriginY*-0.75)
    eventNameTxt:setTextColor(0)
    foilGroup.title = eventNameTxt
    foilGroup:insert(TextureManager.newHorizontalLine(30, -135 + (display.screenOriginY*-0.75), 180))

    local teamBadgeImg = TextureManager.newLogo(teamBadge, 128, foilGroup)
    teamBadgeImg.x = 20
    teamBadgeImg.y = -50 + (display.screenOriginY*-0.75)
    foilGroup.badge = teamBadgeImg

    local description = display.newText(foilGroup, teamName .. " COBRA", 0, 0, "MyriadPro-BoldCond", 14)
    if description.width > 160 then
        description:removeSelf()
        description = display.newText(foilGroup, teamName .. " COBRA", 0, 0, 160, 0, "MyriadPro-BoldCond", 14)
    end
    description.x = 20
    description.y = 40 + (display.screenOriginY*-0.75)
    description:setTextColor(135)
    foilGroup.description = description

    foilGroup:setReferencePoint(display.CenterLeftReferencePoint)
    foilGroup.x = SCREEN_LEFT - foilGroup.width -- + foilGroup.width*0.5
    foilGroup.y = SCREEN_TOP + 240

    return foilGroup
end

local questionsAlternatives = {
    goal    = {text = "GOL",    frameName = "stru_pic_gol_vote"},
    saved   = {text = "SALVA",  frameName = "stru_pic_defende_vote"},
    cleared = {text = "AFASTA", frameName = "stru_pic_tira_vote"},
    missed  = {text = "FORA",   frameName = "stru_pic_fora_vote"},
    yes     = {text = "SIM"},
    no      = {text = "NÃO"}
}

local coinSlotsPosition = {
    {x = -2, y = 17},
    {x = 3, y = 8},
    {x = -2, y = -1},
    {x = 3, y = -10},
    {x = -2, y = -19}
}

local function createBetLuckyAlbum(photos)
    local albumGroup = display.newGroup()
    albumGroup.x = -63
    albumGroup.y = 57

    local photoBg = TextureManager.newImage("stru_albumframe", albumGroup)
    photoBg.x = 0
    photoBg.y = 0

    local function loadPhoto(_photo)
        local photoGroup = display.newGroup()
        photoGroup.x = 3
        photoGroup.y = 3
        local bg = display.newRect(photoGroup, 0, 0, 57, 57)
        bg.x = 0
        bg.y = 0
        local noError, photo = pcall(TextureManager.newImageRect, _photo, 55, 55, photoGroup, system.DocumentsDirectory)
        if noError and photo then
            photo.x = 0
            photo.y = 0
        end
        albumGroup:insert(2, photoGroup)
        if not albumGroup.currentPhoto then
            albumGroup.currentPhoto = photoGroup
        else
            albumGroup.nextPhoto = photoGroup
        end
    end
    loadPhoto(photos[1])
    if #photos > 1 then
        local photoNum = 2
        local photoTimer
        local function checkAlbum()
            if not albumGroup or not albumGroup.insert then
                timer.cancel(photoTimer)
                photoTimer = nil
                return false
            end
            return true
        end
        local function changePhoto()
            if not checkAlbum() then
                return
            end
            loadPhoto(photos[photoNum])
            transition.to(albumGroup.currentPhoto, {time = 500, y = 0, x = 64, transition = easeOutQuad, onComplete = function()
                if not checkAlbum() then
                    return
                end
                albumGroup:insert(1, albumGroup.currentPhoto)
                transition.to(albumGroup.currentPhoto, {time = 500, y = -3, x = 0, transition = easeOutQuad, onComplete = function()
                    if not checkAlbum() then
                        return
                    end
                    albumGroup.currentPhoto:removeSelf()
                    albumGroup.currentPhoto = albumGroup.nextPhoto
                end})
            end})
            photoNum = photoNum + 1
            if photoNum > #photos then
                photoNum = 1
            end
        end
        photoTimer = timer.performWithDelay(3000, changePhoto, 0)
    end

    return albumGroup
end

local function createHexaResult(type, voteButtons, photos)
    local valueMult, betCoins
    for i, vB in ipairs(voteButtons) do
        if vB.label == type then
            valueMult = vB.multiplierValue
            betCoins = vB:getBetCoins()
        end
    end
    local hexaGroup = display.newGroup()
    local topHexaBtn = TextureManager.newImage("stru_buttonhexa_back_vote", hexaGroup)
    topHexaBtn.x = 0
    topHexaBtn.y = -17
    local middleHexaBtn = TextureManager.newImage("stru_buttonhexa_midle_vote", hexaGroup)
    middleHexaBtn.x = 0
    middleHexaBtn.y = 0
    local bottomHexaBtn = TextureManager.newImage("stru_buttonhexa_front_vote", hexaGroup)
    bottomHexaBtn.x = -1
    bottomHexaBtn.y = 28

    local pic = TextureManager.newImage(questionsAlternatives[type].frameName, hexaGroup)
    pic.x = -18
    pic.y = -30
    local label = display.newText(hexaGroup, questionsAlternatives[type].text, 0, 0, "MyriadPro-BoldCond", 16)
    label.x = -2 - label.width*0.5
    label.y = 28
    label:setTextColor(0)

    --local value = display.newText(hexaGroup, string.format("%.1f", valueMult), 0, 0, "MyriadPro-BoldCond", 24) -- float mode
    local value = display.newText(hexaGroup, valueMult, 0, 0, "MyriadPro-BoldCond", 24)
    --value.x = 34 - value.width*0.5 -- float mode
    value.x = 24 - value.width*0.5
    value.y = 27
    value:setTextColor(0)
    local mult = display.newText(hexaGroup, "x", 0, 0, "MyriadPro-BoldCond", 16)
    --mult.x = 42 - mult.width*0.5 -- float mode
    mult.x = 32 - mult.width*0.5
    mult.y = 28
    mult:setTextColor(0)

    local coinSlotGroup = display.newGroup()
    local coinSlotBG = TextureManager.newImage("stru_coinslot_vote", coinSlotGroup)
    coinSlotBG.x = 0
    coinSlotBG.y = 0
    if betCoins > 0 then
        for i = 1, betCoins do
            local coin = TextureManager.newImage("stru_coin_vote", coinSlotGroup)
            coin.x = coinSlotsPosition[i].x
            coin.y = coinSlotsPosition[i].y
        end
    end
    coinSlotGroup.x = 43
    coinSlotGroup.y = -18
    hexaGroup:insert(coinSlotGroup)

    local coinSlotsPosition = {
        {x = -2, y = 17},
        {x = 2, y = 13},
        {x = -2, y = 9},
        {x = 2, y = 5},
        {x = -2, y = 1}
    }
    if photos and #photos > 0 then
        hexaGroup:insert(createBetLuckyAlbum(photos))
    end
    return hexaGroup
end

local function getRightBetFriendsPhotos(ranking)
    if lastRanking then
        local photos = {}
        for i, player in pairs(ranking) do
            if lastRanking[player.user_id] and lastRanking[player.user_id] < player.score then
                lastRanking[player.user_id] = player.score
                photos[#photos + 1] = player.photo
            end
        end
        return photos
    end
end

local function changeFoilToResult(_eventFoil, resultInfo, voteButtons, ranking)
    if _eventFoil.description.removeSelf then
        _eventFoil.description:removeSelf()
    end
    if _eventFoil.badge.removeSelf then
        _eventFoil.badge:removeSelf()
    end
    _eventFoil.title:setText(resultInfo.title)
    local hexaVote = createHexaResult(resultInfo.type, voteButtons, getRightBetFriendsPhotos(ranking))
    hexaVote:setReferencePoint(display.CenterReferencePoint)
    hexaVote.x = 26
    hexaVote.y = -40 + (-display.screenOriginY)
    _eventFoil:insert(hexaVote)
end

local function createRightBet(prize)
    local rightGroup = display.newGroup()
    local rightBar = TextureManager.newImage("stru_pcerto", rightGroup)
    rightBar.x = 20
    rightBar.y = -120
    local coin = TextureManager.newImage("stru_coin_prize", rightGroup)
    coin.x = 0
    coin.y = 0

    local premioTxt = display.newText(rightGroup, "PRÊMIO", 0, 0, "MyriadPro-BoldCond", 18)
    premioTxt.x = 0
    premioTxt.y = -70
    premioTxt:setTextColor(135)
    local prizeTxt = display.newText(rightGroup, prize, 0, 0, "MyriadPro-BoldCond", 80)
    prizeTxt.x = 0
    prizeTxt.y = -20
    prizeTxt:setTextColor(0)

    rightGroup:setReferencePoint(display.CenterRightReferencePoint)
    rightGroup.x = SCREEN_RIGHT + rightGroup.width
    rightGroup.y = display.contentCenterY - 20

    return rightGroup
end

local function createWrongBet()
    local wrongBar = TextureManager.newImage("stru_perrado")
    wrongBar.x = SCREEN_RIGHT + wrongBar.width
    wrongBar.y = display.contentCenterY - wrongBar.height
    wrongBar:setReferencePoint(display.CenterRightReferencePoint)
    return wrongBar
end

local function createWhistle()
    local whistleGroup = display.newGroup()

    local bg = TextureManager.newImageRect("images/stru_bar_mid.png", 100, 40, whistleGroup)
    bg.x = 0
    bg.y = 0
    local bgBorder = TextureManager.newImageRect("images/stru_bar_left.png", 15, 40, whistleGroup)
    bgBorder.x = -bg.width*0.5 - bgBorder.width*0.5
    bgBorder.y = 0

    local whistle = TextureManager.newImage("stru_whistle", whistleGroup)
    whistle.x = 0
    whistle.y = -4

    whistleGroup.x = SCREEN_RIGHT + 64 -- -50
    whistleGroup.y = display.contentCenterY

    return whistleGroup
end

local function setLastRanking()
    local userAndFriendsIds = table.copy({UserData.info.user_id}, UserData.info.friendsIds)
    Server:getPlayersRank(userAndFriendsIds, MatchManager:getMatchId(), function(response, status)
    --printTable(response)
        if status == 200 then
            lastRanking = {}
            for i, player in pairs(response.scores) do
                if player.user_id ~= UserData.info.user_id then
                    lastRanking[player.user_id] = player.score
                end
            end
            for i, id in ipairs(userAndFriendsIds) do
                if not lastRanking[id] and id ~= UserData.info.user_id then
                    lastRanking[id] = 0
                end
            end
        end
    end)
end

local resultInfo = {
    goal = {
        type = "goal",
        title = "GOOOOL!!!",
        earnedCoins = 10,
        totalCoins = 999
    },
    saved = {
        type = "saved",
        title = "O GOLEIRO SALVOU!",
        earnedCoins = 5,
        totalCoins = 999
    },
    cleared = {
        type = "cleared",
        title = "AFASTA A ZAGA!",
        earnedCoins = 2,
        totalCoins = 999
    },
    missed = {
        type = "missed",
        title = "PRA FORA!",
        earnedCoins = 3,
        totalCoins = 999
    }
}

function InGameEvent.betResultListener(message)
    local _resultInfo
    printTable(message)
    if not currentAnswer then
        _resultInfo = resultInfo[message.answer]
        _resultInfo.totalCoins = UserData.inventory.coins
        _resultInfo.isRight = "no_answer"

        AnalyticsManager.question("skiped", 0, "no_answer")
    else
        local isRight = type(message.correct) == "boolean" and message.correct or (message.correct == "true")
        if isRight then
            _resultInfo = resultInfo[currentAnswer]
        else
            _resultInfo = resultInfo[message.answer]
        end
        _resultInfo.earnedCoins = message.coins.prize
        _resultInfo.totalCoins = message.coins.total
        _resultInfo.isRight = isRight

        AnalyticsManager.emptyCoins(nil, message.coins.total == 0)
        AnalyticsManager.question(isRight and "guessed" or "missed", currentBet, currentAnswer)
        currentAnswer = nil
    end

    InGameScreen:onEventEnd(_resultInfo)
end

function InGameEvent:showUp(onComplete)
    local MOVE_TIME = 300
    local SHOW_DURATION = 1500
    self.phase = "began"
    transition.to(self.eventFoil, {time = MOVE_TIME, x = SCREEN_LEFT, transition = easeOutQuad})
    transition.to(self.whistle, {time = MOVE_TIME, x = SCREEN_RIGHT - 50, transition = easeOutQuad, onComplete = function()
        transition.to(self.eventFoil, {delay = SHOW_DURATION, time = MOVE_TIME, x = SCREEN_LEFT - self.eventFoil.width, transition = easeInQuad})
        AudioManager.playAudio("showLogo", SHOW_DURATION)
        transition.to(self.whistle, {delay = SHOW_DURATION, time = MOVE_TIME, x = SCREEN_RIGHT + 64, transition = easeInQuad})
        for i, btn in ipairs(self.voteButtons) do
            btn.isVisible = true
            transition.from(btn, {delay = SHOW_DURATION, time = MOVE_TIME, x = VOTE_BUTTONS_START_POSITIONS_X[i], transition = easeOutQuad})
        end
        timer.performWithDelay(SHOW_DURATION, function()
            self.phase = "betting"
            onComplete()
        end)
    end})
    AudioManager.playAudio("showEvent")
end

function InGameEvent:showResult(resultInfo, ranking, onComplete)
    for i, btn in ipairs(self.voteButtons) do
        transition.to(btn, {time = 300, x = VOTE_BUTTONS_START_POSITIONS_X[i], transition = easeInQuad})
    end
    changeFoilToResult(self.eventFoil, resultInfo, self.voteButtons, ranking)
    transition.to(self.eventFoil, {time = 300, x = SCREEN_LEFT, transition = easeOutQuad, onComplete = function()
        self.phase = "ended"
    end})
    if resultInfo.isRight ~= "no_answer" then
        if resultInfo.isRight then
            self.resultBar = createRightBet(resultInfo.earnedCoins)
            AudioManager.playAudio("betRight")
        else
            self.resultBar = createWrongBet()
            AudioManager.playAudio("betWrong")
        end
        transition.to(self.resultBar, {time = 300, x = SCREEN_RIGHT + 20, transition = easeOutQuad})
        self:insert(self.resultBar)
    end
    onComplete()
    AudioManager.playStopBetAnswerWait()
end

function InGameEvent:hide(onComplete)
    transition.to(self.eventFoil, {time = 300, x = SCREEN_LEFT - self.eventFoil.width, transition = easeInQuad, onComplete = onComplete})
    if self.resultBar then
        transition.to(self.resultBar, {time = 300, x = SCREEN_RIGHT + self.resultBar.width, transition = easeInQuad})
    end
end

function InGameEvent:create(eventInfo)
    local eventGroup = display.newGroup()
    for k, v in pairs(InGameEvent) do
        eventGroup[k] = v
    end

    currentAnswer = nil
    currentBet = nil
    lastRanking = nil
    setLastRanking()

    local undoBtn = QuestionsBar:getUndoBtn()

    local voteButtons = {}
    local function pressHandler(button)
        button:lock(true)
        for i, btn in ipairs(voteButtons) do
            if btn:getBetCoins() > 0 then
                UserData.inventory.coins = UserData.inventory.coins + btn:getBetCoins()
            end
            btn:resetCoins()
            btn:lock(false)
        end
        InGameScreen:updateTotalCoins()
        return true
    end
    undoBtn.onRelease = pressHandler

    local function releaseHandler(button)
        if UserData.inventory.coins > 0 and button:getBetCoins() < 5 then
            UserData.inventory.coins = UserData.inventory.coins - 1
            InGameScreen:updateTotalCoins()
            button:addCoin()
            undoBtn:lock(false)
            for i, btn in ipairs(voteButtons) do
                if btn ~= button then
                    btn:lock(true)
                end
            end
        end
        return true
    end

    local btnLabel = "goal"
    local topLeftBtn = BtnHexaVote:new(btnLabel, eventInfo.alternatives[btnLabel].multiplier, releaseHandler)
    topLeftBtn.x = display.contentCenterX - topLeftBtn.width*0.45
    topLeftBtn.y = VOTE_BUTTONS_POSITIONS_Y[1]
    topLeftBtn.isVisible = false
    topLeftBtn.label = btnLabel
    topLeftBtn.url = eventInfo.alternatives[btnLabel].url
    voteButtons[#voteButtons + 1] = topLeftBtn
    eventGroup:insert(1, topLeftBtn)

    btnLabel = "saved"
    local topRightBtn = BtnHexaVote:new(btnLabel, eventInfo.alternatives[btnLabel].multiplier, releaseHandler)
    topRightBtn.x = display.contentCenterX + topRightBtn.width*0.45
    topRightBtn.y = VOTE_BUTTONS_POSITIONS_Y[2]
    topRightBtn.isVisible = false
    topRightBtn.label = btnLabel
    topRightBtn.url = eventInfo.alternatives[btnLabel].url
    voteButtons[#voteButtons + 1] = topRightBtn
    eventGroup:insert(1, topRightBtn)

    btnLabel = "missed"
    local bottomLeftBtn = BtnHexaVote:new(btnLabel, eventInfo.alternatives[btnLabel].multiplier, releaseHandler)
    bottomLeftBtn.x = display.contentCenterX - bottomLeftBtn.width*0.45
    bottomLeftBtn.y = VOTE_BUTTONS_POSITIONS_Y[3]
    bottomLeftBtn.isVisible = false
    bottomLeftBtn.label = btnLabel
    bottomLeftBtn.url = eventInfo.alternatives[btnLabel].url
    voteButtons[#voteButtons + 1] = bottomLeftBtn
    eventGroup:insert(1, bottomLeftBtn)

    btnLabel = "cleared"
    local bottomRightBtn
    if eventInfo.alternatives[btnLabel] then
        bottomRightBtn = BtnHexaVote:new(btnLabel, eventInfo.alternatives[btnLabel].multiplier, releaseHandler)
        bottomRightBtn.x = display.contentCenterX + bottomRightBtn.width*0.45
        bottomRightBtn.y = VOTE_BUTTONS_POSITIONS_Y[4]
        bottomRightBtn.isVisible = false
        bottomRightBtn.label = btnLabel
        bottomRightBtn.url = eventInfo.alternatives[btnLabel].url
        voteButtons[#voteButtons + 1] = bottomRightBtn
        eventGroup:insert(1, bottomRightBtn)
    end

    eventGroup.onTimeUp = function()
        --local f1 = {photo = "pictures/pic_5.png",  coins = 3}
        --local f2 = {photo = "pictures/pic_8.png",  coins = 5}
        --local f3 = {photo = "pictures/pic_12.png", coins = 1}
        --local f4 = {photo = "pictures/pic_3.png",  coins = 3}
        --topLeftBtn:showFriendVoted(f1)
        --topRightBtn:showFriendVoted(f2)
        --bottomLeftBtn:showFriendVoted(f3)
        --if bottomRightBtn then
        --    bottomRightBtn:showFriendVoted(f4)
        --end
        local function postBet(url, coins)
            local function onClientError(event)
                Server:getUserInventory(nil, function()
                    InGameScreen:updateTotalCoins()
                    --native.showAlert("ERRO", "Possíveis causas:\n- O lance pode ter sido cancelado.\n- Você não possui uma boa conexão com a internet.\n- Suas configurações de data e hora estão erradas.", {"Ok"}, ScreenManager.callNext)
                    native.showAlert("ERRO", "Houve um erro de comunicação com nosso servidor. Verifique se o horário de seu " .. getDeviceName() .. " está sendo ajustado automaticamente e/ou se sua internet está rápida e estável.", {"Ok"}, ScreenManager.callNext)
                end)
                AnalyticsManager.conectivity("LateClientResponse")
            end
            local function listener(response, status)
                if not response or status ~= 200 then
                    print("Bet Error", status)
                    timer.performWithDelay(2000, ScreenManager.callNext)
                    return
                end
                print("Bet Ok", status)
            end
            Server.postBet(url, UserData.info.user_id, coins, onClientError, listener)
        end
        for i, vB in ipairs(voteButtons) do
            if vB:getBetCoins() > 0 then
                --print(vB.url, vB:getBetCoins())
                postBet(vB.url, vB:getBetCoins())
                currentAnswer = vB.label
                currentBet = vB:getBetCoins()

                AnalyticsManager.emptyCoins(UserData.inventory.coins == 0)
            end
            vB:lock(true)
        end
        if not currentAnswer then
            --timer.performWithDelay(2000, ScreenManager.callNext)
            postBet(voteButtons[1].url, 0)
        end
        undoBtn:lock(true)
        AudioManager.playAudio("betTimeout")
    end

    eventGroup.voteButtons = voteButtons
    eventGroup.whistle = createWhistle()
    eventGroup.eventFoil = createEventFoil(eventInfo.title, eventInfo.teamBadge, eventInfo.teamName)
    eventGroup:insert(eventGroup.whistle)
    eventGroup:insert(eventGroup.eventFoil)

    return eventGroup
end

return InGameEvent