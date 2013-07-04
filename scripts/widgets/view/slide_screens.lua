--[[==============
== We Love Quiz
== Date: 28/06/13
== Time: 19:06
==============]]--
SlideScreens = {}

function SlideScreens.new(screenSet, tutorialSheetImage, tutorialSheetInfo)
    local screenW, screenH = CONTENT_WIDTH, CONTENT_HEIGHT
    local viewableScreenW, viewableScreenH = CONTENT_WIDTH, CONTENT_HEIGHT
    local screenOffsetW, screenOffsetH = display.contentWidth - CONTENT_WIDTH, display.contentHeight - CONTENT_HEIGHT

    local imgNum
    local touchListener, nextImage, prevImage, cancelMove, initImage
    local background

    local g = display.newGroup()

    background = display.newRect(SCREEN_LEFT, SCREEN_TOP, CONTENT_WIDTH, CONTENT_HEIGHT)
    background:setFillColor(0)
    g:insert(background)

    local pointBar = display.newGroup()
    for i = 1, #screenSet do
        local p = screenSet[i]
        p.x = (i - 1)*CONTENT_WIDTH
        g:insert(2, p)

        local pointBlack = display.newImage(pointBar, tutorialSheetImage, tutorialSheetInfo:getFrameIndex("stru_progress_grey"))
        pointBlack.x = (i - 1)*22
        local pointRed = display.newImage(pointBar, tutorialSheetImage, tutorialSheetInfo:getFrameIndex("stru_progress_red"))
        pointRed.x = pointBlack.x
        pointRed.isVisible = i == 1
    end
    pointBar:setReferencePoint(display.CenterReferencePoint)
    pointBar.x = 0
    pointBar.y = 4
    local navBar = display.newGroup()
    local tutorialBar = display.newImageRect(navBar, tutorialSheetImage, tutorialSheetInfo:getFrameIndex("stru_progress_bar"), CONTENT_WIDTH + 16, 32)
    tutorialBar.x = 0
    tutorialBar.y = 0
    navBar:insert(pointBar)

    navBar.x = display.contentCenterX
    navBar.y = SCREEN_BOTTOM - tutorialBar.height*0.5
    g:insert(navBar)

    imgNum = 1

    local startPos, prevPos
    local dragDistance
    local tween
    function touchListener (self, touch)
        local phase = touch.phase
        --print("slides", phase)
        if ( phase == "began" ) then
            -- Subsequent touch events will target button even if they are outside the contentBounds of button
            display.getCurrentStage():setFocus( self )
            self.isFocus = true

            startPos = touch.x
            prevPos = touch.x
        elseif( self.isFocus ) then
            if ( phase == "moved" ) then
                if tween then transition.cancel(tween) end

                --print(imgNum)

                local delta = touch.x - prevPos
                prevPos = touch.x

                screenSet[imgNum].x = screenSet[imgNum].x + delta

                if (screenSet[imgNum-1]) then
                    screenSet[imgNum-1].x = screenSet[imgNum-1].x + delta
                end

                if (screenSet[imgNum+1]) then
                    screenSet[imgNum+1].x = screenSet[imgNum+1].x + delta
                end

            elseif (phase == "ended" or phase == "cancelled") then

                dragDistance = touch.x - startPos
                --print("dragDistance: " .. dragDistance)

                if (dragDistance < -40 and imgNum < #screenSet) then
                    nextImage()
                elseif (dragDistance > 40 and imgNum > 1) then
                    prevImage()
                else
                    cancelMove()
                end

                if (phase == "cancelled") then
                    cancelMove()
                end

                -- Allow touch events to be sent normally to the objects they "hit"
                display.getCurrentStage():setFocus( nil )
                self.isFocus = false
            end
        end

        return true
    end

    local function setSlideNumber()
        for i = 1, pointBar.numChildren do
            pointBar[i].isVisible = true
            if i % 2 == 0 and i/2 ~= imgNum then
                pointBar[i].isVisible = false
            end
        end
    end

    local prevTween
    local function cancelTween()
        if prevTween then
            transition.cancel(prevTween)
        end
        prevTween = tween
    end

    function nextImage()
        tween = transition.to( screenSet[imgNum], {time=400, x=screenW*-1.5, transition=easing.outExpo } )
        tween = transition.to( screenSet[imgNum+1], {time=400, x=0, transition=easing.outExpo } )
        g:insert(g.numChildren, screenSet[imgNum+1])
        imgNum = imgNum + 1
        initImage(imgNum)
    end

    function prevImage()
        tween = transition.to( screenSet[imgNum], {time=400, x=screenW*1.5, transition=easing.outExpo } )
        tween = transition.to( screenSet[imgNum-1], {time=400, x=0, transition=easing.outExpo } )
        g:insert(g.numChildren, screenSet[imgNum-1])
        imgNum = imgNum - 1
        initImage(imgNum)
    end

    function cancelMove()
        tween = transition.to( screenSet[imgNum], {time=400, x=0, transition=easing.outExpo } )
        tween = transition.to( screenSet[imgNum-1], {time=400, x=screenW*-1.5, transition=easing.outExpo } )
        tween = transition.to( screenSet[imgNum+1], {time=400, x=screenW*1.5, transition=easing.outExpo } )
        g:insert(g.numChildren, screenSet[imgNum])
    end

    function initImage(num)
        if (num < #screenSet) then
            screenSet[num+1].x = screenW*1.5
        end
        if (num > 1) then
            screenSet[num-1].x = screenW*-1.5
        end
        setSlideNumber()
    end

    background.touch = touchListener
    background:addEventListener( "touch", background )

    ------------------------
    -- Define public methods

    function g:jumpToImage(num)
        local i
        --print("jumpToImage")
        --print("#images", #images)
        for i = 1, #screenSet do
            if i < num then
                screenSet[i].x = -screenW*.5
            elseif i > num then
                screenSet[i].x = screenW*1.5
            else
                screenSet[i].x = screenW*.5
            end
        end
        imgNum = num
        initImage(imgNum)
    end

    function g:hide(onComplete)
        background:removeEventListener("touch", touchListener)
        transition.to(navBar, {time = 400, y = SCREEN_BOTTOM + tutorialBar.height})
        transition.to(screenSet[imgNum], {time = 400, x = screenW*-1.5, transition = easing.outExpo, onComplete = onComplete })
    end

    function g:cleanUp()
        g:removeSelf()
    end

    return g
end

return SlideScreens