-- Script to send messages in Roblox chat using an executor
-- Note: This script utilizes Roblox's RemoteEvent system

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Function to send a chat message
local function SendChatMessage(message)
    -- Debug print to verify chat paths
    print("Attempting to send message: " .. message)
    
    -- Method 1: Using DefaultChatSystemChatEvents (most common)
    local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if chatRemote and chatRemote:FindFirstChild("SayMessageRequest") then
        print("Using DefaultChatSystemChatEvents path")
        chatRemote.SayMessageRequest:FireServer(message, "All")
        return true
    end
    
    -- Method 2: Alternative chat remote (some games use custom chat systems)
    local altChatRemote = ReplicatedStorage:FindFirstChild("ChatRemoteEvent") 
            or ReplicatedStorage:FindFirstChild("ChatEvent")
            or ReplicatedStorage:FindFirstChild("MessageEvent")
    
    if altChatRemote and altChatRemote:IsA("RemoteEvent") then
        print("Using alternative chat remote: " .. altChatRemote.Name)
        -- Some games need additional parameters
        pcall(function()
            altChatRemote:FireServer(message)
            altChatRemote:FireServer(message, "All")
            altChatRemote:FireServer(LocalPlayer, message)
        end)
        return true
    end
    
    -- Method 3: Using TextChatService (newer chat system)
    local success = pcall(function()
        local TextChatService = game:GetService("TextChatService")
        if TextChatService then
            print("Found TextChatService, attempting to use it")
            -- Try direct method
            if TextChatService.ChatInputBarConfiguration then
                local textChannel = TextChatService:FindFirstChildOfClass("TextChannel") or TextChatService:FindFirstChild("TextChannelAll") or TextChatService:FindFirstChild("RBXGeneral")
                if textChannel then
                    print("Using TextChannel: " .. textChannel.Name)
                    textChannel:SendAsync(message)
                    return true
                end
            end
            
            -- Try alternative method for TextChatService
            if TextChatService:FindFirstChild("TextChannels") then
                local general = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
                if general then
                    print("Using RBXGeneral channel")
                    general:SendAsync(message)
                    return true
                end
            end
        end
    end)
    
    if success then return true end
    
    -- Method 4: Legacy method - use StarterGui:SetCore
    pcall(function()
        local StarterGui = game:GetService("StarterGui")
        print("Trying StarterGui method")
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = LocalPlayer.Name .. ": " .. message,
            Color = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.SourceSansBold,
            FontSize = Enum.FontSize.Size18
        })
    end)
    
    -- Method 5: Direct player chat (may be filtered/blocked)
    pcall(function()
        print("Trying direct player chat method")
        if LocalPlayer and LocalPlayer.Character then
            LocalPlayer.Character:FindFirstChild("Humanoid").DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            LocalPlayer.Character:FindFirstChild("Humanoid"):Chat(message)
        end
    end)
    
    -- Fallback: Look through all RemoteEvents in the game for potential chat remotes
    print("Searching for chat RemoteEvents...")
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and (string.find(string.lower(remote.Name), "chat") 
            or string.find(string.lower(remote.Name), "message")) then
            print("Found potential chat remote: " .. remote:GetFullName())
            pcall(function()
                remote:FireServer(message)
                remote:FireServer(message, "All")
                remote:FireServer(LocalPlayer, message)
            end)
            return true
        end
    end
    
    -- Check if Players service has a method
    pcall(function()
        if Players.Chat then
            print("Trying Players.Chat method")
            Players:Chat(message)
        end
    end)
    
    print("All methods attempted, message may not be visible")
    return false
end

-- Get chat remotes and print them for debugging
local function DebugChatRemotes()
    print("=== debe ===")
    
    -- Check for DefaultChatSystemChatEvents
    local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if chatEvents then
        print("Found DefaultChatSystemChatEvents with children:")
        for _, child in pairs(chatEvents:GetChildren()) do
            print("  - " .. child.Name .. " (" .. child.ClassName .. ")")
        end
    else
        print("DefaultChatSystemChatEvents not found")
    end
    
    -- Check for TextChatService
    pcall(function()
        local TextChatService = game:GetService("TextChatService")
        if TextChatService then
            print("TextChatService exists with properties:")
            print("  - Enabled: " .. tostring(TextChatService.Enabled))
            for _, child in pairs(TextChatService:GetChildren()) do
                print("  - " .. child.Name .. " (" .. child.ClassName .. ")")
            end
        end
    end)
    
    -- List potential chat remotes in the game
    print("Potential chat remotes found in game:")
    local potentialRemotes = {}
    for _, remote in pairs(game:GetDescendants()) do
        if remote:IsA("RemoteEvent") and (
            string.find(string.lower(remote.Name), "chat") or
            string.find(string.lower(remote.Name), "message")
        ) then
            table.insert(potentialRemotes, remote:GetFullName())
        end
    end
    
    for i, remotePath in ipairs(potentialRemotes) do
        print("  " .. i .. ". " .. remotePath)
    end
    
    print("===========================")
end

-- Example usage:
local messageToSend = "Hello World! " .. tostring(math.random(1000, 9999)) -- Add random number to verify in chat
print("Attempting to send message: " .. messageToSend)

-- Debug chat remotes first
DebugChatRemotes()

-- Try sending the message
local success = SendChatMessage("168 ll")

if success then
    print("Message triggered successfully, but may not be visible in chat.")
    print("Some games filter messages or block executor chat access.")
else
    print("Failed to find any chat system.")
end

-- Function to spam chat (use responsibly)
local function SpamChat(message, times, delay)
    times = times or 5 -- Default 5 times
    delay = delay or 1 -- Default 1 second delay
    
    for i = 1, times do
        SendChatMessage(message .. " (" .. i .. ")")
        wait(delay) -- Wait between messages to avoid detection
    end
end

-- Additional troubleshooting:
-- Some games use special keys or commands to show chat
print("Reminder: Some games require pressing a key like '/' or 'T' to show chat")
print("Others may have custom chat systems that block executor messages")

-- Game-specific fixes for common Roblox games
local place = game.PlaceId
print("Current Place ID: " .. place)

-- Try game-specific methods based on PlaceId
if place == 155615604 then -- Prison Life
    print("Detected Prison Life, using game-specific method")
    local function prisonChat(msg)
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
    end
    prisonChat(messageToSend)
elseif place == 286090429 then -- Arsenal
    print("Detected Arsenal, using game-specific method")
    game:GetService("ReplicatedStorage").Events.PlayerChatted:FireServer("Trolling", messageToSend, false, false, true)
end

-- Uncomment to use spam function:
-- SpamChat("Test message", 3, 1) -- Will send 3 messages with 1s delay
