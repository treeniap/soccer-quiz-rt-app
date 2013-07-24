--[[==============
== We Love Quiz
== Date: 04/07/13
== Time: 16:32
==============]]--
Facebook = {}

local facebook = require "facebook"
local json = require "Json"
local appId = "371360562986250"
local access_token
local requestType
local userInfo
local stepsCount
local REQUEST_TYPE_LOGIN = "login"
local REQUEST_TYPE_USER_INFO = "me"
local REQUEST_TYPE_USER_FRIENDS = "me/friends?fields=installed,name"
local REQUEST_TYPE_USER_PIC = "me/picture"

local function getPictureSize(size)
    if type(size) == "number" then
        if size == 100 then
            return "2x"
        elseif size == 200 then
            return "4x"
        end
        return "default"
    elseif type(size) == "string" then
        if size == "2x" then
            return 100
        elseif size == "4x" then
            return 200
        end
        return 50
    end
end

local function getPictureFieldName(size)
    if size == "default" then
        return "picture_url"
    end
    return "picture_" .. size .. "_url"
end

local function getUserPictureUrl(username, size)
    local picSize = getPictureSize(size)
    return "me/picture?redirect=false&width=" .. picSize .. "&height=" .. picSize
end

local function request(path, _requestType)
    requestType = _requestType or path
    facebook.request(path)
end

-- listener for "fbconnect" events
local function listener(event)
    if event.isError then
        print(event.response)
        local function onComplete(event)
            if "clicked" == event.action then
                if requestType == REQUEST_TYPE_LOGIN then
                    facebook.login(appId, listener, {"publish_stream"})
                else
                    request(requestType)
                end
            end
        end
        native.showAlert("Erro", "Erro no login do Facebook", { "Ok" }, onComplete)
        return
    end
    if "session" == event.type then
        -- upon successful login, request list of friends of the signed in user
        if "login" == event.phase then
            request(REQUEST_TYPE_USER_INFO)
            -- Fetch access token for use in Facebook's API
            access_token = event.token
            print("login access_token:", access_token)
        end
    elseif "request" == event.type then
        -- event.response is a JSON object from the FB server
        local response = event.response
        response = json.Decode(event.response)
        --printTable(event)
        if requestType == REQUEST_TYPE_USER_INFO then
            userInfo = {
                first_name = response.first_name,
                last_name = response.last_name,
                facebook_profile = {
                    id =  response.id,
                    username = response.username,
                    access_token = access_token
                }
            }
            request(getUserPictureUrl(response.username, "default"), REQUEST_TYPE_USER_PIC)
            request(getUserPictureUrl(response.username, "2x"), REQUEST_TYPE_USER_PIC)
            request(getUserPictureUrl(response.username, "4x"), REQUEST_TYPE_USER_PIC)
            stepsCount = 3

        elseif requestType == REQUEST_TYPE_USER_FRIENDS then
            --printTable(response)
            local friends_ids = {}
            for i, friend in ipairs(response.data) do
                if friend.installed then
                    friends_ids[#friends_ids + 1] = friend.id
                end
            end
            UserData:init(userInfo, friends_ids)
        elseif requestType == REQUEST_TYPE_USER_PIC then
            local imageSize = getPictureSize(tonumber(response.data.width))
            userInfo.facebook_profile[getPictureFieldName(imageSize)] = response.data.url
            stepsCount = stepsCount - 1
            if getImagePrefix() == imageSize then
                Server:downloadFilesList({
                    {
                        url = response.data.url,
                        fileName = getPictureFileName(userInfo.facebook_profile.id)
                    }
                }, function()
                    stepsCount = stepsCount - 1
                    if stepsCount <= 0 then
                        request(REQUEST_TYPE_USER_FRIENDS)
                    end
                end)
                stepsCount = stepsCount + 1
            end
            if stepsCount <= 0 then
                request(REQUEST_TYPE_USER_FRIENDS)
            end
        end
    elseif "dialog" == event.type then
        print("dialog", event.response)
    end
end

function Facebook:init()
    if IS_SIMULATOR then
        userInfo = {
            first_name = "Mark",
            last_name = "Occhinosen",
            facebook_profile = {
                id =  "100006326892112",
                username = "",
                access_token = "",
                picture_url = "https://fbstatic-a.akamaihd.net/rsrc.php/v2/yo/r/UlIqmHJn-SK.gif",
                picture_2x_url = "https://fbstatic-a.akamaihd.net/rsrc.php/v2/yo/r/UlIqmHJn-SK.gif",
                picture_4x_url = "https://fbstatic-a.akamaihd.net/rsrc.php/v2/yo/r/UlIqmHJn-SK.gif"
            }
        }
        local imgFix = getImagePrefix()
        imgFix = imgFix == "default" and "" or (imgFix .. "_")
        Server:downloadFilesList({
            {
                url = userInfo.facebook_profile["picture_"..imgFix.."url"],
                fileName = getPictureFileName(userInfo.facebook_profile.id)
            }
        }, function()
            local friends_ids = {}
            friends_ids[1] = "100006410700030"
            friends_ids[2] = "100006397561562"
            friends_ids[3] = "100006387546231"
            friends_ids[4] = "100006337952512"
            UserData:init(userInfo, friends_ids)
        end)
        return
    end
    requestType = REQUEST_TYPE_LOGIN
    facebook.login(appId, listener, {"publish_stream"})
end

return Facebook

--[[
 data
    1
       id = 521949372
       name = Paulo Ribeiro
    2
       id = 527268622
       name = Ioná Viana
    3
       id = 613734940
       name = Alex Zani Canduçço
    4
       id = 628482685
       name = Ivan Garde
    5
       id = 651178362
       name = Leonardo Fontoura
    6
       id = 665321945
       name = Wesley Alves
    7
       id = 739841333
       installed = true
       name = Gabriel Ochsenhofer
    8
       id = 780080590
       installed = true
]]