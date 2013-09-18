--[[==============
== Pocket World
== Date: 25/04/13
== Time: 11:01
==============]]--

CONTENT_WIDTH   = display.contentWidth + (display.screenOriginX*-2)
CONTENT_HEIGHT  = display.contentHeight + (display.screenOriginY*-2)
SCREEN_TOP      = display.screenOriginY + display.topStatusBarContentHeight
SCREEN_BOTTOM   = display.contentHeight + (-display.screenOriginY)
SCREEN_LEFT     = display.screenOriginX
SCREEN_RIGHT    = display.contentWidth + (-display.screenOriginX)
IS_SIMULATOR    = system.getInfo("environment") == "simulator"
IS_ANDROID      = system.getInfo("platformName") == "Android"
DEBUG_MODE      = false --IS_SIMULATOR or true -- TODO test mode
MINUTE_DURATION = 60000

function getDeviceName()
    return IS_ANDROID and system.getInfo("platformName") or system.getInfo("model")
end

-- Drag and Drop images and print XY position
function dragAndDrop(event)
    local t = event.target
    local phase = event.phase
    if "began" == phase then
        display.getCurrentStage():setFocus( t )
        t.isFocus = true
        t.x0 = event.x - t.x
        t.y0 = event.y - t.y
    elseif t.isFocus then
        if "moved" == phase then
            t.x = event.x - t.x0
            t.y = event.y - t.y0
        elseif "ended" == phase or "cancelled" == phase then
            display.getCurrentStage():setFocus( nil )
            t.isFocus = false
            local xRef = math.abs(t.x - SCREEN_LEFT) < math.abs(t.x - SCREEN_RIGHT) and "SCREEN_LEFT + " .. (t.x - SCREEN_LEFT) or "SCREEN_RIGHT - " .. (SCREEN_RIGHT - t.x)
            local yRef = math.abs(t.y - SCREEN_TOP) < math.abs(t.y - SCREEN_BOTTOM) and "SCREEN_TOP + " .. (t.y - SCREEN_TOP) or "SCREEN_BOTTOM - " .. (SCREEN_BOTTOM - t.y)
            print("X: (" .. t.x .. ") " .. xRef, "Y: (" .. t.y .. ") " .. yRef)
        end
    end
    return true
end

-- Print string tables/JSON
local level = 0
local function getLevel()
    local levelSpaces = ""
    for i = 1, level do
        levelSpaces = levelSpaces.."   "
    end
    return levelSpaces
end
function printTable(tab)
    --
    --print("--==TABLE")
    local n = ""
    level = level + 1
    if level > 10 then
        level = level - 1
        return
    end
    if type(tab) ~= "table" then
        print(tab)
        return
    end
    for k, v in pairs(tab) do
        if tostring(k) == "_class" then
            return
        end
        n = n..getLevel()..tostring(k)
        if type(v) == "table" then
            print(n)
            printTable(v)
        else
            print(n .." = " .. tostring(v))
        end
        n = ""
    end
    level = level - 1
    --]]
end

local MyriadProBoldCondSize = {
    ["0"] = 43,
    ["1"] = 43,
    ["2"] = 43,
    ["3"] = 43,
    ["4"] = 43,
    ["5"] = 43,
    ["6"] = 43,
    ["7"] = 43,
    ["8"] = 43,
    ["9"] = 43,
    ["A"] = 47,
    ["B"] = 50,
    ["C"] = 42,
    ["D"] = 51,
    ["E"] = 42,
    ["F"] = 41,
    ["G"] = 49,
    ["H"] = 54,
    ["I"] = 27,
    ["J"] = 31,
    ["K"] = 48,
    ["L"] = 40,
    ["M"] = 66,
    ["N"] = 54,
    ["O"] = 50,
    ["P"] = 47,
    ["Q"] = 50,
    ["R"] = 49,
    ["S"] = 42,
    ["T"] = 42,
    ["U"] = 52,
    ["V"] = 47,
    ["W"] = 70,
    ["X"] = 43,
    ["Y"] = 43,
    ["Z"] = 41,
    ["a"] = 43,
    ["b"] = 45,
    ["c"] = 32,
    ["d"] = 45,
    ["e"] = 42,
    ["f"] = 29,
    ["g"] = 45,
    ["h"] = 45,
    ["i"] = 22,
    ["j"] = 22,
    ["k"] = 42,
    ["l"] = 22,
    ["m"] = 68,
    ["n"] = 45,
    ["o"] = 43,
    ["p"] = 45,
    ["q"] = 45,
    ["r"] = 30,
    ["s"] = 32,
    ["t"] = 31,
    ["u"] = 45,
    ["v"] = 40,
    ["w"] = 61,
    ["x"] = 40,
    ["y"] = 39,
    ["z"] = 35,
    ["."] = 23,
    [","] = 23,
    [":"] = 23,
    [";"] = 23,
    ["!"] = 24,
    ["?"] = 33,
    ["-"] = 26,
    ["="] = 60,
    ["/"] = 28,
    ["'"] = 17,
    ["\""] = 33,
    [" "] = 15,
}
function getFontLettersSize(letter)
    if MyriadProBoldCondSize[letter] then
        return MyriadProBoldCondSize[letter]
    else
        return 50
    end
    return MyriadProBoldCondSize
    --[[
    local letters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.,:;!?-=/\'\" "
    print("local MyriadProBoldCondSize = {")
    for i = 1, letters:len() do
        local letter = letters:sub(i, i)
        local l = display.newText(letter, 0, 0, "MyriadPro-BoldCond", 100)
        print("[\"" .. letter .. "\"] = " .. l.width .. ",")
    end
    print("}")
    --]]
end

getFontLettersSize("MyriadPro-BoldCond")


local html_replacements = {
    ["&lt;"]    = "<",
    ["&gt;"]    = ">",
    ["&amp;"]   = "&",
    ["&cent;"]  = "¢",
    ["&pound;"] = "£",
    ["&yen;"]   = "¥",
    ["&euro;"]  = "€",
    ["&sect;"]  = "§",
    ["&copy;"]  = "©",
    ["&reg;"]   = "®",
    ["&trade;"] = "™",
}

-- fix text so that < > and & are escaped
function fixhtml(s)
    for k, v in pairs(html_replacements) do
        s = string.gsub(tostring(s), k, v)
    end
    return s
end

function findLink(s)
    local linkStart, linkPart = string.find(s, "http://")
    if linkStart then
        local linkEnd, linkEnd2 = string.find(s, " ", linkStart)
        --print(s)
        if not linkEnd then
            linkEnd = s:len()
        else
            linkEnd = linkEnd - 1
        end
        --print(linkStart, linkEnd, linkEnd2)
        return linkStart, linkEnd
    end
end

-- return the timezone offset in seconds, as it was on the time given by ts
-- Eric Feliksik
local timeZoneOffset
function getTimezoneOffset(ts)
    if not timeZoneOffset then
        local utcdate   = os.date("!*t", ts)
        local localdate = os.date("*t", ts)
        localdate.isdst = false -- this is the trick
        timeZoneOffset = os.difftime(os.time(localdate), os.time(utcdate))
    end
    return timeZoneOffset
end

local lfs = require "lfs"
function hasFile(fileName, dir)
    local noError, result = pcall(function()
        for file in lfs.dir(system.pathForFile(dir or "", system.DocumentsDirectory)) do
            if string.find(file, fileName) then
                return true
            end
        end
    end)
    if noError then
        return result
    end
end

function getImagePrefix()
    if display.imageSuffix then
        if display.imageSuffix == "@2x" then
            return "2x"
        elseif display.imageSuffix == "@4x" then
            return "4x"
        end
    end
    return "default"
end

function getLogoFileName(teamId, size)
    if teamId == "" or teamId == " " then
        return "none"
    end
    if size <= 1 then
        size = "mini"
    elseif size == 2 then
        size = "medium"
    elseif size >= 3 then
        size = "big"
    end
    return "logos/logo_" ..size .. "_" .. teamId .. ".png"
end

function getPictureFileName(userId)
    return "pictures/pic_" .. userId .. (display.imageSuffix or "") .. ".jpg"
end

function setICloudBackupFalse(fileName)
    local value, err = native.setSync(fileName, {iCloudBackup = false}) -- off
    --print("setICloudBackupFalse", value, err)
    if not value then print("Error", fileName, err) end
end

function lockScreen()
    if lockRect then
        --unlockScreen()
        return
    end
    lockRect = display.newRect(display.screenOriginX, display.screenOriginY, CONTENT_WIDTH, CONTENT_HEIGHT)
    lockRect.alpha = 0.01
    lockRect.touch = function()
        return true
    end
    lockRect:addEventListener("touch", lockRect)
end

function unlockScreen()
    if lockRect then
        lockRect:removeEventListener("touch", lockRect)
        lockRect:removeSelf()
        lockRect = nil
    end
end

function getCurrentDate()
    local currentDate = date(os.date("*t"))
    return currentDate
end

function scheduleLocalNotification(uctTime, alertTxt, soundFileName)
    local options = {
        alert = alertTxt,
        badge = 1,
        sound = soundFileName
    }
    --print("scheduleLocalNotification", uctTime, alertTxt)
    --printTable(uctTime)
    return system.scheduleNotification(uctTime, options)
end

-- Monitors memory
--[[ Uncomment to monitor app's lua memory/texture memory usage in terminal...
local memTable = {}
local memTableIndex = 1
local lastSum = 0
local function printMem(str)
    memTable[memTableIndex] = str
    memTableIndex = memTableIndex + 1
    if memTableIndex > 60 then
        memTableIndex = 1
        local sum = 0
        for i, v in ipairs(memTable) do
            sum = sum + v
        end
        --print(sum, lastSum, math.abs(sum - lastSum))
        if math.abs(sum - lastSum) > 600 then
            lastSum = sum
            sum = string.format("memUsage     = %.3f KB", sum/60)
            print(sum)
        end
    end
end
local memTextTable = {}
local memTextTableIndex = 1
local memTxtValue = 0
local function printTextMem(str)
    if str ~= memTxtValue then
        print(string.format("texMemUsage = %.1f MB", str))
        memTxtValue = str
    end
    --
    memTextTable[memTextTableIndex] = str
    memTextTableIndex = memTextTableIndex + 1
    if memTextTableIndex > 60 then
        memTextTableIndex = 1
        local sum = 0
        for i, v in ipairs(memTextTable) do
            sum = sum + v
        end
        sum = string.format("texMemUsage = %.3f KB", sum/60)
        print(sum)
    end
    --
end

--local lastTime = 0
local garbagePrinting = function()
    collectgarbage("collect")

    --local currentTime = system.getTimer()
    --print(1000/(currentTime - lastTime).." FPS")
    --lastTime = currentTime

    printMem(collectgarbage("count"))

--local texMemUsage_str = system.getInfo("textureMemoryUsed")
--texMemUsage_str = texMemUsage_str/1048576
--printTextMem(texMemUsage_str)
end

Runtime:addEventListener("enterFrame", garbagePrinting)
--]]