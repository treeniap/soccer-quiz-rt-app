display.setStatusBar(display.DarkStatusBar)
system.setIdleTimer(false)

require "common"
require "params"
require "scripts.management.texture_manager"
require "util.tween"

-- FLURRY
if system.getInfo("environment") == "simulator" then
    analytics = {
        init = function() end,
        logEvent = function() end
    }
else
    --TODO analytics = require "analytics"
    --analytics.init(Params.flurryId)
end

local function main()
    require "scripts.widgets.controller.button_press_release"
    require "scripts.widgets.controller.button_touch_handler"
    require "scripts.widgets.view.button_hexa_vote"
    require "scripts.widgets.view.button_undo_vote"
    require "scripts.widgets.view.button_back"
    require "scripts.widgets.view.button_facebook"
    require "scripts.widgets.view.button_twitter"
    require "scripts.widgets.view.chronometer"
    require "scripts.widgets.view.bottom_ranking"
    require "scripts.widgets.view.top_bar"
    local bg = TextureManager.newImageRect("images/stru_bg01.png", 360, 570) --1520 x 2280
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY
    local undoBtn
    local buttons = {}

    local function releaseHandler(button)
        button:addCoin()
        undoBtn:lock(false)
        for i, btn in ipairs(buttons) do
            if btn ~= button then
                btn:lock(true)
            end
        end
        return true
    end

    local goalBtn = BtnHexaVote:new("goal", 10.8, releaseHandler)
    goalBtn.x = display.contentCenterX - goalBtn.width*0.45
    goalBtn.y = display.contentCenterY - 90
    buttons[#buttons + 1] = goalBtn
    local saveBtn = BtnHexaVote:new("save", 1.5, releaseHandler)
    saveBtn.x = display.contentCenterX + saveBtn.width*0.45
    saveBtn.y = display.contentCenterY - 60
    buttons[#buttons + 1] = saveBtn
    local outBtn = BtnHexaVote:new("out", 1.2, releaseHandler)
    outBtn.x = display.contentCenterX - outBtn.width*0.45
    outBtn.y = display.contentCenterY + 30
    buttons[#buttons + 1] = outBtn
    local clearBtn = BtnHexaVote:new("clear", 1.1, releaseHandler)
    clearBtn.x = display.contentCenterX + clearBtn.width*0.45
    clearBtn.y = display.contentCenterY + 60
    buttons[#buttons + 1] = clearBtn

    local drawer = TextureManager.newImageRect("images/stru_drawer.png", 360, 360) --1520 x 2280
    drawer.x = display.contentCenterX
    drawer.y = SCREEN_BOTTOM + 16

    local function pressHandler(button)
        button:lock(true)
        for i, btn in ipairs(buttons) do
            btn:resetCoins()
            btn:lock(false)
        end
        return true
    end

    undoBtn = BtnUndoVote:new(pressHandler)
    undoBtn.x = 33 -- 12
    undoBtn.y = SCREEN_BOTTOM - 125 -- -127
    undoBtn:lock(true)

    --local backBtn = BtnBack:new(function() return true end)
    --backBtn.x = SCREEN_LEFT + 13
    --backBtn.y = SCREEN_BOTTOM - 118
    --backBtn:addEventListener("touch", dragAndDrop)
    --local facebookBtn = BtnFacebook:new(function() return true end)
    --facebookBtn.x = 204
    --facebookBtn.y = SCREEN_BOTTOM - 113
    ----facebookBtn:addEventListener("touch", dragAndDrop)
    --local twitterBtn = BtnTwitter:new(function() return true end)
    --twitterBtn.x = 271
    --twitterBtn.y = SCREEN_BOTTOM - 110
    ----twitterBtn:addEventListener("touch", dragAndDrop)

    local bottomRanking = BottomRanking:new()
    local teams = {
        "spaulo",
        "spaulo",
        "spaulo",
        "scaetano",
        "bragantino",
        "scaetano",
        "spaulo",
        "santos",
        "spaulo",
        "portuguesa",
        "bragantino",
        "palmeiras",
        "corinthians"
    }
    local ranking = {}
    for i = 1, 13 do
        ranking[i] = {}
        ranking[i].photo = "pictures/pic_" .. i .. ".png"
        ranking[i].team_badge = "pictures/clubes_" .. teams[i] .. "_p.png"
        ranking[i].score = (14 - i)*123
    end
    ranking[9].isPlayer = true
    bottomRanking:updateRankingPositions(ranking)

    local function onTimeUp()
        local f1 = {photo = "pictures/pic_5.png",  coins = 3}
        local f2 = {photo = "pictures/pic_8.png",  coins = 5}
        local f3 = {photo = "pictures/pic_12.png", coins = 1}
        local f4 = {photo = "pictures/pic_3.png",  coins = 3}
        goalBtn:showFriendVoted(f1)
        saveBtn:showFriendVoted(f2)
        outBtn:showFriendVoted(f3)
        clearBtn:showFriendVoted(f4)

        undoBtn:lock(true)
    end

    local chronometer = Chronometer:new()
    chronometer.x = SCREEN_RIGHT - 108
    chronometer.y = SCREEN_BOTTOM - 103 --379
    chronometer:start(10000, onTimeUp)

    TopBar:new()
end
main()

local onSystem = function(event)
    if event.type == "applicationSuspend" then
    elseif event.type == "applicationResume" then
    elseif event.type == "applicationExit" then
        if system.getInfo("platformName") == "iPhone OS" then
            --require("engine.quiz_data_user").closeDatabase()
            os.exit()
        end
    end
end
Runtime:addEventListener("system", onSystem)

-- Key listener
local function onKeyEvent(event)
    if event.keyName == "back" and event.phase == "down" then
        local function onComplete(event)
            if "clicked" == event.action then
                local i = event.index
                if 1 == i then
                    --require("engine.quiz_data_user").closeDatabase()
                    os.exit()
                elseif 2 == i then
                end
            end
        end
        native.showAlert("QUIT", "Are you sure you want to quit?", { "Yes", "No" }, onComplete)
        return true
    end
end
Runtime:addEventListener("key", onKeyEvent)