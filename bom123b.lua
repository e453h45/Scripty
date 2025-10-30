--// SERVICES
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

--// REMOTES
local RemotesRoot = RS:FindFirstChild("Remotes")
local ragdollRemote = RemotesRoot and RemotesRoot:FindFirstChild("Ragdoll")
local skillRemote = RemotesRoot and RemotesRoot:FindFirstChild("skillUse")
local resetRemote = RS:FindFirstChild("ResetBindLobby") -- ResetBindLobby sits directly under ReplicatedStorage in your snippets

--// RAYFIELD UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "My Game Control Panel",
    LoadingTitle = "Loading UI",
    LoadingSubtitle = "By Developer",
    ConfigurationSaving = {
       Enabled = false,
    }
})

local GeneralTab = Window:CreateTab("General", 4483362458)

local autoWin = false
local winLoop = nil

local function getRandomXZPointInPart(part)
    if not part or not part.Size then return part.CFrame end
    local sx, sz = part.Size.X, part.Size.Z
    local rx = math.random() - 0.5
    local rz = math.random() - 0.5
    local offset = Vector3.new(sx * rx, 0, sz * rz) -- Solo XZ
    return part.CFrame * CFrame.new(offset)
end

local function SetAutoWin(enable)
    autoWin = enable
    if autoWin then
        winLoop = task.spawn(function()
            while autoWin do
                local ceiling = game:GetService("Workspace"):FindFirstChild("Ceiling")
                local player = game:GetService("Players").LocalPlayer
                if ceiling and player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = getRandomXZPointInPart(ceiling)
                end
                -- RemoteEvent (el que pediste)
                local args = { false }
                local notThereRemote = game:GetService("ReplicatedStorage"):FindFirstChild("NotThere")
                if notThereRemote then
                    notThereRemote:FireServer(unpack(args))
                end
                task.wait(0.0000000000000001)
            end
        end)
    else
        winLoop = nil
    end
end

GeneralTab:CreateToggle({
    Name = "auto win (te pueden grabar)",
    CurrentValue = false,
    Callback = SetAutoWin,
})

RunService.Heartbeat:Connect(function()
    if antiRagdoll and ragdollRemote then
        pcall(function()
            ragdollRemote:FireServer("off")
        end)
    end
end)

-- Auto Collect helper for items inside Workspace.Bombs (models or parts)
local function autoCollectFromBombs(itemName)
    if not WS or not WS:FindFirstChild("Bombs") then return end
    local obj = WS.Bombs:FindFirstChild(itemName)
    if obj then
        pcall(function()
            if obj:IsA("BasePart") then
                obj.CanCollide = false
                obj.Transparency = 1
                local player = Players.LocalPlayer
                if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    obj.CFrame = player.Character.HumanoidRootPart.CFrame
                end
            else
                local targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if targetPart then
                    targetPart.CanCollide = false
                    targetPart.Transparency = 1
                    local player = Players.LocalPlayer
                    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        if obj.PrimaryPart then
                            obj:SetPrimaryPartCFrame(player.Character.HumanoidRootPart.CFrame)
                        else
                            targetPart.CFrame = player.Character.HumanoidRootPart.CFrame
                        end
                    end
                end
            end
        end)
    end
end

-- Auto Collect helper for items in Workspace root (Lobby coins)
local function autoCollectFromWorkspaceRoot(itemName)
    if not WS then return end
    local obj = WS:FindFirstChild(itemName)
    if obj then
        pcall(function()
            if obj:IsA("BasePart") then
                obj.CanCollide = false
                obj.Transparency = 1
                local player = Players.LocalPlayer
                if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    obj.CFrame = player.Character.HumanoidRootPart.CFrame
                end
            else
                local targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if targetPart then
                    targetPart.CanCollide = false
                    targetPart.Transparency = 1
                    local player = Players.LocalPlayer
                    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        if obj.PrimaryPart then
                            obj:SetPrimaryPartCFrame(player.Character.HumanoidRootPart.CFrame)
                        else
                            targetPart.CFrame = player.Character.HumanoidRootPart.CFrame
                        end
                    end
                end
            end
        end)
    end
end

-- toggles for collectables
local autoMagicShield = false
GeneralTab:CreateToggle({
    Name = "Auto Collect Magic Shield",
    CurrentValue = false,
    Callback = function(Value)
        autoMagicShield = Value
    end,
})

local autoCoinEvent = false
GeneralTab:CreateToggle({
    Name = "Auto Collect Event Coin",
    CurrentValue = false,
    Callback = function(Value)
        autoCoinEvent = Value
    end,
})

local autoCoinSilver = false
GeneralTab:CreateToggle({
    Name = "Auto Collect Silver Coin",
    CurrentValue = false,
    Callback = function(Value)
        autoCoinSilver = Value
    end,
})

local autoCoinCopper = false
GeneralTab:CreateToggle({
    Name = "Auto Collect Copper Coin",
    CurrentValue = false,
    Callback = function(Value)
        autoCoinCopper = Value
    end,
})

local autoCoinGold = false
GeneralTab:CreateToggle({
    Name = "Auto Collect Golden Coin",
    CurrentValue = false,
    Callback = function(Value)
        autoCoinGold = Value
    end,
})

local autoHeart = false
GeneralTab:CreateToggle({
    Name = "Auto Collect Heart",
    CurrentValue = false,
    Callback = function(Value)
        autoHeart = Value
    end,
})

local autoFireShield = false
GeneralTab:CreateToggle({
    Name = "Auto Collect Fire Shield",
    CurrentValue = false,
    Callback = function(Value)
        autoFireShield = Value
    end,
})

local autoPizza = false
GeneralTab:CreateToggle({
    Name = "Auto Collect Pizza",
    CurrentValue = false,
    Callback = function(Value)
        autoPizza = Value
    end,
})

local autoSoda = false
GeneralTab:CreateToggle({
    Name = "Auto Collect Charge Soda",
    CurrentValue = false,
    Callback = function(Value)
        autoSoda = Value
    end,
})

-- NEW: Auto Collect Gem (targets Workspace.Bombs.Gem specifically)
local autoGem = false
GeneralTab:CreateToggle({
    Name = "Auto Collect Gem",
    CurrentValue = false,
    Callback = function(Value)
        autoGem = Value
    end,
})

-- NEW: Auto Collect Lobby Coins (targets Workspace root coins)
local autoLobbyCoins = false
GeneralTab:CreateToggle({
    Name = "Auto Collect Lobby Coins",
    CurrentValue = false,
    Callback = function(Value)
        autoLobbyCoins = Value
    end,
})

-- Heartbeat collectors (general)
RunService.Heartbeat:Connect(function()
    if autoMagicShield then autoCollectFromBombs("MagicShield") end
    if autoCoinEvent then autoCollectFromBombs("Coin_event") end
    if autoCoinSilver then autoCollectFromBombs("Coin_silver") end
    if autoCoinCopper then autoCollectFromBombs("Coin_copper") end
    if autoCoinGold then autoCollectFromBombs("Coin_gold") end
    if autoHeart then autoCollectFromBombs("HeartPickup") end
    if autoFireShield then autoCollectFromBombs("FireShield") end
    if autoSoda then autoCollectFromBombs("ChargeSoda") end
end)

-- PizzaBox special collector (targets Workspace.Bombs.PizzaBox specifically)
RunService.Heartbeat:Connect(function()
    if not autoPizza then return end
    local bombsFolder = WS:FindFirstChild("Bombs")
    if not bombsFolder then return end
    local pizzaBox = bombsFolder:FindFirstChild("PizzaBox")
    if not pizzaBox then return end

    pcall(function()
        if pizzaBox:IsA("BasePart") then
            pizzaBox.CanCollide = false
            pizzaBox.Transparency = 1
            local player = Players.LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                pizzaBox.CFrame = player.Character.HumanoidRootPart.CFrame
            end
        else
            local targetPart = pizzaBox.PrimaryPart or pizzaBox:FindFirstChildWhichIsA("BasePart")
            if targetPart then
                targetPart.CanCollide = false
                targetPart.Transparency = 1
                local player = Players.LocalPlayer
                if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    if pizzaBox.PrimaryPart then
                        pizzaBox:SetPrimaryPartCFrame(player.Character.HumanoidRootPart.CFrame)
                    else
                        targetPart.CFrame = player.Character.HumanoidRootPart.CFrame
                    end
                end
            end
        end
    end)
end)

-- Gem collector (targets Workspace.Bombs.Gem specifically)
RunService.Heartbeat:Connect(function()
    if not autoGem then return end
    local bombsFolder = WS:FindFirstChild("Bombs")
    if not bombsFolder then return end
    local gem = bombsFolder:FindFirstChild("Gem")
    if not gem then return end

    pcall(function()
        if gem:IsA("BasePart") then
            gem.CanCollide = false
            gem.Transparency = 1
            local player = Players.LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                gem.CFrame = player.Character.HumanoidRootPart.CFrame
            end
        else
            local targetPart = gem.PrimaryPart or gem:FindFirstChildWhichIsA("BasePart")
            if targetPart then
                targetPart.CanCollide = false
                targetPart.Transparency = 1
                local player = Players.LocalPlayer
                if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    if gem.PrimaryPart then
                        gem:SetPrimaryPartCFrame(player.Character.HumanoidRootPart.CFrame)
                    else
                        targetPart.CFrame = player.Character.HumanoidRootPart.CFrame
                    end
                end
            end
        end
    end)
end)

-- Lobby coins collector (Workspace root coins)
RunService.Heartbeat:Connect(function()
    if not autoLobbyCoins then return end
    local coins = {"Coin_copper", "Coin_silver", "Coin_golden", "Coin_gold"}
    for _, coinName in ipairs(coins) do
        autoCollectFromWorkspaceRoot(coinName)
    end
end)


-- If needed, replace GeneralTab with your tab object from Rayfield
-- If testing without Rayfield: call SetAntiBombs(true) or SetAntiBombs(false)

--// EVENT TAB
local EventTab = Window:CreateTab("Event", 4483362458)

local autoCandy = false
EventTab:CreateToggle({
    Name = "Auto Collect Halloween Candy",
    CurrentValue = false,
    Callback = function(Value)
        autoCandy = Value
    end,
})

local autoCandyCorn = false
EventTab:CreateToggle({
    Name = "Auto Collect Candy Corn",
    CurrentValue = false,
    Callback = function(Value)
        autoCandyCorn = Value
    end,
})

RunService.Heartbeat:Connect(function()
    if autoCandy then autoCollectFromBombs("HalloweenCandy") end
    if autoCandyCorn then autoCollectFromBombs("CandyCorn") end
end)

--// FUN TAB (random)
local FunTab = Window:CreateTab("Fun", 4483362458)

-- NEW: Randomize Ability (click once) - placed at top of Fun tab
FunTab:CreateButton({
    Name = "Randomize Ability",
    Callback = function()
        if not skillRemote then return end
        pcall(function()
            local args = {66, 0, "skillScript"}
            skillRemote:FireServer(unpack(args))
        end)
    end,
})

-- Auto Use Skill (every 1 second)
local autoSkill = false
FunTab:CreateToggle({
    Name = "Auto Use Skill",
    CurrentValue = false,
    Callback = function(Value)
        autoSkill = Value
    end,
})

task.spawn(function()
    while true do
        if autoSkill and skillRemote then
            pcall(function()
                local args = {58, 300, "skillScript"}
                skillRemote:FireServer(unpack(args))
            end)
        end
        task.wait(1)
    end
end)

-- Auto Spam ChargeFx (uses Character.Sound.ChargeFx:FireServer())
local autoChargeFx = false
FunTab:CreateToggle({
    Name = "Auto Spam ChargeFx",
    CurrentValue = false,
    Callback = function(Value)
        autoChargeFx = Value
    end,
})

task.spawn(function()
    while true do
        if autoChargeFx then
            local player = Players.LocalPlayer
            local char = player and player.Character
            if char then
                pcall(function()
                    local soundContainer = char:FindFirstChild("Sound")
                    if soundContainer then
                        local chargeFx = soundContainer:FindFirstChild("ChargeFx")
                        if chargeFx and chargeFx.FireServer then
                            chargeFx:FireServer()
                        end
                    end
                end)
            end
        end
        task.wait(0.2) -- spam interval (game cooldown expected)
    end
end)

-- Spam Reset (useless but funny) every 0.1s
local spamReset = false
FunTab:CreateToggle({
    Name = "Spam Reset (funny)",
    CurrentValue = false,
    Callback = function(Value)
        spamReset = Value
    end,
})

task.spawn(function()
    while true do
        if spamReset and resetRemote then
            pcall(function() resetRemote:FireServer() end)
        end
        task.wait(0.1)
    end
end)
local VentajasTab = Window:CreateTab("Ventajas", 4483362458)

-- ANTI BOMBS & EXPLOSIONS YTK
local antiBombsYTK_v = false
local antiBombsYTKLoop_v = nil
local bombsDescendantConn_v = nil
local explosionsDescendantConn_v = nil

local function clearFolder_v(folder)
    for _, obj in ipairs(folder:GetChildren()) do
        pcall(function() obj:Destroy() end)
    end
    folder.ChildAdded:Connect(function(obj)
        pcall(function() obj:Destroy() end)
    end)
end

local function SetAntiBombsYTK_v(enable)
    antiBombsYTK_v = enable
    if antiBombsYTK_v then
        antiBombsYTKLoop_v = task.spawn(function()
            while antiBombsYTK_v do
                local bombsFolder = WS:FindFirstChild("Bombs")
                if bombsFolder then clearFolder_v(bombsFolder) end
                local explosionsFolder = WS:FindFirstChild("Explosions")
                if explosionsFolder then clearFolder_v(explosionsFolder) end
                task.wait(0.1)
            end
        end)
        local bombsFolder = WS:FindFirstChild("Bombs")
        if bombsFolder then
            bombsDescendantConn_v = bombsFolder.DescendantAdded:Connect(function(obj)
                pcall(function() obj:Destroy() end)
            end)
        end
        local explosionsFolder = WS:FindFirstChild("Explosions")
        if explosionsFolder then
            explosionsDescendantConn_v = explosionsFolder.DescendantAdded:Connect(function(obj)
                pcall(function() obj:Destroy() end)
            end)
        end
        WS.ChildAdded:Connect(function(obj)
            if obj:IsA("Explosion") then
                pcall(function() obj:Destroy() end)
            end
        end)
        print("[Ventajas] Anti Bombs/Explosions ON")
    else
        if antiBombsYTKLoop_v then antiBombsYTKLoop_v = nil end
        if bombsDescendantConn_v and bombsDescendantConn_v.Connected then
            bombsDescendantConn_v:Disconnect()
        end
        bombsDescendantConn_v = nil
        if explosionsDescendantConn_v and explosionsDescendantConn_v.Connected then
            explosionsDescendantConn_v:Disconnect()
        end
        explosionsDescendantConn_v = nil
        print("[Ventajas] Anti Bombs/Explosions OFF")
    end
end

VentajasTab:CreateToggle({
    Name = "Anti Bombs & Explosions",
    CurrentValue = false,
    Callback = SetAntiBombsYTK_v,
})

-- ANTI RAGDOLL (ejecuta remote cada frame)
local antiRagdoll_v = false
local ragdollLoop_v = nil

local function SetAntiRagdoll_v(enable)
    antiRagdoll_v = enable
    if antiRagdoll_v then
        ragdollLoop_v = RunService.Heartbeat:Connect(function()
            local remotes = RS:FindFirstChild("Remotes")
            local ragdollRemote = remotes and remotes:FindFirstChild("Ragdoll")
            if ragdollRemote then
                pcall(function()
                    ragdollRemote:FireServer("off")
                end)
            end
        end)
        print("[Ventajas] Anti Ragdoll ON")
    else
        if ragdollLoop_v then
            ragdollLoop_v:Disconnect()
            ragdollLoop_v = nil
        end
        print("[Ventajas] Anti Ragdoll OFF")
    end
end

VentajasTab:CreateToggle({
    Name = "Anti Ragdoll (cada frame)",
    CurrentValue = false,
    Callback = SetAntiRagdoll_v,
})

--// END OF SCRIPT
print("My Game Control Panel loaded.")
