-- Script to send messages in Roblox chat using an executor
-- Note: This script utilizes Roblox's RemoteEvent system

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Function to send a chat message
local function SendChatMessage(message)
    -- Method 1: Using DefaultChatSystemChatEvents
    local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if chatRemote and chatRemote:FindFirstChild("SayMessageRequest") then
        chatRemote.SayMessageRequest:FireServer(message, "All")
        return true
    end
    
    -- Method 2: Alternative chat remote (some games use custom chat systems)
    local altChatRemote = ReplicatedStorage:FindFirstChild("ChatRemoteEvent") 
            or ReplicatedStorage:FindFirstChild("ChatEvent")
            or ReplicatedStorage:FindFirstChild("MessageEvent")
    
    if altChatRemote and altChatRemote:IsA("RemoteEvent") then
        altChatRemote:FireServer(message)
        return true
    end
    
    -- Method 3: Using TextChatService (newer chat system)
    local TextChatService = game:GetService("TextChatService")
    if TextChatService and TextChatService.ChatInputBarConfiguration then
        local textChannel = TextChatService:FindFirstChildOfClass("TextChannel") or TextChatService:FindFirstChild("TextChannelAll")
        if textChannel then
            textChannel:SendAsync(message)
            return true
        end
    end
    
    -- Fallback: Look through all RemoteEvents in the game for potential chat remotes
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and (string.find(string.lower(remote.Name), "chat") 
            or string.find(string.lower(remote.Name), "message")) then
            remote:FireServer(message)
            return true
        end
    end
    
    return false
end

-- Example usage:
local messageToSend = "Hello World!" -- Change this to your desired message
local success = SendChatMessage(messageToSend)

if success then
    print("Message sent successfully")
else
    print("Failed to send message. Chat system not found.")
end

-- Function to spam chat (use responsibly)
local function SpamChat(message, times, delay)
    times = times or 5 -- Default 5 times
    delay = delay or 1 -- Default 1 second delay
    
    for i = 1, times do
        SendChatMessage(message)
        wait(delay) -- Wait between messages to avoid detection
    end
end

-- To use the spam function, uncomment the line below:
-- SpamChat("Your spam message here", 3, 0.5) -- Will send 3 messages with 0.5s delay
