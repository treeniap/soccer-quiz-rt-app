--[[==============
== We Love Quiz
== Date: 28/05/13
== Time: 11:23
==============]]--
Server = {}

local APP_ID = "com.ffgfriends.chutepremiado"

local STATUS_REACHABLE   = "reachable"
local STATUS_UNREACHABLE = "unreachable"
local STATUS_NONE        = "none"
local TRY_AGAIN_ON_NO_RESPONSE = "tryAgain"
local networkStatus = STATUS_REACHABLE
local networkStatusChangeListeners

---URLS
local getUserInventoryUrl

--
-- INITIALIZE PUBNUB STATE
--
local pubnubObj

local function log(...)
    --print("SERVER - ", ...)
    --io.output():flush()
end

---=======================================================================---
---/////////////////////////// NETWORK STATUS ////////////////////////////---
---=======================================================================---

local function networkStatusListener(event)
    --printTable(event)
    if event.isReachable then
        if networkStatus ~= STATUS_REACHABLE then
            print("networkStatusListener CHANGE TO REACHABLE")
            networkStatus = STATUS_REACHABLE
            for k, v in pairs(networkStatusChangeListeners) do
                v()
            end
            for i = #networkStatusChangeListeners, 1, -1 do
                networkStatusChangeListeners[i] = nil
            end
            networkStatusChangeListeners = {}
        end
    else
        if networkStatus ~= STATUS_UNREACHABLE then
            print("networkStatusListener CHANGE TO UNREACHABLE")
            networkStatus = STATUS_UNREACHABLE
            for k, v in pairs(networkStatusChangeListeners) do
                v()
            end
            for i = #networkStatusChangeListeners, 1, -1 do
                networkStatusChangeListeners[i] = nil
            end
            networkStatusChangeListeners = {}
            AnalyticsManager.conectivity("LostInternetConnection")
        end
    end
    Server.wwan = event.isReachableViaCellular
    Server.wifi = event.isReachableViaWiFi
    Server.connectionName = Server.wifi and "Wi-fi" or(Server.wwan and "3G" or (Server.connectionName and Server.connectionName or "Disconnected"))
end

function Server.isNetworkReachable()
    return networkStatus == STATUS_REACHABLE
end

function Server.addNetworkStatusListener(listener)
    networkStatusChangeListeners[#networkStatusChangeListeners + 1] = listener
end

local function encode(_payload)
    local content = Json.Encode(_payload)
    return {
        ["headers"] = { ["Accept"] = "application/json", ["Content-Type"] = "application/json" },
        ["body"] = content
    }
end

---==============================================================---
---////////////////////////// DOWNLOAD //////////////////////////---
---==============================================================---
function Server:downloadFilesList(filesList, listener)
    local downloadCount = #filesList
    if downloadCount <= 0 then
        if listener then
            listener()
        end
        return
    end
    local function logoDownloadListener(event)
        if not event.isError then
            --print("downloaded", event.response.filename)
            if not event.response.filename then
                printTable(event)
            else
                setICloudBackupFalse(event.response.filename)
            end
            downloadCount = downloadCount - 1
            if downloadCount <= 0 then
                if listener then
                    listener()
                end
            end
            --print("downloadCount", #filesList, downloadCount)
        end
    end
    for i, file in ipairs(filesList) do
        --print("download", file.fileName, file.url)
        network.download(file.url, "GET", logoDownloadListener, file.fileName, system.DocumentsDirectory)
    end
end

---============================================================---
---///////////////////////// REQUESTS /////////////////////////---
---============================================================--
local networkRequest
local serverResponseHandler
local callListener
local retryTimes = {1000, 300, 100}
local RETRIES_NUMBER = 3

local function erroTryAgainLater(_request)
    native.showAlert(
        "Erro no servidor",
        "Por favor, tente novamente mais tarde.",
        { "Ok" },
        function() networkRequest(_request) end)
    AnalyticsManager.serverError(_request.name)
end

function callListener(_listener, _response, _status)
    if _listener then
        local noError, result
        noError, result = pcall(_listener, _response, _status)
        if not noError then
            print("Call Listener Error: "..result)
            if _response then
                --printTable(_response)
            end
            if _status then
                print("Status: ".._status)
            end
            return "error"
        end
    end
end


local function onError(_request, status)
    if _request.retries_count and _request.retries_count > 0 then
        --print("Request retry: " .. _request.retries_count)
        local _t = 500
        if _request.retries_count <= #retryTimes then
            _t = retryTimes[_request.retries_count]
        end
        timer.performWithDelay(_t, function()
            _request.retries_count = _request.retries_count - 1
            networkRequest(_request)
        end)
    else
        _request.retries_count = nil
        if _request.on_no_response then
            if type(_request.on_no_response) == "function" then
                _request.on_no_response(nil, status)
            elseif _request.on_no_response == TRY_AGAIN_ON_NO_RESPONSE then
                erroTryAgainLater(_request)
            end
        end
    end
end

function serverResponseHandler(_request)

    return function(event)
        local status = event.status
        log("Result " .. _request.name .. " " .. status)
        --Server Error
        if event.isError or status >= 500  or status == -1 then
            printTable(event)
            onError(_request, status)
            return
        end
        --Client Error
        if status >= 400 then
            if _request.on_client_error then
                _request.on_client_error(event, status)
            end
            return
        end
        --No Error
        local noError, jsonContent = pcall(Json.Decode, event.response)
        if noError and jsonContent then
            --log("-----====RESPONSE START")
            ----printTable(jsonContent)
            --log("-----====RESPONSE END")
            local result = callListener(_request.listener, jsonContent, status)
            if result == "error" then
                onError(_request, status)
            end
        elseif event.response == " " then
            callListener(_request.listener, jsonContent, status)
        end
    end
end

function networkRequest(_request)
    if Server.isNetworkReachable() then
        local URL = _request.url
        if not URL then
            log("Error (nil url): " .. _request.name)
            return
        end
        log(_request.name, URL)
        if not _request.retries_count then
            _request.retries_count = _request.retries_number
        end
        network.request(URL, _request.method, serverResponseHandler(_request), _request.post_params)
    else
        Server.addNetworkStatusListener(function() networkRequest(_request) end)
        native.showAlert("", "Por favor, verifique a sua conexão com a internet.", { "Ok" })
    end
end

---============================================================---
---///////////////////////// GAMEPLAY /////////////////////////---
---============================================================---
function Server.getMatchesList(listener)
    networkRequest{
        name = "getMatchesList",
        url = "http://api.kb.soccer.welovequiz.com/1/championships",
        method = "GET",
        listener = listener,
        retries_number = RETRIES_NUMBER,
        on_no_response = TRY_AGAIN_ON_NO_RESPONSE
    }
end

function Server.getMatchInfo(url, listener)
    networkRequest{
        name = "getMatchInfo",
        url = url,
        method = "GET",
        listener = listener,
        retries_number = 0
    }
end

function Server.getTeamsList(listener)
    networkRequest{
        name = "getTeamsList",
        url = "http://api.kb.soccer.welovequiz.com/1/teams",
        method = "GET",
        listener = listener,
        retries_number = RETRIES_NUMBER,
        on_no_response = TRY_AGAIN_ON_NO_RESPONSE
    }
end

---============================================================---
---/////////////////////////// USER ///////////////////////////---
---============================================================---
function Server:checkUser(userInfo)
    networkRequest{
        name = "checkUser",
        url = "http://api.users.welovequiz.com/v1/facebook_profiles/" .. userInfo.facebook_profile.id,
        method = "GET",
        listener = function(response, status)
            UserData:setUserId(response.user.id)
            Server:getUserInventory(userInfo, ScreenManager.init, TRY_AGAIN_ON_NO_RESPONSE)
        end,
        on_client_error = function()
            Server:createUser(userInfo)
        end,
        retries_number = 30,
        on_no_response = TRY_AGAIN_ON_NO_RESPONSE
    }
end

function Server:createUser(userInfo)
    local payload = {}
    payload.user = {
        first_name = userInfo.first_name,
        last_name = userInfo.first_name,
        facebook_profile = {
            id = userInfo.facebook_profile.id,
            access_token = userInfo.facebook_profile.access_token,
            picture_url = userInfo.facebook_profile.picture_url,
            picture_2x_url = userInfo.facebook_profile.picture_2x_url,
            picture_4x_url = userInfo.facebook_profile.picture_4x_url,
        }
    }

    networkRequest{
        name = "createUser",
        url = "http://api.users.welovequiz.com/v1/users",
        method = "POST",
        listener = function(response, status)
            UserData:setUserId(response.user.id)
            Server:createInventory(userInfo)
        end,
        retries_number = 30,
        on_no_response = TRY_AGAIN_ON_NO_RESPONSE,
        post_params = encode(payload)
    }
end

function Server:getUsers(ids, facebook, listener, onNoResponse)
    if not ids or #ids == 0 then
        if onNoResponse then
            onNoResponse()
        end
        return
    end
    local idStr = facebook and "fb_ids[]=" or "ids[]="
    local url = "http://api.users.welovequiz.com/v1/users?"
    for i, id in ipairs(ids) do
        if i > 1 then
            url = url .. "&"
        end
        url = url .. idStr .. id
    end

    networkRequest{
        name = "getUsers",
        url = url,
        method = "GET",
        listener = listener,
        retries_number = RETRIES_NUMBER,
        on_client_error = onNoResponse,
        on_no_response = onNoResponse
    }
end

---==============================================================---
---////////////////////////// INVENTORY /////////////////////////---
---==============================================================---
function Server:createInventory(userInfo)
    local payload = {}
    payload.app_id = APP_ID
    payload.inventory = {
        attributes = {
            push_notifications_enabled = false,
            favorite_team_id = ""
        }
    }

    networkRequest{
        name = "createInventory",
        url = "http://api.inventory.welovequiz.com/v1/users/" .. UserData.info.user_id .. "/inventories",
        method = "POST",
        listener = function(response, status)
            Server:getUserInventory(userInfo, ScreenManager.init, TRY_AGAIN_ON_NO_RESPONSE)
        end,
        retries_number = 30,
        on_no_response = TRY_AGAIN_ON_NO_RESPONSE,
        post_params = encode(payload)
    }
end

function Server:getUserInventory(userInfo, listener, onNoResponse)
    getUserInventoryUrl = "http://api.inventory.welovequiz.com/v1/users/" .. UserData.info.user_id .. "/inventories?app_id=" .. APP_ID
    networkRequest{
        name = "getUserInventory",
        url = getUserInventoryUrl,
        method = "GET",
        listener = function(response, status)
            --getUserInventoryUrl = response.inventory._links.self.href
            UserData:setInventory(response)
            listener()
        end,
        on_client_error = function()
            if userInfo then
                Server:createInventory(userInfo)
            end
        end,
        retries_number = RETRIES_NUMBER,
        on_no_response = onNoResponse or listener
    }
    testignError = false
end

function Server:getInventory(userId, listener)
    getUserInventoryUrl = "http://api.inventory.welovequiz.com/v1/users/" .. userId .. "/inventories?app_id=" .. APP_ID
    networkRequest{
        name = "getInventory" .. userId,
        url = getUserInventoryUrl,
        method = "GET",
        listener = function(response, status)
            listener(response)
        end,
        retries_number = RETRIES_NUMBER,
        on_no_response = listener
    }
    testignError = false
end

function Server:updateAttributes(userAttributes, userId)
    local payload = {}
    payload.app_id = APP_ID
    payload.attributes = {
        push_notifications_enabled = userAttributes.push_notifications_enabled or false,
        favorite_team_id = userAttributes.favorite_team_id or ""
    }

    networkRequest{
        name = "updateAttributes",
        url = "http://api.inventory.welovequiz.com/v1/users/" .. userId .. "/inventories/attributes",
        method = "PUT",
        listener = function(response, status) --[[print("listener") printTable(response)]] end,
        on_client_error = function(response, status) --[[print("on_client_error") printTable(response)]] end,
        retries_number = RETRIES_NUMBER,
        post_params = encode(payload),
        on_no_response = TRY_AGAIN_ON_NO_RESPONSE
    }
end

function Server:onPurchase(productId, receipt, listener)
    if not UserData or not UserData.info or not UserData.info.user_id then
        timer.performWithDelay(500, function() Server:onPurchase(productId, receipt, listener) end)
        return
    end
    local payload = {}
    payload.app_id = APP_ID
    payload.product_store_id = productId
    payload.receipt = receipt

    networkRequest{
        name = "onPurchase",
        url = "http://api.inventory.welovequiz.com/v1/users/" .. UserData.info.user_id .. "/purchases",
        method = "POST",
        listener = listener,
        on_client_error = function(response, status) print("on_client_error") printTable(response) end,
        retries_number = 5,
        post_params = encode(payload),
        on_no_response = TRY_AGAIN_ON_NO_RESPONSE
    }
end

function Server:claimFavoriteTeamCoins(matchId)
    local payload = {}
    payload.user_id = UserData.info.user_id
    payload.match_id = matchId

    local function listener(response, status)
        timer.performWithDelay(4000, function()
            Server:getUserInventory(nil, function()
                ScreenManager:updateTotalCoin()
            end)

            AchievementNotification:new("images/medals/icon_fichas.png", "VOCÊ GANHOU 5 FICHAS!")
        end)
    end

    networkRequest{
        name = "claimFavoriteTeamCoins",
        url = "http://api.questions.soccer.welovequiz.com/offers/claim",
        method = "PUT",
        listener = listener,
        on_client_error = function(response, status) log("already claimed") end,
        retries_number = RETRIES_NUMBER,
        post_params = encode(payload),
        on_no_response = function(response, status)
            print("on_no_response", status)
        end
    }
end

---==============================================================---
---/////////////////////////// RANKING //////////////////////////---
---==============================================================---
function Server:getPlayersRank(playersIds, leaderboardId, listener)
    --local payload = {
    --    app_id = APP_ID,
    --    key = leaderboardId,
    --    users_ids = playersIds
    --}
    local leaderboardStr = leaderboardId and "temp_leaderboards" or "leaderboards"
    local leaderboardKey = leaderboardId and leaderboardId or "global"
    local url = "http://api.leaderboards.welovequiz.com/v1/" .. leaderboardStr .. "/scores?"
    url = url .. "app_id=" .. APP_ID
    url = url .. "&key=" .. leaderboardKey
    for i, id in ipairs(playersIds) do
        url = url .. "&users_ids[]=" .. id
    end

    networkRequest{
        name = "getPlayersRank",
        url = url,
        method = "GET",
        retries_number = RETRIES_NUMBER,
        listener = listener,
        on_client_error = listener,
        on_no_response = listener,
        --post_params = encode(payload)
    }
end

function Server:getTopRanking(leaderboardId, listener)
    local leaderboardStr = leaderboardId and "temp_leaderboards" or "leaderboards"
    local leaderboardKey = leaderboardId and leaderboardId or "global"
    local url = "http://api.leaderboards.welovequiz.com/v1/" .. leaderboardStr .. "/scores?"
    url = url .. "app_id=" .. APP_ID
    url = url .. "&key=" .. leaderboardKey

    networkRequest{
        name = "getTopRanking",
        url = url,
        method = "GET",
        retries_number = RETRIES_NUMBER,
        listener = listener,
        on_client_error = listener,
    }
end

function Server:getPlayerRanking(leaderboardId, listener, errorListener)
    local leaderboardStr = leaderboardId and "temp_leaderboards" or "leaderboards"
    local leaderboardKey = leaderboardId and leaderboardId or "global"
    local url = "http://api.leaderboards.welovequiz.com/v1/" .. leaderboardStr .. "/user_ranking?"
    url = url .. "app_id=" .. APP_ID
    url = url .. "&key=" .. leaderboardKey
    url = url .. "&for=" .. UserData.info.user_id

    networkRequest{
        name = "getPlayerRanking",
        url = url,
        method = "GET",
        retries_number = RETRIES_NUMBER,
        listener = listener,
        on_client_error = errorListener,
        on_no_response = errorListener,
    }
end

---==============================================================---
---////////////////////////// FACEBOOK //////////////////////////---
---==============================================================---
function Server:getAppLinks(listener)
    networkRequest{
        name = "getAppLinks",
        url = "http://d1a6cxe4fj6xw1.cloudfront.net/facebook_links.json",
        method = "GET",
        retries_number = RETRIES_NUMBER,
        listener = listener,
        on_client_error = listener,
        on_no_response = listener,
    }
end

---==============================================================---
---//////////////////////// USEFUL LINKS ////////////////////////---
---==============================================================---
function Server:getUsefulLinks(listener)
    networkRequest{
        name = "getUsefulLinks",
        url = "http://d1a6cxe4fj6xw1.cloudfront.net/useful_links.json",
        method = "GET",
        retries_number = RETRIES_NUMBER,
        listener = listener,
        on_client_error = listener,
        on_no_response = listener,
    }
end

---==============================================================---
---///////////////////////// APP STATUS /////////////////////////---
---==============================================================---
function Server:getAppStatus(listener)
    networkRequest{
        name = "getAppStatus",
        url = "http://d1a6cxe4fj6xw1.cloudfront.net/app_status.json",
        method = "GET",
        retries_number = RETRIES_NUMBER,
        listener = listener,
        on_client_error = listener,
        on_no_response = TRY_AGAIN_ON_NO_RESPONSE,
    }
end

---==============================================================---
---/////////////////////////// BANNER ///////////////////////////---
---==============================================================---
function Server:getBanner(listener)
    networkRequest{
        name = "getBanner",
        url = "http://d1a6cxe4fj6xw1.cloudfront.net/banners.json",
        method = "GET",
        retries_number = RETRIES_NUMBER,
        listener = listener,
        on_client_error = listener,
        on_no_response = listener,
    }
end

---==============================================================---
---/////////////////////////// PUBNUB ///////////////////////////---
---==============================================================---
function Server.pubnubSubscribe(channel, listener)
    log("pubnubSubscribe", channel)
    if weLovePubnub then
        weLovePubnub.subscribe(channel)
    else
        pubnubObj:subscribe({
            channel = channel,
            connect = function()
            --'Connected to channel '
            end,
            callback = function(message)
            --printTable(message)
                pcall(listener, message)
            end,
            errorback = function()
                print("Oh no!!! Dropped 3G Conection!")
            end
        })
    end
end
function Server.pubnubUnsubscribe(channel)
    pubnubObj:unsubscribe({channel = channel})
end

function Server.postBet(url, id, coins, onClientError, listener)
    local payload = {
        user_id = id,
        coins = coins
    }
    networkRequest{
        name = "postBet",
        url = url,
        method = "POST",
        listener = listener,
        on_no_response = listener,
        on_client_error = onClientError,
        retries_number = 0,
        post_params = encode(payload)
    }
end

function Server.pubnubConnect()
    log("pubnub Connect")

    local noError, errorMessage = pcall(require, "weLovePubnub")
    if noError then
        weLovePubnub.connect()
    else
        require "pubnub"
        pubnubObj = pubnub.new({
            subscribe_key = "sub-c-e2d4b628-fe18-11e2-b670-02ee2ddab7fe",
            ssl           = false,
            origin        = "pubsub.pubnub.com"
        })
    end
end

---=====================================================---
---/////////////////////////////////////////////////////---
---=====================================================---
network.setStatusListener("http://soccer-questions-api.herokuapp.com", networkStatusListener)
networkStatusChangeListeners = {}

function Server.init()
    Server.pubnubConnect()

    AssetsManager:createFolder("logos")
    AssetsManager:createFolder("pictures")
end

return Server
