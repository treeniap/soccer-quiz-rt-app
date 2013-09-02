--[[==============
== We Love Quiz
== Date: 29/08/13
== Time: 15:44
==============]]--
Goal = {}

local TextureManager = TextureManager

local SHARE_BAR_Y = 100
local SHARE_BTNS_Y_DIFF = 2

local goalAnnoucement

local function createText(goalData)
    local text
    local otherTeam      = goalData.scoringTeam == "homeTeam" and "awayTeam" or "homeTeam"
    local goalTeamName   = goalData[goalData.scoringTeam].name
    local goalTeamScore  = goalData[goalData.scoringTeam].score
    local otherTeamScore = goalData[otherTeam].score

    local goleadaTexts = {
        "Mais um para a goleada!",
        goalTeamName .. " não dá chances!",
        goalTeamName .. " impiedoso!",
        goalTeamName .. " balança as redes novamente!",
        "Tá fácil demais!"
    }
    
    local firstTexts = {
        goalTeamName .. " faz o primeiro!",
        goalTeamName .. " sai na frente!",
        goalTeamName .. " abre a contagem do placar!"
    }

    local empataTexts = {
        goalTeamName .. " empata!",
        goalTeamName .. " iguala o placar!",
        "Está tudo igual!"
    }

    local desempataTexts = {
        goalTeamName .. " desempata!",
        goalTeamName .. " está à frente no placar!"
    }

    local goalDiff = goalTeamScore - otherTeamScore
    if goalDiff > 3 then
        text = goleadaTexts[math.random(#goleadaTexts)]
    elseif goalDiff == 3 then
        if otherTeamScore > 0 then
            text = goleadaTexts[math.random(#goleadaTexts)]
        else
            text = "Já virou goleada!"
        end
    elseif goalDiff == 2 then
        text = goalTeamName .. " amplia a vantagem!"
    elseif goalDiff == 1 then
        if otherTeamScore == 0 then
            text = firstTexts[math.random(#firstTexts)]
        else
            text = desempataTexts[math.random(#desempataTexts)]
        end
    elseif goalDiff == 0 then
        text = empataTexts[math.random(#empataTexts)]
    elseif goalDiff == -1 then
        text = goalTeamName .. " diminui a vantagem! Será que ainda dá?"
    elseif goalDiff == -2 then
        if goalTeamScore == 1 then
            text = goalTeamName .. " tira o zero do placar!"
        else
            text = goalTeamName .. " diminui a vantagem!"
        end
    elseif goalDiff < -2 then
        if goalTeamScore == 1 then
            text = goalTeamName .. " faz o seu"
        else
            text = goalTeamName .. " diminui o vexame!"
        end
    end

    text = goalData["homeTeam"].name .. " " .. goalData["homeTeam"].score .. " x "
            .. goalData["awayTeam"].score .. " " .. goalData["awayTeam"].name .. ". " .. text

    return text
end

local function createBtnCore(img, blendMode)
    local btnGroup = display.newGroup()
    local center = TextureManager.newImageRect("images/goal/bar_" .. img .. "_bt_B.png", 76, 24, btnGroup)
    local left = TextureManager.newImageRect("images/goal/bar_" .. img .. "_bt_A.png", 8, 24, btnGroup)
    local right = TextureManager.newImageRect("images/goal/bar_" .. img .. "_bt_C.png", 8, 24, btnGroup)
    left.x = -center.width*0.5 - left.width*0.5
    right.x = center.width*0.5 + right.width*0.5

    center.blendMode = blendMode
    left.blendMode = blendMode
    right.blendMode = blendMode

    return btnGroup
end

local function createFacebookBtn(goalData)
    local BtnFacebook = {}
    function BtnFacebook:createView()
        local fbBarBgCenter = TextureManager.newImageRect("images/goal/bar_01_A.png", 140, 40, self)
        fbBarBgCenter.x = -CONTENT_WIDTH*0.5 + fbBarBgCenter.width*0.5
        fbBarBgCenter.y = SHARE_BAR_Y
        local fbBarBgBorder = TextureManager.newImageRect("images/goal/bar_01_B.png", 16, 40, self)
        fbBarBgBorder.x = fbBarBgCenter.x + fbBarBgCenter.width*0.5 + fbBarBgBorder.width*0.5
        fbBarBgBorder.y = SHARE_BAR_Y

        self.default = createBtnCore("01", "normal")
        self.default.x = fbBarBgCenter.x + (fbBarBgCenter.width - self.default.width)*0.45
        self.default.y = SHARE_BAR_Y - SHARE_BTNS_Y_DIFF
        self:insert(self.default)
        self.over = createBtnCore("01", "multiply")
        self.over.x = self.default.x
        self.over.y = SHARE_BAR_Y - SHARE_BTNS_Y_DIFF
        self.over.isVisible = false
        self:insert(self.over)

        local fbBarIcon = TextureManager.newImageRect("images/goal/bar_01_icon.png", 15, 27, self)
        fbBarIcon.x = self.default.x - self.default.width*0.5 - 12
        fbBarIcon.y = SHARE_BAR_Y - SHARE_BTNS_Y_DIFF

        local txt = display.newText(self, "COMPARTILHAR", 0, 0, "MyriadPro-BoldCond", 14)
        txt.x = self.default.x
        txt.y = self.default.y
        self.isVisible = false
    end

    function BtnFacebook:show()
        self.isVisible = true
        self.trans = transition.from(self, {time = 500, x = -CONTENT_WIDTH*0.5 - self.width, transition = easeOutExpo})
    end

    function BtnFacebook:hide()
        if self.trans then
            transition.cancel(self.trans)
        end
        self.trans = transition.to(self, {time = 500, x = -CONTENT_WIDTH*0.5 - self.width, transition = easeInExpo})
    end

    return PressRelease:new(BtnFacebook, function(self, event)
        self:hide()
        Facebook:postMessage(createText(goalData))
    end)
end

local function createTwitterBtn(goalData)
    local BtnTwitter = {}
    function BtnTwitter:createView()
        local twitterBarBgCenter = TextureManager.newImageRect("images/goal/bar_02_A.png", 140, 40, self)
        twitterBarBgCenter.x = CONTENT_WIDTH*0.5 - twitterBarBgCenter.width*0.5
        twitterBarBgCenter.y = SHARE_BAR_Y
        local twitterBarBgBorder = TextureManager.newImageRect("images/goal/bar_02_B.png", 16, 40, self)
        twitterBarBgBorder.x = twitterBarBgCenter.x - twitterBarBgCenter.width*0.5 - twitterBarBgBorder.width*0.5
        twitterBarBgBorder.y = SHARE_BAR_Y

        self.default = createBtnCore("02", "normal")
        self.default.x = twitterBarBgCenter.x - (twitterBarBgCenter.width - self.default.width)*0.45 - 4
        self.default.y = SHARE_BAR_Y - SHARE_BTNS_Y_DIFF
        self:insert(self.default)
        self.over = createBtnCore("02", "multiply")
        self.over.x = self.default.x
        self.over.y = SHARE_BAR_Y - SHARE_BTNS_Y_DIFF
        self.over.isVisible = false
        self:insert(self.over)

        local twitterBarIcon = TextureManager.newImageRect("images/goal/bar_02_icon.png", 25, 21, self)
        twitterBarIcon.x = self.default.x + self.default.width*0.5 + 12
        twitterBarIcon.y = SHARE_BAR_Y - SHARE_BTNS_Y_DIFF

        local txt = display.newText(self, "TUÍTAR", 0, 0, "MyriadPro-BoldCond", 14)
        txt.x = self.default.x
        txt.y = self.default.y
        self.isVisible = false
    end

    function BtnTwitter:show()
        self.isVisible = true
        self.trans = transition.from(self, {time = 500, x = CONTENT_WIDTH*0.5 + self.width, transition = easeOutExpo})
    end

    function BtnTwitter:hide()
        if self.trans then
            transition.cancel(self.trans)
        end
        self.trans = transition.to(self, {time = 500, x = CONTENT_WIDTH*0.5 + self.width, transition = easeInExpo})
    end

    return PressRelease:new(BtnTwitter, function(self, event)
        local twitter
        local function post()
            twitter:showPopup(createText(goalData), "@chutepremiado")
        end
        local listener = function( event )
        --printTable(event)
            if event.phase == "authorised" then
                post()
            else
                AnalyticsManager.postTwitter("Goal")
            end
        end
        twitter = require("scripts.network.GGTwitter"):new("kaO6n7jMhgyNzx9lXhLg", "OY0PBfVKizWKfUutKjwh1gt3W99YOmlqbYtgqzg81I", listener)
        if twitter:isAuthorised() then
            post()
        else
            twitter:authorise()
        end
        self:hide()
    end)
end

local function createCloseBtn(x, y, listener)
    local BtnClose = {}
    function BtnClose:createView()
        self.default = TextureManager.newImageRect("images/goal/bt_fechar.png", 75, 41, self)
        self.default.x = 0
        self.default.y = 0
        self.over = TextureManager.newImageRect("images/goal/bt_fechar.png", 75, 41, self)
        self.over.x = 0
        self.over.y = 0
        self.over.blendMode = "multiply"
        self.over.isVisible = false

        self.x = x
        self.y = y
        self.isVisible = false
    end

    function BtnClose:show()
        self.isVisible = true
        self.trans = transition.from(self, {time = 500, x = self.x + 100, transition = easeOutExpo})
    end

    function BtnClose:hide(onComplete)
        if self.trans then
            transition.cancel(self.trans)
        end
        self.trans = transition.to(self, {time = 500, x = self.x + 100, transition = easeInExpo, onComplete = function()
            self.isVisible = false
            onComplete()
        end})
    end

    return PressRelease:new(BtnClose, listener)
end

function Goal:close()
    if goalAnnoucement then
        goalAnnoucement:hide()
    end
end

function Goal:new(goalData)
    if goalAnnoucement then
        goalAnnoucement:hide(function() Goal:new(goalData) end)
        return
    end
    local goalGroup = display.newGroup()

    local bg = display.newRect(goalGroup, 0, 0, CONTENT_WIDTH, CONTENT_HEIGHT*2)
    bg.x = 0
    bg.y = 0
    bg:setFillColor(0, 192)
    bg:addEventListener("touch", function() return true end)

    local logoGroup = display.newGroup()
    local mainBarBgCenter = TextureManager.newImageRect("images/goal/bar_gol_B.png", 208, 111, logoGroup)
    local mainBarBgBorder = TextureManager.newImageRect("images/goal/bar_gol_A.png", 42, 111, logoGroup)
    mainBarBgBorder.x = -mainBarBgCenter.width*0.5 - mainBarBgBorder.width*0.5
    local logo = TextureManager.newImageRect("images/goal/bar_gol_symbol.png", 116, 105, logoGroup)
    logo.x = mainBarBgCenter.width*0.5
    logo.y = -4
    logoGroup.isVisible = false
    goalGroup:insert(logoGroup)

    local splashGroup = display.newGroup()
    local splash = TextureManager.newImageRect("images/goal/bar_splash_512.png", 312, 312, splashGroup)
    splash.x = -logo.width*0.25
    local color =
    {
        highlight = {r =0, g = 0, b = 0, a = 200},
        shadow = {r = 0, g = 0, b = 0, a = 0}
    }
    local doOrDa = "DO"
    if goalData[goalData.scoringTeam].name == "Portuguesa" or goalData[goalData.scoringTeam].name == "Ponte Preta" then
        doOrDa = "DA"
    end
    local txt = display.newEmbossedText(splashGroup, "GOOOOOOL " .. doOrDa, 0, 0, "MyriadPro-BoldCond", 32)
    txt.x = -32
    txt.y = -20
    txt:setTextColor(168, 146, 87)
    txt:setEmbossColor(color)

    local teamName = string.utf8upper(goalData[goalData.scoringTeam].name) .. "!!!"
    local lineSize = 0
    local i = 1
    while i <= teamName:len() do
        local l = teamName:sub(i, i)
        lineSize = lineSize + getFontLettersSize(l)
        i = i + 1
    end
    local size = (340/lineSize)*50
    if size > 50 then
        size = 50
    end
    local txt = display.newEmbossedText(splashGroup, teamName, 0, 0, "MyriadPro-BoldCond", size)
    txt.x = -40
    txt.y = 20
    txt:setTextColor(168, 146, 87)
    txt:setEmbossColor(color)
    splashGroup.isVisible = false
    goalGroup:insert(splashGroup)

    local btnClose = createCloseBtn(logo.x, -logo.height*0.75, function() goalGroup:hide() end)
    goalGroup:insert(btnClose)
    local fbBtn = createFacebookBtn(goalData)
    goalGroup:insert(fbBtn)
    local twitterBtn = createTwitterBtn(goalData)
    goalGroup:insert(twitterBtn)

    function goalGroup:show()
        logoGroup.isVisible = true
        transition.from(logoGroup, {time = 500, x = -CONTENT_WIDTH, transition = easeOutExpo, onComplete = function()
            splashGroup.isVisible = true
            transition.from(splashGroup, {time = 500, xScale = 0.1, yScale = 0.1, transition = easeOutExpo, onComplete = function()
                fbBtn:show()
                twitterBtn:show()
                btnClose:show()
            end})
        end})
    end

    function goalGroup:hide(onComplete)
        fbBtn:hide()
        twitterBtn:hide()
        btnClose:hide(function()
            transition.to(splashGroup, {time = 500, alpha = 0, transition = easeInExpo, onComplete = function()
                splashGroup.isVisible = false
                transition.to(logoGroup, {time = 500, x = CONTENT_WIDTH, transition = easeInExpo, onComplete = function()
                    logoGroup.isVisible = false
                    self:removeSelf()
                    goalAnnoucement = nil
                    if onComplete then
                        onComplete()
                    end
                end})
            end})
        end)
    end

    goalAnnoucement = goalGroup

    goalGroup.x = display.contentCenterX
    goalGroup.y = display.contentCenterY - 56
    goalGroup:show()
end

return Goal