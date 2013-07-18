--[[==============
== We Love Quiz
== Date: 28/06/13
== Time: 18:43
==============]]--
TutorialScreen = {}

require "scripts.widgets.view.button_tutorial"

local slideView
local tutorialSheetInfo, tutorialSheetImage

local function createScreen1(loadImage)
    local screenGroup = display.newGroup()

    screenGroup.imgName = "images/tutorial/tuto_01.jpg"
    local width, height = 360, 480
    if CONTENT_HEIGHT > 480 then -- iPhone 5 and Android
        width, height = 428, 570
    end
    if loadImage then
        screenGroup.image = TextureManager.newImageRect(screenGroup.imgName, width, height)
        screenGroup.image.x = display.contentCenterX
        screenGroup.image.y = display.contentCenterY
        screenGroup:insert(1, screenGroup.image)
    end

    local TEXT_SIZE = 22
    local TEXT_Y = 84

    local tutorialBox = display.newImageRect(screenGroup, tutorialSheetImage, tutorialSheetInfo:getFrameIndex("stru_tutorial_box"), width, 128)
    tutorialBox.x = display.contentCenterX
    tutorialBox.y = TEXT_Y

    local text = display.newText(screenGroup, "OLHO NO LANCE,", 0, 0, "MyriadPro-BoldCond", TEXT_SIZE)
    text.x = display.contentCenterX
    text.y = TEXT_Y - 22
    local textGroup = display.newGroup()
    local textYellow = display.newText(textGroup, "TABLET CONECTADO", 0, 0, "MyriadPro-BoldCond", TEXT_SIZE)
    textYellow.x = 0
    textYellow.y = TEXT_Y
    textYellow:setTextColor(255, 225, 5)
    local text = display.newText(textGroup, ", E", 0, 0, "MyriadPro-BoldCond", TEXT_SIZE)
    text.x = textYellow.x + textYellow.width*0.5 + text.width*0.5 - 2
    text.y = textYellow.y
    textGroup:setReferencePoint(display.CenterReferencePoint)
    textGroup.x = display.contentCenterX
    screenGroup:insert(textGroup)
    local text = display.newText(screenGroup, "BATERIA CARREGADA!", 0, 0, "MyriadPro-BoldCond", TEXT_SIZE)
    text.x = display.contentCenterX
    text.y = TEXT_Y + 22

    return screenGroup
end

local function createScreen2(loadImage)
    local screenGroup = display.newGroup()

    screenGroup.imgName = "images/tutorial/tuto_02.jpg"
    local width, height = 360, 480
    if CONTENT_HEIGHT > 480 then -- iPhone 5 and Android
        width, height = 428, 570
    end
    if loadImage then
        screenGroup.image = TextureManager.newImageRect(screenGroup.imgName, width, height)
        screenGroup.image.x = display.contentCenterX
        screenGroup.image.y = display.contentCenterY
        screenGroup:insert(1, screenGroup.image)
    end

    local TEXT_SIZE = 22
    local TEXT_Y = 142

    local tutorialBox = display.newImageRect(screenGroup, tutorialSheetImage, tutorialSheetInfo:getFrameIndex("stru_tutorial_box"), width, 128)
    tutorialBox.x = display.contentCenterX
    tutorialBox.y = TEXT_Y

    local textGroup = display.newGroup()
    local text = display.newText(textGroup, "PALPITE RAPIDAMENTE EM CADA", 0, 0, "MyriadPro-BoldCond", TEXT_SIZE)
    text.x = 0
    text.y = TEXT_Y - 11
    local textYellow = display.newText(textGroup, " FALTA", 0, 0, "MyriadPro-BoldCond", TEXT_SIZE)
    textYellow.x = text.x + text.width*0.5 + textYellow.width*0.5
    textYellow.y = text.y
    textYellow:setTextColor(255, 225, 5)
    textGroup:setReferencePoint(display.CenterReferencePoint)
    textGroup.x = display.contentCenterX
    screenGroup:insert(textGroup)

    local textGroup = display.newGroup()
    local textYel = display.newText(textGroup, "PERIGOSA, PÊNALTI", 0, 0, "MyriadPro-BoldCond", TEXT_SIZE)
    textYel.x = 0
    textYel.y = TEXT_Y + 11
    textYel:setTextColor(255, 225, 5)
    local textOu = display.newText(textGroup, " OU", 0, 0, "MyriadPro-BoldCond", TEXT_SIZE)
    textOu.x = textYel.x + textYel.width*0.5 + textOu.width*0.5
    textOu.y = textYel.y
    local textEscanteio = display.newText(textGroup, " ESCANTEIO.", 0, 0, "MyriadPro-BoldCond", TEXT_SIZE)
    textEscanteio.x = textOu.x + textOu.width*0.5 + textEscanteio.width*0.5
    textEscanteio.y = textYel.y
    textEscanteio:setTextColor(255, 225, 5)
    textGroup:setReferencePoint(display.CenterReferencePoint)
    textGroup.x = display.contentCenterX
    screenGroup:insert(textGroup)

    return screenGroup
end

local function createScreen3(loadImage)
    local screenGroup = display.newGroup()

    screenGroup.imgName = "images/tutorial/tuto_03.jpg"
    local width, height = 360, 480
    if CONTENT_HEIGHT > 480 then -- iPhone 5 and Android
        width, height = 428, 570
    end
    if loadImage then
        screenGroup.image = TextureManager.newImageRect(screenGroup.imgName, width, height)
        screenGroup.image.x = display.contentCenterX
        screenGroup.image.y = display.contentCenterY
        screenGroup:insert(1, screenGroup.image)
    end

    local TEXT_SIZE = 22
    local TEXT_Y = 84

    local tutorialBox = display.newImageRect(screenGroup, tutorialSheetImage, tutorialSheetInfo:getFrameIndex("stru_tutorial_box"), width, 128)
    tutorialBox.x = display.contentCenterX
    tutorialBox.y = TEXT_Y

    local textGroup = display.newGroup()
    local text = display.newText(textGroup, "JOGAR COM", 0, 0, "MyriadPro-BoldCond", TEXT_SIZE)
    text.x = 0
    text.y = TEXT_Y - 11
    local textYellow = display.newText(textGroup, " AMIGOS", 0, 0, "MyriadPro-BoldCond", TEXT_SIZE)
    textYellow.x = text.x + text.width*0.5 + textYellow.width*0.5
    textYellow.y = text.y
    textYellow:setTextColor(255, 225, 5)
    textGroup:setReferencePoint(display.CenterReferencePoint)
    textGroup.x = display.contentCenterX
    screenGroup:insert(textGroup)

    local text = display.newText(screenGroup, "É MUITO MAIS DIVERTIDO!", 0, 0, "MyriadPro-BoldCond", TEXT_SIZE)
    text.x = display.contentCenterX
    text.y = TEXT_Y + 11

    local button = BtnTutorial:new(function() end, tutorialSheetImage, tutorialSheetInfo, {
        bg = "tuto_bt_fb",
        text = "CADASTRE-SE",
        topText = true,
        bottomText = true
    })
    button:setReferencePoint(display.CenterReferencePoint)
    button.x = display.contentCenterX
    button.y = SCREEN_BOTTOM - 72
    screenGroup:insert(button)

    return screenGroup
end

local function createScreen4(loadImage)
    local screenGroup = display.newGroup()

    screenGroup.imgName = "images/tutorial/tuto_05.jpg"
    local width, height = 360, 480
    if CONTENT_HEIGHT > 480 then -- iPhone 5 and Android
        width, height = 428, 570
    end
    if loadImage then
        screenGroup.image = TextureManager.newImageRect(screenGroup.imgName, width, height)
        screenGroup.image.x = display.contentCenterX
        screenGroup.image.y = display.contentCenterY
        screenGroup:insert(1, screenGroup.image)
    end

    local TEXT_SIZE = 22
    local TEXT_Y = 84

    local tutorialBox = display.newImageRect(screenGroup, tutorialSheetImage, tutorialSheetInfo:getFrameIndex("stru_tutorial_box"), width, 128)
    tutorialBox.x = display.contentCenterX
    tutorialBox.y = TEXT_Y

    local text = display.newText(screenGroup, "NÃO PERCA A HORA DO JOGO!", 0, 0, "MyriadPro-BoldCond", TEXT_SIZE)
    text.x = display.contentCenterX
    text.y = TEXT_Y - 22

    local textGroup = display.newGroup()
    local text = display.newText(textGroup, "CONCORRA A", 0, 0, "MyriadPro-BoldCond", TEXT_SIZE)
    text.x = 0
    text.y = TEXT_Y
    local textYellow = display.newText(textGroup, " MAIS PRÊMIOS", 0, 0, "MyriadPro-BoldCond", TEXT_SIZE)
    textYellow.x = text.x + text.width*0.5 + textYellow.width*0.5
    textYellow.y = text.y
    textYellow:setTextColor(255, 225, 5)
    local text2 = display.newText(textGroup, ", PALPITANDO", 0, 0, "MyriadPro-BoldCond", TEXT_SIZE)
    text2.x = textYellow.x + textYellow.width*0.5 + text2.width*0.5
    text2.y = text.y
    textGroup:setReferencePoint(display.CenterReferencePoint)
    textGroup.x = display.contentCenterX
    screenGroup:insert(textGroup)

    local text = display.newText(screenGroup, "EM TODAS AS PARTIDAS DO SEU TIME.", 0, 0, "MyriadPro-BoldCond", TEXT_SIZE)
    text.x = display.contentCenterX
    text.y = TEXT_Y + 22

    local button = BtnTutorial:new(function() end, tutorialSheetImage, tutorialSheetInfo, {
        bg = "tuto_bt_gold",
        text = "ALERTA DE PARTIDA",
        topText = true,
        bottomText = false,
        icon = "tuto_icon02"
    })
    button:setReferencePoint(display.CenterReferencePoint)
    button.x = display.contentCenterX
    button.y = SCREEN_BOTTOM - 72
    screenGroup:insert(button)

    return screenGroup
end

local function createTeam(name, badgeFileName)
    local teamGroup = display.newGroup()
    print(badgeFileName)
    local badge = TextureManager.newImageRect(badgeFileName, 64, 64, teamGroup) --TODO change to DocumentsDirectory
    badge.x = 0
    badge.y = 0
    local nameTxt = display.newText(teamGroup, string.utf8upper(name), 0, 0, "MyriadPro-BoldCond", 14)
    nameTxt.x = 0
    nameTxt.y = badge.height*0.5 + 14
    nameTxt:setTextColor(0)
    teamGroup:setReferencePoint(display.TopCenterReferencePoint)
    return teamGroup
end

local function createScreen5(teamsList)
    local screenGroup = display.newGroup()

    local width, height = 360, 480
    if CONTENT_HEIGHT > 480 then -- iPhone 5 and Android
        width, height = 428, 570
    end
    local bg = TextureManager.newImageRect("images/stru_menu_bg.png", width, height)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY
    screenGroup:insert(bg)

    local widget = require "widget"
    local teamsGroup = widget.newScrollView
        {
            width = SCREEN_RIGHT,
            height = 200,
            maskFile = "images/tutorial_mask.png",
            hideBackground = true,
            horizontalScrollDisabled = true
        }
    for i, team in ipairs(teamsList) do
        local teamBtn = createTeam(team.name, team.badge)
        teamBtn.x = i%3 == 1 and 54 or i%3 == 2 and 168 or i%3 == 0 and 282
        teamBtn.y = math.floor((i - 1)/3)*86
        teamsGroup:insert(teamBtn)
    end
    teamsGroup:setReferencePoint(display.TopCenterReferencePoint)
    teamsGroup.x = display.contentCenterX
    teamsGroup.y = 148 + (display.screenOriginY*-0.25)
    screenGroup:insert(teamsGroup)

    local top = TextureManager.newImageRect("images/stru_menu_bg.png", width, 145 + (display.screenOriginY*-1.25))
    top.x = display.contentCenterX
    top.y = display.screenOriginY + (145 + (display.screenOriginY*-1.25))*0.5
    screenGroup:insert(top)
    local lineShadow = TextureManager.newImageRect("images/stru_shadow.png", CONTENT_WIDTH, 20, screenGroup)
    lineShadow.x = display.contentCenterX
    lineShadow.y = top.y + (145 + (display.screenOriginY*-1.25))*0.5 + 10

    local bottom = TextureManager.newImageRect("images/stru_menu_bg.png", width, 134 + (display.screenOriginY*-0.75))
    bottom.x = display.contentCenterX
    bottom.y = SCREEN_BOTTOM - (134 + (display.screenOriginY*-0.75))*0.5
    screenGroup:insert(bottom)
    local lineShadow = TextureManager.newImageRect("images/stru_shadow.png", CONTENT_WIDTH, 20, screenGroup)
    lineShadow.x = display.contentCenterX
    lineShadow.y = bottom.y - (134 + (display.screenOriginY*-0.75))*0.5 - 10
    lineShadow.yScale = -lineShadow.yScale

    local TEXT_SIZE = 22
    local TEXT_Y = 84 - (display.screenOriginY*-0.5)

    local tutorialBox = display.newImageRect(screenGroup, tutorialSheetImage, tutorialSheetInfo:getFrameIndex("stru_tutorial_box"), width, 128)
    tutorialBox.x = display.contentCenterX
    tutorialBox.y = TEXT_Y

    local textGroup = display.newGroup()
    local text = display.newText(textGroup, "ESCOLHA UM", 0, 0, "MyriadPro-BoldCond", TEXT_SIZE)
    text.x = 0
    text.y = TEXT_Y - 22
    local textYellow = display.newText(textGroup, " TIME", 0, 0, "MyriadPro-BoldCond", TEXT_SIZE)
    textYellow.x = text.x + text.width*0.5 + textYellow.width*0.5
    textYellow.y = text.y
    textYellow:setTextColor(255, 225, 5)
    textGroup:setReferencePoint(display.CenterReferencePoint)
    textGroup.x = display.contentCenterX
    screenGroup:insert(textGroup)

    local text = display.newText(screenGroup, "PARA GANHAR 5 FICHAS A", 0, 0, "MyriadPro-BoldCond", TEXT_SIZE)
    text.x = display.contentCenterX
    text.y = TEXT_Y

    local text = display.newText(screenGroup, "CADA VEZ QUE ELE FOR JOGAR.", 0, 0, "MyriadPro-BoldCond", TEXT_SIZE)
    text.x = display.contentCenterX
    text.y = TEXT_Y + 22

    local button = BtnTutorial:new(function()
        TutorialScreen:hide(function()
            ScreenManager:init()
        end)
        return true
    end, tutorialSheetImage, tutorialSheetInfo, {
        bg = "tuto_bt_gold",
        text = "ENTRAR EM CAMPO",
        topText = false,
        bottomText = false,
        icon = "tuto_icon03"
    })
    button:setReferencePoint(display.CenterReferencePoint)
    button.x = display.contentCenterX
    button.y = SCREEN_BOTTOM - 72 - (display.screenOriginY*-0.5)
    screenGroup:insert(button)

    return screenGroup
end

function TutorialScreen:new(teamsList)
    tutorialSheetInfo, tutorialSheetImage = TextureManager.loadTutorialSheet()
    local screens = {
        createScreen1(true),
        createScreen2(true),
        createScreen3(true),
        createScreen4(true),
        createScreen5(teamsList),
    }

    local slideScreens = require("scripts.widgets.view.slide_screens")
    slideView = slideScreens.new(screens, tutorialSheetImage, tutorialSheetInfo)

    tutorialSheetInfo, tutorialSheetImage = nil, nil
end

function TutorialScreen:hide(onComplete)
    slideView:hide(function()
        self:destroy()
        timer.performWithDelay(100, onComplete)
    end)
end

function TutorialScreen:destroy()
    slideView:cleanUp()
    slideView = nil
    TextureManager.disposeTutorialSheet()
end

return TutorialScreen