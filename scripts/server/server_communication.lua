--[[==============
== We Love Quiz
== Date: 28/05/13
== Time: 11:23
==============]]--
Server = {}

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
---/////////////////////////// NETWORK STATUS ///////////////////////////---
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

---=====================================================---
---/////////////////////////////////////////////////////---
---=====================================================---

function Server.init()
    network.setStatusListener("www.google.com", networkStatusListener)
    networkStatusChangeListeners = {}

    pubnubObj = pubnub.new({
        subscribe_key = "sub-c-83c694d6-c708-11e2-8a13-02ee2ddab7fe",
        ssl           = false,
        origin        = "pubsub.pubnub.com"
    })
end

return Server
