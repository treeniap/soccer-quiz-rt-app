--[[==============
== Pocket World
== Date: 25/04/13
== Time: 11:03
==============]]--
Params = {}

if IS_ANDROID then
    Params.flurryId = "" -- Android Flurry Id
elseif("iPad" == system.getInfo("model")) then
    Params.flurryId = "" -- iPad Flurry Id
else
    Params.flurryId = "" -- iPhone Flurry Id
end

return Params