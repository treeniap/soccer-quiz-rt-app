--[[==============
== We Love Quiz
== Date: 04/09/13
== Time: 14:45
==============]]--
InGameStats = {}

InGameStats.screenName = "Statistics"
InGameStats.imgName = "icon_comparacao_"

local statistics
local currentStats

local function createTeamsBadges(yPos)
    local badgesGroup = display.newGroup()
    local homeTeamLogo = TextureManager.newLogo(MatchManager:getTeamLogoImg(true, 2), 48, badgesGroup)
    homeTeamLogo.x = SCREEN_LEFT + CONTENT_WIDTH*0.25
    homeTeamLogo.y = 0
    local awayTeamLogo = TextureManager.newLogo(MatchManager:getTeamLogoImg(false, 2), 48, badgesGroup)
    awayTeamLogo.x = SCREEN_LEFT + CONTENT_WIDTH*0.75
    awayTeamLogo.y = 0
    badgesGroup:setReferencePoint(display.TopCenterReferencePoint)
    badgesGroup.y = yPos
    local xTxt = display.newText(badgesGroup, "X", 0, 0, "MyriadPro-BoldCond", 32)
    xTxt.x = SCREEN_LEFT + CONTENT_WIDTH*0.5
    xTxt.y = 0
    xTxt:setTextColor(128)
    return badgesGroup
end

local function createBGBar(slim)
    local bgBarGroup = display.newGroup()

    local height = slim and 16 or 32

    local leftCenterBg = TextureManager.newImageRect("images/stats/bar_base_B.png", CONTENT_WIDTH*0.45, height, bgBarGroup)
    leftCenterBg.x = -leftCenterBg.width*0.5
    local leftBorderBg = TextureManager.newImageRect("images/stats/bar_base_A.png", 5, height, bgBarGroup)
    leftBorderBg.x = leftCenterBg.x - leftCenterBg.width*0.5 - leftBorderBg.width*0.5

    local rightCenterBg = TextureManager.newImageRect("images/stats/bar_base_B.png", CONTENT_WIDTH*0.45, height, bgBarGroup)
    rightCenterBg.x = rightCenterBg.width*0.5
    local rightBorderBg = TextureManager.newImageRect("images/stats/bar_base_C.png", 5, height, bgBarGroup)
    rightBorderBg.x = rightCenterBg.x + rightCenterBg.width*0.5 + rightBorderBg.width*0.5

    return bgBarGroup
end

--- bars configurations
local SINGLE_BAR_Y = 0
local DUO_BAR_Y_TOP = -6
local DUO_BAR_Y_BOTTOM = 9
local SINGLE_BAR_HEIGHT = 30
local DUO_BAR_HEIGHT = 15
local FULL_WIDTH = CONTENT_WIDTH*0.455
local EMPTY_WIDTH = 34
local TOTAL_WITDH = FULL_WIDTH - EMPTY_WIDTH
local ANIMATION_MAX_TIME = 2000

local function createValueBars(rightSide, color, duo, percent, value)
    local valueBarGroup = display.newGroup()

    local img = color == "gold" and "gold" or "red"
    local yPos = duo and (color == "gold" and DUO_BAR_Y_TOP or DUO_BAR_Y_BOTTOM) or SINGLE_BAR_Y
    local height = 15 --duo and DUO_BAR_HEIGHT or SINGLE_BAR_HEIGHT
    local width = TOTAL_WITDH*percent + EMPTY_WIDTH

    local leftBorderBg = TextureManager.newImageRect("images/stats/bar_" .. img .. "_A.png", 5, height, valueBarGroup)
    local leftCenterBg = TextureManager.newImageRect("images/stats/bar_" .. img .. "_B.png", width, height, valueBarGroup)

    local valueTxt = display.newText(valueBarGroup, value, 0, -8, "MyriadPro-BoldCond", 12)
    valueTxt.isVisible = false

    local animationTime = ANIMATION_MAX_TIME*percent
    if rightSide then
        leftBorderBg.xScale = -1

        leftCenterBg:setReferencePoint(display.CenterLeftReferencePoint)
        leftBorderBg:setReferencePoint(display.CenterLeftReferencePoint)

        leftBorderBg.x = leftCenterBg.width + leftBorderBg.width
        leftCenterBg.x = 0

        local textSide = (math.abs(leftBorderBg.x) > 58) and -11 or 10
        valueTxt.x = leftBorderBg.x + textSide

        valueBarGroup:setReferencePoint(display.CenterLeftReferencePoint)
    else
        leftCenterBg:setReferencePoint(display.CenterRightReferencePoint)
        leftBorderBg:setReferencePoint(display.CenterRightReferencePoint)

        leftBorderBg.x = -leftCenterBg.width
        leftCenterBg.x = 0

        local textSide = (math.abs(leftBorderBg.x) > 58) and 11 or -10
        valueTxt.x = leftBorderBg.x - leftBorderBg.width + textSide

        valueBarGroup:setReferencePoint(display.CenterRightReferencePoint)
    end
    transition.from(leftCenterBg, {time = animationTime, xScale = 0.1})
    transition.from(leftBorderBg, {time = animationTime, x = 0, onComplete = function() valueTxt.isVisible = true end})

    valueBarGroup.y = yPos
    valueBarGroup.x = 0

    return valueBarGroup
end

local function createDescriptionBarBG(blendMode)
    local centerBarGroup = display.newGroup()

    local titleCenter = TextureManager.newImageRect("images/stats/bar_stats_B.png", 64, 28, centerBarGroup)
    titleCenter.blendMode = blendMode
    local titleBorderLeft = TextureManager.newImageRect("images/stats/bar_stats_A.png", 10, 28, centerBarGroup) --17
    titleBorderLeft.blendMode = blendMode
    local titleBorderRight = TextureManager.newImageRect("images/stats/bar_stats_C.png", 20, 28, centerBarGroup) --35
    titleBorderRight.blendMode = blendMode
    titleBorderLeft.x = titleCenter.x - titleCenter.width*0.5 - titleBorderLeft.width*0.5
    titleBorderRight.x = titleCenter.x + titleCenter.width*0.5 + titleBorderRight.width*0.5

    return centerBarGroup
end

local function createDescriptionBar(name, firstStatName, secondStatName, color)
    local centerBarGroup = display.newGroup()

    local normalBg = createDescriptionBarBG("normal")
    local blendedBg = createDescriptionBarBG("screen")
    blendedBg.alpha = 0.6
    blendedBg.isVisible = false
    centerBarGroup.over = blendedBg
    centerBarGroup:insert(normalBg)
    centerBarGroup:insert(blendedBg)
    centerBarGroup:setReferencePoint(display.CenterReferencePoint)
    centerBarGroup.x = 0

    local titleTxt = display.newEmbossedText(centerBarGroup, name, 0, 0, "MyriadPro-BoldCond", 11)
    titleTxt:setTextColor(128, 128)
    titleTxt.x = 5
    titleTxt.y = -4

    local firstStatTxt = display.newText(centerBarGroup, firstStatName, 0, 0, "MyriadPro-BoldCond", 10)
    if color == "red" then
        firstStatTxt:setTextColor(148, 33, 37)
    else
        firstStatTxt:setTextColor(135, 112, 63)
    end
    firstStatTxt.x = 3
    firstStatTxt.y = 6

    if secondStatName then
        firstStatTxt.y = 5
        local secondStatTxt = display.newText(centerBarGroup, secondStatName, 0, 0, "MyriadPro-BoldCond", 10)
        secondStatTxt:setTextColor(148, 33, 37)
        secondStatTxt.x = 1
        secondStatTxt.y = 14
    end

    return centerBarGroup
end

local function createPlayerName(text, x, y, group)
    local fontSize = 11
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
        txt = display.newText(group, sanitizedText, x, y, WIDTH_LIMIT, fontSize, "MyriadPro-Cond", fontSize)
    else
        txt = display.newText(group, sanitizedText, x, y, "MyriadPro-Cond", fontSize)
    end
    txt:setTextColor(32)
    return txt
end

local function sortPlayers(players)
    local sortedPlayers = {}
    for playerName, v in pairs(players) do
        local added
        for i = 1, #sortedPlayers do
            if v > sortedPlayers[i].value then
                table.insert(sortedPlayers, i, {name = playerName, value = v})
                added = true
                break
            end
        end
        if not added then
            sortedPlayers[#sortedPlayers + 1] = {name = playerName, value = v}
        end
    end
    return sortedPlayers
end

local function createPlayersStats(group, statName)
    if not statistics or (group.parent.openedStat and group.parent.openedStat == group) then
        group.parent:close()
        return
    elseif group.parent.openedStat then
        group.parent:close()
    end

    local homePlayers = sortPlayers(statistics.home_team.stats[statName].players)
    local awayPlayers = sortPlayers(statistics.guest_team.stats[statName].players)

    local playersGroup = display.newGroup()
    playersGroup:setReferencePoint(display.TopCenterReferencePoint)
    playersGroup.y = 12
    local height
    local lineYPos = 0
    local statXPos = -104 - (-display.screenOriginX) - 10
    local playerXPos = statXPos + 8
    for i, player in ipairs(homePlayers) do
        createPlayerName(player.name, playerXPos, lineYPos, playersGroup)
        local stat = display.newText(playersGroup, player.value, statXPos, lineYPos, "MyriadPro-BoldCond", 11)
        stat:setTextColor(32)
        lineYPos = lineYPos + 12
    end
    height = lineYPos
    lineYPos = 0
    statXPos = 32 + (-display.screenOriginX)
    playerXPos = statXPos + 8
    for i, player in ipairs(awayPlayers) do
        createPlayerName(player.name, playerXPos, lineYPos, playersGroup)
        local stat = display.newText(playersGroup, player.value, statXPos, lineYPos, "MyriadPro-BoldCond", 11)
        stat:setTextColor(32)
        lineYPos = lineYPos + 12
    end
    if lineYPos > height then
        height = lineYPos
    end
    playersGroup.alpha = 0
    playersGroup.yScale = 0.1

    group.players = playersGroup
    group:insert(playersGroup)

    group.parent:open(group, height, function() transition.to(playersGroup, {time = 150, alpha = 1, yScale = 1}) end)
end

local function createButton(scrollView, group, button, statName)
    local function listener(target, event)
        if event.phase == "began" then
            display.getCurrentStage():setFocus(button)
            button.isFocus = true
            button.over.isVisible = true
            AudioManager.playAudio("btn")
        elseif button.isFocus then
            if event.phase == "moved" then
                local dy = math.abs((event.y - event.yStart))
                -- If our finger has moved more than the desired range
                if dy > 10 then
                    button.isFocus = nil
                    button.over.isVisible = false
                    -- Pass the focus back to the scrollView
                    scrollView:takeFocus( event )
                end
            elseif event.phase == "ended" then
                button.over.isVisible = false
                button.isFocus = nil
                display.getCurrentStage():setFocus(nil)
                createPlayersStats(group, statName)
            end
        end
        return true
    end
    button.touch = listener
    button:addEventListener("touch", button)
end

local function getBigger(numbers)
    local bigger = 0
    for i, num in ipairs(numbers) do
        if num > bigger then
            bigger = num
        end
    end
    return bigger
end

local function createStatBars(_statistic, scrollView)
    local statsBarGroup = display.newGroup()


    --if _statistic.stat then
    statsBarGroup:insert(createBGBar(true))
    local homeStat = 0
    local awayStat = 0
    local homeStatBarSize = 0
    local awayStatBarSize = 0

    local homeBar = createValueBars(false, _statistic.statColor, false, homeStatBarSize, homeStat)
    statsBarGroup:insert(homeBar)
    local awayBar = createValueBars(true , _statistic.statColor, false, awayStatBarSize, awayStat)
    statsBarGroup:insert(awayBar)
    currentStats[_statistic.stat] = {homeValue = homeStat, homeBar = homeBar, awayValue = awayStat, awayBar = awayBar}


    local descriptionBar = createDescriptionBar(_statistic.name, _statistic.statName, nil, _statistic.statColor)
    statsBarGroup:insert(descriptionBar)
    statsBarGroup.button = createButton(scrollView, statsBarGroup, descriptionBar, _statistic.stat)
    --else
    --    statsBarGroup:insert(createBGBar(false))
    --    local home1Stat = statistics.home_team.stats[_statistic.firstStat].total
    --    local home2Stat = statistics.home_team.stats[_statistic.secondStat].total
    --    local away1Stat = statistics.guest_team.stats[_statistic.firstStat].total
    --    local away2Stat = statistics.guest_team.stats[_statistic.secondStat].total
    --    local home1StatBarSize
    --    local home2StatBarSize
    --    local away1StatBarSize
    --    local away2StatBarSize
    --    local bigger = getBigger({home1Stat, home2Stat, away1Stat, away2Stat})
    --
    --    if bigger == 0 then
    --        home1StatBarSize = 0
    --        home2StatBarSize = 0
    --        away1StatBarSize = 0
    --        away2StatBarSize = 0
    --    else
    --        home1StatBarSize = (1/bigger)*home1Stat
    --        home2StatBarSize = (1/bigger)*home2Stat
    --        away1StatBarSize = (1/bigger)*away1Stat
    --        away2StatBarSize = (1/bigger)*away2Stat
    --    end
    --
    --    statsBarGroup:insert(createValueBars(false, "gold", true, home1StatBarSize, home1Stat))
    --    statsBarGroup:insert(createValueBars(false, "red" , true, home2StatBarSize, home2Stat))
    --    statsBarGroup:insert(createValueBars(true , "gold", true, away1StatBarSize, away1Stat))
    --    statsBarGroup:insert(createValueBars(true , "red" , true, away2StatBarSize, away2Stat))
    --
    --    local descriptionBar, button = createDescriptionBar(_statistic.name, _statistic.firstStatName, _statistic.secondStatName)
    --    statsBarGroup:insert(descriptionBar)
    --    createButton(scrollView, statsBarGroup, button, firstStat, secondStat, color)
    --end

    return statsBarGroup
end

local statisticsBars = {
    --{name = "FINALIZAÇÕES", firstStat = "shots_on_target", secondStat = "shots_off_target", firstStatName = "CERTAS", secondStatName = "ERRADAS"}, --*
    --{name = "CRUZAMENTOS", firstStat = "right_crossings", secondStat = "wrong_crossings", firstStatName = "CERTOS", secondStatName = "ERRADOS"},  --*

    {name = "FINALIZAÇÕES", stat = "shots_on_target", statName = "CERTAS", statColor = "gold"}, --*
    {name = "FINALIZAÇÕES", stat = "shots_off_target", statName = "ERRADAS", statColor = "red"}, --*
    {name = "CRUZAMENTOS", stat = "right_crossings", statName = "CERTOS", statColor = "gold"},  --*
    {name = "CRUZAMENTOS", stat = "wrong_crossings", statName = "ERRADOS", statColor = "red"},  --*

    {name = "DESARMES", stat = "right_tackles", statName = "COMPLETOS", statColor = "gold"},     --*
    {name = "DRIBLES", stat = "right_dribblings", statName = "COMPLETOS", statColor = "gold"},      --*

    {name = "PASSES", stat = "wrong_passes", statName = "ERRADOS", statColor = "red"},       --*
    {name = "FALTAS", stat = "fouls", statName = "COMETIDAS", statColor = "red"},       --*

    --{name = "PÊNALTIS"},
    --{name = "IMPEDIMENTOS"},
    --{name = "PERDA DE BOLA"},
    --{name = "DEFESAS"},
}

-- shots            RW

-- fouls            CR
-- penalty          CR
-- offsides

-- passes           RW
-- crossings        RW

-- tackles          RW
-- dribblings       RW
-- balls_lost
-- saves

--x lobbed passes    RW

local function createStats(yPos, scrollView)
    local statsGroup = display.newGroup()

    local _yPos = yPos
    for i, _statistic in ipairs(statisticsBars) do
        local bar = createStatBars(_statistic, scrollView)
        bar:setReferencePoint(display.TopCenterReferencePoint)
        --bar.x = 0
        bar.y = _yPos
        _yPos = _yPos + bar.height + 6
        statsGroup:insert(bar)
    end

    local function transitionStat(obj, dist, onComplete)
        transition.to(obj, {time = 200, y = obj.y + dist, onComplete = onComplete})
    end

    function statsGroup:open(group, height, onComplete)
        if self.isMoving then
            if not self.openTimer then
                self.openTimer = timer.performWithDelay(200, function()
                    self.openTimer = nil
                    self:open(group, height, onComplete)
                end)
            end
            return
        end
        local scrollY = scrollView:getContentPosition()
        local bottomAreaLimit = 280 + (-display.screenOriginY)
        local beforeYDiff
        local afterYDiff

        if group.y + scrollY + height > bottomAreaLimit then
            local diff = bottomAreaLimit - (group.y + scrollY + height)
            if diff < -height then
                diff = -height
            end
            beforeYDiff = diff
            afterYDiff = height - math.abs(diff)
        else
            beforeYDiff = 0
            afterYDiff = height
        end

        self.isMoving = true
        --scrollView.badges.y = scrollView.badges.y + beforeYDiff
        transitionStat(scrollView.badges, beforeYDiff, function()
            self.isMoving = false
            onComplete()
        end)
        local afterGroup
        for i = 1, self.numChildren do
            if self[i] == group then
                afterGroup = true
                --group.y = group.y + beforeYDiff
                transitionStat(group, beforeYDiff)
            elseif afterGroup then
                --self[i].y = self[i].y + afterYDiff
                transitionStat(self[i], afterYDiff)
            else
                --self[i].y = self[i].y + beforeYDiff
                transitionStat(self[i], beforeYDiff)
            end
        end
        self.beforeYDiff = beforeYDiff
        self.afterYDiff = afterYDiff
        self.openedStat = group
    end

    function statsGroup:close()
        if self.openedStat then
            if self.isMoving then
                if not self.closeTimer then
                    self.closeTimer = timer.performWithDelay(200, function()
                        self.closeTimer = nil
                        self:close()
                    end)
                end
                return
            end
            self.isMoving = true
            --scrollView.badges.y = scrollView.badges.y - self.beforeYDiff
            transitionStat(scrollView.badges, -self.beforeYDiff, function()
                self.isMoving = false
            end)
            local afterGroup
            for i = 1, self.numChildren do
                if afterGroup then
                    --self[i].y = self[i].y - self.afterYDiff
                    transitionStat(self[i], -self.afterYDiff)
                else
                    if self[i] == self.openedStat then
                        afterGroup = true
                    end
                    --self[i].y = self[i].y - self.beforeYDiff
                    transitionStat(self[i], -self.beforeYDiff)
                end
            end
            transition.to(self.openedStat.players, {time = 150, alpha = 0, yScale = 0.1, onComplete = function()
                self.openedStat.players:removeSelf()
                self.openedStat.players = nil
                self.openedStat = nil
            end})
        end
    end

    statsGroup:setReferencePoint(display.TopCenterReferencePoint)
    statsGroup.x = display.contentCenterX
    statsGroup.y = yPos

    return statsGroup
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
                elseif event.phase == "ended" then
                    event.target.statsView:close()
                end
            end
        }
    return scrollGroup
end

function InGameStats:update(match_details)
    statistics = match_details

    self.statsView:close()
    for i, _statistic in ipairs(statisticsBars) do
        local _currentStat = currentStats[_statistic.stat]
        if _currentStat.homeValue ~= statistics.home_team.stats[_statistic.stat].total or
                _currentStat.awayValue ~= statistics.guest_team.stats[_statistic.stat].total then
            transition.to(_currentStat.homeBar, {time = 200, alpha = 0})
            transition.to(_currentStat.awayBar, {time = 200, alpha = 0, onComplete = function()
                local group = _currentStat.homeBar.parent
                _currentStat.homeBar:removeSelf()
                _currentStat.awayBar:removeSelf()

                local homeStat = statistics.home_team.stats[_statistic.stat].total
                local awayStat = statistics.guest_team.stats[_statistic.stat].total
                local homeStatBarSize = 1
                local awayStatBarSize = 1

                if homeStat > awayStat then
                    awayStatBarSize = (1/homeStat)*awayStat
                elseif homeStat < awayStat then
                    homeStatBarSize = (1/awayStat)*homeStat
                elseif homeStat == 0 then
                    homeStatBarSize = 0
                    awayStatBarSize = 0
                end

                local homeBar = createValueBars(false, _statistic.statColor, false, homeStatBarSize, homeStat)
                group:insert(2, homeBar)
                local awayBar = createValueBars(true , _statistic.statColor, false, awayStatBarSize, awayStat)
                group:insert(2, awayBar)
                currentStats[_statistic.stat] = {homeValue = homeStat, homeBar = homeBar, awayValue = awayStat, awayBar = awayBar}
            end})
        end
    end
end

function InGameStats:toFront()
    self.isVisible = true
end

function InGameStats:toBack()
    self.isVisible = false
end

function InGameStats:create()
    local lineupsGroup = display.newGroup()
    for k, v in pairs(InGameStats) do
        lineupsGroup[k] = v
    end

    currentStats = {}

    local scrollView = createScrollView()
    lineupsGroup:insert(scrollView)

    local initialY = SCREEN_TOP + 64
    local badges = createTeamsBadges(initialY)
    local statsView = createStats(initialY + badges.height + 8, scrollView)
    lineupsGroup.statsButtons = {}
    for i = 1, statsView.numChildren do
        lineupsGroup.statsButtons[#lineupsGroup.statsButtons + 1] = statsView[i].button
    end

    scrollView.badges = badges
    scrollView.statsView = statsView
    lineupsGroup.statsView = statsView
    scrollView:insert(badges)
    scrollView:insert(statsView)

    local touchHandler = display.newRect(display.screenOriginX, 0, CONTENT_WIDTH, badges.height + statsView.height)
    touchHandler:setReferencePoint(display.TopCenterReferencePoint)
    touchHandler.y = initialY
    touchHandler.alpha = 0.01
    scrollView:insert(1, touchHandler)

    return lineupsGroup
end

function InGameStats:destroy()
    if self.timer then
        timer.cancel(self.timer)
    end
    if self.statsButtons then
        for i = #self.statsButtons, 1, -1 do
            self.statsButtons[i]:removeEventListener("touch", self.statsButtons[i])
            self.statsButtons[i] = nil
        end
    end
    self.statsButtons = nil
    self:removeSelf()
    statistics = nil
end

return InGameStats