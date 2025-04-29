-----------------------------------------------------------------
-- Full Persistent Auto-Movement Script with Mode Selection,
-- WalkSpeed Control, AutoClick, One-Time Teleport on Mode Reset,
-- "TP to Following Cow" Button, and Utility Buttons.
--
-- REQUIREMENTS:
--  • A portal part exists at Workspace.Lobby.ToArena.Teleport.
--  • A folder named Workspace.Cows exists. Each cow model should contain
--    a BasePart named "Body" (optionally with a ClickDetector for auto-clicking).
--
-- MODES:
--  1) No Aura Hitbox (default):
--       - The auto-movement loop makes the character WALK (via MoveTo) to the portal if within 100 studs,
--         or to the nearest cow's "Body" otherwise.
--       - When you click the "No Aura Hitbox" button (even if already selected), the character resets;
--         upon respawn it finds the nearest cow relative to its spawn and teleports there once,
--         then receives 5 seconds of noclip.
--
--  2) Aura Hitbox:
--       - Every 1 second, the auto-movement loop teleports the character instantly (using SetPrimaryPartCFrame)
--         to fixed coordinates (–41.0237, –5.5689, –790.9323).
--       - When clicking "Aura Hitbox", the character resets and receives 5 seconds of noclip.
--
-- ADDITIONAL BUTTON:
--  • "TP to Following Cow": When pressed, the script finds the nearest cow's "Body"
--     from the new character's current position and teleports the character instantly there.
--
-- OTHER:
--  - WalkSpeed is updated every 0.01 seconds based on a custom value set in the GUI.
--  - An auto-click loop (active only in No Aura mode) fires a cow's ClickDetector when its "Body"
--    is within 3 studs.
--  - A persistent, draggable GUI (ResetOnSpawn = false) offers mode toggles, utilities, and buttons.
-----------------------------------------------------------------

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Helper: Retrieve the player's character.
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end
local character = getCharacter()
if not character.PrimaryPart then
    character.PrimaryPart = character:WaitForChild("HumanoidRootPart")
end

-- Key Workspace objects.
local portal = Workspace.Lobby.ToArena.Teleport
local cowsFolder = Workspace.Cows
local auraTPPosition = Vector3.new(-41.023712158203125, -5.568867206573486, -790.93231200117188)

-- Global state variables.
local autoEnabled = true
local auraHitboxEnabled = false  -- When true, Aura Hitbox mode is active.
local customWalkSpeed = 16       -- Default WalkSpeed.

-- Flag to temporarily pause auto-movement for an instant TP when needed.
local instantTPInProgress = false

-----------------------------------------------------------------
-- Auto-Movement Loop.
-- In Aura Hitbox mode: TP to fixed coordinates every 1 second.
-- In No Aura Hitbox mode:
--   If not paused by an instant TP, WALK (via MoveTo) to the portal if within 100 studs;
--   otherwise, WALK toward the nearest cow's "Body".
-----------------------------------------------------------------
spawn(function()
    while true do
        if autoEnabled and character and character.PrimaryPart then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                if auraHitboxEnabled then
                    -- Aura Hitbox mode: teleport every 1 second.
                    character:SetPrimaryPartCFrame(CFrame.new(auraTPPosition))
                    wait(0.00011)
                else
                    if instantTPInProgress then
                        wait(0.05)
                    else
                        local currentPos = character.PrimaryPart.Position
                        local portalDist = (currentPos - portal.Position).Magnitude
                        local targetPos = nil
                        if portalDist < 100 then
                            targetPos = portal.Position
                        else
                            local nearestCow = nil
                            local shortestDistance = math.huge
                            for _, cow in ipairs(cowsFolder:GetChildren()) do
                                local body = cow:FindFirstChild("Body")
                                if body and body:IsA("BasePart") then
                                    local d = (currentPos - body.Position).Magnitude
                                    if d < shortestDistance then
                                        shortestDistance = d
                                        nearestCow = body
                                    end
                                end
                            end
                            if nearestCow then
                                targetPos = nearestCow.Position
                            else
                                targetPos = portal.Position
                            end
                        end
                        humanoid:MoveTo(targetPos)
                        wait(0.05)
                    end
                end
            end
        else
            wait(0.05)
        end
    end
end)

-----------------------------------------------------------------
-- AutoClick Loop.
-- Every 0.1 seconds, only in No Aura Hitbox mode, if the nearest cow's "Body"
-- is within 3 studs, fire its ClickDetector.
-----------------------------------------------------------------
spawn(function()
    while true do
        if autoEnabled and character and character.PrimaryPart and (not auraHitboxEnabled) then
            local currentPos = character.PrimaryPart.Position
            local portalDist = (currentPos - portal.Position).Magnitude
            if portalDist >= 100 then
                local nearestCow = nil
                local shortestDistance = math.huge
                for _, cow in ipairs(cowsFolder:GetChildren()) do
                    local body = cow:FindFirstChild("Body")
                    if body and body:IsA("BasePart") then
                        local d = (currentPos - body.Position).Magnitude
                        if d < shortestDistance then
                            shortestDistance = d
                            nearestCow = body
                        end
                    end
                end
                if nearestCow and shortestDistance < 3 then
                    local clickDetector = nearestCow:FindFirstChildOfClass("ClickDetector")
                    if clickDetector then
                        fireclickdetector(clickDetector)
                    end
                end
            end
        end
        wait(0.1)
    end
end)

-----------------------------------------------------------------
-- WalkSpeed Update Loop.
-- Every 0.01 seconds, update the player's WalkSpeed to customWalkSpeed.
-----------------------------------------------------------------
spawn(function()
    while true do
        if player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = customWalkSpeed
            end
        end
        wait(0.01)
    end
end)

-----------------------------------------------------------------
-- Respawn Handling.
-- When the character respawns, ensure its PrimaryPart is set.
-- Also, if the character dies, on respawn TP the new character to the portal.
-----------------------------------------------------------------
player.CharacterAdded:Connect(function(char)
    character = char
    if not character.PrimaryPart then
        character.PrimaryPart = character:WaitForChild("HumanoidRootPart")
    end
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        print("Character died. Waiting for respawn to TP to portal.")
        local newChar = player.CharacterAdded:Wait()
        newChar:WaitForChild("Humanoid"):MoveTo(portal.Position)
    end)
end)

-----------------------------------------------------------------
-- Function: Apply 5 Seconds of Noclip to a Character.
-----------------------------------------------------------------
local function applyNoclipForFiveSeconds(char)
    for i = 1, 50 do
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        wait(0.1)
    end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end

-----------------------------------------------------------------
-- Persistent, Draggable GUI Setup.
-- The GUI persists (ResetOnSpawn = false) and can be toggled with F1.
-----------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomControlGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 440)  -- Increased height to accommodate new button
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.3
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Title Bar with label and "X" close button.
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleBar.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Auto Movement Control"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
closeButton.Parent = titleBar
closeButton.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

-- Button: Toggle Auto-Movement.
local toggleAutoBtn = Instance.new("TextButton")
toggleAutoBtn.Size = UDim2.new(1, -20, 0, 30)
toggleAutoBtn.Position = UDim2.new(0, 10, 0, 40)
toggleAutoBtn.Text = "Toggle Auto: ON"
toggleAutoBtn.Parent = frame
toggleAutoBtn.MouseButton1Click:Connect(function()
    autoEnabled = not autoEnabled
    toggleAutoBtn.Text = "Toggle Auto: " .. (autoEnabled and "ON" or "OFF")
end)

-- Button: Select "No Aura Hitbox" Mode.
local noAuraHitboxBtn = Instance.new("TextButton")
noAuraHitboxBtn.Size = UDim2.new(1, -20, 0, 30)
noAuraHitboxBtn.Position = UDim2.new(0, 10, 0, 80)
noAuraHitboxBtn.Text = "No Aura Hitbox (Active)"
noAuraHitboxBtn.Parent = frame
noAuraHitboxBtn.MouseButton1Click:Connect(function()
    auraHitboxEnabled = false
    noAuraHitboxBtn.Text = "No Aura Hitbox (Active)"
    auraHitboxBtn.Text = "Aura Hitbox"
    instantTPInProgress = true  -- Pause normal auto movement temporarily.
    -- Force a character reset.
    player:LoadCharacter()
    spawn(function()
        local newChar = player.CharacterAdded:Wait()
        if not newChar.PrimaryPart then
            newChar.PrimaryPart = newChar:WaitForChild("HumanoidRootPart")
        end
        local currentPos = newChar.PrimaryPart.Position
        local nearestCow = nil
        local shortestDistance = math.huge
        for _, cow in ipairs(cowsFolder:GetChildren()) do
            local body = cow:FindFirstChild("Body")
            if body and body:IsA("BasePart") then
                local d = (currentPos - body.Position).Magnitude
                if d < shortestDistance then
                    shortestDistance = d
                    nearestCow = body
                end
            end
        end
        if nearestCow then
            newChar:SetPrimaryPartCFrame(CFrame.new(nearestCow.Position))
        else
            newChar:SetPrimaryPartCFrame(CFrame.new(portal.Position))
        end
        applyNoclipForFiveSeconds(newChar)
        wait(0.001)  -- Pause auto movement for 2 seconds to avoid overriding the one-time TP.
        instantTPInProgress = false
    end)
end)

-- Button: Select "Aura Hitbox" Mode.
local auraHitboxBtn = Instance.new("TextButton")
auraHitboxBtn.Size = UDim2.new(1, -20, 0, 30)
auraHitboxBtn.Position = UDim2.new(0, 10, 0, 120)
auraHitboxBtn.Text = "Aura Hitbox"
auraHitboxBtn.Parent = frame
auraHitboxBtn.MouseButton1Click:Connect(function()
    auraHitboxEnabled = true
    auraHitboxBtn.Text = "Aura Hitbox (Active)"
    noAuraHitboxBtn.Text = "No Aura Hitbox"
    -- Force a character reset.
    player:LoadCharacter()
    spawn(function()
        local newChar = player.CharacterAdded:Wait()
        applyNoclipForFiveSeconds(newChar)
    end)
end)

-- NEW BUTTON: "TP to Following Cow"
local tpToCowBtn = Instance.new("TextButton")
tpToCowBtn.Size = UDim2.new(1, -20, 0, 30)
tpToCowBtn.Position = UDim2.new(0, 10, 0, 160)  -- Positioned just after the mode buttons
tpToCowBtn.Text = "TP to Following Cow (click this if ur bugged in the house)"
tpToCowBtn.Parent = frame
tpToCowBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if char and char.PrimaryPart then
        local currentPos = char.PrimaryPart.Position
        local nearestCow = nil
        local shortestDistance = math.huge
        for _, cow in ipairs(cowsFolder:GetChildren()) do
            local body = cow:FindFirstChild("Body")
            if body and body:IsA("BasePart") then
                local distance = (currentPos - body.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearestCow = body
                end
            end
        end
        if nearestCow then
            char:SetPrimaryPartCFrame(CFrame.new(nearestCow.Position))
        else
            warn("No cow found! Teleporting to portal instead.")
            char:SetPrimaryPartCFrame(CFrame.new(portal.Position))
        end
    end
end)

-- Adjust subsequent element positions:
-- WalkSpeed Control Label and TextBox are now moved down.
local walkSpeedLabel = Instance.new("TextLabel")
walkSpeedLabel.Size = UDim2.new(0, 100, 0, 30)
walkSpeedLabel.Position = UDim2.new(0, 10, 0, 200)
walkSpeedLabel.BackgroundTransparency = 1
walkSpeedLabel.Text = "Set WalkSpeed:"
walkSpeedLabel.TextColor3 = Color3.new(1, 1, 1)
walkSpeedLabel.Parent = frame

local walkSpeedTextBox = Instance.new("TextBox")
walkSpeedTextBox.Size = UDim2.new(0, 100, 0, 30)
walkSpeedTextBox.Position = UDim2.new(0, 120, 0, 200)
walkSpeedTextBox.PlaceholderText = "16"
walkSpeedTextBox.Text = "16"
walkSpeedTextBox.Parent = frame
walkSpeedTextBox.ClearTextOnFocus = false
walkSpeedTextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local inputSpeed = tonumber(walkSpeedTextBox.Text)
        if inputSpeed then
            customWalkSpeed = inputSpeed
            print("Custom WalkSpeed updated to: " .. inputSpeed)
        else
            print("Invalid WalkSpeed value entered.")
        end
    end
end)

-- Utility Button: Delete Effects.
local deleteEffectsBtn = Instance.new("TextButton")
deleteEffectsBtn.Size = UDim2.new(1, -20, 0, 30)
deleteEffectsBtn.Position = UDim2.new(0, 10, 0, 260)
deleteEffectsBtn.Text = "Delete Effects"
deleteEffectsBtn.Parent = frame
deleteEffectsBtn.MouseButton1Click:Connect(function()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or 
           obj:IsA("Trail") or 
           obj:IsA("Sparkles") or 
           obj:IsA("Fire") or 
           obj:IsA("Smoke") then
            obj:Destroy()
        end
    end
end)

-- Utility Button: Delete Music.
local deleteMusicBtn = Instance.new("TextButton")
deleteMusicBtn.Size = UDim2.new(1, -20, 0, 30)
deleteMusicBtn.Position = UDim2.new(0, 10, 0, 300)
deleteMusicBtn.Text = "Delete Music"
deleteMusicBtn.Parent = frame
deleteMusicBtn.MouseButton1Click:Connect(function()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Sound") and string.find(string.lower(obj.Name), "music") then
            obj:Destroy()
        end
    end
end)

-- Utility Button: Toggle Invisible Environment.
local envInvisible = false
local originalTransparencies = {}
local toggleInvisibleBtn = Instance.new("TextButton")
toggleInvisibleBtn.Size = UDim2.new(1, -20, 0, 30)
toggleInvisibleBtn.Position = UDim2.new(0, 10, 0, 340)
toggleInvisibleBtn.Text = "Toggle Invisible Env"
toggleInvisibleBtn.Parent = frame
toggleInvisibleBtn.MouseButton1Click:Connect(function()
    if not envInvisible then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                if not obj:IsDescendantOf(cowsFolder) and obj ~= portal then
                    if originalTransparencies[obj] == nil then
                        originalTransparencies[obj] = obj.Transparency
                    end
                    obj.Transparency = 1
                end
            end
        end
        envInvisible = true
        toggleInvisibleBtn.Text = "Restore Visible Env"
    else
        for part, trans in pairs(originalTransparencies) do
            if part and part.Parent then
                part.Transparency = trans
            end
        end
        originalTransparencies = {}
        envInvisible = false
        toggleInvisibleBtn.Text = "Toggle Invisible Env"
    end
end)

-- F1 Key: Toggle GUI Visibility.
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        frame.Visible = not frame.Visible
    end
end)
