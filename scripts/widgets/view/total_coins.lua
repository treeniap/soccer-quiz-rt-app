--[[==============
== We Love Quiz
== Date: 09/05/13
== Time: 15:48
==============]]--
TotalCoinsView = {}

local totalCoinsGroup
local text

local function positionsText()
    text:setReferencePoint(display.CenterRightReferencePoint)
    text.x = -4
    text.y = 24
end

local function createView()
    local coins = TextureManager.newImage("stru_iconmorecoins", totalCoinsGroup)
    text = display.newText(totalCoinsGroup, 0, 0, 0, "MyriadPro-BoldCond", 30)
    positionsText()
end

function TotalCoinsView:update(newText)
    text.text = newText
    positionsText()
end

function TotalCoinsView:new()
    if totalCoinsGroup then
        return totalCoinsGroup
    end
    totalCoinsGroup = display.newGroup()
    for k, v in pairs(TotalCoinsView) do
        totalCoinsGroup[k] = v
    end
    createView()
    return totalCoinsGroup
end

return TotalCoinsView