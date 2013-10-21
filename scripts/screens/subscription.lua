--[[==============
== We Love Quiz
== Date: 09/10/13
== Time: 10:31
==============]]--
SubscriptionScreen = {}

local subsGroup
local subsSheetInfo, subsSheetImage
local userCondition

local function updateUserCondition()
    if UserData.inventory.subscribed then
        userCondition.text = "ASSINADO"
        userCondition:setTextColor(0, 128, 0)
    else
        userCondition.text = "NÃO ASSINADO"
        userCondition:setTextColor(192, 0, 0)
    end
    userCondition:setReferencePoint(display.TopLeftReferencePoint)
    userCondition.x = 64 + (-display.screenOriginX)
    userCondition.y = -6
end

local function createBG()
    local bg = TextureManager.newImageRect("images/stretchable/stru_menu_bg.png", CONTENT_WIDTH, CONTENT_HEIGHT)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY
    return bg
end

local function createConditionBar()
    local barGroup = display.newGroup()

    local border = TextureManager.newImageRect("images/stats/bar_stats_A.png", 8, 22, barGroup)
    local center = TextureManager.newImageRect("images/stats/bar_stats_B.png", CONTENT_WIDTH - 24, 22, barGroup)
    center.x = center.width*0.5 + border.width*0.5
    local border = TextureManager.newImageRect("images/stats/bar_stats_C.png", 16, 22, barGroup)
    border.x = center.x + center.width*0.5 + border.width*0.5

    local text = display.newEmbossedText(barGroup, "CONDIÇÃO: ", 8 + (-display.screenOriginX), -6, "MyriadPro-BoldCond", 12)
    text:setTextColor(96)

    userCondition = display.newText(barGroup, "", 0, 0, "MyriadPro-BoldCond", 12)
    updateUserCondition()

    barGroup:setReferencePoint(display.TopCenterReferencePoint)
    barGroup.x = display.contentCenterX
    barGroup.y = display.screenOriginY + 100

    return barGroup
end

local function createButtons()
    local buttonsGroup = display.newGroup()

    local subscribeGroup = {}
    function subscribeGroup:createView()
        self.default = display.newImageRect(self, subsSheetImage, subsSheetInfo:getFrameIndex("bt_vermelho"), 204, 37)
        self.default.x = 0
        self.default.y = 0
        self.over = display.newRect(self, 0, 0, self.default.width, self.default.height)
        self.over.x = 0
        self.over.y = 0
        self.over:setFillColor(255, 32)
        self.over.blendMode = "add"
        self.over.isVisible = false
        self.text = display.newEmbossedText(self, "ASSINAR", 0, 0, "MyriadPro-BoldCond", 18)
        self.text.x = 0
        self.text.y = 0
        self.text:setTextColor(255)
    end
    local subscribeBtn = PressRelease:new(subscribeGroup, function()
        if not UserData.inventory.subscribed then
            StoreManager.buyThis("semana")
        end
    end)

    local restoreGroup = {}
    function restoreGroup:createView()
        self.default = display.newImageRect(self, subsSheetImage, subsSheetInfo:getFrameIndex("bt_gold"), 204, 37)
        self.default.x = 0
        self.default.y = 0
        self.over = display.newRect(self, 0, 0, self.default.width, self.default.height)
        self.over.x = 0
        self.over.y = 0
        self.over:setFillColor(255, 32)
        self.over.blendMode = "add"
        self.over.isVisible = false
        self.text = display.newEmbossedText(self, "RESTAURAR ASSINATURA", 0, 0, "MyriadPro-BoldCond", 18)
        self.text.x = 0
        self.text.y = 0
        self.text:setTextColor(255)
    end
    local restoreBtn = PressRelease:new(restoreGroup, function()
        if not UserData.inventory.subscribed then
            StoreManager.restore()
        end
    end)

    buttonsGroup:insert(subscribeBtn)
    buttonsGroup:insert(restoreBtn)

    buttonsGroup.x = display.contentCenterX
    buttonsGroup.y = display.screenOriginY + 170

    subscribeBtn.x = 0
    subscribeBtn.y = 0
    restoreBtn.x = 0
    restoreBtn.y = restoreBtn.height*1.5

    return buttonsGroup
end

local function createContent()
    local contentGroup = display.newGroup()

    local desc = display.newText(contentGroup, "ASSINATURA", 8 + (-display.screenOriginX), display.screenOriginY + 70, "MyriadPro-BoldCond", 20)
    desc:setTextColor(0)

    contentGroup:insert(createConditionBar())
    contentGroup:insert(createButtons())

    return contentGroup
end

function SubscriptionScreen:updateTotalCoins()
    updateUserCondition()
end

function SubscriptionScreen:showUp(onComplete)
    transition.from(subsGroup[3], {time = 300, y = SCREEN_TOP - 50, transition = easeInQuart, onComplete = function()
        subsGroup[1].isVisible = true
        subsGroup[2].isVisible = true
        transition.from(subsGroup[1], {time = 300, alpha = 0})
        transition.from(subsGroup[2], {time = 300, y = -CONTENT_HEIGHT*0.5, onComplete = onComplete})
    end})
end

function SubscriptionScreen:hide(onComplete)
    transition.to(subsGroup[1], {time = 300, alpha = 0})
    transition.to(subsGroup[2], {time = 300, y = -CONTENT_HEIGHT*0.5, onComplete = function()
        transition.to(subsGroup[3], {time = 300, y = SCREEN_TOP - 50, transition = easeInQuart, onComplete = function()
            SubscriptionScreen:destroy()
            if onComplete then
                onComplete()
            end
        end})
    end})
end

function SubscriptionScreen:new()
    subsGroup = display.newGroup()

    subsSheetInfo, subsSheetImage = TextureManager.loadSubsSheet()

    subsGroup:insert(createBG())
    subsGroup:insert(createContent())
    subsGroup:insert(TopBarMenu:new("CONFIGURAÇÕES"))

    subsGroup[1].isVisible = false
    subsGroup[2].isVisible = false

    return subsGroup
end

function SubscriptionScreen:destroy()
    TextureManager.disposeSubsSheet()
    subsSheetInfo, subsSheetImage = nil, nil
    subsGroup:removeSelf()
    subsGroup = nil
end

return SubscriptionScreen