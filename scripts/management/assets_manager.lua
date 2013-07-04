--[[==============
== We Love Quiz
== Date: 13/06/13
== Time: 16:18
==============]]--
AssetsManager = {}

function AssetsManager:createFolder(folderName)
    if hasFile(folderName) then
        return
    end

    local lfs = require "lfs"

    -- get raw path to app's Temporary directory
    local temp_path = system.pathForFile("", system.DocumentsDirectory)

    -- change current working directory
    local success = lfs.chdir(temp_path) -- returns true on success
    local new_folder_path

    if success then
        lfs.mkdir(folderName)
        new_folder_path = lfs.currentdir() .. "/" .. folderName
    end
end

return AssetsManager