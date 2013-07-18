local _M = {}

local oAuth = require('util.oauth')

_M.consumer_key = 'kaO6n7jMhgyNzx9lXhLg'
_M.consumer_secret = 'OY0PBfVKizWKfUutKjwh1gt3W99YOmlqbYtgqzg81I'
_M.webURL = 'http://www.welovequiz.com'

_M.twitter_request_token_secret = nil

_M.access_token = nil
_M.access_token_secret = nil
_M.user_id = 0
_M.screen_name = ''

_M.action = ''

_M.postMessage = ''
_M.delegate = ''

local function responseToTable(str, delimeters)
    local obj = {}

    while str:find(delimeters[1]) ~= nil do
        if #delimeters > 1 then
            local key_index = 1
            local val_index = str:find(delimeters[1])
            local key = str:sub(key_index, val_index - 1)
    
            str = str:sub((val_index + delimeters[1]:len()))
    
            local end_index
            local value
    
            if str:find(delimeters[2]) == nil then
                end_index = str:len()
                value = str
            else
                end_index = str:find(delimeters[2])
                value = str:sub(1, (end_index - 1))
                str = str:sub((end_index + delimeters[2]:len()), str:len())
            end
            obj[key] = value
        else
    
            local val_index = str:find(delimeters[1])
            str = str:sub((val_index + delimeters[1]:len()))
    
            local end_index
            local value
    
            if str:find(delimeters[1]) == nil then
                end_index = str:len()
                value = str
            else
                end_index = str:find(delimeters[1])
                value = str:sub(1, (end_index - 1))
                str = str:sub(end_index, str:len())
            end
            
            obj[#obj + 1] = value
        end
    end
    
    return obj
end

function _M.listener(event)
    local url = event.url
    local self = _M 
    if url:find(self.webURL) then
        if url:find('oauth_token') then
            url = url:sub(url:find('?') + 1, url:len())
            local authorize_response = responseToTable(url, {'=', '&'})

            oAuth.getAccessToken(authorize_response.oauth_token,
                authorize_response.oauth_verifier, self.twitter_request_token_secret,
                self.consumer_key, self.consumer_secret, 'https://api.twitter.com/oauth/access_token', function (event)
                        if not event.isError then
                            local access_response = responseToTable(event.response, {'=', '&'})
                            self.access_token = access_response.oauth_token
                            self.access_token_secret = access_response.oauth_token_secret
                            self.user_id = access_response.user_id
                            self.screen_name = access_response.screen_name
                            
                            -- New api calls must be out in here as well
                            if self.action == 'tweet' then
                                self:apiTweet()
                            elseif self.action == 'followers' then
                                self:apiGetFollowers()
                            end
                            self.action = ''
                         else
                            print('Twitter getAccessToken Error')
                         end
                    end)
        else
            if type(self.delegate.twitterCancel) == 'function' then
                self.delegate.twitterCancel()
            end
        end
        native.cancelWebPopup()
        return false
    end
    return true
end

function _M:apiLogin()
    print("login")
    if not self.consumer_key or not self.consumer_secret then
        if type(self.delegate.twitterFailed) == 'function' then
            self.delegate.twitterFailed()
        end
        return
    end
    print(self.consumer_key, self.webURL, self.consumer_secret)
    local twitter_request = oAuth.getRequestToken(self.consumer_key, self.webURL, 'https://twitter.com/oauth/request_token', self.consumer_secret, function (event)
        print("apiLoginListe")
        printTable(event)
        if not event.isError then
            local twitter_request_token = event.token
            self.twitter_request_token_secret = event.token_secret
            if not twitter_request_token then
                if type(self.delegate.twitterFailed) == 'function' then
                    self.delegate.twitterFailed()
                end
                return
            end
            -- Full screen WebView
            local _T = SCREEN_TOP
            local _L = SCREEN_LEFT
            local _R = SCREEN_RIGHT
            local _B = SCREEN_BOTTOM
            print("native.showWebPopup")
            native.showWebPopup(_L, _T, _R - _L, _B - _T, 'https://api.twitter.com/oauth/authorize?oauth_token=' .. twitter_request_token, {urlRequest = _M.listener})
        else
             print('Twitter getRequestToken Error')
             if type(self.delegate.twitterFailed) == 'function' then
                self.delegate.twitterFailed()
            end
        end
    end)
end

function _M:apiTweet()
    local params = {{
        key = 'status',
        value = self.postMessage}}
    
    oAuth.makeRequest('https://api.twitter.com/1.1/statuses/update.json',
        params, self.consumer_key, self.access_token, self.consumer_secret, self.access_token_secret, 'POST', function (event)
            if not event.isError then
                if type(self.delegate.twitterSuccess) == 'function' then
                    self.delegate.twitterSuccess()
                end
             else
                 print('Twitter Tweet Error')
                 if type(self.delegate.twitterFailed) == 'function' then
                    self.delegate.twitterFailed()
                 end
             end
        end)
end

function _M:getTweets()
    local params = {{
        key = 'getStatus',
        value = self.postMessage}}

    oAuth.makeRequest('http://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=mobiledevtuts&count=2',
        params, self.consumer_key, self.access_token, self.consumer_secret, self.access_token_secret, 'POST', function (event)
            printTable(event)
            if not event.isError then
                if type(self.delegate.twitterSuccess) == 'function' then
                    self.delegate.twitterSuccess()
                end
             else
                 print('Twitter Tweet Error')
                 if type(self.delegate.twitterFailed) == 'function' then
                    self.delegate.twitterFailed()
                 end
             end
        end)
end

function _M:tweet(del, msg)
    self.action = 'tweet'
    self.postMessage = msg
    self.delegate = del
    
    if not self.access_token then
        self:apiLogin()
    else
        self:apiTweet()
    end
end

function _M:apiGetFollowers()
    local params = {{
        user_id = self.user_id,
        skip_status = true,
        include_user_entities = false}}
    
    oAuth.makeRequest('https://api.twitter.com/1.1/followers/list.json',
        params, self.consumer_key, self.access_token, self.consumer_secret, self.access_token_secret, 'GET', function (event)
            printTable(event)
            if not event.isError then
                if type(self.delegate.twitterSuccess) == 'function' then
                    self.delegate.twitterSuccess(event.response)
                end
             else
                 print('Twitter Get Followers Error')
                 if type(self.delegate.twitterFailed) == 'function' then
                    self.delegate.twitterFailed()
                 end
             end
        end)
end

function _M:getFollowers(del)
    self.action = 'followers'
    self.delegate = del
    if not self.access_token then
        print("not self.access_token ")
        self:apiLogin()
    else
        print("apiGetFollowers")
        self:apiGetFollowers()
    end
end

function _M.getPhotoUrl(id)
    return 'https://api.twitter.com/1/users/profile_image?id=' .. id .. '&size=bigger'
end


return _M