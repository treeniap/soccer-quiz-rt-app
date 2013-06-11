--[[==============
== We Love Quiz
== Date: 17/05/13
== Time: 18:14
==============]]--
InGameEvent = {}

local TextureManager = TextureManager
local BtnHexaVote = BtnHexaVote
local SCREEN_TOP = SCREEN_TOP
local SCREEN_BOTTOM = SCREEN_BOTTOM
local SCREEN_RIGHT = SCREEN_RIGHT
local SCREEN_LEFT = SCREEN_LEFT

local eventGroup

local eventFoil, whistle, voteButtons, resultBar
local onTimeUp
local isShowingResults

local voteButtonsPositionsY = {
    display.contentCenterY - 92,
    display.contentCenterY - 62,
    display.contentCenterY + 28,
    display.contentCenterY + 58
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
    eventNameTxt.x = 20
    eventNameTxt.y = -150 + (display.screenOriginY*-0.75)
    eventNameTxt:setTextColor(0)
    foilGroup.title = eventNameTxt
    foilGroup:insert(TextureManager.newHorizontalLine(20, -135 + (display.screenOriginY*-0.75), 180))

    local teamBadgeImg = TextureManager.newImageRect(teamBadge, 128, 128, foilGroup)
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

local function createHexaResult(type, betCoins, valueMult, friend)
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

    local value = display.newText(hexaGroup, string.format("%.1f", valueMult), 0, 0, "MyriadPro-BoldCond", 24)
    value.x = 34 - value.width*0.5
    value.y = 27
    value:setTextColor(0)
    local mult = display.newText(hexaGroup, "x", 0, 0, "MyriadPro-BoldCond", 16)
    mult.x = 42 - mult.width*0.5
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

    local photoBg = TextureManager.newImage("stru_albumframe", hexaGroup)
    photoBg.x = -63
    photoBg.y = 57
    local photo = TextureManager.newImageRect(friend.photo, 53, 53, hexaGroup)
    photo.x = -60
    photo.y = 60

    local coinSlotGroup = display.newGroup()
    for i = 1, friend.coins do
        local coin = TextureManager.newImage("stru_coin_friendsvote", coinSlotGroup)
        coin.x = coinSlotsPosition[i].x
        coin.y = coinSlotsPosition[i].y
    end
    coinSlotGroup.x = -79
    coinSlotGroup.y = 68
    hexaGroup:insert(coinSlotGroup)

    return hexaGroup
end

local function changeFoilToResult(_eventFoil, resultInfo)
    _eventFoil.description:removeSelf()
    _eventFoil.badge:removeSelf()
    _eventFoil.title:setText(resultInfo.resultTitle)
    local hexaVote = createHexaResult(resultInfo.type, resultInfo.betCoins, resultInfo.valueMult, resultInfo.friend)
    hexaVote:setReferencePoint(display.CenterReferencePoint)
    hexaVote.x = 26
    hexaVote.y = -40 + (-display.screenOriginY)
    eventFoil:insert(hexaVote)
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
    local wrongBar = TextureManager.newImage("stru_perrado", eventGroup)
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

function InGameEvent:showUp(onComplete)
    if isShowingResults then
        self:hide(function() self:showUp(onComplete) end)
        return
    end
    transition.to(eventFoil, {time = 500, x = SCREEN_LEFT, transition = easeOutQuad})
    transition.to(whistle, {time = 500, x = SCREEN_RIGHT - 50, transition = easeOutQuad, onComplete = function()
        transition.to(eventFoil, {delay = 3000, time = 500, x = SCREEN_LEFT - eventFoil.width, transition = easeInCirc})
        transition.to(whistle, {delay = 3000, time = 500, x = SCREEN_RIGHT + 64, transition = easeInCirc})
        for i, btn in ipairs(voteButtons) do
            transition.to(btn, {delay = 2800 + i*200, time = 1000, y = voteButtonsPositionsY[i], transition = easeOutBack})
        end
        timer.performWithDelay(4000, onComplete)
    end})
end

function InGameEvent:showResult(resultInfo, onComplete)
    for i, btn in ipairs(voteButtons) do
        transition.to(btn, {delay = 800 - i*200, time = 1000, y = SCREEN_BOTTOM + btn.height, transition = easeInBack})
    end
    changeFoilToResult(eventFoil, resultInfo)
    transition.to(eventFoil, {delay = 1800, time = 500, x = SCREEN_LEFT, transition = easeOutQuad, onComplete = onComplete})
    if resultInfo.isRight then
        resultBar = createRightBet(resultInfo.prize)
    else
        resultBar = createWrongBet()
    end
    transition.to(resultBar, {delay = 1800, time = 500, x = SCREEN_RIGHT + 20, transition = easeOutQuad})
    eventGroup:insert(resultBar)
    isShowingResults = true
end

function InGameEvent:hide(onComplete)
    transition.to(eventFoil, {time = 500, x = SCREEN_LEFT - eventFoil.width, transition = easeInCirc, onComplete = onComplete})
    transition.to(resultBar, {time = 500, x = SCREEN_RIGHT + resultBar.width, transition = easeInCirc})
    isShowingResults = false
end

function InGameEvent:create(eventInfo)
    eventGroup = display.newGroup()
    for k, v in pairs(InGameEvent) do
        eventGroup[k] = v
    end

    isShowingResults = false

    local undoBtn = QuestionsBar:getUndoBtn()

    voteButtons = {}
    local function pressHandler(button)
        button:lock(true)
        for i, btn in ipairs(voteButtons) do
            btn:resetCoins()
            btn:lock(false)
        end
        return true
    end
    undoBtn.onRelease = pressHandler

    local function releaseHandler(button)
        button:addCoin()
        undoBtn:lock(false)
        for i, btn in ipairs(voteButtons) do
            if btn ~= button then
                btn:lock(true)
            end
        end
        return true
    end

    local btnLabel = "goal"
    local topLeftBtn = BtnHexaVote:new(btnLabel, eventInfo.alternatives[btnLabel].multiplier, releaseHandler)
    topLeftBtn.x = display.contentCenterX - topLeftBtn.width*0.45
    topLeftBtn.y = SCREEN_BOTTOM + topLeftBtn.height -- display.contentCenterY - 90
    topLeftBtn.label = btnLabel
    topLeftBtn.url = eventInfo.alternatives[btnLabel].url
    voteButtons[#voteButtons + 1] = topLeftBtn
    eventGroup:insert(1, topLeftBtn)

    btnLabel = "saved"
    local topRightBtn = BtnHexaVote:new(btnLabel, eventInfo.alternatives[btnLabel].multiplier, releaseHandler)
    topRightBtn.x = display.contentCenterX + topRightBtn.width*0.45
    topRightBtn.y = SCREEN_BOTTOM + topLeftBtn.height -- display.contentCenterY - 60
    topRightBtn.label = btnLabel
    topRightBtn.url = eventInfo.alternatives[btnLabel].url
    voteButtons[#voteButtons + 1] = topRightBtn
    eventGroup:insert(1, topRightBtn)

    btnLabel = "missed"
    local bottomLeftBtn = BtnHexaVote:new(btnLabel, eventInfo.alternatives[btnLabel].multiplier, releaseHandler)
    bottomLeftBtn.x = display.contentCenterX - bottomLeftBtn.width*0.45
    bottomLeftBtn.y = SCREEN_BOTTOM + topLeftBtn.height -- display.contentCenterY + 30
    bottomLeftBtn.label = btnLabel
    bottomLeftBtn.url = eventInfo.alternatives[btnLabel].url
    voteButtons[#voteButtons + 1] = bottomLeftBtn
    eventGroup:insert(1, bottomLeftBtn)

    btnLabel = "cleared"
    local bottomRightBtn
    if eventInfo.alternatives[btnLabel] then
        bottomRightBtn = BtnHexaVote:new(btnLabel, eventInfo.alternatives[btnLabel].multiplier, releaseHandler)
        bottomRightBtn.x = display.contentCenterX + bottomRightBtn.width*0.45
        bottomRightBtn.y = SCREEN_BOTTOM + topLeftBtn.height -- display.contentCenterY + 60
        bottomRightBtn.label = btnLabel
        bottomRightBtn.url = eventInfo.alternatives[btnLabel].url
        voteButtons[#voteButtons + 1] = bottomRightBtn
        eventGroup:insert(1, bottomRightBtn)
    end

    onTimeUp = function()
        local f1 = {photo = "pictures/pic_5.png",  coins = 3}
        local f2 = {photo = "pictures/pic_8.png",  coins = 5}
        local f3 = {photo = "pictures/pic_12.png", coins = 1}
        local f4 = {photo = "pictures/pic_3.png",  coins = 3}
        topLeftBtn:showFriendVoted(f1)
        topRightBtn:showFriendVoted(f2)
        bottomLeftBtn:showFriendVoted(f3)
        if bottomRightBtn then
            bottomRightBtn:showFriendVoted(f4)
        end

        for i, vB in ipairs(voteButtons) do
            if vB:getBetCoins() > 0 then
                Server.postBet(vB.url)
            end
        end

        undoBtn:lock(true)
    end

    whistle = createWhistle()
    eventFoil = createEventFoil(eventInfo.eventName, eventInfo.teamBadge, eventInfo.teamName)
    eventGroup:insert(whistle)
    eventGroup:insert(eventFoil)

    return eventGroup, onTimeUp
end

return InGameEvent