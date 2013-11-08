--[[==============
== We Love Quiz
== Date: 07/10/13
== Time: 11:15
==============]]--
local widget = require "widget"
require "scripts.widgets.view.button_open_menu"

VideosScreen = {}

local videosGroup
local topBar
local spinner
local buttons
local waitingBilling

local function createScrollView(topY)
    -- Create a ScrollView
    local scrollView = widget.newScrollView
        {
            width = CONTENT_WIDTH,
            height = CONTENT_HEIGHT - topY + display.screenOriginY,
            hideBackground = true,
            hideScrollBar = true,
            horizontalScrollDisabled = true,
            friction = 0.7,
            isBounceEnabled = false
        }

    scrollView.y = topY

    return scrollView
end

local function createPreviewImage(url, fileName, maskFileName)
    local previewGroup = display.newGroup()

    local WIDTH, HEIGHT, HEIGHT_MASK = 245, 204, 154  --245, 204(154)

    local rectBg = display.newRect(previewGroup, 0, 0, WIDTH - 2, HEIGHT_MASK - 2)
    rectBg:setFillColor(128, 128)
    rectBg.x = 0
    rectBg.y = 0

    local rectBg = display.newRect(previewGroup, 0, 0, WIDTH - 2, HEIGHT_MASK - 2)
    rectBg:setFillColor(192, 128)
    rectBg.x = 0
    rectBg.y = 0
    rectBg.isVisible = false
    previewGroup.over = rectBg

    local playBtn = TextureManager.newImage("play_icon", previewGroup)
    playBtn.x = 0
    playBtn.y = 0

    function previewGroup:download()
        self.status = "downloading"
        Server:downloadFilesList({{url = url, fileName = fileName, directory = system.TemporaryDirectory}}, function()
            self.status = "available"
            self:show()
        end)
    end

    function previewGroup:show()
        if self.status == "unavailable" then
            self:download()
        elseif self.status == "available" then
            local noError
            noError, self.prevImg = pcall(display.newImage, self, fileName, system.TemporaryDirectory)
            if noError and self.prevImg then
                self.prevImg.x = 0
                self.prevImg.y = 0
                self.prevImg.xScale = WIDTH/self.prevImg.width
                self.prevImg.yScale = HEIGHT/self.prevImg.height
                local previewMask = graphics.newMask(maskFileName)
                self.prevImg:setMask(previewMask)
                self:insert(2, self.prevImg)
            end
        end
    end

    function previewGroup:hide()
        if self.prevImg then
            self.prevImg:removeSelf()
            self.prevImg = nil
        end
    end

    previewGroup.status = hasFile(fileName, nil, system.TemporaryDirectory) and "available" or "unavailable"

    return previewGroup
end

local function createDateBar(title)
    local barGroup = display.newGroup()

    local border = TextureManager.newImageRect("images/stats/bar_stats_A.png", 8, 22, barGroup)
    local center = TextureManager.newImageRect("images/stats/bar_stats_B.png", CONTENT_WIDTH - 24, 22, barGroup)
    center.x = center.width*0.5 + border.width*0.5
    local border = TextureManager.newImageRect("images/stats/bar_stats_C.png", 16, 22, barGroup)
    border.x = center.x + center.width*0.5 + border.width*0.5

    local text = display.newEmbossedText(barGroup, title, 0, -6, "MyriadPro-BoldCond", 12)
    text:setTextColor(96)
    text.x = center.x

    barGroup:setReferencePoint(display.TopCenterReferencePoint)
    barGroup.x = display.contentCenterX
    barGroup.y = 0

    return barGroup
end

local function getVideoPreviewUrlAndMask(videoDataPreviews)
    if display.imageSuffix and (display.imageSuffix == "@2x" or display.imageSuffix == "@4x") then
        return videoDataPreviews.img_490, "images/masks/video_preview_mask.png"
    else
        return videoDataPreviews.img_200, "images/masks/video_preview_mask_small.png"
    end
end

local function getVideoUrl(videoDataStreamings)
    if display.imageSuffix then
        if display.imageSuffix == "@2x" then
            return videoDataStreamings.pd_high
        elseif display.imageSuffix == "@4x" then
            return videoDataStreamings.pd_high
        end
    end
    return videoDataStreamings.pd_mid
end

local function createVideoView(video)
    local videoGroup = display.newGroup()
    local matchDate = date(video.data.publishTime):adddays(-1)

    videoGroup:insert(createDateBar(string.utf8upper(matchDate:fmt("%d DE %B DE %Y"))))

    local titleTxt = display.newText(videoGroup, string.utf8upper(video.name), 0, 0, "MyriadPro-BoldCond", 14)
    titleTxt:setReferencePoint(display.TopCenterReferencePoint)
    titleTxt.x = display.contentCenterX
    titleTxt.y = 28
    titleTxt:setTextColor(0)

    local url, maskName = getVideoPreviewUrlAndMask(video.data.previews)
    local previewImg = createPreviewImage(url, matchDate:fmt("preview%y%m%d.png"), maskName)
    previewImg:setReferencePoint(display.TopCenterReferencePoint)
    previewImg.x = display.contentCenterX
    previewImg.y = videoGroup.height + 4
    videoGroup.btn = previewImg
    videoGroup:insert(previewImg)

    local descriptionTxt = display.newText(videoGroup, video.data.description, display.screenOriginX + 8, previewImg.y + previewImg.height + 4, CONTENT_WIDTH - 16, 0, "MyriadPro-Regular", 12)
    descriptionTxt:setTextColor(0)

    previewImg:show()

    return videoGroup
end

local function videoPreviewTouchListener(scrollView)
    return function(button, event)
        if waitingBilling then
            return true
        end
        if event.phase == "began" then
            display.getCurrentStage():setFocus(button)
            button.isFocus = true
            button.over.isVisible = true
            --AudioManager.playAudio("btn")
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

                AnalyticsManager.touchedAVideo()

                if UserData.inventory.subscribed then
                    media.playVideo(button.videoUrl, media.RemoteSource, true, function(event) AnalyticsManager.watchedAVideo() end)
                else
                    local function onComplete(event)
                        if "clicked" == event.action then
                            local i = event.index
                            if 1 == i then
                            elseif 2 == i then
                                waitingBilling = true
                                spinner = widget.newSpinner{width = 128, height = 128}
                                spinner.x = display.contentCenterX
                                spinner.y = display.contentCenterY
                                spinner:start()
                                videosGroup:insert(spinner)
                                StoreManager.buyThis("semana")
                            end
                        end
                    end
                    native.showAlert("Show do Brasileirão", "Veja todos os gols do Brasileirão quantas vezes quiser!", {"Agora não.", "Ok."}, onComplete)
                end
            end
        end
        return true
    end
end

local function createVideoList()
    Server:getVideos(function(response, status)
        if status == 200 and response.body and response.body.children then
            if not videosGroup then
                return
            end
            if spinner then
                spinner:stop()
                spinner:removeSelf()
                spinner = nil
            end
            buttons = {}

            local videosScrollView = createScrollView(SCREEN_TOP + topBar.height + 2)
            videosGroup:insert(1, videosScrollView)
            local yPos = 0
            for i, _video in ipairs(response.body.children) do
                if i > 4 then
                    break
                end
                local videoView = createVideoView(_video)
                videoView.y = yPos
                yPos = yPos + videoView.height + 16
                videosScrollView:insert(videoView)
                videoView.btn.videoUrl = getVideoUrl(_video.data.streamings)
                videoView.btn.touch = videoPreviewTouchListener(videosScrollView)
                videoView.btn:addEventListener("touch", videoView.btn)
                buttons[#buttons + 1] = videoView.btn
            end
        end
    end)
end

function VideosScreen:setBillingComplete()
    waitingBilling = false
    if spinner then
        spinner:stop()
        spinner:removeSelf()
        spinner = nil
    end
end

function VideosScreen:showUp(onComplete)
    topBar.isVisible = true
    transition.from(topBar, {time = 300, y = SCREEN_TOP - 50, transition = easeInQuart, onComplete = function()
        createVideoList()
        if onComplete then
            onComplete()
        end
    end})
    unlockScreen()
end

function VideosScreen:hide(onComplete)
    if spinner then
        spinner:stop()
        spinner:removeSelf()
        spinner = nil
    end
    transition.to(videosGroup, {time = 300, alpha = 0})
    transition.to(topBar, {time = 300, y = SCREEN_TOP - 50, transition = easeInQuart, onComplete = function()
        VideosScreen:destroy()
        if onComplete then
            onComplete()
        end
    end})
end

function VideosScreen:new()
    videosGroup = display.newGroup()

    spinner = widget.newSpinner()
    spinner.x = display.contentCenterX
    spinner.y = display.contentCenterY
    spinner:start()
    videosGroup:insert(spinner)

    topBar = TopBarMenu:new("GOLS DA RODADA", function() ScreenManager:show("initial") end, require("scripts.widgets.view.button_config"):new(function() ScreenManager:show("subscription") end))
    videosGroup:insert(topBar)

    topBar.isVisible = false

    AnalyticsManager.enteredVideosScreen()

    return videosGroup
end

function VideosScreen:destroy()
    if buttons then
        for i, btn in ipairs(buttons) do
            btn:removeEventListener("touch", btn)
        end
        buttons = nil
    end
    spinner = nil
    topBar:removeSelf()
    topBar = nil
    videosGroup:removeSelf()
    videosGroup = nil
end

return VideosScreen