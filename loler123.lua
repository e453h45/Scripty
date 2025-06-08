-- Load external source (checkpoint)
loadstring(game:HttpGet("https://raw.githubusercontent.com/e453h45/Scripty/refs/heads/main/lua.lua"))()

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
end

createDebugButtons()
