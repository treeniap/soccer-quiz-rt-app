--[[==============
== We Love Quiz
== Date: 05/09/13
== Time: 16:19
==============]]--
SegmentedControl = {}

local buttons
local listener

local function onScreenChoosed(button)
    for i, btn in ipairs(buttons) do
        if btn ~= button then
            btn:switch(false)
        end
    end
    button:switch(true)
    listener(button.state)
end

local function touchListener(button, event)
    if button.isOn then
        return true
    end

    local phase = event.phase

    if "began" == phase then
        button:onPressed()

        -- Subsequent touch events will target button even if they are outside the stageBounds of button
        display.getCurrentStage():setFocus(button)
        button.isFocus = true
        AudioManager.playAudio("btn")
    elseif button.isFocus then
        local bounds = button.stageBounds
        local x, y = event.x, event.y
        local isWithinBounds =
        bounds.xMin <= x and bounds.xMax >= x and bounds.yMin <= y and bounds.yMax >= y

        if "moved" == phase then
            -- The rollover image should only be visible while the finger is within button's stageBounds
            if isWithinBounds then
                button:onPressed()
            else
                button:onReleased()
            end
        elseif "ended" == phase or "cancelled" == phase then
            button:onReleased()
            if "ended" == phase then
                -- Only consider this a "click" if the user lifts their finger inside button's stageBounds
                if isWithinBounds then
                    onScreenChoosed(button)
                end
            end
            -- Allow touch events to be sent normally to the objects they "hit"
            display.getCurrentStage():setFocus( button, nil )
            button.isFocus = false
        end
    end

    return true
end

local function createButton(state, x, y)
    local buttonGroup = display.newGroup()
    local touchHandler = display.newRect(buttonGroup, -16, -16, 32, 32)
    touchHandler:setFillColor(255, 1)
    local offBtn = TextureManager.newImage(state.imgName .. "off", buttonGroup)
    offBtn.x = 0
    offBtn.y = 0
    local offBtnPressed = TextureManager.newImage(state.imgName .. "off", buttonGroup)
    offBtnPressed.x = 0
    offBtnPressed.y = 0
    offBtnPressed:setFillColor(255, 255)
    offBtnPressed.blendMode = "screen"
    offBtnPressed.isVisible = false
    local onBtn = TextureManager.newImage(state.imgName .. "on", buttonGroup)
    onBtn.x = 0
    onBtn.y = 0
    onBtn.isVisible = false

    buttonGroup.state = state
    buttonGroup.x = x
    buttonGroup.y = y
    buttonGroup.touch = touchListener
    buttonGroup:addEventListener("touch", buttonGroup)

    function buttonGroup:switch(on)
        self.isOn = on
        onBtn.isVisible = on
    end

    function buttonGroup:onPressed()
        offBtnPressed.isVisible = true
    end

    function buttonGroup:onReleased()
        offBtnPressed.isVisible = false
    end

    if state.defaultState then
        buttonGroup:switch(true)
    end

    return buttonGroup
end

local function createView(states)
    local segmentedControlGroup = display.newGroup()
    buttons = {}
    local buttonsDistance = 140/#states
    for i, _state in ipairs(states) do
        segmentedControlGroup:insert(createButton(_state, i*buttonsDistance, 0))
        buttons[i] = segmentedControlGroup[i]
    end
    segmentedControlGroup:setReferencePoint(display.CenterReferencePoint)

    segmentedControlGroup.parentRemoveSelf = segmentedControlGroup.removeSelf
    function segmentedControlGroup:removeSelf()
        listener = nil
        buttons = nil
        self:parentRemoveSelf()
    end

    return segmentedControlGroup
end

function SegmentedControl:new()
    listener = InGameState:getListener()
    return createView(InGameState:getStates())
end

return SegmentedControl