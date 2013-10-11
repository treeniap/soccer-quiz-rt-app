--[[==============
== We Love Quiz
== Date: 02/10/13
== Time: 14:34
==============]]--
InitialPopUp = {}

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

function InitialPopUp:new(imageName, listener)
    local popUpGroup = display.newGroup()

    local bg = display.newRect(popUpGroup, SCREEN_LEFT, SCREEN_TOP, CONTENT_WIDTH, CONTENT_HEIGHT)
    bg:setFillColor(0, 192)
    local function bgTouch(event)
        return true
    end
    bg.touch = bgTouch
    bg:addEventListener("touch", bg)

    local panel = TextureManager.newImageRect(imageName, 300, 372, popUpGroup)
    panel.x = display.contentCenterX
    panel.y = display.contentCenterY
    local closeBtn
    local function close()
        bg:removeEventListener("touch", bg)
        panel:removeEventListener("touch", panel)
        bg:removeSelf()
        panel:removeSelf()
        closeBtn:removeSelf()
        popUpGroup:removeSelf()
    end
    panel.touch = function(target, event)
        if event.phase == "ended" then
            listener()
            close()
        end
    end
    panel:addEventListener("touch", panel)

    closeBtn = createCloseBtn(panel.x + panel.width*0.5 - 24, panel.y - panel.height*0.5, close)
    popUpGroup:insert(closeBtn)

    transition.from(bg, {time = 200, alpha = 0})
    transition.from(panel, {time = 300, xScale = 0.1, yScale = 0.1})
    transition.from(closeBtn, {delay = 300, time = 300, xScale = 0.1, yScale = 0.1})
end

return InitialPopUp