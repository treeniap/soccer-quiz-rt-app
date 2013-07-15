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

function UserData:init(params)
    self.info = params
    Server:checkUser(self.info)
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