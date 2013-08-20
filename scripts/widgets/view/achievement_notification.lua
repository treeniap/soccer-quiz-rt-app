--[[==============
== We Love Quiz
== Date: 19/08/13
== Time: 17:01
==============]]--
AchievementNotification = {}

function AchievementNotification:new(medalFileName, text)
    local notificationGroup = display.newGroup()

    local bg = TextureManager.newImageRect("images/stru_bar_mid.png", 100, 40, notificationGroup)
    bg.x = 0
    bg.y = 0
    local medal = TextureManager.newImageRect(medalFileName, 39, 53, notificationGroup)
    medal.x = -bg.width*0.5
    medal.y = -5
    local txt = display.newText(notificationGroup, string.utf8upper(text), -bg.width*0.26, -15, 75, 0, "MyriadPro-BoldCond", 12)
    txt:setTextColor(35)

    notificationGroup.x = SCREEN_RIGHT - 50
    notificationGroup.y = display.contentHeight * 0.66

    display.getCurrentStage():insert(4, notificationGroup)

    transition.from(notificationGroup, {time = 500, x = SCREEN_RIGHT + 150, transition = easeOutCirc, onComplete = function()
        transition.to(notificationGroup, {delay = 3000, time = 500, x = SCREEN_RIGHT + 150, transition = easeInCirc, onComplete = function()
            notificationGroup:removeSelf()
        end})
    end})
end

return AchievementNotification