--[[==============
== We Love Quiz
== Date: 09/05/13
== Time: 15:48
==============]]--
TotalCoinsView = display.newGroup()

local text

local function positionsText()
    text:setReferencePoint(display.CenterRightReferencePoint)
    text.x = -4
    text.y = 24
end

local function createView()
    local coins = TextureManager.newImage("stru_iconmorecoins", TotalCoinsView)
    text = display.newText(TotalCoinsView, 99999, 0, 0, "MyriadPro-BoldCond", 30)
    positionsText()
end

function TotalCoinsView:update(newText)
    text.text = newText
    positionsText()
end

function TotalCoinsView:new()
    createView()
    return TotalCoinsView
end

return TotalCoinsView