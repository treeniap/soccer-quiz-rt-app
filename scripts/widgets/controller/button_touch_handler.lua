--[[==============
== Pocket World
== Date: 25/04/13
== Time: 18:26
==============]]--
TouchHandler = {}

function TouchHandler.touchBeganHandler(button, event)
    if not button.isLocked and "began" == event.phase then
        button.onPress(button, event)
    end

    return true
end

function TouchHandler.pressReleaseHandler(button, event)
    if button.isLocked then
        return false
    end

    local result = false
    local onRelease = button.onRelease
    local phase = event.phase

    if "began" == phase then
        button:onPressed()
        result = true

        -- Subsequent touch events will target button even if they are outside the stageBounds of button
        display.getCurrentStage():setFocus(button)
        button.isFocus = true
        if not button.noAudio then
            AudioManager.playAudio("btn")
        end
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
            result = true

        elseif "ended" == phase or "cancelled" == phase then
            button:onReleased()

            if "ended" == phase then
                -- Only consider this a "click" if the user lifts their finger inside button's stageBounds
                if isWithinBounds then
                    result = onRelease(button, event)
                end
            end

            -- Allow touch events to be sent normally to the objects they "hit"
            display.getCurrentStage():setFocus( button, nil )
            button.isFocus = false
        end
    end

    return result
end

function TouchHandler.pressPushHandler(button, event)
    if button.isLocked then
        return false
    end

    local result = false
    local onRelease = button.onRelease
    local phase = event.phase
    local btnGroup = button.group

    if "began" == phase then
        button:onPressed()
        result = true

        btnGroup.startX = btnGroup.x

        -- Subsequent touch events will target button even if they are outside the stageBounds of button
        display.getCurrentStage():setFocus(button)
        button.isFocus = true

        AudioManager.playAudio("btn")
    elseif button.isFocus then

        if "moved" == phase then
            -- The rollover image should only be visible while the finger is within button's stageBounds
            local moveDist = event.x - event.xStart
            btnGroup:setX(btnGroup.startX + moveDist)
            if math.abs(moveDist) >= 8 then
                button.hasMoved = true
            end

            result = true

        elseif "ended" == phase or "cancelled" == phase then
            button:onReleased()

            if "ended" == phase then
                -- Only consider this a "click" if the user lifts their finger inside button's stageBounds
                result = onRelease(button, event)
            end
            button.hasMoved = false

            -- Allow touch events to be sent normally to the objects they "hit"
            display.getCurrentStage():setFocus( button, nil )
            button.isFocus = false
        end
    end

    return result
end

local function groupTransition(group, handler, pixelPerMs)
    local isOnLimit
    local destinationX = group.x + pixelPerMs*400
    if destinationX > handler.leftLimit then
        destinationX = handler.leftLimit
        isOnLimit = true
    elseif destinationX < -handler.rightLimit then
        destinationX = -handler.rightLimit
        isOnLimit = true
    end
    if not isOnLimit and math.abs(pixelPerMs) < 0.15 then
        return
    end
    local _time = 500
    handler.trans = transition.to(group, {time = _time, x = destinationX, transition = easeOutExpo, onComplete = function()
        handler.trans = nil
    end})
end

local function slideGroup(handler, event)
    if handler.trans then
        transition.cancel(handler.trans)
        handler.trans = nil
    end
    local group = handler.group
    local onRelease = group.onRelease
    local phase = event.phase

    if "began" == phase then
        handler.startTime = event.time
        handler.startX = group.x
        handler.moved = false

        -- Subsequent touch events will target button even if they are outside the stageBounds of button
        display.getCurrentStage():setFocus(handler)
        handler.isFocus = true
    elseif handler.isFocus then
        if "moved" == phase then
            local moveDist = event.x - event.xStart
            group.x = handler.startX + moveDist
            if group.x > handler.leftLimit then
                group.x = handler.leftLimit + (group.x - handler.leftLimit)*0.25
            elseif group.x < -handler.rightLimit then
                group.x = -handler.rightLimit + (group.x + handler.rightLimit)*0.25
            end
            --print(group.x, handler.leftLimit, -handler.rightLimit)
            if math.abs(moveDist) >= 8 then
                handler.moved = true
            end

        elseif "ended" == phase or "cancelled" == phase then
            if "ended" == phase and not handler.moved then
                for i = 1, group.numChildren do
                    local object = group[i]
                    if object ~= handler and
                            math.abs(object.x + group.x - event.x) < object.width*0.5 then
                        if object.onRelease then
                            object.onRelease()
                        end
                    end
                end
            end
            local scrollTime = event.time - handler.startTime
            local pixelPerMs = (event.x - event.xStart) / scrollTime
            groupTransition(group, handler, pixelPerMs)
            -- Allow touch events to be sent normally to the objects they "hit"
            display.getCurrentStage():setFocus( handler, nil )
            handler.isFocus = false
        end
    end
    return true
end

function TouchHandler.setSlideListener(touchHandler, visibleWidth)
    touchHandler.leftLimit = touchHandler.group.x
    touchHandler.rightLimit = touchHandler.group.x + touchHandler.group.width - visibleWidth
    touchHandler.touch = slideGroup
    touchHandler:addEventListener("touch", touchHandler)
end

return TouchHandler