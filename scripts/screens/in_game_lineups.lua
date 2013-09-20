--[[==============
== We Love Quiz
== Date: 05/09/13
== Time: 11:55
==============]]--
InGameLineups = {}

InGameLineups.screenName = "Lineups"
InGameLineups.imgName = "icon_escalacao_"

local lineups

---///////////    COMMON    ///////////---

local function newTitleBar(title)
    local barGroup = display.newGroup()

    local border = TextureManager.newImageRect("images/stats/bar_stats_A.png", 8, 22, barGroup)
    local center = TextureManager.newImageRect("images/stats/bar_stats_B.png", CONTENT_WIDTH - 48, 22, barGroup)
    center.x = center.width*0.5 + border.width*0.5
    local border = TextureManager.newImageRect("images/stats/bar_stats_C.png", 16, 22, barGroup)
    border.x = center.x + center.width*0.5 + border.width*0.5

    local text = display.newEmbossedText(barGroup, title, 0, 0, "MyriadPro-BoldCond", 15)
    --text:setReferencePoint(display.CenterLeftReferencePoint)
    text:setTextColor(128, 128)
    text.x = center.width*0.5 + 4
    text.y = 3

    local homeTeamLogo = TextureManager.newLogo(MatchManager:getTeamLogoImg(true, 1), 32, barGroup)
    homeTeamLogo.x = center.width*0.2 + 4
    homeTeamLogo.y = -4
    local awayTeamLogo = TextureManager.newLogo(MatchManager:getTeamLogoImg(false, 1), 32, barGroup)
    awayTeamLogo.x = center.width*0.8 + 4
    awayTeamLogo.y = -4

    barGroup:setReferencePoint(display.CenterRightReferencePoint)
    barGroup.x = -8
    barGroup.y = 0

    return barGroup
end

local function createPlayerName(text)
    local fontSize = 13
    local WIDTH_LIMIT = 104 + (-display.screenOriginX)
    local sanitizedText = string.utf8upper(text)

    local function getNameWidth(name)
        local nameSize = 0
        for i = 1, name:len() do
            local l = name:sub(i, i)
            nameSize = nameSize + getFontLettersSize(l)
        end
        return nameSize
    end

    local function getFontSize(nameSize)
        return (WIDTH_LIMIT / (nameSize * (fontSize / 100)))*fontSize
    end

    local function abbreviateName(name)
        local charNum = 1
        local shortText = ""
        local charPos
        local hasSpace = true
        while hasSpace do
            charPos = string.find(name, " ", charNum)
            if charPos then
                shortText = shortText .. name:sub(charNum, charNum) .. ". "
                charNum = charPos + 1
            else
                shortText = shortText .. name:sub(charNum)
                hasSpace = false
            end
        end
        return shortText
    end

    local nameWidth = getNameWidth(sanitizedText)

    if nameWidth * (fontSize / 100) > WIDTH_LIMIT then
        if string.find(sanitizedText, " ") then
            sanitizedText = abbreviateName(sanitizedText)
            local shortNameWidth = getNameWidth(sanitizedText)
            if shortNameWidth * (fontSize / 100) > WIDTH_LIMIT then
                fontSize = getFontSize(shortNameWidth)
            end
        else
            fontSize = getFontSize(nameWidth)
        end
    end

    local txt
    if getNameWidth(sanitizedText) * (fontSize / 100) > WIDTH_LIMIT then
        --print(sanitizedText, getNameWidth(sanitizedText), WIDTH_LIMIT)
        txt = display.newText(sanitizedText, 0, 0, WIDTH_LIMIT, fontSize, "MyriadPro-Cond", fontSize)
    else
        txt = display.newText(sanitizedText, 0, 0, "MyriadPro-Cond", fontSize)
    end
    txt:setReferencePoint(display.CenterLeftReferencePoint)
    txt:setTextColor(32)
    return txt
end

---///////////    LINEUP    ///////////---

local function newLineupLine(identifier, name)
    local lineGroup = display.newGroup()

    local preText = display.newText(lineGroup, identifier, 0, 0, "MyriadPro-BoldCond", 12)
    preText:setTextColor(0)
    preText:setReferencePoint(display.CenterRightReferencePoint)
    preText.x = 0
    preText.y = 0
    local name = createPlayerName(name)
    lineGroup:insert(name)
    name.x = 4
    name.y = 0

    return lineGroup
end

local function createViewLineup(yPos)
    local lineupsGroup = display.newGroup()
    lineupsGroup.x = SCREEN_RIGHT
    lineupsGroup.y = yPos
    lineupsGroup:insert(newTitleBar("JOGADORES EM CAMPO"))

    if not lineups then
        return lineupsGroup
    end

    local xPos, yPos = -CONTENT_WIDTH + 40, 28
    for i, player in ipairs(lineups.home_team.lineup) do
        local line = newLineupLine(player.number, player.name)
        line.x = xPos
        line.y = yPos
        lineupsGroup:insert(line)
        yPos = yPos + 16
    end
    yPos = yPos + 8
    local line = newLineupLine("TÉC.:", lineups.home_team.coach)
    line.x = xPos
    line.y = yPos
    lineupsGroup:insert(line)

    xPos, yPos = -CONTENT_WIDTH*0.5 + 40, 28
    for i, player in ipairs(lineups.guest_team.lineup) do
        local line = newLineupLine(player.number, player.name)
        line.x = xPos
        line.y = yPos
        lineupsGroup:insert(line)
        yPos = yPos + 16
    end
    yPos = yPos + 8
    local line = newLineupLine("TÉC.:", lineups.guest_team.coach)
    line.x = xPos
    line.y = yPos
    lineupsGroup:insert(line)

    local size = lineupsGroup.height - lineupsGroup[1].height
    local blackLine, whiteLine = TextureManager.newVerticalLine(-CONTENT_WIDTH*0.5, size*0.5 + lineupsGroup[1].height*0.5, size)
    lineupsGroup:insert(blackLine)
    lineupsGroup:insert(whiteLine)

    return lineupsGroup
end

---///////////    GOALS/CARDS    ///////////---

local function newGoalLine(goal)
    local lineGroup = display.newGroup()

    local ballImgName = goal.own_goal and "icon_gol_contra" or "icon_gol_favor"

    local ball = TextureManager.newImage(ballImgName, lineGroup)
    ball.x = 0
    ball.y = 0

    local name = createPlayerName(goal.player_name)
    lineGroup:insert(name)
    name.x = 8
    name.y = 4
    if goal.team == "home" then
        name:setReferencePoint(display.CenterRightReferencePoint)
        name.x = -8
    end

    return lineGroup
end

local function newCardLine(card)
    local lineGroup = display.newGroup()

    local cardImg = display.newRoundedRect(lineGroup, 0, 0, 10, 13, 1)
    cardImg.x = 0
    cardImg.y = 0
    cardImg.strokeWidth = 1
    if card.type == "yellow" then
        cardImg:setFillColor(222, 191, 0)
        cardImg:setStrokeColor(178, 153, 0)
    else
        cardImg:setFillColor(216, 48, 53)
        cardImg:setStrokeColor(173, 39, 43)
    end

    local name = createPlayerName(card.player_name)
    lineGroup:insert(name)
    name.x = 8
    name.y = 4
    if card.team == "home" then
        name:setReferencePoint(display.CenterRightReferencePoint)
        name.x = -8
    end

    return lineGroup
end

local function addGoalsOrCards(goalsAndCards, list, homeAway, event)
    for i, newEvent in ipairs(list) do
        newEvent.team = homeAway
        if newEvent.own_goal then
            newEvent.team = newEvent.team == "home" and "away" or "home"
        end
        newEvent.event = event
        local itemPeriod = newEvent.period
        if goalsAndCards[itemPeriod] then
            local wasAdded
            for j = #goalsAndCards[itemPeriod], 1, -1 do
                local _event = goalsAndCards[itemPeriod][j]
                --print(itemPeriod, item.minute, _event.minute)
                if newEvent.minute > _event.minute then
                    table.insert(goalsAndCards[itemPeriod], j + 1, newEvent)
                    wasAdded = true
                    break
                elseif newEvent.minute == _event.minute then
                    if newEvent.player_name == _event.player_name then
                        if newEvent.type and newEvent.type == "red" then
                            table.insert(goalsAndCards[itemPeriod], j + 1, newEvent)
                        elseif newEvent.type and newEvent.type == "yellow" and not _event.type then
                            table.insert(goalsAndCards[itemPeriod], j + 1, newEvent)
                        else
                            table.insert(goalsAndCards[itemPeriod], j, newEvent)
                        end
                        wasAdded = true
                        break
                    end
                end
            end
            if not wasAdded then
                table.insert(goalsAndCards[itemPeriod], 1, newEvent)
            end
        end
    end
end

local function createPeriodSeparator(period)
    local periods = {["first_half"] = "1º Tempo", ["second_half"] = "2º Tempo", ["extra_first_half"] = "1º Tempo da Prorrogação", ["extra_second_half"] = "2º Tempo da Prorrogação" }

    local separtorGroup = display.newGroup()

    local periodTxt = display.newText(periods[period], 0, 0, "MyriadPro-BoldCond", 12)
    periodTxt:setTextColor(0)
    periodTxt.x = display.contentCenterX
    periodTxt.y = 4
    separtorGroup:insert(TextureManager.newHorizontalLine(display.contentCenterX, -8, CONTENT_WIDTH*0.9))
    separtorGroup:insert(periodTxt)
    separtorGroup:insert(TextureManager.newHorizontalLine(display.contentCenterX, 8, CONTENT_WIDTH*0.9))

    separtorGroup:setReferencePoint(display.CenterReferencePoint)

    return separtorGroup
end

local function createViewTimeLine(yPos)
    local goalsCardsGroup = display.newGroup()
    goalsCardsGroup.x = SCREEN_RIGHT
    goalsCardsGroup.y = yPos
    goalsCardsGroup:insert(newTitleBar("GOLS/CARTÕES"))

    if not lineups then
        return goalsCardsGroup
    end

    local goalsAndCards = {["first_half"] = {}, ["second_half"] = {}, ["extra_first_half"] = {}, ["extra_second_half"] = {} }
    local sequence = {"first_half", "second_half", "extra_first_half", "extra_second_half"}

    addGoalsOrCards(goalsAndCards, lineups.home_team.goals, "home", "goal")
    addGoalsOrCards(goalsAndCards, lineups.home_team.cards, "home", "card")
    addGoalsOrCards(goalsAndCards, lineups.guest_team.goals, "away", "goal")
    addGoalsOrCards(goalsAndCards, lineups.guest_team.cards, "away", "card")

    local xHomePos, xAwayPos = -CONTENT_WIDTH*0.5 - 20, -CONTENT_WIDTH*0.5 + 20
    local yPos = 20
    local homeYPos = yPos
    local awayYPos = yPos
    local i = 1
    for k, v in pairs(goalsAndCards) do
        local goalsAndCardsPeriod  = goalsAndCards[sequence[i]]
        if #goalsAndCardsPeriod > 0 or (sequence[i] == "first_half" or sequence[i] == "second_half") then
            if yPos < homeYPos then
                yPos = homeYPos
            end
            if yPos < awayYPos then
                yPos = awayYPos
            end
            yPos = yPos + 8
            local sep = createPeriodSeparator(sequence[i])
            sep.x = -CONTENT_WIDTH*0.5
            sep.y = yPos
            goalsCardsGroup:insert(sep)
            yPos = yPos + 24

            local lastEventTime = -1
            local startY = yPos

            for i, event in ipairs(goalsAndCardsPeriod) do
                local line
                if event.event == "goal" then
                    line = newGoalLine(event)
                else
                    line = newCardLine(event)
                end
                if event.team == "home" then
                    line.x = xHomePos
                else
                    line.x = xAwayPos
                end

                if event.minute == lastEventTime then
                    if event.team == "home" then
                        line.y = homeYPos
                        homeYPos = homeYPos + 16
                    else
                        line.y = awayYPos
                        awayYPos = awayYPos + 16
                    end
                else
                    if yPos < homeYPos then
                        yPos = homeYPos
                    end
                    if yPos < awayYPos then
                        yPos = awayYPos
                    end

                    local timeCircle = TextureManager.newImageRect("images/stats/time_bg.png", 14, 14, goalsCardsGroup)
                    timeCircle.x = -CONTENT_WIDTH*0.5
                    timeCircle.y = yPos
                    local timeTxt = display.newText(goalsCardsGroup, event.minute .. "'", 0, 0, "MyriadPro-BoldCond", 10)
                    timeTxt.x = timeCircle.x + 1
                    timeTxt.y = timeCircle.y + 2
                    timeTxt:setTextColor(0)

                    line.y = yPos
                    if event.team == "home" then
                        homeYPos = yPos + 16
                        awayYPos = yPos
                    else
                        homeYPos = yPos
                        awayYPos = yPos + 16
                    end
                    yPos = yPos + 16
                end

                lastEventTime = event.minute
                goalsCardsGroup:insert(line)
            end

            local size = yPos - startY
            local blackLine, whiteLine = TextureManager.newVerticalLine(-CONTENT_WIDTH*0.5, yPos - size*0.5 - 8, size)
            goalsCardsGroup:insert(1, blackLine)
            goalsCardsGroup:insert(1, whiteLine)
        end
        i = i + 1
    end
    return goalsCardsGroup
end

---///////////    SUBSTITUTIONS    ///////////---

local function newSubstitutionLine(playerIn, playerOut, hasLine)
    local lineGroup = display.newGroup()

    local inImg = TextureManager.newSpriteRect("icon_seta_verde", 10, 10, lineGroup)
    inImg.x = 0
    inImg.y = 0

    local outImg = TextureManager.newSpriteRect("icon_seta_vermelha", 10, 10, lineGroup)
    outImg.x = 0
    outImg.y = 16

    local nameIn = createPlayerName(playerIn)
    lineGroup:insert(nameIn)
    nameIn.x = 8
    nameIn.y = 4

    local nameOut = createPlayerName(playerOut)
    lineGroup:insert(nameOut)
    nameOut.x = 8
    nameOut.y = 20

    if hasLine then
        lineGroup:insert(TextureManager.newHorizontalLine(38, 26, CONTENT_WIDTH*0.35))
    end

    return lineGroup
end

local function createViewSubstitutions(yPos)
    local substitutionsGroup = display.newGroup()
    substitutionsGroup.x = SCREEN_RIGHT
    substitutionsGroup.y = yPos
    substitutionsGroup:insert(newTitleBar("SUBSTITUIÇÕES"))

    if not lineups then
        return substitutionsGroup
    end

    local xPos, yPos = -CONTENT_WIDTH + 40, 28
    for i, player in ipairs(lineups.home_team.substitutions) do
        local line = newSubstitutionLine(player.player_in_name, player.player_out_name, #lineups.home_team.substitutions > i)
        line.x = xPos
        line.y = yPos
        substitutionsGroup:insert(line)
        yPos = yPos + 32
    end

    xPos, yPos = -CONTENT_WIDTH*0.5 + 40, 28
    for i, player in ipairs(lineups.guest_team.substitutions) do
        local line = newSubstitutionLine(player.player_in_name, player.player_out_name, #lineups.guest_team.substitutions > i)
        line.x = xPos
        line.y = yPos
        substitutionsGroup:insert(line)
        yPos = yPos + 32
    end

    local size = substitutionsGroup.height - substitutionsGroup[1].height
    local blackLine, whiteLine = TextureManager.newVerticalLine(-CONTENT_WIDTH*0.5, size*0.5 + substitutionsGroup[1].height*0.5, size)
    substitutionsGroup:insert(blackLine)
    substitutionsGroup:insert(whiteLine)

    return substitutionsGroup
end

---///////////    GENERAL    ///////////---

local function createScrollView()
    local widget = require("widget")
    -- Create a ScrollView
    local scrollGroup = widget.newScrollView
        {
            width = SCREEN_RIGHT,
            height = 230 + display.screenOriginY*-2,
            maskFile = "images/masks/menuranking_mask.png",
            hideBackground = true,
            hideScrollBar = true,
            horizontalScrollDisabled = true,
            isBounceEnabled = false,
            friction = 0.85,
            listener = function(event)
                if event.phase == "moved" then
                    local dX = math.abs(event.x - event.xStart)
                    local dY = math.abs(event.y - event.yStart)
                    -- If our finger has moved more than the desired range
                    if dY < 25 and dX > 50 then
                        InGameScreen:getStateManager().touchHandler:takeFocus(event)
                    end
                end
            end
        }
    return scrollGroup
end

local function createView(lineupsGroup)
    local scrollView = createScrollView()
    lineupsGroup:insert(scrollView)

    local initialY = SCREEN_TOP + 84
    local timelineView = createViewTimeLine(initialY)
    local lineupView = createViewLineup(initialY + timelineView.height)
    local substitutionView = createViewSubstitutions(initialY + timelineView.height + lineupView.height)
    scrollView:insert(timelineView)
    scrollView:insert(lineupView)
    scrollView:insert(substitutionView)

    local touchHandler = display.newRect(0, 0, CONTENT_WIDTH, lineupView.height + timelineView.height)
    touchHandler:setReferencePoint(display.TopCenterReferencePoint)
    touchHandler.y = initialY
    touchHandler.alpha = 0.01
    scrollView:insert(1, touchHandler)
end

function InGameLineups:update(match_details)
    lineups = match_details

    if self.numChildren > 0 then
        display.getCurrentStage():setFocus(nil)
        for i = self.numChildren, 1, -1 do
            self[i]:removeSelf()
        end
    end

    createView(self)
end

function InGameLineups:toFront()
    self.isVisible = true
end

function InGameLineups:toBack()
    self.isVisible = false
end

function InGameLineups:create()
    local lineupsGroup = display.newGroup()
    for k, v in pairs(InGameLineups) do
        lineupsGroup[k] = v
    end

    createView(lineupsGroup)

    return lineupsGroup
end

function InGameLineups:destroy()
    if self.timer then
        timer.cancel(self.timer)
    end
    self:removeSelf()
    lineups = nil
end

return InGameLineups