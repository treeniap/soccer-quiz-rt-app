--[[==============
== Pocket World
== Date: 25/04/13
== Time: 11:03
==============]]--
Params = {}

if IS_ANDROID then
    Params.flurryId = "" -- Android Flurry Id
else
    Params.flurryId = "TYQXPJZ66XM6FRNXZRT2" -- iPhone Flurry Id
end

if IS_ANDROID then
    Params.rateId = "" -- Android Bundle Name
else
    Params.rateId = "670063656" -- App id
end

return Params