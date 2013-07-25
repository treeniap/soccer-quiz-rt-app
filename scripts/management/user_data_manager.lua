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

    self.attributes = {}
    self.attributes.favorite_team_id = response.inventory.attributes.favorite_team_id
    self.attributes.push_notifications_enabled = response.inventory.attributes.push_notifications_enabled
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

function UserData:checkTutorial()
    local path = system.pathForFile("user.txt", system.DocumentsDirectory)

    local file = io.open(path, "r")

    if file then
        io.close(file)
        return false
    end
    local file = io.open(path, "w")
    file:write("tutorial=1")
    io.close(file)
    return true
end

return UserData