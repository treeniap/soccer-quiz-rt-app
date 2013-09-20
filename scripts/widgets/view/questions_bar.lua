--[[==============
== We Love Quiz
== Date: 14/05/13
== Time: 12:08
==============]]--
QuestionsBar = {}

require "scripts.widgets.view.button_open_questions"
require "scripts.widgets.view.button_next"
require "scripts.widgets.view.segmented_control"

local questionsBarGroup
local openCloseBtn, nextBtn, undoBtn, chronometer, facebookBtn, twitterBtn, waitingGroup, segmentedControl
local barTrans

local VER_LINE_1_X = 200 + (-display.screenOriginX)
local VER_LINE_2_X = 260 + (-display.screenOriginX)

local HOR_LINE_Y_INCR = 60

local OPENED_MASK = "big"
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
            hideScrollBar = true,
            horizontalScrollDisabled = true
        }
    scrollView.x = 0
    scrollView.y = -135 - (-display.screenOriginY)
    scrollView.num = 0

    return scrollView
end

local function createEventLine(event, num)
    local eventGroup = display.newGroup()

    local vertLine1 = display.newLine(VER_LINE_1_X, 0, VER_LINE_1_X, HOR_LINE_Y_INCR)
    vertLine1:setColor(135, 192)
    local vertLine2 = display.newLine(VER_LINE_2_X, 0, VER_LINE_2_X, HOR_LINE_Y_INCR)
    vertLine2:setColor(135, 192)
    eventGroup:insert(vertLine1)
    eventGroup:insert(vertLine2)

    local goal = TextureManager.newImage("bola_frame01", eventGroup)

    eventGroup:insert(TextureManager.newHorizontalLine(display.contentCenterX, HOR_LINE_Y_INCR, CONTENT_WIDTH))

    local vertLine1 = display.newLine(VER_LINE_1_X + 1, 1, VER_LINE_1_X + 1, HOR_LINE_Y_INCR + 1)
    local vertLine2 = display.newLine(VER_LINE_2_X + 1, 1, VER_LINE_2_X + 1, HOR_LINE_Y_INCR + 1)
    eventGroup:insert(vertLine1)
    eventGroup:insert(vertLine2)

    eventGroup.y = num*HOR_LINE_Y_INCR

    return eventGroup
end

local function createWaiting()
    waitingGroup = display.newGroup()
    local waitingTxt = display.newEmbossedText(waitingGroup, "Aguardando Resultado...", 0, 0, "MyriadPro-BoldCond", 16)
    waitingTxt:setTextColor(32)
    --local ball = LoadingBall:createBall(-24, waitingTxt.height*0.5)
    --waitingGroup:insert(ball)
    waitingGroup:setReferencePoint(display.CenterReferencePoint)
end

function QuestionsBar:getUndoBtn()
    return undoBtn
end

function QuestionsBar:addEvent(event)
    if not self.list then
        self.list = createScrollGroup()
        self:insert(2, self.list)
    end
    self.list:insert(createEventLine(event, self.list.num))
    self.list.num = self.list.num + 1
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
    nextBtn.y = bar.y + 4
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

    facebookBtn = BtnFacebook:new(function(button, event)
        if not button.hasPosted and not MatchManager.finalResultInfo then
            Facebook:post()
            button.hasPosted = true
            timer.performWithDelay(2000, function() button.hasPosted = false end)
        elseif not button.hasPosted and MatchManager.finalResultInfo and MatchManager.finalResultInfo.matchPoints ~= " " then
            Facebook:postMessage("Meus palpites no jogo " .. MatchManager:getTeamName(true) .. " x " ..
                    MatchManager:getTeamName(false) .. " valeram " .. MatchManager.finalResultInfo.matchPoints ..
                    " pontos.") --TODO Estou mais perto de ganhar minha camisa de futebol oficial no prêmio desta semana!")
            button.hasPosted = true
        end
        return true
    end)
    facebookBtn.x = 27
    facebookBtn.y = bar.y - 19
    facebookBtn.isVisible = false
    self:insert(facebookBtn)
    --facebookBtn:addEventListener("touch", dragAndDrop)

    twitterBtn = BtnTwitter:new(function(button, event)
        if not button.hasPosted and not MatchManager.finalResultInfo then
            local twitter
            local function post()
                twitter:showPopup("", "@chutepremiado")
            end
            local listener = function( event )
            --printTable(event)
                if event.phase == "authorised" then
                    post()
                else
                    AnalyticsManager.postTwitter("PostedOnTwitter")
                    --native.showAlert("Twitter", "Pontuação postada.", {"Ok"})
                end
            end
            twitter = require("scripts.network.GGTwitter"):new("kaO6n7jMhgyNzx9lXhLg", "OY0PBfVKizWKfUutKjwh1gt3W99YOmlqbYtgqzg81I", listener)
            if twitter:isAuthorised() then
                post()
            else
                twitter:authorise()
            end
            button.hasPosted = true
            timer.performWithDelay(2000, function() button.hasPosted = false end)
        elseif not button.hasPosted and MatchManager.finalResultInfo and MatchManager.finalResultInfo.matchPoints ~= " " then
            local twitter
            local function post()
                twitter:showPopup("Ganhei " .. MatchManager.finalResultInfo.matchPoints ..
                        " pontos no jogo " .. MatchManager:getTeamName(true) .. " x " ..
                        MatchManager:getTeamName(false) .. ".", "@chutepremiado") --TODO  Estou perto de ganhar minha camisa oficial no prêmio da semana!", "@chutepremiado")
            end
            local listener = function( event )
                --printTable(event)
                if event.phase == "authorised" then
                    post()
                else
                    AnalyticsManager.postTwitter("MatchResult")
                    native.showAlert("Twitter", "Pontuação compartilhada no Twitter.", {"Ok"})
                end
            end
            twitter = require("scripts.network.GGTwitter"):new("kaO6n7jMhgyNzx9lXhLg", "OY0PBfVKizWKfUutKjwh1gt3W99YOmlqbYtgqzg81I", listener)
            if twitter:isAuthorised() then
                post()
            else
                twitter:authorise()
            end
            button.hasPosted = true
        end
        return true
    end)
    twitterBtn.x = 77
    twitterBtn.y = bar.y - 17
    twitterBtn.isVisible = false
    self:insert(twitterBtn)
    --twitterBtn:addEventListener("touch", dragAndDrop)

    segmentedControl = SegmentedControl:new()
    segmentedControl.x = display.contentCenterX + 36
    segmentedControl.y = bar.y + 8
    segmentedControl.isVisible = false
    self:insert(segmentedControl)

    createWaiting()
    waitingGroup.x = display.contentCenterX
    waitingGroup.y = bar.y + 4
    waitingGroup.isVisible = false
    self:insert(waitingGroup)
    
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
        facebookBtn.isVisible = true
        twitterBtn.isVisible = true
        segmentedControl.isVisible = true
        waitingGroup.isVisible = false
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
        segmentedControl.isVisible = false
        waitingGroup.isVisible = false

        if onTimeUp then
            chronometer:start(time, function()
                self:onWaitingBetResponse()
                onTimeUp()
            end)
        end
        self:showUp()
    end)
end

function QuestionsBar:onWaitingBetResponse()
    self:hide(function()
        openCloseBtn.isVisible = false
        nextBtn.isVisible = false
        undoBtn.isVisible = false
        chronometer.isVisible = false
        facebookBtn.isVisible = false
        twitterBtn.isVisible = false
        segmentedControl.isVisible = false
        waitingGroup.isVisible = true
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
        segmentedControl.isVisible = false
        waitingGroup.isVisible = false
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
        segmentedControl.isVisible = true
        waitingGroup.isVisible = false
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
    questionsBarGroup.touch = function() return true end
    questionsBarGroup:addEventListener("touch", questionsBarGroup)

    return questionsBarGroup
end

function QuestionsBar:destroy()
    questionsBarGroup:removeEventListener("touch", questionsBarGroup)
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
    segmentedControl:removeSelf()
    waitingGroup:removeSelf()
    questionsBarGroup:removeSelf()
    questionsBarGroup = nil
    openCloseBtn, nextBtn, undoBtn, chronometer, facebookBtn, twitterBtn, segmentedControl, waitingGroup = nil, nil, nil, nil, nil, nil, nil, nil
end

return QuestionsBar