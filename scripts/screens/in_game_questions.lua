--[[==============
== We Love Quiz
== Date: 16/05/13
== Time: 15:16
==============]]--
InGameQuestions = {}

require "scripts.widgets.view.button_skip"
require "scripts.widgets.view.button_confirm_answer"

local txtTime, matchStartTime

local function createChallengeName(name)
    local challengeNameGroup = display.newGroup()
    local name = display.newEmbossedText(name, 0, 0, "MyriadPro-BoldCond", 20)
    name:setTextColor(92)
    name.x = 0
    name.y = 0
    local barSize = name.width + 24
    local bg = TextureManager.newImageRect("images/stretchable/stru_bar_mid.png", barSize, 40, challengeNameGroup)
    bg.x = 0
    bg.y = 0
    local bgBorder = TextureManager.newImageRect("images/stretchable/stru_bar_right.png", 15, 40, challengeNameGroup)
    bgBorder.x = bg.width*0.5 + bgBorder.width*0.5
    bgBorder.y = 0
    challengeNameGroup:insert(name)
    challengeNameGroup.barSize = barSize
    return challengeNameGroup
end

local function createChallengeProgress(questionsNumber)
    local challengeProgressGroup = display.newGroup()
    local number = display.newText("1/"..questionsNumber, 0, 0, "MyriadPro-BoldCond", 20)
    number:setTextColor(0)
    number.x = 0
    number.y = 0
    local barSize = number.width + 24
    local bg = TextureManager.newImageRect("images/stretchable/stru_bar_mid.png", barSize, 40, challengeProgressGroup)
    bg.x = 0
    bg.y = 0
    local bgBorder = TextureManager.newImageRect("images/stretchable/stru_bar_left.png", 15, 40, challengeProgressGroup)
    bgBorder.x = -bg.width*0.5 - bgBorder.width*0.5
    bgBorder.y = 0
    challengeProgressGroup:insert(number)
    challengeProgressGroup.barSize = barSize
    return challengeProgressGroup
end

local function createRedBar()
    local redBarGroup = display.newGroup()
    local button = BtnSkip:new(function() return true end)
    button.x = 0
    button.y = -3
    local barSize = button.width + 12
    local bg = TextureManager.newImageRect("images/stretchable/stru_bar_red_mid.png", barSize, 40, redBarGroup)
    bg.x = 0
    bg.y = 0
    local bgBorder = TextureManager.newImageRect("images/stretchable/stru_bar_red.png", 15, 40, redBarGroup)
    bgBorder.x = bg.width*0.5 + bgBorder.width*0.5
    bgBorder.y = 0
    redBarGroup:insert(button)
    redBarGroup.barSize = barSize
    return redBarGroup
end

local function createGoldBar()
    local challengeProgressGroup = display.newGroup()
    local button = BtnConfirmAnswer:new(function() return true end)
    button.x = 0
    button.y = -3
    local barSize = button.width + 12
    local bg = TextureManager.newImageRect("images/stretchable/stru_bar_gold_mid.png", barSize, 40, challengeProgressGroup)
    bg.x = 0
    bg.y = 0
    local bgBorder = TextureManager.newImageRect("images/stretchable/stru_bar_gold.png", 15, 40, challengeProgressGroup)
    bgBorder.x = -bg.width*0.5 - bgBorder.width*0.5
    bgBorder.y = 0
    challengeProgressGroup:insert(button)
    challengeProgressGroup.barSize = barSize
    return challengeProgressGroup
end

local function createQuestionText(question)
    local questionGroup = display.newGroup()

    local FONT_SIZE = 28

    local lineSize = 0
    local lastSpace = 1
    local firstLineLetter = 1
    local lines = {}
    local i = 1
    while i <= question:len() do
        local l = question:sub(i, i)
        lineSize = lineSize + getFontLettersSize(l)
        if l == " " then
            lastSpace = i
        end
        if lineSize * (FONT_SIZE / 100) > CONTENT_WIDTH - 24 then
            lines[#lines + 1] = question:sub(firstLineLetter, lastSpace - 1)
            --print(question:sub(firstLineLetter, lastSpace))
            firstLineLetter = lastSpace + 1
            i = lastSpace
            lineSize = 0
        end
        i = i + 1
    end
    if lastSpace < question:len() then
        lastSpace = question:len()
    end
    lines[#lines + 1] = question:sub(firstLineLetter, lastSpace)
    --print(question:sub(firstLineLetter, lastSpace))

    local lineY = 0
    for i, v in ipairs(lines) do
        local questionLine = display.newText(questionGroup, v, 0, 0, "MyriadPro-BoldCond", FONT_SIZE)
        questionLine:setTextColor(0)
        questionLine.x = 0
        questionLine.y = lineY
        lineY = lineY + questionLine.height
    end

    return questionGroup
end

local lastSecond = -1
local function updateTime()
    local date = os.date( "*t" )
    if date.sec == lastSecond then
        return
    end
    --print( date.hour, date.min, date.sec )
    lastSecond = date.sec
    local seconds = (matchStartTime.hour*3600 + matchStartTime.min*60 + matchStartTime.sec) - (date.hour*3600 + date.min*60 + date.sec)
    local minutes = math.floor(seconds/60)
    seconds = seconds%60
    txtTime.text = string.format("%02d", minutes) .. ":" .. string.format("%02d", seconds)
end

local function createTimerBar()
    local timerBarGroup = display.newGroup()

    local bg = TextureManager.newImageRect("images/stretchable/stru_bar_mid.png", CONTENT_WIDTH, 40, timerBarGroup)
    bg.x = display.contentCenterX
    bg.y = 0

    local txtComecandoEm = display.newText(timerBarGroup, "COMEÇANDO EM", 0, 0, "MyriadPro-BoldCond", 15)
    txtComecandoEm:setTextColor(0)
    txtComecandoEm.x = SCREEN_RIGHT - 104
    txtComecandoEm.y = -1
    txtTime = display.newText(timerBarGroup, "00:00", 0, 0, "MyriadPro-BoldCond", 20)
    txtTime:setTextColor(0)
    txtTime.x = txtComecandoEm.x + 64
    txtTime.y =  - 2

    Runtime:addEventListener("enterFrame", updateTime)

    return timerBarGroup
end

--[[
name = "DESAFIO DO PRÉ-JOGO",
matchTime = {hour = 19, min = 15, sec = 0},
questions = {
]]
function InGameQuestions:create(challengeInfo)
    local questionGroup = display.newGroup()
    for k, v in pairs(InGameQuestions) do
        questionGroup[k] = v
    end

    matchStartTime = challengeInfo.matchTime

    local challengeName = createChallengeName(challengeInfo.name)
    challengeName.x = SCREEN_LEFT + challengeName.barSize*0.5
    challengeName.y = SCREEN_TOP + 100
    questionGroup:insert(challengeName)
    local challengeProgress = createChallengeProgress(#challengeInfo.questions)
    challengeProgress.x = SCREEN_RIGHT - challengeProgress.barSize*0.5
    challengeProgress.y = SCREEN_TOP + 100
    questionGroup:insert(challengeProgress)
    local questionText = createQuestionText(challengeInfo.questions[1])
    questionText:setReferencePoint(display.CenterReferencePoint)
    questionText.x = display.contentCenterX
    questionText.y = SCREEN_TOP + 180 + (-display.screenOriginY)
    questionGroup:insert(questionText)

    local buttons = {}

    local function releaseHandler(button)
        button:addCoin()
        for i, btn in ipairs(buttons) do
            if btn ~= button then
                btn:lock(true)
            end
        end
        return true
    end

    local outBtn = BtnHexaVote:new("yes", 1.2, releaseHandler)
    outBtn.x = display.contentCenterX - outBtn.width*0.47
    outBtn.y = display.contentCenterY + 75 + (-display.screenOriginY)
    buttons[#buttons + 1] = outBtn
    questionGroup:insert(outBtn)
    local clearBtn = BtnHexaVote:new("no", 1.1, releaseHandler)
    clearBtn.x = display.contentCenterX + clearBtn.width*0.47
    clearBtn.y = display.contentCenterY + 95 + (-display.screenOriginY)
    buttons[#buttons + 1] = clearBtn
    questionGroup:insert(clearBtn)

    local redBar = createRedBar()
    redBar.x = SCREEN_LEFT + redBar.barSize*0.5
    redBar.y = SCREEN_BOTTOM - 70
    questionGroup:insert(redBar)
    local goldBar = createGoldBar()
    goldBar.x = SCREEN_RIGHT - goldBar.barSize*0.5
    goldBar.y = SCREEN_BOTTOM - 70
    questionGroup:insert(goldBar)
    local timeBar = createTimerBar()
    timeBar.x = 0
    timeBar.y = SCREEN_BOTTOM - timeBar.height*0.5 + 6.5
    questionGroup:insert(timeBar)

    --challengeName:addEventListener("touch", dragAndDrop)
    return questionGroup
end

return InGameQuestions