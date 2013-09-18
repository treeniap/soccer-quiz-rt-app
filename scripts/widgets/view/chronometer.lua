--[[==============
== We Love Quiz
== Date: 30/04/13
== Time: 15:32
==============]]--
Chronometer = {}

function Chronometer:createView()
    local back = TextureManager.newImage("stru_timebarback", self)
    back.x = 11
    back.y = 0
    self.bar = TextureManager.newImage("stru_timebarcover", self)
    self.bar.x = 13
    self.bar.y = 0
    local cover = TextureManager.newImage("stru_timebarframe", self)
    cover.x = 0
    cover.y = 1

    local timerMask = graphics.newMask("images/masks/timer_mask.png")
    self.bar:setMask(timerMask)
    self.bar.maskX = -82
end

function Chronometer:resetBar()
    self.bar.x = 13
    self.bar.maskX = -82
end

function Chronometer:moveBar()
    self.bar.x = self.bar.x - 1
    self.bar.maskX = self.bar.maskX + 1
end

function Chronometer:start(endTime, onFinish)
    local time = date.diff(endTime, date(os.date("*t")))
    time = time:spanseconds()*1000

    self:resetBar()
    local BAR_SIZE = 163
    local MILLISECONDS_PER_PIXEL = time/BAR_SIZE
    local count = 0
    local lastTime = system.getTimer()
    local cycleTimeElapsed = 0
    local audioHandler = AudioManager.playAudio("chronometer", nil, -1)
    AudioManager.playStopBetAnswerWait(true)
    local function updateChronometer(event)
        local currentTime = system.getTimer()
        cycleTimeElapsed = cycleTimeElapsed + (currentTime - lastTime)
        lastTime = currentTime
        while cycleTimeElapsed >= MILLISECONDS_PER_PIXEL do
            if not self.bar.x then
                Runtime:removeEventListener("enterFrame", updateChronometer)
                AudioManager.stopAudio(audioHandler)
                return
            end
            self:moveBar()
            cycleTimeElapsed = cycleTimeElapsed - MILLISECONDS_PER_PIXEL
            count = count + 1
            if count == BAR_SIZE then
                onFinish()
                Runtime:removeEventListener("enterFrame", updateChronometer)
                AudioManager.stopAudio(audioHandler)
                return
            end
        end
    end
    Runtime:addEventListener("enterFrame", updateChronometer)
end

function Chronometer:new()
    local chronometerGroup = display.newGroup()
    for k, v in pairs(Chronometer) do
        chronometerGroup[k] = v
    end

    chronometerGroup:createView()
    chronometerGroup:setReferencePoint(display.CenterReferencePoint)

    return chronometerGroup
end

return Chronometer