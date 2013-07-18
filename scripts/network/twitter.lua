--[[==============
== We Love Quiz
== Date: 18/07/13
== Time: 15:18
==============]]--
local json = require "json"
local http = require "socket.http"

local data,httpStatus,httpResponseHeaders,httpResponseStatusLine=http.request("https://api.twitter.com/1.1/search/tweets.json?q=%23freebandnames&since_id=24012619984051000&max_id=250126199840518145&result_type=mixed&count=4")

--[ uncomment for debugging purposes
print("Data: "..data)
print("HTTP Status: "..httpStatus)

httpResponseHeaders=json.encode(httpResponseHeaders)
print("HTTP Response Headers: "..httpResponseHeaders)
print("HTTP Response Status Line: "..httpResponseStatusLine)
--]]

local background=display.newRect(0,0,320,480)
background:setFillColor(0xff,0xff,0xff)

local tweet=json.decode(data)
local profilePicture
local userName
local tweetText

local function listener( event )
    if ( event.isError ) then
        print ( "Network error - download failed" )
    else


    end
end


if data ~= nil then
    profilePicture=display.loadRemoteImage(tweet[1].user.profile_image_url,"GET",listener,"userPhoto.png",10,150)
    userName=display.newText("User: \n"..tweet[1].user.name,10,200):setTextColor(0,0,0)
    tweetText=display.newText("Tweet: \n"..tweet[1].text,10,250):setTextColor(0,0,0)
end