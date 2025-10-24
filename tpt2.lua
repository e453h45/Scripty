-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Window Setup (ZIndex = 1)
local Window = Rayfield:CreateWindow({
    Name = "Speed & Fuzzy nigger",
    LoadingTitle = "Fuzzy Teleport nigger",
    LoadingSubtitle = "By nigger",
    ZIndex = -math.huge -- <--- Makes the window layer lowest
})

local Tab = Window:CreateTab("nigger Controls", 4483362458)
Tab.ZIndex = 1

---------------------------------------------------------------------
-- SPEED CONTROL
---------------------------------------------------------------------
local SpeedValue = 16

local CustomSpeedBox = Tab:CreateInput({
    Name = "Custom Speed",
    PlaceholderText = "pon la velocidad q te de la gana y dale a change speed ",
    RemoveTextAfterFocusLost = false,
    ZIndex = 1,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            SpeedValue = num
        end
    end,
})

Tab:CreateButton({
    Name = "Change Speed (recomiendo 70-80)",
    ZIndex = 1,
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = SpeedValue
        end
    end,
})

---------------------------------------------------------------------
-- FUZZY PLAYER SEARCH (FULL PLAYER LIST)
---------------------------------------------------------------------
local TargetName = ""

local FuzzyInput = Tab:CreateInput({
    Name = "Type Player Name (Fuzzy Search)",
    PlaceholderText = "Type part of a name...",
    RemoveTextAfterFocusLost = false,
    ZIndex = 1,
    Callback = function(Value)
        TargetName = Value
    end,
})

-- Enhanced fuzzy similarity calculation
local function similarityScore(a, b)
    a, b = a:lower(), b:lower()
    local score = 0
    for i = 1, #a do
        local ch = a:sub(i, i)
        if b:find(ch, 1, true) then
            score = score + 1
        end
    end
    -- bonus if substring directly matches
    if b:find(a, 1, true) then
        score = score + #a
    end
    return score
end

local function getBestFuzzyMatch(input)
    if not input or input == "" then return nil end
    local bestMatch = nil
    local bestScore = -1
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local score = similarityScore(input, plr.Name)
            if score > bestScore then
                bestScore = score
                bestMatch = plr
            end
        end
    end
    return bestMatch
end

---------------------------------------------------------------------
-- TELEPORT BUTTONS
---------------------------------------------------------------------
Tab:CreateButton({
    Name = "Fuzzy Teleport To Player",
    ZIndex = 1,
    Callback = function()
        local target = getBestFuzzyMatch(TargetName)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end,
})

Tab:CreateButton({
    Name = "Fuzzy Tween To Player (Smooth)",
    ZIndex = 1,
    Callback = function()
        local target = getBestFuzzyMatch(TargetName)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local goal = {CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)}
                local tween = TweenService:Create(root, TweenInfo.new(2, Enum.EasingStyle.Linear), goal)
                tween:Play()
            end
        end
    end,
})
-- TAB EXTRA con Toggle típico ON/OFF
local ExtraTab = Window:CreateTab("Extra", 4483362460)
ExtraTab.ZIndex = 1

local AntiAfkConnection

local function EnableAntiAfk()
    if not AntiAfkConnection then
        local vu = game:GetService("VirtualUser")
        AntiAfkConnection = game:GetService("Players").LocalPlayer.Idled:connect(function()
            vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            wait(1)
            vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        end)
    end
end

local function DisableAntiAfk()
    if AntiAfkConnection then
        AntiAfkConnection:Disconnect()
        AntiAfkConnection = nil
    end
end

ExtraTab:CreateToggle({
    Name = "Antiafk",
    CurrentValue = true,  -- Empieza activado
    ZIndex = 1,
    Callback = function(state)
        if state then
            EnableAntiAfk()
        else
            DisableAntiAfk()
        end
    end,
})

