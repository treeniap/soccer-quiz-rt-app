--[[==============
== We Love Quiz
== Date: 10/09/13
== Time: 11:02
==============]]--
InGameState = {}

require "scripts.screens.in_game_score"
require "scripts.screens.in_game_lineups"
require "scripts.screens.in_game_stats"

local managerGroup

local currentState
local states

local transitionHandler

function InGameState:getListener()
    return function(clickedState)
        if clickedState ~= currentState then
            AnalyticsManager.selectedInGameScreen(clickedState.screenName)
            InGameState:changeState(clickedState)
        end
    end
end

function InGameState:getStates()
    return states
end

function InGameState:changeState(nextState)
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

        currentState = nextState
        transition.to(nextState, {delay = 100, time = 200, x = 0, transition = easeOutExpo})
    end})
end

function InGameState:showUp()
    if transitionHandler or managerGroup.alpha == 1 then
        return
    end
    transitionHandler = transition.to(managerGroup, {delay = 500, time = 1000, alpha = 1, onComplete = function() transitionHandler = nil end})
end

function InGameState:hide(onComplete)
    if transitionHandler or managerGroup.alpha == 0 then
        --transition.cancel(transitionHandler)
        if onComplete then
            onComplete()
        end
        return
    end
    transitionHandler = transition.to(managerGroup, {time = 400, alpha = 0, onComplete = function()
        transitionHandler = nil
        if onComplete then
            onComplete()
        end
    end})
end

function InGameState:updateLineupsAndStats()
    local MIN_UPDATE_TIME = 180 -- seconds = tempo minimo para a proxima atualizacao, quando uma das telas esta visivel
    local MAX_UPDATE_TIME = 600 -- seconds = tempo maximo para a proxima atualizacao, quando nenhuma das telas esta visivel
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

function InGameState:init()
    managerGroup = display.newGroup()
    for k, v in pairs(InGameState) do
        managerGroup[k] = v
    end

    states = {
        InGameScore:create(),
        InGameLineups:create(),
        InGameStats:create(),
    }

    for i, _state in ipairs(states) do
        if _state.defaultState then
            currentState = _state
        else
            _state.isVisible = false
        end
        managerGroup:insert(_state)
    end

    managerGroup.alpha = 0

    self:updateLineupsAndStats()

    return managerGroup
end

function InGameState:stop()
    if self.timer then
        timer.cancel(self.timer)
        self.timer = nil
    end
    for i = #states, 1, -1 do
        states[i]:destroy()
        states[i] = nil
    end
    currentState = nil
    states = nil
    managerGroup:removeSelf()
    managerGroup = nil
    if transitionHandler then
        transition.cancel(transitionHandler)
    end
    transitionHandler = nil
end

return InGameState