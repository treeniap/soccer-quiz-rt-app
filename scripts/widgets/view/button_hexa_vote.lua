--[[==============
== Pocket World
== Date: 26/04/13
== Time: 10:47
==============]]--
BtnHexaVote = {}

local function newLockableImage(frameName)
    local blendedImageGroup = display.newGroup()
    local backImage = TextureManager.newImage(frameName, blendedImageGroup)
    backImage.x = 0
    backImage.y = -17
    local foreImage = TextureManager.newImage(frameName, blendedImageGroup)
    foreImage.x = 0
    foreImage.y = -17
    foreImage:setFillColor(200, 255)
    foreImage.blendMode = "screen"
    foreImage.isVisible = false
    function blendedImageGroup:lock(isLock)
        self[2].isVisible = isLock
        --self.alpha = isLock and 0.5 or 1
    end
    return blendedImageGroup
end

local function newLockableText(group, text, x, y, size)
    local _text = display.newText(group, text, 0, 0, "MyriadPro-BoldCond", size)
    _text.x = x - _text.width*0.5
    _text.y = y
    _text:setTextColor(0)
    function _text:lock(isLock)
        self:setTextColor(isLock and 160 or 0)
    end
    return _text
end

function BtnHexaVote:createBase()
    local topHexaBtn = newLockableImage("stru_buttonhexa_back_vote")
    topHexaBtn.y = -17
    local middleHexaBtn = newLockableImage("stru_buttonhexa_midle_vote")
    local bottomHexaBtn = newLockableImage("stru_buttonhexa_front_vote")
    bottomHexaBtn.x = -1
    bottomHexaBtn.y = 28
    self.baseTop = topHexaBtn
    self.baseBottom = bottomHexaBtn
    self:insert(1, topHexaBtn)
    self:insert(2, middleHexaBtn)
    self:insert(bottomHexaBtn)
end

local coinSlotsPosition = {
    {x = -2, y = 17},
    {x = 3, y = 8},
    {x = -2, y = -1},
    {x = 3, y = -10},
    {x = -2, y = -19}
}

function BtnHexaVote:createCoinSlot()
    local coinSlotGroup = display.newGroup()
    local coinSlotBg = newLockableImage("stru_coinslot_vote")
    coinSlotGroup:insert(coinSlotBg)
    for i = 1, #coinSlotsPosition do
        local coin = newLockableImage("stru_coin_vote")
        coin.x = coinSlotsPosition[i].x
        coin.y = coinSlotsPosition[i].y
        coin.isVisible = false
        coinSlotGroup:insert(coin)
    end
    coinSlotGroup.x = 43
    coinSlotGroup.y = -18
    coinSlotGroup.coinsAmount = 0
    function coinSlotGroup:lock(isLock)
        self[1]:lock(isLock)
    end
    self.coinSlot = coinSlotGroup
    self:insert(coinSlotGroup)
end

local questionsAlternatives = {
    goal    = {text = "GOL",    frameName = "stru_pic_gol_vote"},
    saved   = {text = "SALVA",  frameName = "stru_pic_defende_vote"},
    cleared = {text = "AFASTA", frameName = "stru_pic_tira_vote"},
    missed  = {text = "FORA",   frameName = "stru_pic_fora_vote"},
    yes     = {text = "SIM"},
    no      = {text = "NÃO"}
}

function BtnHexaVote:createAlternativePicture(question)
    local pic = newLockableImage(question.frameName)
    self:insert(pic)
    pic.x = -18
    pic.y = -30
    local label = newLockableText(self, question.text, -2, 10, 16)
end

function BtnHexaVote:createAlternativeText(question)
    newLockableText(self, question.text, 18, -11, 48)
end

function BtnHexaVote:createMultiplier(value)
    self.multiplierTxt = newLockableText(self, string.format("%.1f", value), 34, 9, 24)
    newLockableText(self, "x", 42, 10, 16)
end

function BtnHexaVote:showFriendVoted(friend)
    self:lock(true)
    local coinSlotsPosition = {
        {x = -2, y = 17},
        {x = 2, y = 13},
        {x = -2, y = 9},
        {x = 2, y = 5},
        {x = -2, y = 1}
    }

    self.friendView = {}
    local photoBg = TextureManager.newImage("stru_albumframe", self)
    photoBg.x = -28
    photoBg.y = -48
    self.friendView[#self.friendView + 1] = photoBg
    local photo = TextureManager.newImageRect(friend.photo, 53, 53, self)
    photo.x = -25
    photo.y = -45
    self.friendView[#self.friendView + 1] = photo

    local coinSlotGroup = display.newGroup()
    for i = 1, friend.coins do
        local coin = TextureManager.newImage("stru_coin_friendsvote", coinSlotGroup)
        coin.x = coinSlotsPosition[i].x
        coin.y = coinSlotsPosition[i].y
    end
    coinSlotGroup.x = -44
    coinSlotGroup.y = -38
    self:insert(coinSlotGroup)
    self.friendView[#self.friendView + 1] = coinSlotGroup
end

function BtnHexaVote:resetButton(multiplier)
    self:lock(false)
    if self.friendView then
        for i, v in ipairs(self.friendView) do
            v:removeSelf()
        end
        self.friendView = nil
    end
    self.multiplierTxt.text = string.format("%.1f", multiplier)
end

function BtnHexaVote:addCoin()
    if self.coinSlot.coinsAmount < #coinSlotsPosition then
        self.coinSlot.coinsAmount = self.coinSlot.coinsAmount + 1
        self.coinSlot[self.coinSlot.coinsAmount + 1].isVisible = true
    end
end

function BtnHexaVote:getBetCoins()
    return self.coinSlot.coinsAmount
end

function BtnHexaVote:resetCoins()
    local btnCoinSlot = self.coinSlot
    while btnCoinSlot.coinsAmount > 0 do
        btnCoinSlot[btnCoinSlot.coinsAmount + 1].isVisible = false
        btnCoinSlot.coinsAmount = btnCoinSlot.coinsAmount - 1
    end
end

function BtnHexaVote:lock(isLock)
    for i = 1, self.numChildren do
        self[i]:lock(isLock)
    end
    self.isLocked = isLock
end

function BtnHexaVote:onPressed()
    if self.isPressed then
        return
    end
    self.y = self.y + 3
    self.baseTop.y = self.baseTop.y - 3
    self.baseBottom.y = self.baseBottom.y - 3
    self.isPressed = true
end

function BtnHexaVote:onReleased()
    if not self.isPressed then
        return
    end
    self.y = self.y - 3
    self.baseTop.y = self.baseTop.y + 3
    self.baseBottom.y = self.baseBottom.y + 3
    self.isPressed = false
end

function BtnHexaVote:new(questionLabel, multiplierValue, onRelease)
    local hexaBtnGroup = display.newGroup()
    for k, v in pairs(BtnHexaVote) do
        hexaBtnGroup[k] = v
    end

    if questionsAlternatives[questionLabel].frameName then
        hexaBtnGroup:createAlternativePicture(questionsAlternatives[questionLabel])
    else
        hexaBtnGroup:createAlternativeText(questionsAlternatives[questionLabel])
    end
    hexaBtnGroup:createCoinSlot()
    hexaBtnGroup:createMultiplier(multiplierValue)
    hexaBtnGroup:createBase()

    hexaBtnGroup.onRelease = onRelease
    hexaBtnGroup.touch = TouchHandler.pressReleaseHandler
    hexaBtnGroup:addEventListener("touch", hexaBtnGroup)

    hexaBtnGroup.xScale = 0.95
    hexaBtnGroup.yScale = 0.95

    return hexaBtnGroup
end

return BtnHexaVote