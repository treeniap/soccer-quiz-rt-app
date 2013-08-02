display.setStatusBar(display.DarkStatusBar)
system.setIdleTimer(false)
require "scripts.management.texture_manager"
require "scripts.widgets.view.loading_ball"
LoadingBall:newScreen()

require "common"
require "params"
require "scripts.management.screen_manager"
require "scripts.management.match_manager"
require "scripts.management.assets_manager"
require "scripts.management.user_data_manager"
require "scripts.management.audio_manager"
require "scripts.management.store_manager"
require "scripts.network.server_communication"
require "scripts.network.facebook"
require "util.tween"
require "util.date"

-- FLURRY
if IS_SIMULATOR then
    analytics = {
        init = function() end,
        logEvent = function() end
    }
else
    --TODO analytics = require "analytics"
    --analytics.init(Params.flurryId)
end

StoreManager.initStore()
AudioManager.init()
if UserData:checkTutorial() then
    Server.init()
    Facebook:init()
else
    ScreenManager:startTutorial()
end

local onSystem = function(event)
    if event.type == "applicationSuspend" then
    elseif event.type == "applicationResume" then
        ScreenManager.onAppResume()
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
        native.showAlert("QUIT", "Are you sure you want to quit?", {"Yes", "No"}, onComplete)
        return true
    end
end
Runtime:addEventListener("key", onKeyEvent)