--[[==============
== We Love Quiz
== Date: 28/05/13
== Time: 11:23
==============]]--
Server = {}

local json = require "json"
require "pubnub"

local STATUS_REACHABLE   = "reachable"
local STATUS_UNREACHABLE = "unreachable"
local STATUS_NONE        = "none"
local networkStatus = STATUS_REACHABLE
local networkStatusChangeListeners

--
-- INITIALIZE PUBNUB STATE
--
local pubnubObj

local function log(...)
    --print("SERVER - " .. ...)
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
---/////////////////////////// USER ///////////////////////////---
---============================================================---
function Server:checkUser(userInfo)
    local url = "http://api.users.welovequiz.com/v1/facebook_profiles/" .. userInfo.facebook_profile.id
    --print("GET", url)
    network.request(url, "GET", function(event)
        if event.status ~= 200 then
            printTable(event)
        end

        if event.status == 404 then -- usuário não cadastrado
            Server:createUser(userInfo)
            return
        elseif event.status >= 500 or event.status == -1 then -- erro no servidor
            Server:checkUser(userInfo)
            return
        end
        --usuário cadastrado
        local noError, jsonContent = pcall(json.decode, event.response)
        if noError and jsonContent then
            UserData:setUserId(jsonContent.facebook_profile.user_id) --TODO mudar "user_id" de lugar
            ScreenManager:init()
        end
    end)
end

function Server:createUser(userInfo)
    local payload = {}
    payload.user = userInfo
    local url = "http://api.users.welovequiz.com/v1/users"
    --print("POST", url)
    network.request(url, "POST", function(event)
        --printTable(event)
        if event.status == 201 then
            local noError, jsonContent = pcall(json.decode, event.response)
            if noError and jsonContent then
                UserData:setUserId(jsonContent.user.id)
                ScreenManager:init()
            end
        else
            Server:createUser(userInfo)
        end
    end, encode(payload))
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

local function getBet()
    local payload = {
        facebook = {access_token = _accessToken}
    }
    return encode(payload)
end
function Server.postBet(url, id, coins)
    local payload = {
        user_id = id,
        coins = coins
    }
    --print("POST", url)
    network.request(url, "POST", function(event) --[[printTable(event)]] end, encode(payload))
end

function Server.getMatches(url, listener)
    --print("GET Matches", url)
    network.request(url, "GET", listener)
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
