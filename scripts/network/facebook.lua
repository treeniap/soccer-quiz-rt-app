--[[==============
== We Love Quiz
== Date: 04/07/13
== Time: 16:32
==============]]--
Facebook = {}

local facebook = require "facebook"
local appId = "371360562986250"
local access_token
local requestType
local userInfo
local loginListener
local friendsListener
local REQUEST_TYPE_LOGIN = "login"
local REQUEST_TYPE_USER_INFO = "me"
local REQUEST_TYPE_USER_FRIENDS = "me/friends?fields=installed,name"
local REQUEST_TYPE_USER_PIC = "me/picture"
local REQUEST_TYPE_USER_PERM = "me/permissions"
local REQUEST_TYPE_POST_MATCH = "postmatch"
local REQUEST_TYPE_POST_SCORE = "postscore"
local REQUEST_TYPE_INVITE = "invite"
local REQUEST_TYPE_POST_FRIEND = "postfriend"
local REQUEST_TYPE_POST_GOAL = "postgoal"
local REQUEST_TYPE_POST = "post"
local REQUEST_TYPE_POST_RANKING_SCORE = "rankingscore"
local acceptedPublishStream = true
local facebookSteps
local stepsCount

local function getPictureSize(size)
    if type(size) == "number" then
        if size <= 60 then
            return "default"
        elseif size <= 110 then
            return "2x"
        end
        return "4x"
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

local function getUserPictureUrl(size)
    local picSize = getPictureSize(size)
    return "me/picture?redirect=false&width=" .. picSize .. "&height=" .. picSize
end

local function request(pathOrSize, _requestType)
    requestType = _requestType or pathOrSize
    if _requestType == REQUEST_TYPE_USER_PIC then
        facebook.request("me/picture", "GET", {
            redirect = "false",
            width = string.format("%i", pathOrSize),
            height = string.format("%i", pathOrSize)
        })
    elseif pathOrSize == REQUEST_TYPE_USER_FRIENDS then
        facebook.request("me/friends", "GET", {
            fields = "installed,name"
        })
    else
        facebook.request(pathOrSize)
    end
end

local function setUserInfo(info)
    userInfo = {
        first_name = info.first_name,
        last_name = info.last_name,
        facebook_profile = {
            id =  info.id,
            username = info.username,
            access_token = access_token
        }
    }
end

local function setUserPicture(response)
    local imageSize = getPictureSize(tonumber(response.data.width))
    userInfo.facebook_profile[getPictureFieldName(imageSize)] = response.data.url
    facebookSteps[stepsCount]() ---> 3, 4, 5
end

local function setUserFriends(response)
    local friends_ids = {}
    for i, friend in ipairs(response.data) do
        if friend.installed then
            friends_ids[#friends_ids + 1] = friend.id
        end
    end
    if facebookSteps then
        facebookSteps[stepsCount](friends_ids) ---> 6
        facebookSteps = nil
    else
        UserData:updateFriends(friends_ids, friendsListener)
    end
end

-- listener for "fbconnect" events
local function listener(event)
    if event.isError then
        print(event.response)
        if requestType == REQUEST_TYPE_POST_MATCH or requestType == REQUEST_TYPE_POST_SCORE or
                requestType == REQUEST_TYPE_POST_FRIEND or requestType == REQUEST_TYPE_POST or
                requestType == REQUEST_TYPE_POST_GOAL then
            acceptedPublishStream = false
            return
        end
        local function onComplete(event)
            if "clicked" == event.action then
                if requestType == REQUEST_TYPE_LOGIN then
                    if not loginListener then
                        facebook.login(appId, listener)
                    end
                else
                    request(requestType)
                end
            end
        end
        native.showAlert("Facebook", "Falha de comunicação com o Facebook.", { "Tentar novamente" }, onComplete)
        return
    end
    if "session" == event.type then
        -- upon successful login, request list of friends of the signed in user
        if "loginFailed" == event.phase then
        elseif "login" == event.phase then
            -- Fetch access token for use in Facebook's API
            access_token = event.token
            --print("login access_token:", access_token)
            if loginListener then
                loginListener()
            end
            facebookSteps[stepsCount]() ---> 1
        end
    elseif "request" == event.type then
        -- event.response is a JSON object from the FB server
        local response
        response = Json.Decode(event.response)
        --printTable(response)
        if requestType == REQUEST_TYPE_USER_INFO then
            setUserInfo(response)

            facebookSteps[stepsCount](response) ---> 2
        elseif requestType == REQUEST_TYPE_USER_PIC then
            setUserPicture(response)
        elseif requestType == REQUEST_TYPE_USER_FRIENDS then
            setUserFriends(response)
        elseif requestType == REQUEST_TYPE_USER_PERM then
            if response.data[1].publish_stream and response.data[1].publish_stream == 1 then
                AnalyticsManager.acceptedFacebookWritePermission()
            else
                acceptedPublishStream = false
            end
        elseif requestType == REQUEST_TYPE_POST_MATCH then
            AnalyticsManager.post("PostedMatchOnFacebookWall")
        end
    elseif "dialog" == event.type then
        if requestType == REQUEST_TYPE_INVITE then
            local charNum = 1
            local friendsCount = 0
            while charNum and charNum < event.response:len() do
                local st
                st, charNum = string.find(event.response, "to%5B", charNum, true)
                if st then
                    friendsCount = friendsCount + 1
                end
            end
            if friendsCount > 0 then
                AnalyticsManager.inviteFriends("success", friendsCount)
            else
                AnalyticsManager.inviteFriends("cancelled", friendsCount)
            end
        elseif requestType == REQUEST_TYPE_POST_SCORE then
            AnalyticsManager.postFacebook("MatchResult")
            native.showAlert("Facebook", "Pontuação compartilhada com seus amigos.", {"Ok"})
        elseif requestType == REQUEST_TYPE_POST_FRIEND then
            AnalyticsManager.postFacebook("PostedOnFriendFacebookWall")
        elseif requestType == REQUEST_TYPE_POST then
            AnalyticsManager.postFacebook("PostedOnFacebookWall")
        elseif requestType == REQUEST_TYPE_POST_GOAL then
            AnalyticsManager.postFacebook("Goal")
        end
    end
end

function Facebook:postFacebookScore(score)
    --local params = {}
    --params.body = "&score="..tostring(score).."&access_token="..access_token
    --network.request("https://graph.facebook.com/"..UserData.info.facebook_profile.id.."/scores", "POST", function(event)
    --end, params)
end

function Facebook:invite(message)
    --print(message)
    requestType = REQUEST_TYPE_INVITE
    facebook.showDialog("apprequests", {message = message})
    Facebook:requestFriends(function()
        InGameScreen:updateBottomRanking()
    end)
end

function Facebook:postEnterMatch(message)
    --print(message)
    if acceptedPublishStream then
        Server:getAppLinks(function(response)
            requestType = REQUEST_TYPE_POST_MATCH
            local actions
            local link = "http://welovequiz.com"
            if response and response.url then
                actions = Json.Encode(
                    { name = "App Store",
                        link = response.url } )
                link = response.url
            end
            local attachment = {
                name = "Chute Premiado",
                link = link,
                description = message,
                picture = "http://d1a6cxe4fj6xw1.cloudfront.net/fb-icon.jpg",
                actions = actions
            }
            facebook.request("me/feed", "POST", attachment)
        end)
    end
end

function Facebook:postMessage(message, isScore)
    Server:getAppLinks(function(response)
        requestType = isScore and REQUEST_TYPE_POST_SCORE or REQUEST_TYPE_POST_GOAL
        facebook.showDialog("feed", {
            link = response.url,
            picture = "http://d1a6cxe4fj6xw1.cloudfront.net/fb-icon.jpg",
            name = "Chute Premiado",
            caption = "",
            description = message
        })
    end)
end

function Facebook:postFriend(friendId)
    requestType = REQUEST_TYPE_POST_FRIEND
    facebook.showDialog("feed", {to = UserData.info.friendsFacebookIds[friendId]})
end

function Facebook:post()
    requestType = REQUEST_TYPE_POST
    facebook.showDialog("feed", {})
end

function Facebook:requestFriends(_friendsListener)
    friendsListener = _friendsListener
    request(REQUEST_TYPE_USER_FRIENDS)
end

function Facebook:init(_listener)
    if IS_SIMULATOR then
        userInfo = {
            first_name = "John",
            last_name = "Smithwitz",
            facebook_profile = {
                id =  "100006337952512",
                username = "",
                access_token = "",
                picture_url = "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash4/c5.5.65.65/s50x50/1006257_1375577609330158_216697327_t.jpg",
                picture_2x_url = "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash4/c9.9.113.113/s100x100/1006257_1375577609330158_216697327_s.jpg",
                picture_4x_url = "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash4/1006257_1375577609330158_216697327_n.jpg"
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
            --friends_ids[1] = "100006326892112"
            --friends_ids[2] = "100006410700030"
            --friends_ids[3] = "100006397561562"
            --friends_ids[4] = "100006387546231"
            --friends_ids[5] = "100006460237951"
            UserData:init(userInfo, friends_ids)
        end)
        if _listener then
            _listener()
        end
        return
    end
    loginListener = _listener
    facebookSteps = {
        function() ---> 1
            request(REQUEST_TYPE_USER_INFO)
            stepsCount = stepsCount + 1
        end,
        function() ---> 2
            request(getPictureSize("default"), REQUEST_TYPE_USER_PIC)
            stepsCount = stepsCount + 1
        end,
        function() ---> 3
            request(getPictureSize("2x"), REQUEST_TYPE_USER_PIC)
            stepsCount = stepsCount + 1
        end,
        function() ---> 4
            request(getPictureSize("4x"), REQUEST_TYPE_USER_PIC)
            stepsCount = stepsCount + 1
        end,
        function() ---> 5
            local defaultPicUrl = userInfo.facebook_profile.picture_url
            local x2PicUrl = userInfo.facebook_profile.picture_2x_url
            local x4PicUrl = userInfo.facebook_profile.picture_4x_url
            if not defaultPicUrl then
                if x2PicUrl then
                    defaultPicUrl = x2PicUrl
                else
                    defaultPicUrl = x4PicUrl
                end
            end
            if not x2PicUrl then
                x2PicUrl = defaultPicUrl
            end
            userInfo.facebook_profile.picture_url = defaultPicUrl
            userInfo.facebook_profile.picture_2x_url = x2PicUrl
            userInfo.facebook_profile.picture_4x_url = x4PicUrl

            Server:downloadFilesList({
                {
                    url = userInfo.facebook_profile[getPictureFieldName(getImagePrefix())],
                    fileName = getPictureFileName(userInfo.facebook_profile.id)
                }
            }, function()
                LoadingBall:newStage() --- 3
                request(REQUEST_TYPE_USER_FRIENDS)
                stepsCount = stepsCount + 1
            end)
        end,
        function(friends_ids) ---> 6
            UserData:init(userInfo, friends_ids)
            request(REQUEST_TYPE_USER_PERM)
            stepsCount = stepsCount + 1
        end
    }
    stepsCount = 1
    requestType = REQUEST_TYPE_LOGIN
    facebook.login(appId, listener)
end

return Facebook