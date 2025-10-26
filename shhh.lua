local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({ Name = "Universal Remotes" })
local MainTab = Window:CreateTab("Main")

local remoteToggled = false
MainTab:CreateToggle({
    Name = "Auto Remotes (ON/OFF)",
    CurrentValue = false,
    Flag = "AutoRemoteToggle",
    Callback = function(Value)
        remoteToggled = Value
    end
})

local antiafkEnabled = true
MainTab:CreateToggle({
    Name = "AntiAFK (ON/OFF)",
    CurrentValue = true,
    Flag = "AntiAFKToggle",
    Callback = function(Value)
        antiafkEnabled = Value
    end
})

local PlayerCountLabel = MainTab:CreateLabel("Jugadores: " .. #Players:GetPlayers())
Players.PlayerAdded:Connect(function()
    PlayerCountLabel:Set("Jugadores: " .. #Players:GetPlayers())
end)
Players.PlayerRemoving:Connect(function()
    PlayerCountLabel:Set("Jugadores: " .. #Players:GetPlayers())
end)

local vu = game:GetService("VirtualUser")
LocalPlayer.Idled:connect(function()
    if antiafkEnabled then
        vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end
end)

local remoteHit = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tools"):WaitForChild("HitRequest")
local remoteEat = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tools"):WaitForChild("EatEvent")
local localPlayer = Players.LocalPlayer
local function getCone()
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    return character:FindFirstChild("Cone")
end

task.spawn(function()
    while true do
        if remoteToggled then
            local cone = getCone()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    local args = {
                        {player},
                        cone
                    }
                    remoteHit:FireServer(unpack(args))
                end
            end
            if cone then
                remoteEat:FireServer(cone)
            end
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    local args2 = {
                        {player},
                        cone
                    }
                    remoteHit:FireServer(unpack(args2))
                end
            end
        end
        task.wait(0.001)
    end
end)
