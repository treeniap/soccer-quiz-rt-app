--[[==============
== We Love Quiz
== Date: 24/07/13
== Time: 10:59
==============]]--
local widget = require "widget"
require "scripts.widgets.view.top_bar_menu"
require "scripts.widgets.view.button_open_menu"

RankingScreen = {}

local rankingScreenGroup
local bgGroup
local rankingsListGroup
local rankingButtons

local function closeRankingButtons(openingButton)
    for i, button in ipairs(rankingButtons) do
        if button ~= openingButton and button.isOpen then
            button:close()
            button.isOpen = false
            button.parent[button.parent.numChildren].isVisible = true
        end
    end
end

local function displaceOpenRankBtns(openingButtonY, partHeight)
    for i, button in ipairs(rankingButtons) do
        if button.y > openingButtonY then
            transition.to(button.parent, {time = 200, y = button.parent.y + partHeight})
        end
    end
end

local function displaceCloseRankBtns()
    for i, button in ipairs(rankingButtons) do
        transition.to(button.parent, {time = 200, y = SCREEN_TOP + 68})
    end
end

local function createNameText(name)
    local nameGroup = display.newGroup()

    local FONT_SIZE = 18

    local lineSize = 0
    local i = 1
    local nameSize = display.contentWidth*0.4 + (-display.screenOriginX)
    while i <= name:len() do
        local l = name:sub(i, i)
        lineSize = lineSize + getFontLettersSize(l)
        if lineSize * (FONT_SIZE / 100) > nameSize then
            break
        end
        i = i + 1
    end

    if i >= name:len() then
        return name:sub(1, i)
    else
        return name:sub(1, i) .. "..."
    end
end

local function createPlayerView(player, playersGroup, yPos, rankingPosition)
    local playerGroup = display.newGroup()

    if player.isPlayer then
        local bg = TextureManager.newImageRect("images/stru_ranking_user.png", CONTENT_WIDTH, 64, playerGroup)
        bg.x = display.contentCenterX + (-display.screenOriginX) + 4
        bg.y = 0
    end

    local playerPositionTxt = display.newText(playerGroup, rankingPosition, 0, 0, "MyriadPro-BoldCond", 32)
    playerPositionTxt:setReferencePoint(display.CenterLeftReferencePoint)
    playerPositionTxt.x = 16
    playerPositionTxt.y = 0

    local noError, photo = pcall(TextureManager.newImageRect, player.photo, 46, 46, playerGroup, system.DocumentsDirectory)
    if noError and photo then
        photo.x = 64
        photo.y = 0
    end

    local function createBadge()
        if not playerGroup or not playerGroup.insert then
            return
        end
        if not player.teamBadge then
            timer.performWithDelay(500, createBadge)
        elseif player.teamBadge ~= "none" then
            local noError, badge = pcall(TextureManager.newImageRect, player.teamBadge, 24, 24, playerGroup, system.DocumentsDirectory)
            if noError and badge then
                badge.x = 80
                badge.y = 16
            end
        end
    end
    createBadge()

    local playerName = display.newText(playerGroup, string.utf8upper(createNameText(player.first_name .. " " .. player.last_name)), 0, 0, "MyriadPro-BoldCond", 18)
    playerName:setReferencePoint(display.CenterLeftReferencePoint)
    --if playerName.width > 175 then
    --    local scale = 175/ playerName.width
    --    playerName.xScale = scale
    --    playerName.yScale = scale
    --end
    playerName.x = 96
    playerName.y = 0

    local playerScore = display.newText(playerGroup, player.score .. " Pts", 0, 0, "MyriadPro-BoldCond", 18)
    playerScore:setReferencePoint(display.CenterRightReferencePoint)
    playerScore.x = CONTENT_WIDTH - 8
    playerScore.y = 0

    if player.isPlayer then
        playerPositionTxt:setTextColor(255)
        playerName:setTextColor(255)
        playerScore:setTextColor(255)
    else
        playerPositionTxt:setTextColor(128)
        playerName:setTextColor(32)
        playerScore:setTextColor(32)
    end

    playerGroup:insert(TextureManager.newHorizontalLine(display.contentCenterX + (-display.screenOriginX) + 8, 32, CONTENT_WIDTH*0.9))

    return playerGroup
end

local function createPlayersView(playersList, topY)
    if not playersList then
        return display.newGroup()
    end
    -- Create a ScrollView
    local scrollSize = #playersList < 6 and #playersList*64 or 320
    local distToBottom = SCREEN_BOTTOM - topY
    scrollSize = distToBottom < scrollSize and distToBottom or scrollSize
    local playersListGroup = widget.newScrollView
        {
            width = SCREEN_RIGHT,
            height = scrollSize,
            maskFile = "images/menuranking_mask.png",
            hideBackground = true,
            horizontalScrollDisabled = true,
            verticalScrollDisabled = #playersList < 6
        }

    playersListGroup:insert(TextureManager.newHorizontalLine(display.contentCenterX, 6, CONTENT_WIDTH*0.9))

    local yPos = 14
    for i, player in ipairs(playersList) do
        local playerView = createPlayerView(player, playersListGroup, yPos, i)
        playerView:setReferencePoint(display.TopCenterReferencePoint)
        playerView.x = display.contentCenterX
        playerView.y = yPos
        if player.isPlayer then
            playerView.y = playerView.y - 9
        end
        playersListGroup:insert(playerView)
        yPos = yPos + 64
    end

    playersListGroup.y = topY - 8

    --print(scrollSize, matchesGroup.height)
    return playersListGroup
end

local function createOpenMenuLine(isBottom)
    local lineGroup = display.newGroup()
    local line = display.newLine(lineGroup, SCREEN_LEFT, display.screenOriginY, SCREEN_RIGHT, display.screenOriginY)
    if isBottom then
        line:setColor(255)
    else
        line:setColor(135, 224)
    end
    local lineShadow = TextureManager.newImageRect("images/stru_shadow.png", CONTENT_WIDTH, 20, lineGroup)
    lineShadow.x = display.contentCenterX
    lineShadow.y = display.screenOriginY + (isBottom and -10 or 10)
    lineShadow.yScale = isBottom and -lineShadow.yScale or lineShadow.yScale
    lineGroup:setReferencePoint(isBottom and display.BottomCenterReferencePoint or display.TopCenterReferencePoint)

    return lineGroup
end

local function createBG()
    bgGroup = display.newGroup()

    local bgTop = TextureManager.newImageRect("images/stru_menu_bg.png", CONTENT_WIDTH, CONTENT_HEIGHT, bgGroup)
    bgTop.x = display.contentCenterX
    bgTop.y = display.contentCenterY
    local menuMask = graphics.newMask("images/menuselectmatch_mask.png")
    bgTop:setMask(menuMask)
    local bgBottom = TextureManager.newImageRect("images/stru_menu_bg.png", CONTENT_WIDTH, CONTENT_HEIGHT, bgGroup)
    bgBottom.x = display.contentCenterX
    bgBottom.y = display.contentCenterY
    local menuMask = graphics.newMask("images/menuselectmatch_mask.png")
    bgBottom:setMask(menuMask)

    local CENTER_MASK_Y = 282.5
    bgTop.maskY = -CENTER_MASK_Y
    bgBottom.maskY = CENTER_MASK_Y

    local lineTop = createOpenMenuLine(false)
    bgGroup:insert(lineTop)

    local lineBottom = createOpenMenuLine(true)
    bgGroup:insert(lineBottom)

    function RankingScreen:openBG(button, champNum)
        local yOpenPart = button.y + SCREEN_TOP + 89
        local partHeight
        if self.isOpen then
            RankingScreen:closeBG(function()
                closeRankingButtons(button)
                RankingScreen:openBG(button, champNum)
            end)
            return
        end
        self.openButton = button
        self.openChampNum = champNum
        rankingScreenGroup:insert(1, createPlayersView(button.ranking, yOpenPart + 8))
        local distToBottom = SCREEN_BOTTOM - yOpenPart
        partHeight = distToBottom < 320 and distToBottom or (rankingScreenGroup[1].height < 320 and rankingScreenGroup[1].height + 4 or 320)
        lineTop.y = yOpenPart - 1
        lineBottom.y = lineTop.y + 1
        lineBottom.alpha = 0
        transition.to(lineBottom, {time = 200, y = yOpenPart + partHeight + 2, alpha = 1})

        bgTop.maskY = -CENTER_MASK_Y - (display.contentCenterY) + yOpenPart
        bgBottom.maskY = CENTER_MASK_Y - (display.contentCenterY) + yOpenPart
        transition.to(bgBottom, {time = 200, maskY = CENTER_MASK_Y - (display.contentCenterY) + yOpenPart + partHeight, onComplete = function()
            self.isOpen = true
            self.inTransition = false
            unlockScreen()
        end})

        button:open()
        button.parent[button.parent.numChildren].isVisible = false
        displaceOpenRankBtns(button.y, partHeight)

        self.inTransition = true
        lockScreen()
    end

    function RankingScreen:closeBG(onClose)
        self.openButton = nil
        self.openChampNum = nil
        transition.to(bgBottom, {time = 200, maskY = CENTER_MASK_Y*2 + bgTop.maskY, onComplete = function()
            rankingScreenGroup[1]:removeSelf()
            self.isOpen = false
            if onClose then
                timer.performWithDelay(200, onClose)
            else
                self.inTransition = false
                unlockScreen()
            end
        end})
        lineTop.y = display.screenOriginY
        lineBottom.y = display.screenOriginY
        displaceCloseRankBtns()
        self.inTransition = true
        lockScreen()
    end

    return bgGroup
end

local function getPlayersInTheRanking(button, ranking)
    local imageSize = getImagePrefix()
    if imageSize == "default" then
        imageSize = ""
    else
        imageSize = imageSize .. "_"
    end
    local function listener(response, status)
        local downloadList = {}
        --printTable(response)
        for i, user in ipairs(response.users) do
            local url
            if user.facebook_profile["picture_" .. imageSize .. "url"] then
                url = user.facebook_profile["picture_" .. imageSize .. "url"]
            else
                url = user.facebook_profile["picture_url"]
            end
            downloadList[#downloadList + 1] = {
                url = url,
                fileName = getPictureFileName(user.id)
            }
            for i, player in ipairs(ranking) do
                --print(user.id, friend.user_id)
                if user.id == player.user_id then
                    ranking[i].first_name = user.first_name
                    ranking[i].last_name = user.last_name
                    ranking[i].photo = getPictureFileName(user.id)
                    local isPlayer = (user.id == UserData.info.user_id)
                    ranking[i].isPlayer = isPlayer
                    if isPlayer then
                        ranking[i].teamBadge = getLogoFileName(UserData.attributes.favorite_team_id, 1)
                    else
                        Server:getInventory(user.id, function(response)
                            ranking[i].teamBadge = getLogoFileName(response.inventory.attributes.favorite_team_id, 1)
                        end)
                    end
                end
            end
        end
        Server:downloadFilesList(downloadList, function()
            button.ranking = ranking
            button.spinnerDefault:removeSelf()
            button:lock(false)
        end)
    end
    local playersIds = {}
    for i, player in ipairs(ranking) do
        playersIds[#playersIds + 1] = player.user_id
    end
    --printTable(friendsIds)
    Server:getUsers(playersIds, false, listener)
end

local function getAmigosRanking(button)
    local userAndFriendsIds = table.copy({UserData.info.user_id}, UserData.info.friendsIds)
    local function callback(response, status)
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
        getPlayersInTheRanking(button, ranking)
    end
    Server:getPlayersRank(userAndFriendsIds, nil, callback)
end

local function getGlobalRanking(button)
    local function callback(response, status)
        --printTable(response)
        local ranking
        if status == 200 then
            ranking = response.scores
            --for i=#ranking, 5, -1 do
            --    table.remove(ranking, i)
            --end
        else
            return
        end
        getPlayersInTheRanking(button, ranking)
    end
    Server:getTopRanking(nil, callback)
end

local function createRankingsList()
    rankingsListGroup = display.newGroup()
    local rankingsList = {{name = "amigos", getRanking = getAmigosRanking}, {name = "global", getRanking = getGlobalRanking}}
    local Y_RANKING = 50
    for i, ranking in ipairs(rankingsList) do
        local rankingGroup = display.newGroup()
        local title = display.newText(string.utf8upper(ranking.name), 0, 0, "MyriadPro-BoldCond", 24)
        title.x = title.width*0.5 + 8
        title.y = (i - 1)* Y_RANKING
        title:setTextColor(0)
        local arrow = ButtonOpenMenu:new(function(button, event)
            if RankingScreen.inTransition then
                return true
            end
            button.isOpen = not button.isOpen
            if button.isOpen then
                RankingScreen:openBG(button, i)
            else
                RankingScreen:closeBG()
                button:close()
                button.parent[button.parent.numChildren].isVisible = true
            end
            return true
        end)
        rankingGroup:insert(arrow)
        arrow.x = SCREEN_RIGHT - arrow.width*0.5
        arrow.y = (i - 1)* Y_RANKING - 6
        arrow:lock(true)
        rankingGroup:insert(title)
        rankingButtons[#rankingButtons + 1] = arrow
        rankingGroup:insert(TextureManager.newHorizontalLine(display.contentCenterX, (i - 1)* Y_RANKING + title.height*0.5 + 4, CONTENT_WIDTH*0.9))
        rankingGroup.x = 0
        rankingGroup.y = SCREEN_TOP + 68

        local spinnerDefault = LoadingBall:createBall(SCREEN_RIGHT - 20, (i - 1)* Y_RANKING)
        rankingGroup:insert(spinnerDefault)
        arrow.spinnerDefault = spinnerDefault

        ranking.getRanking(arrow)

        rankingsListGroup:insert(rankingGroup)
    end
    return rankingsListGroup
end

function RankingScreen:showUp(onComplete)
    bgGroup.isVisible = true
    transition.from(bgGroup, {time = 500, alpha = 0, onComplete = function()
        rankingsListGroup.isVisible = true
        rankingScreenGroup[rankingScreenGroup.numChildren].isVisible = true
        for i = 1, rankingsListGroup.numChildren do
            transition.from(rankingsListGroup[i], {delay = 300, time = 300, y = 50*-i - 50, transition = easeInQuart})
        end
        AudioManager.playAudio("openCloseMenu", 500)
        transition.from(rankingScreenGroup[rankingScreenGroup.numChildren], {time = 300, y = SCREEN_TOP - 50, transition = easeInQuart})
        AudioManager.playAudio("showTopBar")
        timer.performWithDelay(650, onComplete)
    end})
end

function RankingScreen:new()
    RankingScreen.inTransition = false
    rankingScreenGroup = display.newGroup()
    rankingButtons = {}

    rankingScreenGroup:insert(createBG())
    rankingScreenGroup:insert(createRankingsList())
    rankingScreenGroup:insert(TopBarMenu:new("RANKING"))

    bgGroup.isVisible = false
    rankingsListGroup.isVisible = false
    rankingScreenGroup[rankingScreenGroup.numChildren].isVisible = false

    return rankingScreenGroup
end

function RankingScreen:hide(onComplete)
    local function hiding()
        for i = 1, rankingsListGroup.numChildren do
            transition.to(rankingsListGroup[i], {time = 300, y = 50*-i - 50, transition = easeInQuart})
        end
        transition.to(rankingScreenGroup[rankingScreenGroup.numChildren], {delay = 300, time = 300, y = SCREEN_TOP - 50, transition = easeInQuart, onComplete = function()
            transition.to(bgGroup, {time = 500, alpha = 0, onComplete = RankingScreen.destroy})
            onComplete()
        end})
    end

    if self.isOpen then
        self:closeBG(hiding)
    else
        hiding()
    end
end

function RankingScreen:destroy()
    bgGroup:removeSelf()
    rankingsListGroup:removeSelf()
    rankingScreenGroup:removeSelf()
    rankingScreenGroup = nil
    bgGroup = nil
    rankingsListGroup = nil
    rankingButtons = nil
end

return RankingScreen