--[[==============
== We Love Quiz
== Date: 28/05/13
== Time: 11:23
==============]]--
Server = {}

local json = require "json"
require "pubnub"

local APP_ID = "com.ffgfriends.chutepremiado"

local STATUS_REACHABLE   = "reachable"
local STATUS_UNREACHABLE = "unreachable"
local STATUS_NONE        = "none"
local networkStatus = STATUS_REACHABLE
local networkStatusChangeListeners

---URLS
local getInventoryUrl

--
-- INITIALIZE PUBNUB STATE
--
local pubnubObj

local function log(...)
    print("SERVER - ", ...)
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
        end
    end
    Server.wwan = event.isReachableViaCellular
    Server.wifi = event.isReachableViaWiFi
end

function Server.isNetworkReachable()
    return networkStatus == STATUS_REACHABLE
end

function Server.addNetworkStatusListener(listener)
    networkStatusChangeListeners[#networkStatusChangeListeners + 1] = listener
end

local function encode(_payload)
    local content = json.encode(_payload)
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
        listener()
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
                listener()
            end
            --print("downloadCount", #logosList, downloadCount)
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
    if _request.retries_number and _request.retries_number > 0 then
        --print("Request retry: " .. _request.retries_number)
        local _t = 500
        if _request.retries_number <= #retryTimes then
            _t = retryTimes[_request.retries_number]
        end
        timer.performWithDelay(_t, function()
            _request.retries_number = _request.retries_number - 1
            networkRequest(_request)
        end)
    elseif _request.on_no_response then
        _request.on_no_response(nil, status)
    end
end

function serverResponseHandler(_request)

    return function(event)
        local status = event.status
        --Server Error
        if event.isError or status >= 500  or status == -1 then
            onError(_request, status)
            return
        end
        --Client Error
        if status >= 400 then
            if _request.on_client_error then
                _request.on_client_error(event)
            end
            return
        end
        --No Error
        local noError, jsonContent = pcall(json.decode, event.response)
        if noError and jsonContent then
            --log("-----====RESPONSE START")
            ----printTable(jsonContent)
            --log("-----====RESPONSE END")
            local result = callListener(_request.listener, jsonContent, status)
            if result == "error" then
                onError(_request, status)
            end
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
        network.request(URL, _request.method, serverResponseHandler(_request), _request.post_params)
    else
        Server.addNetworkStatusListener(function() networkRequest(_request) end)
        native.showAlert("", "Please check your internet connection.", { "Ok" })
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
        retries_number = RETRIES_NUMBER
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
            Server:getInventory(userInfo, ScreenManager.init)
        end,
        on_client_error = function()
            Server:createUser(userInfo)
        end,
        retries_number = 30,
        on_no_response = function()
            native.showAlert("Erro no servidor", "Por favor, tente mais tarde.", { "Ok" }, function() Server:checkUser(userInfo) end)
        end
    }
end

function Server:createUser(userInfo)
    local payload = {}
    payload.user = userInfo

    networkRequest{
        name = "createUser",
        url = "http://api.users.welovequiz.com/v1/users",
        method = "POST",
        listener = function(response, status)
            UserData:setUserId(response.user.id)
            Server:createInventory(userInfo)
        end,
        retries_number = 30,
        on_no_response = function()
            native.showAlert("Erro no servidor", "Por favor, tente mais tarde.", { "Ok" }, function() Server:createUser(userInfo) end)
        end,
        post_params = encode(payload)
    }
end

function Server:checkFriend(fbId, listener, onNoResponse)
    networkRequest{
        name = "checkFriend" .. fbId,
        url = "http://api.users.welovequiz.com/v1/facebook_profiles/" .. fbId,
        method = "GET",
        listener = listener,
        retries_number = RETRIES_NUMBER,
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
            push_notifications_enabled = userInfo.pushNotification or false, -- TODO get push enabled
            favorite_team_id = userInfo.favoriteTeam or "" -- TODO get favorite team
        }
    }

    networkRequest{
        name = "createInventory",
        url = "http://api.inventory.welovequiz.com/v1/users/" .. UserData.info.user_id .. "/inventories",
        method = "POST",
        listener = function(response, status)
            Server:getInventory(userInfo, ScreenManager.init)
        end,
        retries_number = 30,
        on_no_response = function()
            native.showAlert("Erro no servidor", "Por favor, tente mais tarde.", { "Ok" }, function() Server:createInventory(userInfo) end)
        end,
        post_params = encode(payload)
    }
end

function Server:getInventory(userInfo, listener)
    getInventoryUrl = "http://api.inventory.welovequiz.com/v1/users/" .. UserData.info.user_id .. "/inventories?app_id=" .. APP_ID
    networkRequest{
        name = "getInventory",
        url = getInventoryUrl,
        method = "GET",
        listener = function(response, status)
            --getInventoryUrl = response.inventory._links.self.href
            UserData:setInventory(response)
            listener()
        end,
        on_client_error = function()
            if userInfo then
                Server:createInventory(userInfo)
            end
        end,
        retries_number = RETRIES_NUMBER
    }
end

function Server:updateAttributes(userInfo)
    local payload = {}
    payload.app_id = APP_ID
    payload.attributes = {
        push_notifications_enabled = userInfo.pushNotification or false,
        favorite_team_id = userInfo.favoriteTeam or ""
    }
end

---==============================================================---
---/////////////////////////// PUBNUB ///////////////////////////---
---==============================================================---
function Server.pubnubSubscribe(channel, listener)
    pubnubObj:subscribe({
        channel = channel,
        connect = function()
            --'Connected to channel '
        end,
        callback = function(message)
            --printTable(message)
            listener(message)
        end,
        errorback = function()
            print("Oh no!!! Dropped 3G Conection!")
        end
    })
end
function Server.pubnubUnsubscribe(channel)
    pubnubObj:unsubscribe({channel = channel})
end

local function getBet()
    local payload = {
        facebook = {access_token = _accessToken}
    }
    return encode(payload)
end
function Server.postBet(url, id, coins, onClientError)
    local payload = {
        user_id = id,
        coins = coins
    }
    networkRequest{
        name = "postBet",
        url = url,
        method = "POST",
        listener = function() end,
        on_client_error = onClientError,
        retries_number = RETRIES_NUMBER,
        post_params = encode(payload)
    }
end

---=====================================================---
---/////////////////////////////////////////////////////---
---=====================================================---

function Server.init()
    network.setStatusListener("http://soccer-questions-api.herokuapp.com", networkStatusListener)
    networkStatusChangeListeners = {}

    pubnubObj = pubnub.new({
        subscribe_key = "sub-c-83c694d6-c708-11e2-8a13-02ee2ddab7fe",
        ssl           = false,
        origin        = "pubsub.pubnub.com"
    })
    AssetsManager:createFolder("logos")
    AssetsManager:createFolder("pictures")
end

return Server
