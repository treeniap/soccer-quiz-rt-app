display.setStatusBar(display.DarkStatusBar)
system.setIdleTimer(false)
require "Json"
require "params"
require "common"
require "scripts.management.user_data_manager"
require "scripts.management.texture_manager"
require "scripts.management.audio_manager"
require "scripts.widgets.view.loading_ball"
require "scripts.network.server_communication"
LoadingBall:newScreen()

local tutorial = UserData:checkTutorial()

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
                os.exit()
            end
        end
    end
    native.showAlert("Atualização Disponível", "Atualize o aplicativo para continuar jogando", {"Ok", "Mais Tarde"}, onComplete)
end

local function load()
    require "scripts.management.screen_manager"
    require "scripts.management.match_manager"
    require "scripts.management.assets_manager"
    require "scripts.management.store_manager"
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
        analytics = require "analytics"
        analytics.init(Params.flurryId)
    end

    StoreManager.initStore()
    AudioManager.init()
    if tutorial then
        Server.init()
        Facebook:init()
    else
        ScreenManager:startTutorial()
    end

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
                else
                    native.showAlert("Erro no servidor", "Por favor, tente mais tarde.", { "Ok" }, function() Server:getAppStatus(onAppStatusReceived) end)
                end
            end

            Server:getAppStatus(onAppStatusReceived)

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
            native.showAlert("SAIR", "Tem certeza de que deseja sair?", {"Sim", "Não"}, onComplete)
            return true
        end
    end
    Runtime:addEventListener("key", onKeyEvent)
end

local function onAppStatusReceived(response, status)
    if status == 200 and response and response.appstore_last_version then
        print(tonumber(system.getInfo("appVersionString")), tonumber(response.appstore_last_version))
        if (tonumber(system.getInfo("appVersionString")) or tonumber(response.appstore_last_version)) <
                tonumber(response.appstore_last_version) then
            onUpdateNeeded()
            return
        else
            if tutorial and response.message and response.message ~= "" then
                native.showAlert("", response.message, {"Ok"})
            end
            load()
        end
    else
        load()
        --TODO
        --native.showAlert("Erro no servidor", "Por favor, tente mais tarde.", { "Ok" }, function() Server:getAppStatus(onAppStatusReceived) end)
    end
end

Server:getAppStatus(onAppStatusReceived)