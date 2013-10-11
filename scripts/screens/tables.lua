--[[==============
== We Love Quiz
== Date: 14/06/13
== Time: 12:15
==============]]--
local widget = require "widget"
require "scripts.widgets.view.button_open_menu"

TablesScreen = {}

local tablesGroup
local isBgOpen
local isInTransition
local championshipButtons
local OPENED_HEIGHT = 342 + (display.screenOriginY*-2)

local function closeChampionshipButtons(openingButton)
    for i, button in ipairs(championshipButtons) do
        if button ~= openingButton and button.isOpen then
            button:close()
            button.isOpen = false
            button.parent[button.parent.numChildren].isVisible = true
        end
    end
end

local function displaceOpenChampBtns(openingButtonY, partHeight)
    for i, button in ipairs(championshipButtons) do
        if button.y > openingButtonY then
            transition.to(button.parent, {time = 200, y = button.parent.y + partHeight})
        end
    end
end

local function displaceCloseChampBtns()
    for i, button in ipairs(championshipButtons) do
        transition.to(button.parent, {time = 200, y = SCREEN_TOP + 68})
    end
end

local function createTouchHandler(yPos)
    local touchHandler = display.newRect(display.screenOriginX + 1, yPos - 3, CONTENT_WIDTH - 2, 74)
    touchHandler.strokeWidth = 2
    touchHandler:setStrokeColor(0, 0, 0, 64)
    local g = graphics.newGradient(
        { 180,  180,  180, 128 },
        { 0,  0,  0, 96 },
        "down" )
    touchHandler:setFillColor( g )
    touchHandler.alpha = 0.01
    return touchHandler
end

local openBG
local closeBG
local TABLE_STATS = {
    {abrev =  "POS", x =   8, key = nil},
    {abrev = "TIME", x =  30, key = "team_name"},
    {abrev =   "PG", x = 115, key = "points"},
    {abrev =    "J", x = 140, key = "matches_played"},
    {abrev =    "V", x = 165, key = "victories"},
    {abrev =    "E", x = 190, key = "draw"},
    {abrev =    "D", x = 215, key = "defeats"},
    {abrev =   "GP", x = 240, key = "goals_scored"},
    {abrev =   "GC", x = 265, key = "goals_conceded"},
    {abrev =   "SG", x = 290, key = "goals_balance"},
}

local function createTeamView(group, team, pos, y)
    for i, v in ipairs(TABLE_STATS) do
        local text = display.newText(team[v.key] or pos, v.x, y, "MyriadPro-BoldCond", 12)
        text:setTextColor(96)

        if v.key == "points" then
            text:setTextColor(0)
        elseif not v.key then
            if pos <= 4 then
                text:setTextColor(0, 0, 224)
            elseif pos >= 17 then
                text:setTextColor(224, 0, 0)
            end
        end

        if v.key ~= "team_name" then
            text:setReferencePoint(display.TopRightReferencePoint)
            text.x = v.x + 16
            text.y = y
        end
        group:insert(text)
    end

    group:insert(TextureManager.newHorizontalLine(display.contentCenterX, y + 16, CONTENT_WIDTH))
end

local function newStatsBar(y)
    local barGroup = display.newGroup()

    local border = TextureManager.newImageRect("images/stats/bar_stats_A.png", 8, 22, barGroup)
    local center = TextureManager.newImageRect("images/stats/bar_stats_B.png", CONTENT_WIDTH - 24, 22, barGroup)
    center.x = center.width*0.5 + border.width*0.5
    local border = TextureManager.newImageRect("images/stats/bar_stats_C.png", 16, 22, barGroup)
    border.x = center.x + center.width*0.5 + border.width*0.5

    for i, v in ipairs(TABLE_STATS) do
        local text = display.newEmbossedText(barGroup, v.abrev, v.x, -8, "MyriadPro-BoldCond", 12)
        text:setTextColor(96)
    end

    barGroup:setReferencePoint(display.TopCenterReferencePoint)
    barGroup.x = display.contentCenterX
    barGroup.y = y

    return barGroup
end

local function createColumnSeparator(x, y)
    local rect = display.newRect(0, 0, 25, OPENED_HEIGHT)
    rect:setFillColor(128, 64)
    rect:setReferencePoint(display.TopCenterReferencePoint)
    rect.x = x
    rect.y = y
    return rect
end

local function createChampionshipTableView(table, topY)
    -- Create a ScrollView
    local scrollSize = OPENED_HEIGHT - 48
    local distToBottom = SCREEN_BOTTOM - topY
    scrollSize = distToBottom < scrollSize and distToBottom or scrollSize

    local maskSize = OPENED_HEIGHT > 342 and "big" or "default"

    local matchesGroup = widget.newScrollView
        {
            width = SCREEN_RIGHT,
            height = scrollSize,
            maskFile = "images/masks/rankingscreen_" .. maskSize .. "_mask.png",
            hideBackground = true,
            hideScrollBar = true,
            verticalScrollDisabled = maskSize == "big",
            horizontalScrollDisabled = true,
            isBounceEnabled = false
        }

    if table then
        local yPos = 30
        for i, team in ipairs(table) do
            --print("createMatchView", (i - 1)*73 + (dateSeparatorCount*42))
            createTeamView(matchesGroup, team, i, yPos)
            yPos = yPos + 20
        end
    end

    matchesGroup.y = topY - 8

    --print(scrollSize, matchesGroup.height)
    return matchesGroup
end

function closeBG(onClose)
    tablesGroup.openButton = nil
    tablesGroup.openChampNum = nil
    tablesGroup.bg:close(function()
        tablesGroup[1]:removeSelf()
        isBgOpen = false
        if onClose then
            timer.performWithDelay(200, onClose)
        else
            isInTransition = false
            unlockScreen()
        end
    end)
    displaceCloseChampBtns()
    isInTransition = true
    lockScreen()
end

function openBG(button)
    local yOpenPart = button.y + SCREEN_TOP + 89
    local partHeight
    if isBgOpen then
        closeBG(function()
            closeChampionshipButtons(button)
            openBG(button)
        end)
        return
    end
    isBgOpen = true
    tablesGroup.openButton = button
    local championshipTableGroup = display.newGroup()
    local columnX = 124
    for i = 1, 4 do
        championshipTableGroup:insert(createColumnSeparator(columnX, yOpenPart))
        columnX = columnX + 50
    end
    local championshipTableView = createChampionshipTableView(button.table, yOpenPart + 8)
    championshipTableGroup:insert(championshipTableView)
    championshipTableGroup:insert(newStatsBar(yOpenPart + 8))
    tablesGroup:insert(1, championshipTableGroup)
    local distToBottom = SCREEN_BOTTOM - yOpenPart
    partHeight = distToBottom < OPENED_HEIGHT and distToBottom or (championshipTableView.height < OPENED_HEIGHT and championshipTableView.height + 4 or OPENED_HEIGHT)
    tablesGroup.bg:open(yOpenPart, partHeight, function()
        isInTransition = false
        unlockScreen()
    end)

    button:open()
    button.parent[button.parent.numChildren].isVisible = false
    displaceOpenChampBtns(button.y, partHeight)

    isInTransition = true
    lockScreen()
end

local function createOpenMenuLine(isBottom)
    local lineGroup = display.newGroup()
    local line = display.newLine(lineGroup, SCREEN_LEFT, display.screenOriginY, SCREEN_RIGHT, display.screenOriginY)
    if isBottom then
        line:setColor(255)
    else
        line:setColor(135, 224)
    end
    local lineShadow = TextureManager.newImageRect("images/stretchable/stru_shadow.png", CONTENT_WIDTH, 20, lineGroup)
    lineShadow.x = display.contentCenterX
    lineShadow.y = display.screenOriginY + (isBottom and -10 or 10)
    lineShadow.yScale = isBottom and -lineShadow.yScale or lineShadow.yScale
    lineGroup:setReferencePoint(isBottom and display.BottomCenterReferencePoint or display.TopCenterReferencePoint)

    return lineGroup
end

local function createBG()
    local bgGroup = display.newGroup()

    local bgTop = TextureManager.newImageRect("images/stretchable/stru_menu_bg.png", CONTENT_WIDTH, CONTENT_HEIGHT, bgGroup)
    bgTop.x = display.contentCenterX
    bgTop.y = display.contentCenterY
    local menuMask = graphics.newMask("images/masks/menuselectmatch_mask.png")
    bgTop:setMask(menuMask)
    local bgBottom = TextureManager.newImageRect("images/stretchable/stru_menu_bg.png", CONTENT_WIDTH, CONTENT_HEIGHT, bgGroup)
    bgBottom.x = display.contentCenterX
    bgBottom.y = display.contentCenterY
    local menuMask = graphics.newMask("images/masks/menuselectmatch_mask.png")
    bgBottom:setMask(menuMask)

    local CENTER_MASK_Y = 282.5
    bgTop.maskY = -CENTER_MASK_Y
    bgBottom.maskY = CENTER_MASK_Y

    local lineTop = createOpenMenuLine(false)
    bgGroup:insert(lineTop)

    local lineBottom = createOpenMenuLine(true)
    bgGroup:insert(lineBottom)

    function bgGroup:showUp(onComplete)
        self.isVisible = true
        transition.from(self, {time = 500, alpha = 0, onComplete = onComplete})
    end

    function bgGroup:hide()
        transition.to(self, {time = 500, alpha = 0, onComplete = TablesScreen.destroy})
    end

    function bgGroup:open(yOpenPart, partHeight, onComplete)
        lineTop.y = yOpenPart - 1
        lineBottom.y = lineTop.y + 1
        lineBottom.alpha = 0
        transition.to(lineBottom, {time = 200, y = yOpenPart + partHeight + 2, alpha = 1})

        bgTop.maskY = -CENTER_MASK_Y - (display.contentCenterY) + yOpenPart
        bgBottom.maskY = CENTER_MASK_Y - (display.contentCenterY) + yOpenPart
        transition.to(bgBottom, {time = 200, maskY = CENTER_MASK_Y - (display.contentCenterY) + yOpenPart + partHeight, onComplete = onComplete})
    end

    function bgGroup:close(onComplete)
        transition.to(bgBottom, {time = 200, maskY = CENTER_MASK_Y*2 + bgTop.maskY, onComplete = onComplete})
        lineTop.y = display.screenOriginY
        lineBottom.y = display.screenOriginY
    end

    return bgGroup
end

local function createChampionshipsList(championshipList)
    local championshipsListGroup = display.newGroup()
    local Y_CHAMPIONSHIP = 50
    for i, championship in ipairs(championshipList) do
        if championship.ranking_url then
            local championshipGroup = display.newGroup()
            local title = display.newText(string.utf8upper(championship.name), 0, 0, "MyriadPro-BoldCond", 24)
            title.x = title.width*0.5 + 8
            title.y = (i - 1)*Y_CHAMPIONSHIP
            title:setTextColor(0)
            local arrow = ButtonOpenMenu:new(function(button, event)
                if isInTransition then
                    return true
                end
                button.isOpen = not button.isOpen
                if button.isOpen then
                    openBG(button)
                else
                    closeBG()
                    button:close()
                    button.parent[button.parent.numChildren].isVisible = true
                end
                return true
            end)
            championshipGroup:insert(arrow)
            arrow.x = SCREEN_RIGHT - arrow.width*0.5
            arrow.y = (i - 1)*Y_CHAMPIONSHIP - 6
            arrow:lock(true)
            championshipGroup:insert(title)
            championshipButtons[#championshipButtons + 1] = arrow
            championshipGroup:insert(TextureManager.newHorizontalLine(display.contentCenterX, (i - 1)*Y_CHAMPIONSHIP + title.height*0.5 + 4, CONTENT_WIDTH*0.9))
            championshipGroup.x = 0
            championshipGroup.y = SCREEN_TOP + 68

            local spinnerDefault = LoadingBall:createBall(SCREEN_RIGHT - 20, (i - 1)*Y_CHAMPIONSHIP)
            championshipGroup:insert(spinnerDefault)
            Server.getChampionshipTable(championship.ranking_url, function(response, status)
                if status == 200 and response.ranking and response.ranking.entries then
                    --printTable(response)
                    if tablesGroup then
                        arrow.table = response.ranking.entries
                        spinnerDefault:removeSelf()
                        arrow:lock(false)
                        timer.performWithDelay(900, function()
                            if tablesGroup then
                                local someOpen
                                for i = 1, championshipsListGroup.numChildren do
                                    if championshipsListGroup[i][1].isOpen then
                                        someOpen = true
                                    end
                                end
                                if not someOpen then
                                    championshipsListGroup[i][1].isOpen = true
                                    openBG(championshipsListGroup[i][1])
                                end
                            end
                        end)
                    end
                else
                    printTable(response)
                end
            end)

            championshipsListGroup:insert(championshipGroup)
        end
    end

    championshipsListGroup.isVisible = false
    function championshipsListGroup:showUp()
        self.isVisible = true
        for i = 1, self.numChildren do
            transition.from(self[i], {delay = 300, time = 300, y = 50*-i - 50, transition = easeInQuart})
        end
        timer.performWithDelay(900, unlockScreen)
        if self.numChildren > 0 then
            AudioManager.playAudio("openCloseMenu", 500)
        end
    end

    function championshipsListGroup:hide()
        for i = 1, self.numChildren do
            transition.to(self[i], {time = 300, y = 50*-i - 50, transition = easeInQuart})
        end
    end

    return championshipsListGroup
end

function TablesScreen:showUp(onComplete)
    tablesGroup.bg:showUp(function()
        tablesGroup.championshipsList:showUp()
        tablesGroup.topBar.isVisible = true
        transition.from(tablesGroup.topBar, {time = 300, y = SCREEN_TOP - 50, transition = easeInQuart})
        AudioManager.playAudio("showTopBar")
        timer.performWithDelay(650, function()
            onComplete()
            lockScreen()
        end)
    end)
end

function TablesScreen:hide(onComplete)
    local function hiding()
        tablesGroup.championshipsList:hide()
        transition.to(tablesGroup.topBar, {delay = 300, time = 300, y = SCREEN_TOP - 50, transition = easeInQuart, onComplete = function()
            tablesGroup.bg:hide()
            onComplete()
        end})
    end

    if isBgOpen then
        closeBG(hiding)
    else
        hiding()
    end
end

function TablesScreen:new()
    isBgOpen = false
    isInTransition = false
    tablesGroup = display.newGroup()
    championshipButtons = {}

    tablesGroup.bg = createBG()
    tablesGroup:insert(tablesGroup.bg)
    tablesGroup.championshipsList = createChampionshipsList(MatchManager:getChampionshipsList())
    tablesGroup:insert(tablesGroup.championshipsList)
    tablesGroup.topBar = TopBarMenu:new("CLASSIFICAÇÃO")
    tablesGroup.topBar.isVisible = false
    tablesGroup:insert(tablesGroup.topBar)

    AnalyticsManager.enteredTablesScreen()

    return tablesGroup
end

function TablesScreen:destroy()
    tablesGroup:removeSelf()
    tablesGroup = nil
    championshipButtons = nil
end

return TablesScreen