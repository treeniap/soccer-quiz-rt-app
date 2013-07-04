--[[==============
== We Love Quiz
== Date: 14/05/13
== Time: 12:08
==============]]--
QuestionsBar = {}

require "scripts.widgets.view.button_open_questions"
require "scripts.widgets.view.button_next"

local questionsBarGroup
local openCloseBtn, nextBtn, undoBtn, chronometer, facebookBtn, twitterBtn
local barTrans

local VER_LINE_1_X = 200 + (-display.screenOriginX)
local VER_LINE_2_X = 260 + (-display.screenOriginX)

local HOR_LINE_Y_INCR = 60

local OPENED_MASK = "half"
local OPENED_SIZE = OPENED_MASK == "big" and 100 or 0

local function openCloseListener(button, event)
    if barTrans then
        return true
    end
    if button.isOpen then
        barTrans = transition.to(button.bar, {time = 1000, y = button.bar.closedY, transition = easeOutBounce, onComplete = function()
            barTrans = nil
            button:changeState(false)
        end})
    else
        barTrans = transition.to(button.bar, {time = 250, y = button.bar.openedY, transition = easeInBack, onComplete = function()
            barTrans = nil
            button:changeState(false)
        end})
    end
    button.isOpen = not button.isOpen
    return true
end

local function createScrollGroup()
    local widget = require "widget"
    -- Create a ScrollView
    local scrollView = widget.newScrollView
        {
            width = SCREEN_RIGHT,
            height = 160 + OPENED_SIZE + (display.screenOriginY*-2),
            maskFile = "images/questions_mask_" .. OPENED_MASK .. ".png",
            hideBackground = true,
            horizontalScrollDisabled = true
        }

    return scrollView
end

--{text = "Bragantines fará gol no primeiro tempo?", answer = "SIM", prize = 5, result = "right"},
local function createQuestionLine(question, horLineY)
    local questionGroup = display.newGroup()
    questionGroup.y = horLineY

    local qText = display.newText(questionGroup, question.text, display.screenOriginX + 12, 8, VER_LINE_1_X - (display.screenOriginX + 12), HOR_LINE_Y_INCR - 12, "MyriadPro-Cond", 20)
    local aText = display.newText(question.answer, VER_LINE_1_X + 8, 16, "MyriadPro-BoldCond", 32)
    if question.answer == "" then
        question.result = "wrong"
    end

    if question.result == "waiting" then
        qText:setTextColor(92)
        aText:setTextColor(92)
        local iconTime = TextureManager.newImage("stru_icontime", questionGroup)
        iconTime.x = VER_LINE_2_X + HOR_LINE_Y_INCR*0.5
        iconTime.y = HOR_LINE_Y_INCR*0.5
    else
        if question.result == "right" then
            local iconRight = TextureManager.newImage("stru_aright", questionGroup)
            iconRight.x = VER_LINE_1_X + HOR_LINE_Y_INCR*0.5
            iconRight.y = HOR_LINE_Y_INCR*0.5
            local coin = TextureManager.newImage("stru_coin_vote", questionGroup)
            coin.x = VER_LINE_2_X + HOR_LINE_Y_INCR*0.5
            coin.y = HOR_LINE_Y_INCR*0.75
            local pText = display.newText(questionGroup, question.prize, VER_LINE_2_X + 20, 8, "MyriadPro-BoldCond", 50)
            pText:setTextColor(0)
        elseif question.result == "wrong" then
            local iconWrong = TextureManager.newImage("stru_awrong", questionGroup)
            iconWrong.x = VER_LINE_1_X + HOR_LINE_Y_INCR*0.5
            iconWrong.y = HOR_LINE_Y_INCR*0.5
            local pText = display.newText(questionGroup, "_", VER_LINE_2_X + 8, -32, "MyriadPro-BoldCond", 80)
            pText:setTextColor(0)
        end
        qText:setTextColor(0)
        aText:setTextColor(0)
    end

    questionGroup:insert(aText)

    return questionGroup
end

local function createQuestionsList(list)
    local questionsListGroup = createScrollGroup()

    local LIST_HEIGHT = #list*HOR_LINE_Y_INCR

    local vertLine1 = display.newLine(VER_LINE_1_X, 0, VER_LINE_1_X, LIST_HEIGHT)
    vertLine1:setColor(135, 192)
    local vertLine2 = display.newLine(VER_LINE_2_X, 0, VER_LINE_2_X, LIST_HEIGHT)
    vertLine2:setColor(135, 192)
    questionsListGroup:insert(vertLine1)
    questionsListGroup:insert(vertLine2)

    local horLineY = 0
    for i, question in ipairs(list) do
        if not question.wasSaw then
            local lineBg = TextureManager.newImageRect("images/stru_tablehigh.png", CONTENT_WIDTH, HOR_LINE_Y_INCR)
            lineBg.x = display.contentCenterX
            lineBg.y = horLineY + HOR_LINE_Y_INCR*0.5
            questionsListGroup:insert(1, lineBg)
        end
        questionsListGroup:insert(createQuestionLine(question, horLineY))
        questionsListGroup:insert(TextureManager.newHorizontalLine(display.contentCenterX, horLineY, CONTENT_WIDTH))
        --display.newText(playerGroup, player.score .. " pts", 0, 0, "MyriadPro-BoldCond", 16)
        horLineY = horLineY + HOR_LINE_Y_INCR
    end
    questionsListGroup:insert(TextureManager.newHorizontalLine(display.contentCenterX, horLineY, CONTENT_WIDTH))

    local vertLine1 = display.newLine(VER_LINE_1_X + 1, 1, VER_LINE_1_X + 1, LIST_HEIGHT + 1)
    local vertLine2 = display.newLine(VER_LINE_2_X + 1, 1, VER_LINE_2_X + 1, LIST_HEIGHT + 1)
    questionsListGroup:insert(vertLine1)
    questionsListGroup:insert(vertLine2)

    return questionsListGroup
end

function QuestionsBar:getUndoBtn()
    return undoBtn
end

function QuestionsBar:setQuestions(questions)
    local list = createQuestionsList(questions)
    list.x = 0
    list.y = -135 - (-display.screenOriginY)
    self:insert(2, list)
end

function QuestionsBar:createView()
    --- Background
    local bg = display.newRect(0, 0, CONTENT_WIDTH, 270 + (display.screenOriginY*-2))
    bg.x = display.contentCenterX
    bg.y = 0
    bg:setFillColor(216)
    self:insert(bg)

    --- Bar
    local bar = TextureManager.newImage("stru_drawer", self)
    bar.x = display.contentCenterX
    bar.y = -bg.height*0.5 - bar.height*0.5 + 7

    --- Open/Close Button
    openCloseBtn = BtnOpenQuestions:new(openCloseListener)
    openCloseBtn.x = display.contentCenterX
    openCloseBtn.y = bar.y - 8
    openCloseBtn.isVisible = false
    openCloseBtn.bar = self
    self:insert(openCloseBtn)

    --- Next Button
    nextBtn = BtnNext:new(function() ScreenManager:callNext() end)
    nextBtn.x = 311
    nextBtn.y = bar.y + 3
    nextBtn.isVisible = false
    self:insert(nextBtn)

    --- Undo Button
    undoBtn = BtnUndoVote:new()
    undoBtn.x = 47
    undoBtn.y = bar.y - 15
    undoBtn:lock(true)
    undoBtn.isVisible = false
    self:insert(undoBtn)

    --- Chronometer
    chronometer = Chronometer:new()
    chronometer.x = 211
    chronometer.y = bar.y + 11
    chronometer.isVisible = false
    self:insert(chronometer)
    --chronometer:addEventListener("touch", dragAndDrop)

    facebookBtn = BtnFacebook:new(function() return true end)
    facebookBtn.x = 31
    facebookBtn.y = bar.y - 19
    facebookBtn.isVisible = false
    self:insert(facebookBtn)
    --facebookBtn:addEventListener("touch", dragAndDrop)

    twitterBtn = BtnTwitter:new(function() return true end)
    twitterBtn.x = 98
    twitterBtn.y = bar.y - 16
    twitterBtn.isVisible = false
    self:insert(twitterBtn)
    --twitterBtn:addEventListener("touch", dragAndDrop)

    self.closedY = SCREEN_BOTTOM - 172
    self.openedY = SCREEN_TOP + 113 - OPENED_SIZE
end

function QuestionsBar:lock()
    if barTrans then
        transition.cancel(barTrans)
        barTrans = nil
    end
    if self.y ~= self.closedY then
        transition.to(self, {time = 300, y = self.closedY, transition = easeOutQuint})
    end
    openCloseBtn.isOpen = false
    openCloseBtn:changeState(false)
    openCloseBtn:lock(true)
end

function QuestionsBar:showUp(onComplete)
    if barTrans then
        transition.cancel(barTrans)
        barTrans = nil
    end
    transition.to(self, {time = 150, y = self.closedY, transition = easeOutQuint, onComplete = onComplete})
    openCloseBtn.isOpen = false
    openCloseBtn:changeState(false)
end

function QuestionsBar:hide(onComplete)
    if barTrans then
        transition.cancel(barTrans)
        barTrans = nil
    end
    transition.to(self, {time = 150, y = SCREEN_BOTTOM, transition = easeOutQuint, onComplete = onComplete})
    openCloseBtn.isOpen = false
    openCloseBtn:changeState(false)
end

function QuestionsBar:onGame()
    self:hide(function()
        --openCloseBtn.isVisible = true
        openCloseBtn:lock(false)
        nextBtn.isVisible = false
        undoBtn.isVisible = false
        chronometer.isVisible = false
        facebookBtn.isVisible = false
        twitterBtn.isVisible = false
        self:showUp()
    end)
end

function QuestionsBar:onEventBet(onTimeUp, time)
    self:hide(function()
        openCloseBtn.isVisible = false
        nextBtn.isVisible = false
        undoBtn.isVisible = true
        chronometer.isVisible = true
        facebookBtn.isVisible = false
        twitterBtn.isVisible = false

        if onTimeUp then
            chronometer:start(time, onTimeUp)
        end
        self:showUp()
    end)
end

function QuestionsBar:onEventResult()
    self:hide(function()
        openCloseBtn.isVisible = false
        nextBtn.isVisible = true
        undoBtn.isVisible = false
        chronometer.isVisible = false
        facebookBtn.isVisible = false
        twitterBtn.isVisible = false
        self:showUp()
    end)
end

function QuestionsBar:onGameOver()
    self:hide(function()
        --openCloseBtn.isVisible = true
        openCloseBtn:lock(false)
        nextBtn.isVisible = true
        undoBtn.isVisible = false
        chronometer.isVisible = false
        facebookBtn.isVisible = true
        twitterBtn.isVisible = true
        self:showUp()
    end)
end

function QuestionsBar:new()
    if questionsBarGroup then
        return questionsBarGroup
    end
    questionsBarGroup = display.newGroup()
    for k, v in pairs(QuestionsBar) do
        questionsBarGroup[k] = v
    end

    questionsBarGroup:createView()
    questionsBarGroup:setReferencePoint(display.TopCenterReferencePoint)
    questionsBarGroup.y = SCREEN_BOTTOM

    return questionsBarGroup
end

function QuestionsBar:destroy()
    if barTrans then
        transition.cancel(barTrans)
        barTrans = nil
    end
    openCloseBtn:removeSelf()
    nextBtn:removeSelf()
    undoBtn:removeSelf()
    chronometer:removeSelf()
    facebookBtn:removeSelf()
    twitterBtn:removeSelf()
    questionsBarGroup = nil
    openCloseBtn, nextBtn, undoBtn, chronometer, facebookBtn, twitterBtn = nil, nil, nil, nil, nil, nil
end

return QuestionsBar