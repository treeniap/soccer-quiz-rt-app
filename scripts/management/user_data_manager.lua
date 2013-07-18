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

function UserData:init(params)
    self.info = params
    --printTable(params)
    local friendsAmount = #params.facebook_profile.friends_ids

    local function oneFriendLess()
        friendsAmount = friendsAmount - 1
        if friendsAmount <= 0 then
            Server:checkUser(self.info)
        end
    end

    local function listener(response, status)
        --printTable(response)
        local imageSize = getImagePrefix()
        if imageSize == "default" then
            imageSize = ""
        else
            imageSize = imageSize .. "_"
        end
        local url
        if response.user.facebook_profile["picture_" .. imageSize .. "url"] then
            url = response.user.facebook_profile["picture_" .. imageSize .. "url"]
        else
            url = response.user.facebook_profile["picture_url"]
        end

        Server:downloadFilesList({
            {
                url = url,
                fileName = getPictureFileName(response.user.facebook_profile.id)
            }
        }, function() end)

        oneFriendLess()
    end

    for i, friendId in ipairs(params.facebook_profile.friends_ids) do
        Server:checkFriend(friendId, listener, oneFriendLess)
    end

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