--[[==============
== We Love Quiz
== Date: 10/09/13
== Time: 11:02
==============]]--
InGameState = {}

require "scripts.screens.in_game_score"
require "scripts.screens.in_game_lineups"
require "scripts.screens.in_game_stats"

function InGameState:getListener()
    return function(clickedState)
        if clickedState ~= self.currentState then
            AnalyticsManager.selectedInGameScreen(clickedState.screenName)
            self:changeState(clickedState)
        end
    end
end

function InGameState:getStates()
    return self.states
end

function InGameState:changeState(nextState)
    if not self.canChange then
        return
    end
    local states = self.states
    local currentState = self.currentState
    local currentStatePos = table.indexOf(states, currentState)
    local nextStatePos = table.indexOf(states, nextState)
    local toX = currentStatePos < nextStatePos and -CONTENT_WIDTH or CONTENT_WIDTH
    transition.to(currentState, {time = 200, x = toX, transition = easeInExpo, onComplete = function()
        nextState.x = currentState.x*-1
        currentState:toBack()
        nextState:toFront()

        if nextState == states[2] or nextState == states[3] then
            self:updateLineupsAndStats()
        end
        if self.endView then
            if nextState == states[1] then
                self.endView:showUp(nil, true)
            else
                self.endView:hide()
            end
        end

        self.currentState = nextState
        SegmentedControl:onScreenSwiped(self.currentState)
        transition.to(nextState, {delay = 100, time = 200, x = 0, transition = easeOutExpo})
    end})
end

function InGameState:showUp()
    if self.transitionHandler or self.alpha == 1 then
        return
    end
    self.transitionHandler = transition.to(self, {delay = 500, time = 1000, alpha = 1, onComplete = function() self.transitionHandler = nil end})
end

function InGameState:hide(onComplete)
    if self.transitionHandler or self.alpha == 0 then
        --transition.cancel(transitionHandler)
        if onComplete then
            onComplete()
        end
        return
    end
    self.transitionHandler = transition.to(self, {time = 400, alpha = 0, onComplete = function()
        self.transitionHandler = nil
        if onComplete then
            onComplete()
        end
    end})
end

function InGameState:onResumeUpdate()
    self.states[1]:forceUpdateMatch()
    self:updateLineupsAndStats()
end

function InGameState:updateLineupsAndStats()
    local MIN_UPDATE_TIME = 60 -- seconds = tempo minimo para a proxima atualizacao, quando uma das telas esta visivel
    local MAX_UPDATE_TIME = 300 -- seconds = tempo maximo para a proxima atualizacao, quando nenhuma das telas esta visivel
    if self.updateCooldown then -- nao atualiza com um tempo menor do que o permitido
        if self.nextUpdateTime == MAX_UPDATE_TIME then -- adianta a atualizacao caso a tela de stats ou lineup seja aberta
            self.advanceUpdate = true
        end
        return
    end
    self.updateCooldown = true
    local cooldownTime = MIN_UPDATE_TIME*1000 -- seconds to milliseconds
    timer.performWithDelay(cooldownTime, function()
        self.updateCooldown = false
        if self.advanceUpdate then
            self.advanceUpdate = false
            self:updateLineupsAndStats()
        end
    end)

    if self.timer then
        timer.cancel(self.timer)
        self.timer = nil
    end

    Server.getMatchDetails(MatchManager:getCurrentMatchInfo().details_url, function(response, status)
        local states = self.states
        if not states then
            return
        end
        if status == 200 then
            states[2]:update(response.match_details)
            states[3]:update(response.match_details)
        else
            states[2]:update()
        end
        local nextUpdateTime = MAX_UPDATE_TIME
        if states[2].isVisible or states[3].isVisible then -- se alguma das telas estiver visivel, diminui o tempo para o update
            nextUpdateTime = MIN_UPDATE_TIME
        end
        self.nextUpdateTime = nextUpdateTime
        nextUpdateTime = nextUpdateTime*1000 -- seconds to milliseconds
        self.timer = timer.performWithDelay(nextUpdateTime, function() -- agenda proxima atualizacao
            self.timer = nil
            self:updateLineupsAndStats()
        end)
    end)
end

local function toNextState(inGameState, nextStateIndex)
    inGameState:changeState(inGameState.states[nextStateIndex])
end

local function toPreviousState(inGameState, prevStateIndex)
    inGameState:changeState(inGameState.states[prevStateIndex])
end

local function cancelMove(currentState)
    transition.to(currentState, {delay = 100, time = 200, x = 0, transition = easeOutExpo})
end

local function createSwipe(group)
    local touchHandler = display.newRect(0, 0, group.width, group.height)
    group:insert(1, touchHandler)
    touchHandler.alpha = 0.01

    local function touchListener(self, touch)
        local phase = touch.phase
        if phase == "began" then
            display.getCurrentStage():setFocus(self)
            self.isFocus = true
            self.startPos = touch.x
            self.prevPos = touch.x
        elseif self.isFocus then
            if phase == "moved" then
                local delta = touch.x - self.prevPos
                delta = delta*.25
                self.prevPos = touch.x

                group.currentState.x = group.currentState.x + delta
            elseif phase == "ended" or phase == "cancelled" then
                local dragDistance = touch.x - self.startPos
                local statePos = table.indexOf(group.states, group.currentState) or #group.states
                if dragDistance < -60 and statePos < #group.states then
                    toNextState(group, statePos + 1)
                elseif dragDistance > 60 and statePos > 1 then
                    toPreviousState(group, statePos - 1)
                else
                    cancelMove(group.currentState)
                end
                self.isFocus = nil
                display.getCurrentStage():setFocus(nil)
            end
        end

        return true
    end
    touchHandler.touch = touchListener
    touchHandler:addEventListener("touch", touchHandler)

    function touchHandler:takeFocus(event)
        display.getCurrentStage():setFocus(self)
        self.isFocus = true
        self.startPos = event.xStart
        self.prevPos = event.x
    end

    group.touchHandler = touchHandler
end

function InGameState:onGameOver(endView)
    transition.to(self.states[1], {time = 200, alpha = 0})
    self:changeState(self.states[1])
    self.canChange = false
    timer.performWithDelay(300, function()
        self.endView = endView
    end)
end

function InGameState:init()
    local managerGroup = display.newGroup()
    for k, v in pairs(InGameState) do
        managerGroup[k] = v
    end

    managerGroup.states = {
        InGameScore:create(),
        InGameLineups:create(),
        InGameStats:create(),
    }

    for i, _state in ipairs(managerGroup.states) do
        if _state.defaultState then
            managerGroup.currentState = _state
        else
            _state.isVisible = false
        end
        managerGroup:insert(_state)
    end

    managerGroup.alpha = 0
    managerGroup.canChange = true

    managerGroup:updateLineupsAndStats()

    createSwipe(managerGroup)

    return managerGroup
end

function InGameState:stop()
    if self.timer then
        timer.cancel(self.timer)
        self.timer = nil
    end
    for i = #self.states, 1, -1 do
        self.states[i]:destroy()
        self.states[i] = nil
    end
    self.endView = nil
    self.currentState = nil
    self.states = nil
    if self.transitionHandler then
        transition.cancel(self.transitionHandler)
    end
    self.transitionHandler = nil
    self:removeSelf()
    self = nil
end

return InGameState