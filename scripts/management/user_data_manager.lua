--[[==============
== We Love Quiz
== Date: 04/07/13
== Time: 16:54
==============]]--
UserData = {}

function UserData:getUserPicture()
    return getPictureFileName(self.info.facebook_profile.id)
end

function UserData:setUserId(userId)
    self.info.user_id = userId
    Server.pubnubSubscribe(self.info.user_id, require("scripts.screens.in_game_event").betResultListener)
end

function UserData:setTotalCoins(coins)
    self.inventory.coins = coins
end

function UserData:setInventory(response)
    self.inventory = {}
    self.inventory.coins = 0
    for i, item in ipairs(response.inventory.items) do
        if item.key == "coin" then
            self.inventory.coins = item.amount
        end
    end
    --print("inventory--------------")
    --print(self.inventory.coins)

    self.attributes = {}
    self.attributes.favorite_team_id = response.inventory.attributes.favorite_team_id
    self.attributes.push_notifications_enabled = response.inventory.attributes.push_notifications_enabled
end

function UserData:updateAttributes(pushNotificationEnabled, favoriteTeamId)
    if self.attributes then
        self.attributes.favorite_team_id = favoriteTeamId
        self.attributes.push_notifications_enabled = pushNotificationEnabled
        Server:updateAttributes(self.attributes, self.info.user_id)
        return true
    end
    return false
end

function UserData:init(params, friends_ids)
    self.info = params
    self.info.friendsIds = {}
    --printTable(params)

    local function checkUser()
        Server:checkUser(self.info)
    end

    local imageSize = getImagePrefix()
    if imageSize == "default" then
        imageSize = ""
    else
        imageSize = imageSize .. "_"
    end
    local function listener(response, status)
        --printTable(response)
        local downloadList = {}
        for i, user in ipairs(response.users) do
            local url
            if user.facebook_profile["picture_" .. imageSize .. "url"] then
                url = user.facebook_profile["picture_" .. imageSize .. "url"]
            else
                url = user.facebook_profile["picture_url"]
            end
            downloadList[#downloadList + 1] = {
                    url = url,
                    fileName = getPictureFileName(user.id)
                }
            self.info.friendsIds[#self.info.friendsIds + 1] = user.id
        end
        Server:downloadFilesList(downloadList, function() end)

        checkUser()
    end

    Server:getUsers(friends_ids, true, listener, checkUser)
end

function UserData:switchSound(isOn)
    self.soundOn = isOn
    self:save()
    AudioManager.setVolume(isOn)
end

function UserData:checkTutorial()
    self.session = 1
    self.lastNotificationDate = getCurrentDate()
    self.lastFavTeamMatchId = "xxxxx"
    local path = system.pathForFile("user.txt", system.DocumentsDirectory)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        for line in io.lines(path) do

            if(line:sub(1, 6) == "sound=") then
                self.soundOn = (tonumber(line:sub(7)) == 1)
                AudioManager.setVolume(self.soundOn)
            elseif(line:sub(1, 9) == "tutorial=") then
                -- = tonumber(line:sub(10))
            elseif(line:sub(1, 8) == "session=") then
                self.session = tonumber(line:sub(9)) + 1
            elseif(line:sub(1, 21) == "lastNotificationDate=") then
                self.lastNotificationDate = date(line:sub(22))
            elseif(line:sub(1, 19) == "lastFavTeamMatchId=") then
                self.lastFavTeamMatchId = line:sub(20)
            end
        end
        self:save()
        return true
    end
    AudioManager.setVolume(true)
    return false
end

function UserData:setTutorialCompleted()
    self.soundOn = true
    self:save()
end

function UserData:save()
    local path = system.pathForFile("user.txt", system.DocumentsDirectory)
    local file = io.open(path, "w+")

    file:write("tutorial=1")
    file:write("\nsound=" .. (self.soundOn and 1 or 0))
    file:write("\nsession=" .. self.session or 1)
    file:write("\nlastNotificationDate=" .. self.lastNotificationDate or getCurrentDate())
    file:write("\nlastFavTeamMatchId=" .. self.lastFavTeamMatchId or "xxxxx")

    io.close(file)
end

return UserData