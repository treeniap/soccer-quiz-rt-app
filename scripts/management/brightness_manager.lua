--[[==============
== We Love Quiz
== Date: 03/09/13
== Time: 12:36
==============]] --
BrightnessManager = {}

local SystemControl = SystemControl
if not SystemControl then
    local brightness = 100
    SystemControl = {
        getBrightness = function()
            --print("getBrightness()", brightness)
            return brightness
        end,
        setBrightness = function(value)
            brightness = value
            --print("setBrightness(value)", value)
        end
    }
end

local MIN_BRIGHTNESS = 60

function BrightnessManager.setBrightness(value)
    SystemControl.setBrightness(value)
end

function BrightnessManager.getBrightness()
    return math.floor(SystemControl.getBrightness())
end

function BrightnessManager.onEnterMatch()

    if BrightnessManager.getBrightness() > MIN_BRIGHTNESS and not UserData.brightness then
        local function onComplete(event)
            if "clicked" == event.action then
                local i = event.index
                if 1 == i then
                    BrightnessManager.setBrightness(MIN_BRIGHTNESS)
                elseif 2 == i then
                end
            end
        end
        native.showAlert("Atenção", "Recomendamos diminuir o brilho da tela para economizar bateria.", {"Ajustar brilho", "Manter brilho atual"}, onComplete)
        UserData.brightness = true
        UserData:save()
    end
end

return BrightnessManager