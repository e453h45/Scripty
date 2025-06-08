-- Load external source (checkpoint)
loadstring(game:HttpGet("https://raw.githubusercontent.com/e453h45/Scripty/refs/heads/main/loler123.lua"))()

-- UI Buttons for debug teleport actions
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local function findTeleportPortal()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Teleport1Frame" then
            return obj
        end
    end
    return nil
end

local function createDebugButtons()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DebugButtonsGUI"
    screenGui.Parent = CoreGui

    local function makeButton(name, pos, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 150, 0, 40)
        btn.Position = pos
        btn.Text = name
        btn.Parent = screenGui
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    makeButton("Tp al portal", UDim2.new(0, 20, 0, 100), function()
        local portal = findTeleportPortal()
        if portal and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
            LocalPlayer.Character:PivotTo(portal.CFrame)
        end
    end)

    makeButton("Reiniciar", UDim2.new(0, 20, 0, 150), function()
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = 0
            else
                LocalPlayer.Character:BreakJoints()
            end
        end
    end)

    -- Speed changer toggle button
    local speedToggle = Instance.new("TextButton")
    speedToggle.Size = UDim2.new(0, 150, 0, 40)
    speedToggle.Position = UDim2.new(0, 20, 0, 200)
    speedToggle.Text = "Speed: OFF"
    speedToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    speedToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedToggle.TextScaled = true
    speedToggle.Parent = screenGui

    local speedEnabled = false
    local defaultSpeed = 22
    _G.AutoFarmSpeed = defaultSpeed

    speedToggle.MouseButton1Click:Connect(function()
        speedEnabled = not speedEnabled
        speedToggle.Text = speedEnabled and "Speed: ON" or "Speed: OFF"
        if speedEnabled then
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = _G.AutoFarmSpeed
                end
            end
        end
    end)

    -- Speed input box
    local speedInput = Instance.new("TextBox")
    speedInput.Size = UDim2.new(0, 150, 0, 40)
    speedInput.Position = UDim2.new(0, 20, 0, 250)
    speedInput.PlaceholderText = "Speed (default: 22)"
    speedInput.Text = ""
    speedInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedInput.TextScaled = true
    speedInput.Parent = screenGui

    speedInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local newSpeed = tonumber(speedInput.Text)
            if newSpeed and newSpeed > 0 then
                defaultSpeed = newSpeed
                _G.AutoFarmSpeed = newSpeed
                if speedEnabled then
                    local character = LocalPlayer.Character
                    if character then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid.WalkSpeed = newSpeed
                        end
                    end
                end
            end
        end
    end)

    spawn(function()
        while true do
            if speedEnabled and LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = _G.AutoFarmSpeed
                end
            end
            task.wait(0.5)
        end
    end)

    -- Autoreset toggle with delay setup
    local autoResetToggle = Instance.new("TextButton")
    autoResetToggle.Size = UDim2.new(0, 150, 0, 40)
    autoResetToggle.Position = UDim2.new(0, 20, 0, 300)
    autoResetToggle.Text = "AutoReset: OFF"
    autoResetToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    autoResetToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoResetToggle.TextScaled = true
    autoResetToggle.Parent = screenGui

    local autoResetEnabled = false
    local autoResetInterval = 150 -- 2.5 minutes default

    autoResetToggle.MouseButton1Click:Connect(function()
        autoResetEnabled = not autoResetEnabled
        autoResetToggle.Text = autoResetEnabled and "AutoReset: ON" or "AutoReset: OFF"
    end)

    spawn(function()
        while true do
            if autoResetEnabled and LocalPlayer.Character then
                task.wait(autoResetInterval)
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.Health = 0
                else
                    LocalPlayer.Character:BreakJoints()
                end
            else
                task.wait(1)
            end
        end
    end)

    -- Delete all GUI button
    makeButton("Delete All GUI", UDim2.new(0, 20, 0, 350), function()
        for _, gui in pairs(CoreGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                gui:Destroy()
            end
        end
    end)
end

createDebugButtons()
