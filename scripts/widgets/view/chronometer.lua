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

    local timerMask = graphics.newMask("images/timer_mask.png")
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

function Chronometer:start(time, onFinish)
    local BAR_SIZE = 163
    self:resetBar()
    timer.performWithDelay(time/BAR_SIZE, function(event)
        self:moveBar()
        if event.count == BAR_SIZE then
            onFinish()
        end
    end, BAR_SIZE)
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