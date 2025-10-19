local replicated_storage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local local_player = players.LocalPlayer

getgenv().killall = true

local function createPlatform()
    if workspace:FindFirstChild("AntiFallCube") then return end
    local cube = Instance.new("Part")
    cube.Name = "AntiFallCube"
    cube.Size = Vector3.new(50, 2, 50)
    cube.Anchored = true
    cube.CanCollide = true
    cube.Transparency = 0.5
    cube.Color = Color3.fromRGB(120, 120, 255)
    cube.Parent = workspace
end

if killall then
    createPlatform()
    repeat
        for _, v in next, players:GetPlayers() do
            if v ~= local_player 
                and v.Name ~= "radzrg"
                and v.Name ~= "hackerinc8ng"
                and local_player.Character
                and local_player.Character:FindFirstChildOfClass("Tool")
                and v.Character
                and v.Character:FindFirstChild("Humanoid")
                and v.Character.Humanoid.Health > 0
                and not v.Character:FindFirstChildOfClass("ForceField") then

                local root = local_player.Character:FindFirstChild("HumanoidRootPart") or local_player.Character:FindFirstChild("Torso") or local_player.Character:FindFirstChild("UpperTorso")
                local targetRoot = v.Character:FindFirstChild("HumanoidRootPart") or v.Character:FindFirstChild("Torso") or v.Character:FindFirstChild("UpperTorso")
                
                if root and targetRoot then
                    root.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 10000, 0))
                    local platform = workspace:FindFirstChild("AntiFallCube")
                    if platform then
                        platform.Position = root.Position - Vector3.new(0, root.Size.Y / 2 + platform.Size.Y / 2 + 2, 0)
                    end
                end

                replicated_storage:WaitForChild("RemoteTriggers"):WaitForChild("Bolster"):FireServer(
                    v.Character.Humanoid, v.Character:FindFirstChildOfClass("Tool")
                )
                task.wait()
            end
        end
        task.wait()
    until not killall
end
