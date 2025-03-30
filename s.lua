-- Script to send messages in Roblox chat using an executor

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Function to send a chat message (includes multiple methods for compatibility)
local function SendChatMessage(message)
    -- Debug print to verify the attempt
    print("Attempting to send message: " .. message)

    -- Method 1: Using DefaultChatSystemChatEvents (most common)
    local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if chatRemote and chatRemote:FindFirstChild("SayMessageRequest") then
        print("Using DefaultChatSystemChatEvents path")
        chatRemote.SayMessageRequest:FireServer(message, "All")
        return true -- Indicate an attempt was made
    end

    -- Method 2: Alternative chat remote (some games use custom chat systems)
    local altChatRemote = ReplicatedStorage:FindFirstChild("ChatRemoteEvent")
            or ReplicatedStorage:FindFirstChild("ChatEvent")
            or ReplicatedStorage:FindFirstChild("MessageEvent")

    if altChatRemote and altChatRemote:IsA("RemoteEvent") then
        print("Using alternative chat remote: " .. altChatRemote.Name)
        pcall(function() altChatRemote:FireServer(message) end)
        pcall(function() altChatRemote:FireServer(message, "All") end)
        pcall(function() altChatRemote:FireServer(LocalPlayer, message) end)
        return true -- Indicate an attempt was made
    end

    -- Method 3: Using TextChatService (newer chat system)
    local textChatSuccess = pcall(function()
        local TextChatService = game:GetService("TextChatService")
        if TextChatService and TextChatService.Enabled then
            print("Found TextChatService, attempting to use it")
            local textChannel = TextChatService:FindFirstChildOfClass("TextChannel") or TextChatService:FindFirstChild("RBXGeneral")
            if textChannel then
                print("Using TextChannel: " .. textChannel.Name)
                textChannel:SendAsync(message)
                return true -- Successfully sent via TextChatService
            end
            -- Try alternative TextChatService channel structure
            local textChannels = TextChatService:FindFirstChild("TextChannels")
            if textChannels then
                 local general = textChannels:FindFirstChild("RBXGeneral")
                 if general then
                    print("Using RBXGeneral channel via TextChannels")
                    general:SendAsync(message)
                    return true -- Successfully sent via TextChatService (alt)
                 end
            end
        end
        return false -- TextChatService not found, not enabled, or channel not found
    end)

    if textChatSuccess then return true end -- Return if TextChatService method worked

    -- Method 4: Legacy method - use StarterGui:SetCore (less likely to work for chat)
    local starterGuiSuccess = pcall(function()
        local StarterGui = game:GetService("StarterGui")
        print("Trying StarterGui method (usually for system messages)")
        StarterGui:SetCore("ChatMakeSystemMessage", { Text = message })
    end)
    -- Note: This likely won't show as a normal chat message from the player

    -- Method 5: Direct player chat (often filtered/blocked by FilteringEnabled)
    local humanoidChatSuccess = pcall(function()
        if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            print("Trying direct player Humanoid:Chat method")
            LocalPlayer.Character.Humanoid:Chat(message)
            return true
        end
        return false
    end)
    if humanoidChatSuccess then return true end

    -- Fallback: Look through all RemoteEvents in ReplicatedStorage for potential chat remotes
    print("Searching ReplicatedStorage for potential chat RemoteEvents...")
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and (string.find(string.lower(remote.Name), "chat")
            or string.find(string.lower(remote.Name), "message")) then
            print("Found potential chat remote: " .. remote:GetFullName())
            local fired = pcall(function() remote:FireServer(message) end)
            if fired then print("Fired remote with message only.") end
            fired = pcall(function() remote:FireServer(message, "All") end)
            if fired then print("Fired remote with message and 'All'.") end
            fired = pcall(function() remote:FireServer(LocalPlayer, message) end)
            if fired then print("Fired remote with LocalPlayer and message.") end
            return true -- Indicate an attempt was made with a found remote
        end
    end

    -- Check Players service method (rarely used for sending)
    local playersChatSuccess = pcall(function()
        if Players.Chat then
            print("Trying Players:Chat method")
            Players:Chat(message)
            return true
        end
        return false
    end)
    if playersChatSuccess then return true end

    print("All methods attempted, could not confirm message send.")
    return false -- No method confirmed successful execution
end

-- Call the function with your specific message
local success = SendChatMessage("168 ll")

-- Report if any method was attempted
if success then
    print("A chat send method was attempted. Check the game chat.")
    print("Note: The message might be filtered or blocked by the game's systems.")
else
    print("Failed to find any known chat system or potential remote event.")
end
