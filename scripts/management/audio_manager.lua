--[[==============
== We Love Quiz
== Date: 01/08/13
== Time: 12:15
==============]]--
AudioManager = {}

local extName = "aif"
if IS_ANDROID then
    extName = "aif"
end

local SUPPORTERS_CHANNEL = 1

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
    finalWhistle      = "18." .. extName,
    coinPlus          = "coins." .. extName,
    lastCoinPlus      = "last_coin." .. extName
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
    audio.reserveChannels(1)
end

function AudioManager.playTeamAnthem(soundName)
    local anthem = audio.loadSound(soundName)
    audio.play(anthem, {onComplete = function() audio.dispose(anthem) end})
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

local timerBetAnswerWait
function AudioManager.playStopBetAnswerWait(play)
    if play then
        if timerBetAnswerWait then
            timer.cancel(timerBetAnswerWait)
        end
        audio.play(sounds["betAnswerWait"], {channel = SUPPORTERS_CHANNEL, loops = -1, onComplete = function()
            audio.setVolume(1, {channel = SUPPORTERS_CHANNEL})
        end})
        timerBetAnswerWait = timer.performWithDelay(60000, function()
            timerBetAnswerWait = nil
            AudioManager.playStopBetAnswerWait()
        end)
    elseif audio.isChannelActive(SUPPORTERS_CHANNEL) then
        audio.fadeOut({channel = SUPPORTERS_CHANNEL, time = 2000})
        if timerBetAnswerWait then
            timer.cancel(timerBetAnswerWait)
        end
        timerBetAnswerWait = nil
    end
end

return AudioManager