local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Loader Sirius Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({ Name = "Auto Checkpoints" })
local MainTab = Window:CreateTab("Main")

local StageLabel = MainTab:CreateLabel("Stage actual: 0")

local toggled = false
MainTab:CreateToggle({
    Name = "autofarm",
    CurrentValue = false,
    Flag = "AutoTouchToggle",
    Callback = function(Value)
        toggled = Value
    end
})

local antikickEnabled = true
local AntiKickBtn = MainTab:CreateToggle({
    Name = "AntiKick (viene preterminadamente activado)",
    CurrentValue = true,
    Flag = "AntiKickToggle",
    Callback = function(Value)
        antikickEnabled = Value
    end
})

-- Always enable antikick unless toggled off by user (toggle always ON by default)
local vu = game:GetService("VirtualUser")
LocalPlayer.Idled:connect(function()
    if antikickEnabled then
        vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end
end)

local checkpoints = Workspace:WaitForChild("Checkpoints")
local rebirthEvent = ReplicatedStorage:WaitForChild("RebirthEvent", 9e9)
local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
LocalPlayer.CharacterAdded:Connect(function(character)
    root = character:WaitForChild("HumanoidRootPart")
end)

RunService.Heartbeat:Connect(function()
    if not toggled then return end
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local stageObj = leaderstats:FindFirstChild("Stage")
        if stageObj then
            local currentStage = tonumber(stageObj.Value) or 0
            StageLabel:Set("Stage actual: " .. tostring(currentStage))
            if currentStage == 51 then
                rebirthEvent:FireServer()
                currentStage = 0
            end
            for i = 1, 7 do
                local nextStage = currentStage + i
                if nextStage > 51 then break end
                local checkpoint = checkpoints:FindFirstChild(tostring(nextStage))
                if checkpoint and checkpoint:IsA("BasePart") and root then
                    local touchInterest = checkpoint:FindFirstChild("TouchInterest")
                    if touchInterest then
                        firetouchinterest(root, checkpoint, 0)
                        firetouchinterest(root, checkpoint, 1)
                    end
                end
            end
        end
    end
end)
