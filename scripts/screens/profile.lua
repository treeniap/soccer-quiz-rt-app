--[[==============
== We Love Quiz
== Date: 23/05/13
== Time: 12:37
==============]]--
require "scripts.widgets.view.button_import_profile"
require "scripts.widgets.view.button_profile"
require "scripts.widgets.view.button_text_underline"

ProfileScreen = {}

local profileGroup
local scrollGroup
local textFields
local isKeyboardOn
local HEIGHT_DIFF = display.screenOriginY*-0.2

local function createBG()
    local bg = TextureManager.newImageRect("images/stretchable/stru_menu_bg.png", CONTENT_WIDTH, CONTENT_HEIGHT, profileGroup)
    bg.x = display.contentCenterX
    bg.y = display.contentCenterY
    return bg
end

local function showKeyboard(textFieldFocused)
    if scrollGroup.y > textFieldFocused.yEditing then
        scrollGroup.y = textFieldFocused.yEditing
        for i, tf in ipairs(textFields) do
            tf.y = tf.yDefault + textFieldFocused.yEditing
        end
    end
    isKeyboardOn = true
end

local function hideKeyboard()
    native.setKeyboardFocus(nil)
    if scrollGroup.y < 0 then
        scrollGroup.y = 0
        for i, tf in ipairs(textFields) do
            tf.y = tf.yDefault
        end
    end
    isKeyboardOn = false
end

local function toNextTextField(currentTextField)
    local nextTextFiel = table.indexOf(textFields, currentTextField) + 1
    if nextTextFiel > #textFields then
        hideKeyboard()
        return
    end
    nextTextFiel = textFields[nextTextFiel]
    showKeyboard(nextTextFiel)
    native.setKeyboardFocus(nextTextFiel)
end

local function createScrollGroup()
    local function scrollListener(scroll, event)
        if not isKeyboardOn then
            return
        end
        local phase = event.phase
        if "began" == phase then
            display.getCurrentStage():setFocus(scroll)
            scroll.isFocus = true
            scroll.y0 = event.y - scroll.y
            scroll.lastY = scroll.y
            scroll.hasScrolled = false
        elseif scroll.isFocus then
            if "moved" == phase then
                --print(scroll.y)
                scroll.y = event.y - scroll.y0
                if scroll.y > 0 then
                    scroll.y = 0
                end
                if scroll.y < -130 then
                    scroll.y = -130
                end
                local yPos = (scroll.y - scroll.lastY)
                scroll.lastY = scroll.y
                for i, tf in ipairs(textFields) do
                    tf.y = tf.y + yPos
                end
                scroll.hasScrolled = true
            elseif "ended" == phase or "cancelled" == phase then
                display.getCurrentStage():setFocus(nil)
                scroll.isFocus = false
                if not scroll.hasScrolled then
                    hideKeyboard()
                end
            end
        end
        return true
    end
    -- Create a ScrollView
    local scrollView = display.newGroup()
    local scrollRect = display.newRect(0, 0, CONTENT_WIDTH, CONTENT_HEIGHT)
    scrollRect:setFillColor(255, 1)
    scrollView:insert(scrollRect)

    scrollView.touch = scrollListener
    scrollView:addEventListener("touch", scrollView)

    return scrollView
end

local function createDescription()
    local desc = display.newText("QUER COMPETIR POR PRÊMIOS REAIS? FAÇA SEU PERFIL!", 0, SCREEN_TOP + 54, "MyriadPro-BoldCond", 16)
    desc.x = display.contentCenterX
    desc:setTextColor(0)
    scrollGroup:insert(desc)

    scrollGroup:insert(TextureManager.newHorizontalLine(display.contentCenterX, desc.y + 18, CONTENT_WIDTH))
end

local function createImportProfileBtn()
    local btn = BtnImportProfile:new(function() end)
    btn.x = display.contentCenterX
    btn.y = SCREEN_TOP + 128 + HEIGHT_DIFF
    scrollGroup:insert(btn)
end

local function createOuLine()
    scrollGroup:insert(TextureManager.newHorizontalLine(SCREEN_LEFT + CONTENT_WIDTH*0.225, SCREEN_TOP + 174 + HEIGHT_DIFF*2, CONTENT_WIDTH*0.4))
    scrollGroup:insert(TextureManager.newHorizontalLine(SCREEN_LEFT + CONTENT_WIDTH*0.775, SCREEN_TOP + 174 + HEIGHT_DIFF*2, CONTENT_WIDTH*0.4))
    local ouTxt = display.newText("OU", 0, SCREEN_TOP + 164 + HEIGHT_DIFF*2, "MyriadPro-BoldCond", 16)
    ouTxt.x = display.contentCenterX
    ouTxt:setTextColor(135)
    scrollGroup:insert(ouTxt)
end

local function createELine()
    scrollGroup:insert(TextureManager.newHorizontalLine(SCREEN_LEFT + CONTENT_WIDTH*0.225, SCREEN_TOP + 387 + HEIGHT_DIFF*4, CONTENT_WIDTH*0.4))
    scrollGroup:insert(TextureManager.newHorizontalLine(SCREEN_LEFT + CONTENT_WIDTH*0.775, SCREEN_TOP + 387 + HEIGHT_DIFF*4, CONTENT_WIDTH*0.4))
    local eTxt = display.newText("E", 0, SCREEN_TOP + 377 + HEIGHT_DIFF*4, "MyriadPro-BoldCond", 16)
    eTxt.x = display.contentCenterX
    eTxt:setTextColor(135)
    scrollGroup:insert(eTxt)
end

local function createTextField(x, y, text, inputType, isSecure)
    local textFieldGroup = display.newGroup()
    scrollGroup:insert(textFieldGroup)
    local textField
    local textFieldBG = TextureManager.newImage("stru_textbox01", textFieldGroup)
    textFieldBG:setReferencePoint(display.TopLeftReferencePoint)
    textFieldBG.x = x
    textFieldBG.y = y

    local function textListener(target, event)
        --print(event.phase)

        if event.phase == "began" then
            -- user begins editing textField
            target.defaultTxt.isVisible = false
            showKeyboard(target)
        elseif event.phase == "ended" then
            -- textField/Box loses focus
            if target.text == "" then
                target.defaultTxt.isVisible = true
            end
            --hideKeyboard()
        elseif event.phase == "submitted" then
            toNextTextField(target)
        end
    end

    -- Create our Text Field
    textField = native.newTextField( 0, 0, 196, 24 )
    --textFieldGroup:insert(textField)
    textField.userInput = textListener
    textField:addEventListener("userInput", textField)
    textField.text = ""
    local defaultTxt = display.newText(textFieldGroup, text, x + 3, y + 4, "MyriadPro-BoldCond", 18)
    defaultTxt:setTextColor(200)
    textField.defaultTxt = defaultTxt
    textField.inputType = inputType
    textField.font = native.newFont("MyriadPro-BoldCond", 18)
    textField:setTextColor(200, 200, 200)
    textField.hasBackground = false
    textField.isSecure = isSecure or false
    textField.x = x + 104
    textField.y = y + 15
    textField.yDefault = y + 15
    textField.yEditing = #textFields*-35 - 15
    --transition.to(textField, {time = 10000, y = textField.y - 200})
    textFields[#textFields + 1] = textField
    --scrollGroup:insert(textField)
end

local function createEmailLogin()
    local preenchaTxt = display.newText("PREENCHA SEUS DADOS MANUALMENTE", 24, SCREEN_TOP + 194 + HEIGHT_DIFF*3, "MyriadPro-BoldCond", 16)
    preenchaTxt:setTextColor(0)
    scrollGroup:insert(preenchaTxt)

    local photo = TextureManager.newSpriteRect("stru_pic", 60, 60)
    photo:setReferencePoint(display.TopLeftReferencePoint)
    photo.x = 24
    photo.y = SCREEN_TOP + 224 + HEIGHT_DIFF*3
    scrollGroup:insert(photo)

    local textFieldX = photo.x + photo.width + 8
    local textFieldY = SCREEN_TOP + 224 + HEIGHT_DIFF*3

    local textFieldNameBG = createTextField(textFieldX, textFieldY, "NOME E SOBRENOME", "default")

    textFieldY = textFieldY + 35
    local textFieldEMailBG = createTextField(textFieldX, textFieldY, "E-MAIL", "email")

    textFieldX = photo.x
    textFieldY = textFieldY + 35
    local textFieldPasswordBG = createTextField(textFieldX, textFieldY, "CRIE SUA SENHA", "default", true)

    textFieldY = textFieldY + 35
    local textFieldCondifrmPasswordBG = createTextField(textFieldX, textFieldY, "CONFIRME SUA SENHA", "default", true)

    local btn = BtnProfile:new("SALVAR", "PERFIL", function() end)
    btn:setReferencePoint(display.TopRightReferencePoint)
    btn.x = 295
    btn.y = textFieldY - 35
    scrollGroup:insert(btn)

    local login = BtnTextUnderline:new("LOGAR COM CONTA EXISTENTE", function() end)
    login:setReferencePoint(display.TopRightReferencePoint)
    login.x = 230
    login.y = textFieldY + 30
    scrollGroup:insert(login)
end

local function createChooseFavoriteTeam()
    local badge = TextureManager.newSpriteRect("stru_chooseteam", 60, 60)
    badge:setReferencePoint(display.TopLeftReferencePoint)
    badge.x = 24
    badge.y = SCREEN_TOP + 395 + HEIGHT_DIFF*6
    scrollGroup:insert(badge)
    local chooseTeamTxt = display.newText("ESCOLHA SEU TIME DO CORAÇÃO!!!", badge.x + badge.width + 4, badge.y + badge.height*0.5 - 8, "MyriadPro-BoldCond", 16)
    chooseTeamTxt:setTextColor(0)
    scrollGroup:insert(chooseTeamTxt)
end

function ProfileScreen:showUp(onComplete)
end

function ProfileScreen:new()
    profileGroup = display.newGroup()
    textFields = {}

    createBG()

    scrollGroup = createScrollGroup()
    profileGroup:insert(scrollGroup)

    profileGroup:insert(TopBarMenu:new("PERFIL"))
    createDescription()
    createImportProfileBtn()
    createOuLine()
    createEmailLogin()
    createELine()
    createChooseFavoriteTeam()

    isKeyboardOn = false

    return profileGroup
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
        self.isVisible = true
    end

    return PressRelease:new(BtnClose, listener)
end

local function createTextField(panel, x, y, text)
    local textField

    local function textListener(target, event)

        if event.phase == "began" then
            target.text = ""
            if panel.y >= display.contentCenterY then
                panel.y = panel.y - 60
                panel.firstNameTextField.y = panel.firstNameTextField.y - 60
                panel.lastNameTextField.y = panel.lastNameTextField.y - 60
            end
        elseif event.phase == "ended" then
            -- textField/Box loses focus
            if target.text == "" then
                target.text = text
            end
        elseif event.phase == "submitted" then
            if target == panel.firstNameTextField then
                native.setKeyboardFocus(panel.lastNameTextField)
            elseif target == panel.lastNameTextField then
                if panel.firstNameTextField.text ~= "NOME" and panel.firstNameTextField.text ~= "" and panel.firstNameTextField.text ~= " " then
                    panel.demoLogin(panel.firstNameTextField.text, panel.lastNameTextField.text)
                end
            end
        end
    end

    -- Create our Text Field
    textField = native.newTextField( 0, 0, 196, 24 )
    --textFieldGroup:insert(textField)
    textField.userInput = textListener
    textField:addEventListener("userInput", textField)
    textField.text = text
    --local defaultTxt = display.newText(textFieldGroup, text, x + 3, y + 4, "MyriadPro-BoldCond", 18)
    --defaultTxt:setTextColor(200)
    textField.defaultTxt = defaultTxt
    textField.font = native.newFont("MyriadPro-BoldCond", 18)
    textField:setTextColor(200, 200, 200)
    textField.hasBackground = true
    --textFieldGroup:insert(textField)
    textField:setReferencePoint(display.TopLeftReferencePoint)
    textField.x = x
    textField.y = y

    return textField
end

local function createPanel()
    local panel = display.newGroup()

    local panelBg = display.newRect(panel, SCREEN_LEFT, SCREEN_TOP, 298, 300)
    panelBg.x = 0
    panelBg.y = -50
    panelBg:setFillColor(graphics.newGradient({ 200, 200, 200 }, { 255, 255, 255 }, "down"))

    local desc = display.newText("ESTE JOGO CONTÉM PRÊMIOS REAIS. VOCÊ PRECISA SE CADASTRAR PELO FACEBOOK PARA CONCORRER.", 0, 0, 290, 0, "MyriadPro-BoldCond", 16)
    desc.x = 0
    desc.y = -165
    desc:setTextColor(0)
    panel:insert(desc)

    panel:insert(TextureManager.newHorizontalLine(0, desc.y + 30, CONTENT_WIDTH))

    local fbDesc = display.newText("PREENCHIMENTO PELO FACEBOOK", 0, 0, 290, 0, "MyriadPro-BoldCond", 14)
    fbDesc.x = 0
    fbDesc.y = desc.y + 50
    fbDesc:setTextColor(64)
    panel:insert(fbDesc)

    local button = BtnProfile:new(function()
        panel.facebookLogin()
    end, {
        bg = "stru_button_import",
        text = "CADASTRO AUTOMÁTICO"
    })
    button:setReferencePoint(display.CenterReferencePoint)
    button.x = 0
    button.y = fbDesc.y + 55
    panel:insert(button)

    panel:insert(TextureManager.newHorizontalLine(-CONTENT_WIDTH*0.225, button.y + 55, CONTENT_WIDTH*0.4))
    panel:insert(TextureManager.newHorizontalLine(CONTENT_WIDTH*0.225, button.y + 55, CONTENT_WIDTH*0.4))
    local ouTxt = display.newText("OU", 0, 0, "MyriadPro-BoldCond", 16)
    ouTxt.x = 0
    ouTxt.y = button.y + 55
    ouTxt:setTextColor(135)
    panel:insert(ouTxt)

    local otDesc = display.newText("PREENCHIMENTO MANUAL", 0, 0, 290, 0, "MyriadPro-BoldCond", 14)
    otDesc.x = 0
    otDesc.y = ouTxt.y + 20
    otDesc:setTextColor(64)
    panel:insert(otDesc)

    panel.x = display.contentCenterX
    panel.y = display.contentCenterY

    local salvarperfilBtn = BtnProfile:new(function()
        if panel.firstNameTextField.text ~= "NOME" and panel.firstNameTextField.text ~= "" and panel.firstNameTextField.text ~= " " then
            panel.demoLogin(panel.firstNameTextField.text, panel.lastNameTextField.text)
        end
    end, {
        bg = "stru_button_save",
    })
    salvarperfilBtn:setReferencePoint(display.CenterRightReferencePoint)
    salvarperfilBtn.x = 140
    salvarperfilBtn.y = otDesc.y + 37
    panel:insert(salvarperfilBtn)
    panel.salvarperfilBtn = salvarperfilBtn

    timer.performWithDelay(300, function()
        panel.firstNameTextField = createTextField(panel, display.contentCenterX - 140, display.contentCenterY + otDesc.y + 10, "NOME")
        panel.lastNameTextField = createTextField(panel, display.contentCenterX - 140, display.contentCenterY + otDesc.y + 39, "SOBRENOME")
    end)

    return panel
end

function ProfileScreen:newPopUp()
    local popUpGroup = display.newGroup()

    local bg = display.newRect(popUpGroup, SCREEN_LEFT, SCREEN_TOP, CONTENT_WIDTH, CONTENT_HEIGHT)
    bg:setFillColor(0, 192)
    local function bgTouch(event)
        return true
    end
    bg.touch = bgTouch
    bg:addEventListener("touch", bg)

    local panel
    local closeBtn

    local function close()
        bg:removeEventListener("touch", bg)
        bg:removeSelf()
        panel.firstNameTextField:removeSelf()
        panel.lastNameTextField:removeSelf()
        panel:removeSelf()
        closeBtn:removeSelf()
        popUpGroup:removeSelf()
    end

    panel = createPanel()
    panel.facebookLogin = function()
        close()
        UserData:reset()
    end
    panel.demoLogin = function(firstName, lastName)
        close()
        local userInfo = {
            first_name = firstName,
            last_name = lastName,
            facebook_profile = {}
        }
        Server:updateUser(userInfo, UserData.userId)
    end
    popUpGroup:insert(panel)
    closeBtn = createCloseBtn(panel.x + panel.width*0.5 - 22, panel.y - panel.height*0.5 - 50, close)
    popUpGroup:insert(closeBtn)

    transition.from(bg, {time = 200, alpha = 0})
    transition.from(panel, {time = 300, y = panel.y + 150, xScale = 0.1, yScale = 0.1})
    transition.from(closeBtn, {delay = 300, time = 300, xScale = 0.1, yScale = 0.1})
end

return ProfileScreen