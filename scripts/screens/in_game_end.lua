--[[==============
== We Love Quiz
== Date: 21/05/13
== Time: 14:19
==============]]--
InGameEnd = {}

local stats, scores
local finalScore
local bannerGroup

--[[
-- rightGuesses       = {number = 8, points = 7000},
    challengesOvercome = {number = 3, points = 100},
    giftsGiven         = {number = 6, points = 200},
    friendsDefeated    = {number = 9, points = 282},
    couponsEarned      = 100,
    totalCoupons       = 1100,
    championshipName   = "PAULISTA",
    position           = "12345º"
 ]]

local function createResultLine(resultsGroup, txtString, imgName, txtPoints, yPos, noLine)
    local PTS_X = 175

    local txt = display.newText(resultsGroup, txtString, 0, yPos, "MyriadPro-BoldCond", 16)
    txt:setTextColor(0)
    txt.isVisible = false
    stats[#stats + 1] = txt
    --local img = TextureManager.newImage(imgName, resultsGroup)
    --img.x = IMGS_X
    --img.y = yPos + img.height*0.5
    local pts = display.newText(resultsGroup, txtPoints, 0, yPos, "MyriadPro-BoldCond", 16)
    pts:setTextColor(0)
    pts:setReferencePoint(display.CenterRightReferencePoint)
    pts.x = PTS_X
    pts.isVisible = false
    scores[#scores + 1] = pts

    if not noLine then
        txt:setTextColor(135)
        pts:setTextColor(135)
        resultsGroup:insert(TextureManager.newHorizontalLine(92, yPos + 24, 200))
    end
end

local function createFinalResults(finalResultInfo)
    local resultsGroup = display.newGroup()

    local blackLine, whiteLine = TextureManager.newVerticalLine(130, 42, 100)
    resultsGroup:insert(blackLine)

    local lineY = 0
    --createResultLine(resultsGroup,
    --    finalResultInfo.rightGuesses.number .. " PALPITES CERTOS",
    --    "stru_icon01_encerramento",
    --    finalResultInfo.rightGuesses.points .. "pts",
    --    lineY)
    --lineY = lineY + 30
    --createResultLine(resultsGroup,
    --    finalResultInfo.challengesOvercome.number .. " DESAFIOS VENCIDOS",
    --    "stru_icon02_encerramento",
    --    finalResultInfo.challengesOvercome.points .. "pts",
    --    lineY)
    --lineY = lineY + 30
    --createResultLine(resultsGroup,
    --    finalResultInfo.giftsGiven.number .. " PRESENTES DADOS",
    --    "stru_icon03_encerramento",
    --    finalResultInfo.giftsGiven.points .. "pts",
    --    lineY)
    --lineY = lineY + 30
    --createResultLine(resultsGroup,
    --    finalResultInfo.friendsDefeated.number .. " AMIGOS DERROTADOS",
    --    "stru_icon04_encerramento",
    --    finalResultInfo.friendsDefeated.points .. "pts",
    --    lineY, true)
    createResultLine(resultsGroup,
        "PONTOS NA PARTIDA",
        nil,--"stru_icon02_encerramento",
        finalResultInfo.matchPoints .. "pts",
        lineY)
    lineY = lineY + 34
    createResultLine(resultsGroup,
        "PONTOS NA SEMANA",
        nil,--"stru_icon02_encerramento",
        finalResultInfo.weekPoints .. "pts",
        lineY)
    lineY = lineY + 34
    createResultLine(resultsGroup,
        "RANKING SEMANAL",
        nil,--"stru_icon02_encerramento",
        finalResultInfo.weekPosition .. "º",
        lineY, true)

    resultsGroup:insert(whiteLine)

    resultsGroup:setReferencePoint(display.CenterReferencePoint)
    resultsGroup.x = 28
    resultsGroup.y = -64 + (display.screenOriginY*-0.75)

    return resultsGroup
end

local function createFinalFoil(finalResultInfo)
    local foilGroup = display.newGroup()
    -- scalable menu background
    --local menuFoilCenter = TextureManager.newImageRect("images/stretchable/stru_foil_center.png", 150 + display.screenOriginX*-2, 404, foilGroup)
    local menuFoilCenter = TextureManager.newImageRect("images/stretchable/stru_foil_center.png", 141 + display.screenOriginX*-2 + display.screenOriginY*-0.25, 450, foilGroup)
    menuFoilCenter.x = 0
    menuFoilCenter.y = 0

    -- menu background border
    --local menuFoilBorder = TextureManager.newImage("stru_foil_border", foilGroup)
    local menuFoilBorder = TextureManager.newSpriteRect("stru_foil_border", 100, 450, foilGroup)
    menuFoilBorder.x = menuFoilCenter.width*0.5 + menuFoilBorder.width*0.5
    menuFoilBorder.y = 0

    -- title
    local eventNameTxt = display.newEmbossedText(foilGroup, "PARTIDA ENCERRADA!", 0, 0, "MyriadPro-BoldCond", 24)
    eventNameTxt.x = 28
    eventNameTxt.y = -150 + (display.screenOriginY*-0.75)
    eventNameTxt:setTextColor(0)
    foilGroup.title = eventNameTxt
    foilGroup:insert(TextureManager.newHorizontalLine(20, -135 + (display.screenOriginY*-0.75), 180))

    foilGroup:insert(createFinalResults(finalResultInfo))
    --foilGroup:insert(TextureManager.newHorizontalLine(20, 10 + (display.screenOriginY*-0.75), 160))

    --local pontuacaoTxt = display.newText(foilGroup, "PONTUAÇÃO TOTAL", 0, 0, "MyriadPro-BoldCond", 12)
    --pontuacaoTxt.x = 20
    --pontuacaoTxt.y = 24 + (display.screenOriginY*-0.75)
    --pontuacaoTxt:setTextColor(0)

    --finalScore = display.newText(foilGroup, "0pts", 0, 0, "MyriadPro-BoldCond", 20)
    --finalScore.x = 20
    --finalScore.y = 44 + (display.screenOriginY*-0.75)
    --finalScore:setTextColor(0)

    --local cuponsTxt = display.newText(foilGroup, "CUPONS GANHOS", 0, 0, "MyriadPro-BoldCond", 12)
    --cuponsTxt.x = 20
    --cuponsTxt.y = 24 + (display.screenOriginY*-0.75)
    --cuponsTxt:setTextColor(0)
    --cuponsTxt.isVisible = false
    --local cuponsTxt = display.newText(foilGroup, finalResultInfo.couponsEarned .. " cupons", 0, 0, "MyriadPro-BoldCond", 20)
    --cuponsTxt.x = 20
    --cuponsTxt.y = 44 + (display.screenOriginY*-0.75)
    --cuponsTxt:setTextColor(0)
    --cuponsTxt.isVisible = false

    local whistle = TextureManager.newImage("stru_whistle", foilGroup)
    whistle.x = 20
    whistle.y = 24 + (display.screenOriginY*-0.75)

    foilGroup:setReferencePoint(display.CenterLeftReferencePoint)
    foilGroup.x = SCREEN_LEFT
    foilGroup.y = SCREEN_TOP + 240

    return foilGroup
end

local function createRightSide(totalCoupons, championshipName, position)
    local rightSideGroup = display.newGroup()
    local posicaonoTxt = display.newText(rightSideGroup, "POSIÇÃO NO", 0, 0, "MyriadPro-BoldCond", 12)
    posicaonoTxt.x = SCREEN_RIGHT - 48
    posicaonoTxt.y = 94
    posicaonoTxt:setTextColor(0)
    local championshipNameTxt = display.newText(rightSideGroup, championshipName, 0, 0, "MyriadPro-BoldCond", 12)
    championshipNameTxt.x = SCREEN_RIGHT - 48
    championshipNameTxt.y = 104
    championshipNameTxt:setTextColor(0)
    local positionNum = display.newText(rightSideGroup, position, 0, 0, "MyriadPro-BoldCond", 24)
    positionNum.x = SCREEN_RIGHT - 48
    positionNum.y = 124
    positionNum:setTextColor(0)

    --local awardImg = TextureManager.newImageRect("pictures/stru_banner_end.png", 165, 194, rightSideGroup)
    --awardImg.x = SCREEN_RIGHT - awardImg.width*0.5 + 20
    --awardImg.y = display.contentCenterY + awardImg.height*0.5 - 48 + (display.screenOriginY*-0.5)
    local barSize = 94
    local bg = TextureManager.newImageRect("images/stretchable/stru_bar_mid.png", barSize, 40, rightSideGroup)
    bg.x = SCREEN_RIGHT - bg.width*0.5
    bg.y = display.contentCenterY - 50 + (display.screenOriginY*-0.5)
    local bgBorder = TextureManager.newImageRect("images/stretchable/stru_bar_left.png", 15, 40, rightSideGroup)
    bgBorder.x = bg.x - bg.width*0.5 - bgBorder.width*0.5
    bgBorder.y = bg.y
    local trophy = TextureManager.newImage("stru_trophy", rightSideGroup)
    trophy.x = bg.x - 5
    trophy.y = bg.y - 14

    local voceacumulouTxt = display.newText(rightSideGroup, "VOCÊ ACUMULOU", 0, 0, "MyriadPro-BoldCond", 12)
    voceacumulouTxt.x = bg.x - 5
    voceacumulouTxt.y = bg.y + 28
    voceacumulouTxt:setTextColor(0)
    local cuponsTxt = display.newText(rightSideGroup, totalCoupons .. " CUPONS", 0, 0, "MyriadPro-BoldCond", 18)
    cuponsTxt.x = voceacumulouTxt.x
    cuponsTxt.y = voceacumulouTxt.y + 14
    cuponsTxt:setTextColor(0)
    local paraganharTxt = display.newText(rightSideGroup, "PARA GANHAR", 0, 0, "MyriadPro-BoldCond", 12)
    paraganharTxt.x = voceacumulouTxt.x
    paraganharTxt.y = cuponsTxt.y + 14
    paraganharTxt:setTextColor(0)

    return rightSideGroup
end

local function createBanner()
    local BANNER_FILE_NAME = "banner_results.jpg"
    bannerGroup = display.newGroup()
    bannerGroup.x = SCREEN_RIGHT + 80
    bannerGroup.y = display.contentCenterY - 24
    function bannerGroup:showUp()
        self.show = true
        transition.to(self, {time = 300, x = SCREEN_RIGHT - 80, alpha = 1, transition = easeOutExpo})
    end
    function bannerGroup:hide()
        self.show = false
        transition.to(self, {time = 300, x = SCREEN_RIGHT + 80, alpha = 0, transition = easeOutExpo})
    end

    Server:getBanner(function(response, status)
        if response and status == 200 then
            local function newBanner()
                if not bannerGroup then
                    return
                end
                local noError, banner = pcall(TextureManager.newImageRect, BANNER_FILE_NAME, 160, 377, bannerGroup, system.DocumentsDirectory)
                if noError and banner then
                    banner.x = 0
                    banner.y = 0
                    local bannerMask = graphics.newMask("images/masks/banner_results_mask.png")
                    banner:setMask(bannerMask)
                    banner.maskX = 24
                    bannerGroup.touch = function(self, event)
                        if event.phase == "ended" then
                            ScreenManager:showWebView(response.results.url)
                        end
                    end
                    bannerGroup:addEventListener("touch", bannerGroup)
                    if bannerGroup.show then
                        bannerGroup.x = SCREEN_RIGHT + 80
                        bannerGroup:showUp()
                    end
                end
            end
            Server:downloadFilesList({{
                url = response.results.banner_img,
                fileName = BANNER_FILE_NAME
            }}, newBanner)
        end
    end)

    return bannerGroup
end

local function showScore(onComplete, rightSideView)
    local bannerShowTime = 6000
    local statShowDelayTime = 2000
    local statShowTime = 1000
    if not onComplete then
        bannerShowTime = 1500
        statShowDelayTime = 500
        statShowTime = 200
    end
    local count = 0
    local PTS_X = 175
    for i, v in ipairs(stats) do
        transition.to(v, {delay = (i - 1)*statShowDelayTime, time = statShowTime, x = v.x, transition = easeOutExpo, onComplete = function()
            scores[i].isVisible = true
            scores[i].x = PTS_X - 48
            scores[i].xScale = 0.2
            scores[i].yScale = 0.2
            transition.to(scores[i], {time = 500, x = PTS_X, xScale = 1, yScale = 1, transition = easeOutBack, onComplete = function()
                --local ptsNum = scores[i].text
                --ptsNum = tonumber(ptsNum:sub(1, ptsNum:len() - 3))
                --pts = pts + ptsNum
                --finalScore.text = pts .. "pts"
                --finalScore:setReferencePoint(display.CenterReferencePoint)
                --finalScore.x = 20
                count = count + 1
                if count >= 3 then
                    --rightSideView.isVisible = true
                    --transition.from(rightSideView, {delay = 2000, time = 700, x = SCREEN_RIGHT + rightSideView.width, transition = easeOutExpo, onComplete = onComplete})
                    if onComplete then
                        onComplete()
                    end
                end
                --stats, scores = nil, nil
                --finalScore = nil
            end})
        end})
        v.x = -100 + display.screenOriginX
        v.isVisible = true
    end
    timer.performWithDelay(bannerShowTime, function()
        bannerGroup:showUp()
    end)
end

function InGameEnd:showUp(onComplete, noWhistle)
    self.isVisible = true
    --self.rightSideView.isVisible = false

    transition.from(self.leftSideView, {time = 300, x = SCREEN_LEFT - self.leftSideView.width, transition = easeOutExpo, onComplete = function()
        if not noWhistle then
            showScore(onComplete, self.rightSideView)
        else
            if onComplete then
                onComplete()
            end
            bannerGroup:showUp()
        end
    end})
    if not noWhistle then
        AudioManager.playAudio("finalWhistle")
    end
end

function InGameEnd:hide(onComplete)
    transition.to(self.leftSideView, {time = 300, x = SCREEN_LEFT - self.leftSideView.width, transition = easeOutExpo, onComplete = function()
        self.isVisible = false
        self.leftSideView.x = SCREEN_LEFT
        if onComplete then
            onComplete()
        end
    end})
    bannerGroup:hide()
end

function InGameEnd:create(finalResultInfo)
    local endGroup = display.newGroup()
    for k, v in pairs(InGameEnd) do
        endGroup[k] = v
    end

    stats, scores = {}, {}

    endGroup:insert(createBanner())

    endGroup.leftSideView = createFinalFoil(finalResultInfo)
    endGroup:insert(endGroup.leftSideView)
    --endGroup.rightSideView = createRightSide(finalResultInfo.totalCoupons, finalResultInfo.championshipName, finalResultInfo.position)
    --endGroup:insert(endGroup.rightSideView)

    endGroup.isVisible = false

    return endGroup
end

return InGameEnd