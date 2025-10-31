--[[
    GAME CONTROL PANEL - OPTIMIZED VERSION
    
    IMPROVEMENTS:
    - Modular organization with clear sections
    - Optimized collection system to prevent lag
    - Separate Anti Bombs and Anti Explosions toggles
    - Reduced Heartbeat connections for better performance
    - Proper connection management to prevent memory leaks
    - Better variable scoping and naming conventions
]]

--// ============================================
--// SERVICES
--// ============================================
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

--// ============================================
--// REMOTES
--// ============================================
local RemotesRoot = RS:FindFirstChild("Remotes")
local ragdollRemote = RemotesRoot and RemotesRoot:FindFirstChild("Ragdoll")
local skillRemote = RemotesRoot and RemotesRoot:FindFirstChild("skillUse")
local resetRemote = RS:FindFirstChild("ResetBindLobby")

--// ============================================
--// RAYFIELD UI SETUP
--// ============================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Game Control Panel",
    LoadingTitle = "Loading UI",
    LoadingSubtitle = "Optimized Version",
    ConfigurationSaving = {
        Enabled = false,
    }
})

--// ============================================
--// UTILITY FUNCTIONS
--// ============================================

-- Get random point inside a part (XZ plane only)
local function getRandomXZPointInPart(part)
    if not part or not part.Size then 
        return part.CFrame 
    end
    local sx, sz = part.Size.X, part.Size.Z
    local rx = (math.random() - 0.5) * sx
    local rz = (math.random() - 0.5) * sz
    return part.CFrame * CFrame.new(rx, 0, rz)
end

-- Teleport object to player
local function teleportToPlayer(obj)
    local character = player.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    pcall(function()
        if obj:IsA("BasePart") then
            obj.CanCollide = false
            obj.Transparency = 1
            obj.CFrame = hrp.CFrame
        else
            local targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if targetPart then
                targetPart.CanCollide = false
                targetPart.Transparency = 1
                if obj.PrimaryPart then
                    obj:SetPrimaryPartCFrame(hrp.CFrame)
                else
                    targetPart.CFrame = hrp.CFrame
                end
            end
        end
    end)
end

--// ============================================
--// GENERAL TAB
--// ============================================
local GeneralTab = Window:CreateTab("General", 4483362458)

-- Auto Win Feature
local autoWin = false
local winConnection = nil

local function SetAutoWin(enable)
    autoWin = enable
    
    if autoWin then
        winConnection = RunService.Heartbeat:Connect(function()
            if not autoWin then return end
            
            local ceiling = WS:FindFirstChild("Ceiling")
            local character = player.Character
            
            if ceiling and character then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = getRandomXZPointInPart(ceiling)
                end
            end
            
            -- Fire NotThere remote
            local notThereRemote = RS:FindFirstChild("NotThere")
            if notThereRemote then
                pcall(function()
                    notThereRemote:FireServer(false)
                end)
            end
            
            task.wait(0.001) -- Small delay to prevent overwhelming the server
        end)
    else
        if winConnection then
            winConnection:Disconnect()
            winConnection = nil
        end
    end
end

GeneralTab:CreateToggle({
    Name = "Auto Win (te pueden grabar)",
    CurrentValue = false,
    Callback = SetAutoWin,
})

--// ============================================
--// COLLECTABLES SYSTEM
--// ============================================

-- Collectable items configuration
local collectableItems = {
    -- Items in Workspace.Bombs
    bombs = {
        {name = "MagicShield", toggle = false},
        {name = "Coin_event", toggle = false},
        {name = "Coin_silver", toggle = false},
        {name = "Coin_copper", toggle = false},
        {name = "Coin_gold", toggle = false},
        {name = "HeartPickup", toggle = false},
        {name = "FireShield", toggle = false},
        {name = "PizzaBox", toggle = false},
        {name = "ChargeSoda", toggle = false},
        {name = "Gem", toggle = false},
    },
    -- Items in Workspace root (Lobby)
    lobby = {
        {name = "Coin_copper", toggle = false},
        {name = "Coin_silver", toggle = false},
        {name = "Coin_golden", toggle = false},
        {name = "Coin_gold", toggle = false},
    }
}

-- Collect item from Workspace.Bombs
local function collectFromBombs(itemName)
    local bombsFolder = WS:FindFirstChild("Bombs")
    if not bombsFolder then return end
    
    local obj = bombsFolder:FindFirstChild(itemName)
    if obj then
        teleportToPlayer(obj)
    end
end

-- Collect item from Workspace root
local function collectFromWorkspace(itemName)
    local obj = WS:FindFirstChild(itemName)
    if obj then
        teleportToPlayer(obj)
    end
end

-- Create toggles for bomb items
for _, item in ipairs(collectableItems.bombs) do
    local itemName = item.name
    local displayName = itemName:gsub("_", " "):gsub("(%a)([%w_']*)", function(f, r) return f:upper()..r end)
    
    GeneralTab:CreateToggle({
        Name = "Auto Collect " .. displayName,
        CurrentValue = false,
        Callback = function(value)
            item.toggle = value
        end,
    })
end

-- Create toggle for lobby coins
local autoLobbyCoins = false
GeneralTab:CreateToggle({
    Name = "Auto Collect Lobby Coins",
    CurrentValue = false,
    Callback = function(value)
        autoLobbyCoins = value
    end,
})

-- Single Heartbeat connection for all collectables (OPTIMIZED)
local collectConnection = RunService.Heartbeat:Connect(function()
    -- Collect items from Bombs folder
    for _, item in ipairs(collectableItems.bombs) do
        if item.toggle then
            collectFromBombs(item.name)
        end
    end
    
    -- Collect lobby coins
    if autoLobbyCoins then
        for _, item in ipairs(collectableItems.lobby) do
            collectFromWorkspace(item.name)
        end
    end
end)

--// ============================================
--// EVENT TAB
--// ============================================
local EventTab = Window:CreateTab("Event", 4483362458)

-- Event collectables
local eventItems = {
    {name = "HalloweenCandy", toggle = false, displayName = "Halloween Candy"},
    {name = "CandyCorn", toggle = false, displayName = "Candy Corn"},
}

for _, item in ipairs(eventItems) do
    EventTab:CreateToggle({
        Name = "Auto Collect " .. item.displayName,
        CurrentValue = false,
        Callback = function(value)
            item.toggle = value
        end,
    })
end

-- Event collection heartbeat
local eventConnection = RunService.Heartbeat:Connect(function()
    for _, item in ipairs(eventItems) do
        if item.toggle then
            collectFromBombs(item.name)
        end
    end
end)

--// ============================================
--// FUN TAB
--// ============================================
local FunTab = Window:CreateTab("Fun", 4483362458)

-- Randomize Ability Button
FunTab:CreateButton({
    Name = "Randomize Ability",
    Callback = function()
        if skillRemote then
            pcall(function()
                skillRemote:FireServer(66, 0, "skillScript")
            end)
        end
    end,
})

-- Auto Use Skill
local autoSkill = false
local autoSkillConnection = nil

local function SetAutoSkill(enable)
    autoSkill = enable
    
    if autoSkill then
        autoSkillConnection = task.spawn(function()
            while autoSkill do
                if skillRemote then
                    pcall(function()
                        skillRemote:FireServer(58, 300, "skillScript")
                    end)
                end
                task.wait(1) -- Wait 1 second between skill uses
            end
        end)
    else
        if autoSkillConnection then
            task.cancel(autoSkillConnection)
            autoSkillConnection = nil
        end
    end
end

FunTab:CreateToggle({
    Name = "Auto Use Skill",
    CurrentValue = false,
    Callback = SetAutoSkill,
})

-- Auto Spam ChargeFx
local autoChargeFx = false
local chargeFxConnection = nil

local function SetAutoChargeFx(enable)
    autoChargeFx = enable
    
    if autoChargeFx then
        chargeFxConnection = task.spawn(function()
            while autoChargeFx do
                local character = player.Character
                if character then
                    pcall(function()
                        local soundContainer = character:FindFirstChild("Sound")
                        if soundContainer then
                            local chargeFx = soundContainer:FindFirstChild("ChargeFx")
                            if chargeFx and chargeFx.FireServer then
                                chargeFx:FireServer()
                            end
                        end
                    end)
                end
                task.wait(0.2) -- Spam interval
            end
        end)
    else
        if chargeFxConnection then
            task.cancel(chargeFxConnection)
            chargeFxConnection = nil
        end
    end
end

FunTab:CreateToggle({
    Name = "Auto Spam ChargeFx",
    CurrentValue = false,
    Callback = SetAutoChargeFx,
})

-- Spam Reset
local spamReset = false
local spamResetConnection = nil

local function SetSpamReset(enable)
    spamReset = enable
    
    if spamReset then
        spamResetConnection = task.spawn(function()
            while spamReset do
                if resetRemote then
                    pcall(function()
                        resetRemote:FireServer()
                    end)
                end
                task.wait(0.1)
            end
        end)
    else
        if spamResetConnection then
            task.cancel(spamResetConnection)
            spamResetConnection = nil
        end
    end
end

FunTab:CreateToggle({
    Name = "Spam Reset (funny)",
    CurrentValue = false,
    Callback = SetSpamReset,
})
--// VENTAJAS TAB (ADVANTAGES)
local VentajasTab = Window:CreateTab("Ventajas", 4483362458)

--// ANTI BOMBS/EXPLOSIONS (modo hardblock frame a frame)
local antiHardBlock = false
local hardBlockConnection = nil

local FoldersToDestroy = {"Bombs", "Explosions", "Projectiles", "Traps"}
local ClassesToDestroy = {"Explosion", "RocketProjectile", "TrapPart", "Fireball"}
local NamesToDestroy = {"Bomb", "Mine", "Trap", "Missile", "Bazooka", "Grenade", "Projectile"}

local function SetAntiHardBlock(enable)
    antiHardBlock = enable

    if antiHardBlock then
        hardBlockConnection = RunService.Heartbeat:Connect(function()
            if not antiHardBlock then return end
            -- Carpetas peligrosas
            for _, folderName in ipairs(FoldersToDestroy) do
                local folder = workspace:FindFirstChild(folderName)
                if folder then
                    for _, obj in ipairs(folder:GetChildren()) do
                        pcall(function() obj:Destroy() end)
                    end
                end
            end
            -- Instancias peligrosas por clase/nombre
            for _, obj in ipairs(workspace:GetChildren()) do
                for _, c in ipairs(ClassesToDestroy) do
                    if obj.ClassName == c or obj:IsA(c) then
                        pcall(function() obj:Destroy() end)
                    end
                end
                for _, dangerous in ipairs(NamesToDestroy) do
                    if obj.Name:lower():find(dangerous:lower()) then
                        pcall(function() obj:Destroy() end)
                    end
                end
            end
        end)
        print("[Ventajas] Anti Bombs/Explosions HARDBLOCK ON")
    else
        if hardBlockConnection then
            hardBlockConnection:Disconnect()
            hardBlockConnection = nil
        end
        print("[Ventajas] Anti Bombs/Explosions HARDBLOCK OFF")
    end
end

VentajasTab:CreateToggle({
    Name = "Anti Bombs & Explosions (HARDBLOCK)",
    CurrentValue = false,
    Callback = SetAntiHardBlock,
})
-
--// ============================================
--// CLEANUP ON SCRIPT UNLOAD
--// ============================================
game:GetService("Players").PlayerRemoving:Connect(function(plr)
    if plr == player then
        -- Disconnect all connections to prevent memory leaks
        if winConnection then winConnection:Disconnect() end
        if collectConnection then collectConnection:Disconnect() end
        if eventConnection then eventConnection:Disconnect() end
        if bombsConnection then bombsConnection:Disconnect() end
        if bombsChildConnection then bombsChildConnection:Disconnect() end
        if explosionsConnection then explosionsConnection:Disconnect() end
        if explosionsChildConnection then explosionsChildConnection:Disconnect() end
        if workspaceExplosionConnection then workspaceExplosionConnection:Disconnect() end
        if ragdollConnection then ragdollConnection:Disconnect() end
    end
end)

--// ============================================
--// END OF SCRIPT
--// ============================================
print("✓ Game Control Panel loaded successfully (Optimized Version)")
