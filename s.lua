-- Simplified Roblox chat script
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Function to send a chat message
local function SendChatMessage(message)
    -- Using DefaultChatSystemChatEvents (most common)
    local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if chatRemote and chatRemote:FindFirstChild("SayMessageRequest") then
        chatRemote.SayMessageRequest:FireServer(message, "All")
        return true
    end
    
    -- Alternative chat remote (some games use custom chat systems)
    local altChatRemote = ReplicatedStorage:FindFirstChild("ChatRemoteEvent") 
            or ReplicatedStorage:FindFirstChild("ChatEvent")
            or ReplicatedStorage:FindFirstChild("MessageEvent")
    
    if altChatRemote and altChatRemote:IsA("RemoteEvent") then
        altChatRemote:FireServer(message)
        return true
    end
    
    return false
end

-- Send your message here
local success = SendChatMessage("168 ll")

-- Basic confirmation
if success then
    print("Message sent")
else
    print("Failed to send message")
end
