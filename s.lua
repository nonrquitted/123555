-- Script to send messages using the TextChatService RBXGeneral channel

-- Function to send a chat message using only the confirmed method
local function SendChatMessage(message)
    print("Attempting to send message via TextChatService (RBXGeneral): " .. message)

    -- Method: Using TextChatService RBXGeneral channel (Derived from original Method 3)
    local success, result = pcall(function()
        local TextChatService = game:GetService("TextChatService")
        -- Check if TextChatService exists and is enabled (important!)
        if TextChatService and TextChatService.Enabled then
            local textChannels = TextChatService:FindFirstChild("TextChannels")
            if textChannels then
                local general = textChannels:FindFirstChild("RBXGeneral")
                if general then
                    print("Using RBXGeneral channel via TextChannels")
                    general:SendAsync(message) -- Use the message argument here
                    return true -- Indicate send was attempted
                else
                    print("RBXGeneral channel not found under TextChannels.")
                    return false
                end
            else
                 print("TextChannels folder not found under TextChatService.")
                 return false
            end
        else
             print("TextChatService not found or not enabled.")
             return false
        end
    end)

    -- Check if the pcall itself failed (e.g., unexpected error within the function)
    if not success then
        warn("Error occurred while trying to send message:", result)
        return false
    end

    -- Return the result from inside the pcall (true if send was attempted, false otherwise)
    return result
end

-- Define the message you want to send
local messageToSend = "168 ll" -- You can change this message easily

-- Call the function with your specific message
local sendAttempted = SendChatMessage(messageToSend)

-- Report if the attempt was made
if sendAttempted then
    print("Message send attempted via TextChatService.")
    print("Note: Visibility depends on game filtering/blocking and if the service/channel exists.")
else
    print("Failed to send message via TextChatService (service/channel likely missing or disabled, or error occurred).")
end
