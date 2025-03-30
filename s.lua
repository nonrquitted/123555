-- Script to send messages in Roblox chat using an executor
-- Note: This script utilizes Roblox's RemoteEvent system
-- MODIFIED: Each method sends a unique message for identification

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Generate a random number once for this script execution
local randomSuffix = " [" .. tostring(math.random(1000, 9999)) .. "]"

-- Function to send a chat message
-- baseMessage: The core text you want to send
local function SendChatMessage(baseMessage)
    print("Base message for this attempt: " .. baseMessage)

    -- Method 1: Using DefaultChatSystemChatEvents (most common)
    local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if chatRemote and chatRemote:FindFirstChild("SayMessageRequest") then
        local messageToSend = "[M1 DefaultChat] " .. baseMessage .. randomSuffix
        print("Attempting Method 1: DefaultChatSystemChatEvents with message: " .. messageToSend)
        pcall(function()
             chatRemote.SayMessageRequest:FireServer(messageToSend, "All")
        end)
        -- We return true here because this is the most standard method.
        -- Even if filtered, the attempt was made via the correct channel.
        return true
    end

    -- Method 2: Alternative chat remote (some games use custom chat systems)
    local altChatRemote = ReplicatedStorage:FindFirstChild("ChatRemoteEvent")
            or ReplicatedStorage:FindFirstChild("ChatEvent")
            or ReplicatedStorage:FindFirstChild("MessageEvent")

    if altChatRemote and altChatRemote:IsA("RemoteEvent") then
        local messageToSend = "[M2 AltRemote " .. altChatRemote.Name .. "] " .. baseMessage .. randomSuffix
        print("Attempting Method 2: Alternative chat remote: " .. altChatRemote.Name .. " with message: " .. messageToSend)
        -- Try different ways to fire, some games need specific parameters
        local success, err = pcall(function()
            altChatRemote:FireServer(messageToSend, "All") -- Common signature
            wait(0.1) -- Small delay between attempts if needed
            altChatRemote:FireServer(messageToSend) -- Just the message
            wait(0.1)
            altChatRemote:FireServer(LocalPlayer, messageToSend) -- Player and message
        end)
        if not success then print("Error firing AltRemote:", err) end
        return true -- Return true as an attempt was made
    end

    -- Method 3: Using TextChatService (newer chat system)
    local textChatSuccess = pcall(function()
        local TextChatService = game:GetService("TextChatService")
        if TextChatService and TextChatService.Enabled then
            print("Found enabled TextChatService, attempting methods...")

            -- Method 3a: Try via ChatInputBarConfiguration's target channel
            if TextChatService.ChatInputBarConfiguration then
                 local targetChannel = TextChatService.ChatInputBarConfiguration.TargetTextChannel
                 if targetChannel then
                    local messageToSend = "[M3a TextChannel Target] " .. baseMessage .. randomSuffix
                    print("Attempting Method 3a: Using TextChannel Target (" .. targetChannel.Name .. ") with message: " .. messageToSend)
                    targetChannel:SendAsync(messageToSend)
                    return true -- Indicate success within pcall
                 end
                 -- Fallback if TargetTextChannel isn't set but config exists
                 local generalChannel = TextChatService:FindFirstChild("TextChannels"):FindFirstChild("RBXGeneral")
                 if generalChannel then
                    local messageToSend = "[M3a TextChannel Fallback RBXGeneral] " .. baseMessage .. randomSuffix
                     print("Attempting Method 3a Fallback: Using RBXGeneral channel with message: " .. messageToSend)
                     generalChannel:SendAsync(messageToSend)
                     return true -- Indicate success within pcall
                 end
            end

            -- Method 3b: Try directly finding RBXGeneral channel
            if TextChatService:FindFirstChild("TextChannels") then
                local general = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
                if general then
                     local messageToSend = "[M3b RBXGeneral Direct] " .. baseMessage .. randomSuffix
                    print("Attempting Method 3b: Using RBXGeneral channel directly with message: " .. messageToSend)
                    general:SendAsync(messageToSend)
                    return true -- Indicate success within pcall
                end
            end

             -- Method 3c: Try finding *any* text channel if others fail
             local anyChannel = TextChatService:FindFirstChildOfClass("TextChannel")
             if anyChannel then
                 local messageToSend = "[M3c Any TextChannel] " .. baseMessage .. randomSuffix
                 print("Attempting Method 3c: Using first TextChannel found (".. anyChannel.Name ..") with message: " .. messageToSend)
                 anyChannel:SendAsync(messageToSend)
                 return true -- Indicate success within pcall
             end
        end
        return false -- No TextChatService method succeeded inside pcall
    end)

    if textChatSuccess then return true end -- Return true if any TextChatService method succeeded

    -- Method 4: Legacy method - use StarterGui:SetCore (LOCAL SCRIPT ONLY - Won't show to others)
    local starterGuiSuccess = pcall(function()
        local StarterGui = game:GetService("StarterGui")
        local messageToSend = "[M4 StarterGui LOCAL] " .. baseMessage .. randomSuffix
        print("Attempting Method 4 (Local Only): StarterGui:SetCore with message: " .. messageToSend)
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = LocalPlayer.Name .. ": " .. messageToSend, -- Include identifier here too
            Color = Color3.fromRGB(200, 200, 255), -- Slightly different color for visual cue
            Font = Enum.Font.SourceSansBold,
            FontSize = Enum.FontSize.Size18
        })
    end)
    -- Don't return true here, as this is local only and doesn't confirm server chat.

    -- Method 5: Direct player chat (LOCAL SCRIPT ONLY / Bubble Chat - often filtered/blocked)
    local humanoidChatSuccess = pcall(function()
        if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            local messageToSend = "[M5 HumanoidChat LOCAL] " .. baseMessage .. randomSuffix
            print("Attempting Method 5 (Local Only): Humanoid:Chat() with message: " .. messageToSend)
            -- humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None -- Might hide chat bubble name sometimes
            humanoid:Chat(messageToSend)
        end
    end)
    -- Don't return true here either, local/bubble chat.

    -- Method 6: Fallback - Look through all RemoteEvents in ReplicatedStorage for potential chat remotes
    print("Attempting Method 6: Searching ReplicatedStorage for chat/message remotes...")
    local foundFallback = false
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and (string.find(string.lower(remote.Name), "chat")
            or string.find(string.lower(remote.Name), "message")) then
            -- Avoid re-trying the ones we already explicitly checked
            if remote.Name ~= "SayMessageRequest" and remote.Name ~= "ChatRemoteEvent" and remote.Name ~= "ChatEvent" and remote.Name ~= "MessageEvent" then
                local messageToSend = "[M6 Fallback " .. remote.Name .. "] " .. baseMessage .. randomSuffix
                print("Found potential remote: " .. remote:GetFullName() .. ". Attempting fire with message: " .. messageToSend)
                local success, err = pcall(function()
                    remote:FireServer(messageToSend, "All")
                    wait(0.1)
                    remote:FireServer(messageToSend)
                    wait(0.1)
                    remote:FireServer(LocalPlayer, messageToSend)
                end)
                if not success then print("Error firing Fallback Remote:", err) end
                foundFallback = true
                -- We found and attempted *a* fallback remote, consider this an "attempt" success
                -- Break after finding the first potential candidate to avoid spamming unrelated remotes
                break
            end
        end
    end
    if foundFallback then return true end

    -- Method 7: Using Players service Chat method (Less common, might be custom implementation)
    local playersChatSuccess = pcall(function()
        if Players.Chat then -- Check if the method exists
            local messageToSend = "[M7 PlayersChat] " .. baseMessage .. randomSuffix
            print("Attempting Method 7: Players:Chat() with message: " .. messageToSend)
            Players:Chat(messageToSend) -- Assuming it takes only the message
        end
    end)
    -- It's unclear if this method truly sends to server or returns success, so don't return true yet.

    print("All primary methods attempted. Check chat and console.")
    return false -- Return false if none of the likely server methods were found/attempted
end

-- Get chat remotes and print them for debugging
local function DebugChatRemotes()
    print("=== CHAT REMOTE DEBUGGING ===")
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
            print("TextChatService exists:")
            print("  - Enabled: " .. tostring(TextChatService.Enabled))
            print("  - ChatVersion: " .. tostring(TextChatService.ChatVersion))
            local config = TextChatService.ChatInputBarConfiguration
            if config then
                 print("  - InputBarConfig TargetChannel: " .. (config.TargetTextChannel and config.TargetTextChannel.Name or "nil"))
            end
            print("  - Children:")
            for _, child in pairs(TextChatService:GetChildren()) do
                 print("    - " .. child.Name .. " (" .. child.ClassName .. ")")
            end
        else
            print("TextChatService not found")
        end
    end)

    -- List potential chat remotes in ReplicatedStorage
    print("Potential chat/message remotes found in ReplicatedStorage:")
    local potentialRemotes = {}
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and (
            string.find(string.lower(remote.Name), "chat") or
            string.find(string.lower(remote.Name), "message")
        ) then
            table.insert(potentialRemotes, remote:GetFullName())
        end
    end

    if #potentialRemotes > 0 then
        for i, remotePath in ipairs(potentialRemotes) do
            print("  " .. i .. ". " .. remotePath)
        end
    else
        print("  No relevant remotes found in ReplicatedStorage.")
    end

    print("===========================")
end

-- === Script Execution ===

local baseMessageToSend = "Test" -- CHANGE THIS TO YOUR DESIRED MESSAGE

print("Starting chat test...")
print("Will attempt to send messages with prefixes like [M1 DefaultChat], [M2 AltRemote], etc.")
print("Look in the Roblox chat window AND your executor's console output.")
print("The random number suffix " .. randomSuffix .. " helps identify messages from this specific run.")

-- Debug chat remotes first
DebugChatRemotes()
wait(1) -- Give time to read debug info

-- Try sending the message using the combined function
print("--- Attempting General Chat Methods ---")
local success = SendChatMessage(baseMessageToSend)

if success then
    print("--- General chat attempt sequence completed. Check game chat for messages prefixed with [M1] to [M7]. ---")
    print("NOTE: Success means a potential method was FOUND and FIRED. Message might still be filtered by the game.")
else
    print("--- Failed to find any common or fallback chat methods. ---")
end

wait(1) -- Wait before trying game-specific methods

-- Game-specific fixes for common Roblox games
local placeId = game.PlaceId
print("--- Checking Game-Specific Methods (Place ID: " .. placeId .. ") ---")

if placeId == 155615604 then -- Prison Life
    local messageToSend = "[GS PrisonLife] " .. baseMessageToSend .. randomSuffix
    print("Detected Prison Life. Attempting specific method with message: " .. messageToSend)
    pcall(function()
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(messageToSend, "All")
    end)
    print("Prison Life method attempted.")

elseif placeId == 286090429 then -- Arsenal
    local messageToSend = "[GS Arsenal] " .. baseMessageToSend .. randomSuffix
    print("Detected Arsenal. Attempting specific method with message: " .. messageToSend)
    -- Arsenal's remote might need specific arguments, this is a common structure:
    pcall(function()
        game:GetService("ReplicatedStorage").Events.PlayerChatted:FireServer("All", messageToSend, false, false, false) -- Guessed args, might need adjustment
    end)
    print("Arsenal method attempted.")

-- Add more 'elseif placeId == XXXXX then ...' blocks for other games if you know their specific chat remotes/methods

else
    print("No specific method found for this Place ID.")
end

print("--- Script Finished ---")
print("Remember:")
print("- Methods [M4 StarterGui] and [M5 HumanoidChat] are LOCAL ONLY and won't appear to others.")
print("- Check the game's chat window for messages. Prefixes indicate which method worked (if any).")
print("- Some games heavily filter or block executor chat.")
