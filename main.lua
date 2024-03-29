display.setStatusBar(display.DarkStatusBar)
system.setIdleTimer(false)
require "Json"
require "common"
require "params"
require "util.date"
require "scripts.management.brightness_manager"
require "scripts.management.user_data_manager"
require "scripts.management.texture_manager"
require "scripts.management.audio_manager"
require "scripts.management.analytics_manager"
require "scripts.widgets.view.loading_ball"
require "scripts.network.server_communication"
require "scripts.network.push_notification"
LoadingBall:newScreen()

local tutorialCompleted = UserData:checkTutorial()

local function onUpdateNeeded()
    local function onComplete(event)
        if "clicked" == event.action then
            local i = event.index
            if 1 == i then
                local url
                if IS_ANDROID then
                    url = "market://details?id="
                else
                    url = "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa"
                    url = url .. "/wa/viewContentsUserReviews?"
                    url = url .. "type=Purple+Software&id="
                end
                url = url .. Params.rateId

                system.openURL(url)
            elseif 2 == i then
                if IS_ANDROID then
                    native.requestExit()
                else
                    os.exit()
                end
            end
        end
    end
    native.showAlert("Atualização Disponível", "Você precisa atualizar a versão do aplicativo para continuar jogando.", {"Atualizar", "Sair"}, onComplete)
end

local function load()
    require "scripts.management.screen_manager"
    require "scripts.management.match_manager"
    require "scripts.management.assets_manager"
    require "scripts.management.store_manager"
    require "scripts.widgets.view.achievement_notification"
    require "scripts.network.facebook"
    require "util.tween"

    -- FLURRY
    AnalyticsManager.init()
    -- STORE
    StoreManager.initStore()
    -- AUDIO
    AudioManager.init()

    if tutorialCompleted then
        LoadingBall:newStage() --- 2
        Server.init()
        if UserData.demoModeOn then
            UserData.showFacebookLogin = true
            UserData:initDemoMode(" ", " ")
        else
            UserData.showSubscriptionOffer = UserData:hasToShowSubscriptionPopUp()
            Facebook:init()
        end
    else
        ScreenManager:startTutorial()
    end
    --Server.init()
    --Server.pubnubSubscribe(UserData.userId, require("scripts.screens.in_game_event").betResultListener)
    --ScreenManager.quickInit()
    --
    --UserData.info = {}
    --UserData.inventory = {coins = "", subscribed = false}
    --UserData.attributes = {favorite_team_id = UserData.favoriteTeamId}
    --
    --MatchManager:resquestMatches(function()
    --    MatchManager:setCurrentMatch("526d50d4d23b1a1c700007b3")
    --end)

    local onSystem = function(event)
        if event.type == "applicationSuspend" then
        elseif event.type == "applicationResume" then
            local function onAppStatusReceived(response, status)
                if status == 200 then
                    if (tonumber(system.getInfo("appVersionString")) or tonumber(response.appstore_last_version)) <
                            tonumber(response.appstore_last_version) then
                        onUpdateNeeded()
                        return
                    else
                        if response.message and response.message ~= "" then
                            native.showAlert("", response.message, {"Ok"})
                        end
                        ScreenManager.onAppResume()
                    end
                end
            end

            Server:getAppStatus(onAppStatusReceived)

            --if systemControl then
            --    systemControl.setBrightness(0)
            --end
            native.setProperty("applicationIconBadgeNumber", 0)
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
                        native.requestExit()
                    elseif 2 == i then
                    end
                end
            end
            native.showAlert("SAIR", "Tem certeza de que deseja sair?", {"Sim", "Não"}, onComplete)
            return true
        end
    end
    Runtime:addEventListener("key", onKeyEvent)
end

local function onAppStatusReceived(response, status)
    if status == 200 and response and response.appstore_last_version then
        --print(tonumber(system.getInfo("appVersionString")), tonumber(response.appstore_last_version))
        if (tonumber(system.getInfo("appVersionString")) or tonumber(response.appstore_last_version)) <
                tonumber(response.appstore_last_version) then
            onUpdateNeeded()
            return
        else
            if tutorialCompleted and response.message and response.message ~= "" then
                native.showAlert("", response.message, {"Ok"})
            end
            load()
        end
    end
end

LoadingBall:newStage() --- 1
Server:getAppStatus(onAppStatusReceived)

RatingTxt = " "
MatchResultPostTxt = " "

local function onMessagesReceived(response, status)
    if status == 200 and response then
        RatingTxt = response.rating or " "
        MatchResultPostTxt = response.match_result_post or " "
    end
end
timer.performWithDelay(12000, function() Server:getMessages(onMessagesReceived) end)

--- LOCAL AND PUSH NOTIFICATION
native.setProperty("applicationIconBadgeNumber", 0)

local function notificationListener( event )
    --print("=====================")
    --printTable(event)
    --print("=====================")
    if ( event.type == "remote" ) then
        --handle the push notification
    elseif event.type == "remoteRegistration" then
        PushNotification:parseInstall(event.token)
    elseif ( event.type == "local" ) then
        --handle the local notification
    end
    native.setProperty("applicationIconBadgeNumber", 0)
end

Runtime:addEventListener( "notification", notificationListener )

local launchArgs = ...

if ( launchArgs and launchArgs.notification ) then
    --print( "event via launchArgs" )
    notificationListener( launchArgs.notification )
end

--- DEVICE ORIENTATION
local function onRotation(event)
    if event.name == "orientation" then
        if event.type == "portrait" or event.type == "portraitUpsideDown" or event.type == "faceUp" then
            display.setStatusBar(display.DarkStatusBar)
        else
            display.setStatusBar(display.HiddenStatusBar)
        end
    end
end
Runtime:addEventListener( "orientation", onRotation )