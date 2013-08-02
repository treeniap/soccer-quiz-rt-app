--[[==============
== We Love Quiz
== Date: 01/08/13
== Time: 12:15
==============]]--
AudioManager = {}

local extName = "aif"
if IS_ANDROID then
    extName = "aif" --TODO mudar extensão para android
end

local sounds = {
    showSideMenuBtn   = "01." .. extName,
    showBottomRanking = "02." .. extName,
    showNextMatches   = "03." .. extName,
    showLogo          = "04." .. extName,
    showPlayBtn       = "05." .. extName,
    showBottomRL      = "06." .. extName,
    showTopBar        = "06." .. extName,
    matchesFoil       = "07." .. extName,
    btn               = "08." .. extName,
    onOffBtn          = "09." .. extName,
    hideInitialScreen = "10." .. extName,
    openCloseMenu     = "11." .. extName,
    betTimeout        = "12." .. extName,
    showEvent         = "13." .. extName,
    chronometer       = "14." .. extName,
    betAnswerWait     = "15." .. extName,
    betRight          = "16." .. extName,
    betWrong          = "17." .. extName,
}

local function loadGameAudio()
    for k, v in pairs(sounds) do
        --print("loading", k)
        sounds[k] = audio.loadSound("sounds/" .. extName .. "/" .. v)
    end
end

function AudioManager.setVolume(isOn)
    audio.setVolume(isOn and 1 or 0)
end

function AudioManager.init()
    loadGameAudio()
end

function AudioManager.playAudio(soundName, delay, loops)
    --print("PLAY", soundName)
    if delay then
        timer.performWithDelay(delay, function()
            audio.play(sounds[soundName], {loops = loops or 0})
        end)
        return
    end
    return audio.play(sounds[soundName], {loops = loops or 0})
end

function AudioManager.stopAudio(audioHandler)
    audio.stop(audioHandler)
end

local betAnswerWaitHandler
function AudioManager.playStopBetAnswerWait()
    if betAnswerWaitHandler then
        audio.stop(betAnswerWaitHandler)
        betAnswerWaitHandler = nil
    else
        betAnswerWaitHandler = audio.play(sounds["betAnswerWait"], {loops = -1})
    end
end

return AudioManager