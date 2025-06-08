local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace   = game:GetService("Workspace")

-- Settings
local autoFarmEnabled       = false
local walkSpeedToPortal     = 20
local walkSpeedToPlayer     = 22
local autoClickRange        = 8
local maxDistanceThreshold  = 140
local portalTeleportRadius  = 140
local teleportCooldown      = 1

-- State flags
local hasVisitedPortal = false
local hasTeleported    = false
local canTeleportAgain = true

-- GUI Creation
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name   = "AutoFarmGUI"
    screenGui.Parent = game:GetService("CoreGui")

    local toggleButton = Instance.new("TextButton", screenGui)
    toggleButton.Size  = UDim2.new(0,200,0,50)
    toggleButton.Position = UDim2.new(0.5,-100,0,10)
    toggleButton.Text = "AutoFarm: OFF"
    toggleButton.BackgroundColor3 = Color3.new(1,0,0)
    toggleButton.TextScaled = true

    toggleButton.MouseButton1Click:Connect(function()
        autoFarmEnabled = not autoFarmEnabled
        if autoFarmEnabled then
            toggleButton.Text = "AutoFarm: ON"
            toggleButton.BackgroundColor3 = Color3.new(0,1,0)
            hasVisitedPortal = false
            hasTeleported    = false
            canTeleportAgain = true
        else
            toggleButton.Text = "AutoFarm: OFF"
            toggleButton.BackgroundColor3 = Color3.new(1,0,0)
        end
    end)

    local statusLabel = Instance.new("TextLabel", screenGui)
    statusLabel.Size  = UDim2.new(0,400,0,50)
    statusLabel.Position = UDim2.new(0.5,-200,0,70)
    statusLabel.Text = "Status: Idle"
    statusLabel.BackgroundColor3 = Color3.new(0,0,0)
    statusLabel.TextColor3 = Color3.new(1,1,1)
    statusLabel.TextScaled = true

    return screenGui, statusLabel
end

local gui, statusLabel = createGUI()

local function resetCharacter()
    if LocalPlayer.Character then
        LocalPlayer.Character:BreakJoints()
        statusLabel.Text = "[DEBUG] Character reset."
    end
end

local function findTeleportPortal()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Teleport1Frame" then
            return obj
        end
    end
    return nil
end

local function findNearestPlayer()
    local nearest, bestDist = nil, math.huge
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil, nil end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - myHRP.Position).Magnitude
            if dist < bestDist then
                bestDist, nearest = dist, p
            end
        end
    end
    return nearest, bestDist
end

local function countPlayersInRadius(radius)
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return 0 end
    local count = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - myHRP.Position).Magnitude
            if dist <= radius then
                count += 1
            end
        end
    end
    return count
end

local function hasGear()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not bp then return false end
    for _, item in pairs(bp:GetChildren()) do
        if item:IsA("Tool") then
            return true
        end
    end
    return false
end

local function hasGlove()
    local char = LocalPlayer.Character
    if not char then return false end
    for _, item in pairs(char:GetChildren()) do
        if item:IsA("Tool") and item.Name:lower():find("glove") then
            return true
        end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not bp then return false end
    for _, item in pairs(bp:GetChildren()) do
        if item:IsA("Tool") and item.Name:lower():find("glove") then
            return true
        end
    end
    return false
end

local function moveTo(pos, speed)
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = speed
        humanoid:MoveTo(pos)
    end
end

local function teleportToPortal()
    local portal = findTeleportPortal()
    local char   = LocalPlayer.Character
    if not portal or not char or not char.PrimaryPart then
        statusLabel.Text = "[DEBUG] Teleport failed."
        return
    end
    char:PivotTo(portal.CFrame)
    hasTeleported = true
    statusLabel.Text = "[DEBUG] Teleported to portal."
end

LocalPlayer.CharacterAdded:Connect(function()
    hasTeleported = false
    hasVisitedPortal = false
    canTeleportAgain = true
end)

spawn(function()
    while true do
        if autoFarmEnabled then
            local char   = LocalPlayer.Character
            local portal = findTeleportPortal()

            if char and portal then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if hrp and humanoid then
                    local pDist = (hrp.Position - portal.Position).Magnitude
                    local player, plDist = findNearestPlayer()

                    if humanoid.Health <= 0 or not hrp then
                        statusLabel.Text = "[DEBUG] Dead/reset. Waiting 3s then checking portal."
                        task.wait(3)
                        local _, newDist = findNearestPlayer()
                        if newDist and newDist <= portalTeleportRadius then
                            teleportToPortal()
                        end
                        continue
                    end

                    if countPlayersInRadius(120) == 0 then
                        statusLabel.Text = "[DEBUG] No players nearby. Resetting."
                        resetCharacter()
                        task.wait(2.2)
                        hasVisitedPortal = false
                        hasTeleported    = false
                        canTeleportAgain = true
                    elseif pDist <= portalTeleportRadius and not hasGear() and not hasGlove() then
                        if canTeleportAgain then
                            canTeleportAgain = false
                            teleportToPortal()
                            task.delay(teleportCooldown, function()
                                canTeleportAgain = true
                            end)
                        end
                    elseif player and plDist and plDist <= maxDistanceThreshold then
                        statusLabel.Text = string.format("[DEBUG] Following %s (%.1f studs)", player.Name, plDist)
                        moveTo(player.Character.HumanoidRootPart.Position, walkSpeedToPlayer)
                    else
                        statusLabel.Text = "[DEBUG] No player within range."
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

spawn(function()
    local clickCount = 0
    while true do
        if autoFarmEnabled and LocalPlayer.Character then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                local player, dist = findNearestPlayer()
                if player and player.Character and dist <= autoClickRange then
                    tool:Activate()
                    clickCount += 1
                    if clickCount >= 2 then
                        statusLabel.Text = "[DEBUG] Clicked twice, waiting 0.68s"
                        task.wait(0.68)
                        clickCount = 0
                    else
                        task.wait(0.1)
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)
