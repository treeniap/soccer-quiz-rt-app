--[[==============
== We Love Quiz
== Date: 01/11/13
== Time: 16:31
==============]]--
PushNotification = {}

local deviceToken
local baseUrl = "https://api.parse.com/1/installations/"

local headers = {}
headers["Content-Type"]  = "application/json"
headers["X-Parse-Application-Id"] = "H4G8No01QP7Ws4eHwuCADYIL1qGzkIkxtRs45Ho0"
headers["X-Parse-REST-API-Key"] = "ToDgUIBZmCPeMspmk3SOLyfjLqXPDC224BYc0aCe"

local params = {}
params.headers = headers

local function installListener(event)
    if event.isError then
        print("Network error!")
    else
        --print("RESPONSE: " .. event.response)
        local noError, response = pcall(Json.Decode, event.response)
        --print(noError, response)
        --print(response.objectId)
        if noError and response and response.objectId then
            UserData:setParseObjectId(response.objectId)
        end
    end
end

local function updateListener(event)
    if event.isError then
        print("Network error!")
    else
        --print("RESPONSE: " .. event.response)
    end
end

--Send the message over with the new token
function PushNotification:parseInstall(token)
    deviceToken = token
    if UserData.parseObjectId == " " then
        local message = {deviceType = "ios", deviceToken = deviceToken}
        params.body = Json.Encode(message)
        network.request(baseUrl, "POST", installListener,  params)
    end
end

function PushNotification:parseSubscribe(channel)
    if IS_ANDROID then
        SystemControl.parseSubscribe(channel)
    else
        if UserData.parseObjectId ~= " " then
            local message = {deviceType = "ios", deviceToken = deviceToken, channels = {"t" .. UserData.favoriteTeamId, channel}}
            params.body = Json.Encode(message)
            network.request(baseUrl .. UserData.parseObjectId, "PUT", updateListener,  params)
        end
    end
end

function PushNotification:parseUnsubscribe()
    if IS_ANDROID then
        SystemControl.parseUnsubscribe("t" .. UserData.favoriteTeamId, UserData.userId)
    else
        if UserData.parseObjectId ~= " " then
            local message = {deviceType = "ios", deviceToken = deviceToken, channels = {"t" .. UserData.favoriteTeamId}}
            params.body = Json.Encode(message)
            network.request(baseUrl .. UserData.parseObjectId, "PUT", updateListener,  params)
        end
    end
end

return PushNotification