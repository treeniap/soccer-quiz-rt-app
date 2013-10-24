--[[==============
== Pocket World
== Date: 25/04/13
== Time: 11:03
==============]]--
Params = {}

if IS_ANDROID then
    Params.flurryId = "XGRT2ZZZ2NMH87F8BJBB" -- Android Flurry Id
else
    Params.flurryId = "TYQXPJZ66XM6FRNXZRT2" -- iPhone Flurry Id
end

if IS_ANDROID then
    Params.rateId = "com.welovequiz.chutepremiado" -- Android Bundle Name
else
    Params.rateId = "731495715" -- App id
end

return Params