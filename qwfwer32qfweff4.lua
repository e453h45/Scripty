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

-- Dangerous Parts to avoid
local dangerParts = {
    Workspace.Arena.island5:FindFirstChild("Union"),
    Workspace.Arena.Chainwork:FindFirstChild("MeshPart")
}

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

local function isNearDangerPart(position)
    for _, part in pairs(dangerParts) do
        if part and (position - part.Position).Magnitude <= 10 then
            return true
        end
    end
    return false
end

local function isValidTarget(player)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local grass = Workspace:FindFirstChild("Arena") and Workspace.Arena:FindFirstChild("main island") and Workspace.Arena["main island"]:FindFirstChild("Grass")
    local plate = Workspace:FindFirstChild("Arena") and Workspace.Arena:FindFirstChild("Plate")

    if not hrp or not targetHRP or not grass or not plate then return false end

    local dy = targetHRP.Position.Y - grass.Position.Y
    if dy < -1 or dy > 20 then return false end

    if isNearDangerPart(targetHRP.Position) then return false end

    local distToPlate = (targetHRP.Position - plate.Position).Magnitude
    if distToPlate <= 10 then return false end

    return true
end

local function findNearestValidPlayer()
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil, nil end

    local nearest, bestDist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and isValidTarget(p) then
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
    local portal = Workspace:FindFirstChild("Lobby") and Workspace.Lobby:FindFirstChild("Teleport1")
    local char = LocalPlayer.Character
    if not portal or not char or not char.PrimaryPart then
        statusLabel.Text = "[DEBUG] Teleport failed."
        return
    end
    char:PivotTo(portal.CFrame)
    hasTeleported = true
    statusLabel.Text = "[DEBUG] Teleported to portal."
end

local function removeAllWithKey()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("key") then
            obj:Destroy()
            statusLabel.Text = "[DEBUG] Objeto con 'key' eliminado: "..tostring(obj:GetFullName())
        end
    end
end

local function removeAllWithTurret()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("turret") then
            obj:Destroy()
            statusLabel.Text = "[DEBUG] Objeto con 'turret' eliminado: "..tostring(obj:GetFullName())
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    hasTeleported = false
    hasVisitedPortal = false
    canTeleportAgain = true
end)

spawn(function()
    while true do
        if autoFarmEnabled then
            local char = LocalPlayer.Character
            local portal = Workspace:FindFirstChild("Lobby") and Workspace.Lobby:FindFirstChild("Teleport1")
            local mesh = Workspace:FindFirstChild("Lobby") and Workspace.Lobby:FindFirstChild("MeshPart")

            if char and portal then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if hrp and humanoid then
                    local pDist = (hrp.Position - portal.Position).Magnitude
                    local player, plDist = findNearestValidPlayer()

                    if (mesh and hrp:IsDescendantOf(mesh)) or (pDist <= 55) then
                        if canTeleportAgain then
                            canTeleportAgain = false
                            teleportToPortal()
                            task.delay(teleportCooldown, function()
                                canTeleportAgain = true
                            end)
                        end
                    elseif humanoid.Health <= 0 then
                        statusLabel.Text = "[DEBUG] Dead/reset. Waiting 3s then checking portal."
                        task.wait(3)
                        local _, newDist = findNearestValidPlayer()
                        if newDist and newDist <= portalTeleportRadius then
                            teleportToPortal()
                        end
                    elseif countPlayersInRadius(120) == 0 then
                        statusLabel.Text = "[DEBUG] No players nearby. Resetting."
                        resetCharacter()
                        task.wait(2.2)
                        hasVisitedPortal = false
                        hasTeleported    = false
                        canTeleportAgain = true
                    elseif player and plDist and plDist <= maxDistanceThreshold then
                        statusLabel.Text = string.format("[DEBUG] Following %s (%.1f studs)", player.Name, plDist)
                        moveTo(player.Character.HumanoidRootPart.Position, walkSpeedToPlayer)
                    else
                        statusLabel.Text = "[DEBUG] No player within range."
                    end
                end
            else
                statusLabel.Text = "[DEBUG] Waiting for character or portal..."
            end
        else
            statusLabel.Text = "Status: Idle"
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
                local player, dist = findNearestValidPlayer()
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

spawn(function()
    while true do
        local cube = Workspace:FindFirstChild("Arena") and Workspace.Arena:FindFirstChild("CubeOfDeathArea") and Workspace.Arena.CubeOfDeathArea:FindFirstChild("the cube of death(i heard it kills)")
        if cube then
            cube:Destroy()
            statusLabel.Text = "[DEBUG] 'Cube of Death' eliminado."
        end
        task.wait(1)
    end
end)

spawn(function()
    while true do
        removeAllWithKey()
        task.wait(1)
    end
end)

spawn(function()
    while true do
        removeAllWithTurret()
        task.wait(1)
    end
end)
-- Loop para eliminar Workspace.amDADMUMÃ…Barrier cada 1 segundo si existe y AutoFarm está activado
spawn(function()
    while true do
        if autoFarmEnabled then
            local barrier = Workspace:FindFirstChild("amDADMUMÃ…Barrier")
            if barrier then
                barrier:Destroy()
                statusLabel.Text = "[DEBUG] 'amDADMUMÃ…Barrier' eliminado."
            end
        end
        task.wait(1)
    end
end)
-- Loop que mueve el SiphonOrb al jugador después de cruzar el portal y esperar 0.5s
spawn(function()
    while true do
        if autoFarmEnabled then
            local orb = Workspace:FindFirstChild("SiphonOrb")
            local portal = Workspace:FindFirstChild("Lobby") and Workspace.Lobby:FindFirstChild("Teleport1")
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if orb and portal and hrp then
                local distToPortal = (hrp.Position - portal.Position).Magnitude
                if distToPortal > 60 then -- ha cruzado el portal
                    task.wait(0.5)
                    if orb and hrp and (hrp.Position - portal.Position).Magnitude > 60 then
                        orb:PivotTo(hrp.CFrame)
                        statusLabel.Text = "[DEBUG] 'SiphonOrb' movido al jugador."
                    end
                end
            end
        end
        task.wait(0.002)
    end
end)
-- Extensión para ignorar jugadores dentro o cerca de Sheriff_Ravage.rock
local rock = Workspace:FindFirstChild("Sheriff_Ravage") and Workspace.Sheriff_Ravage:FindFirstChild("rock")

-- Guardamos la función original para envolverla
local originalIsValidTarget = isValidTarget

function isValidTarget(player)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    -- Si no existe rock, no aplica esta condición, pasa a la función original
    if rock then
        local center = rock.Position or (rock.PrimaryPart and rock.PrimaryPart.Position)
        if hrp:IsDescendantOf(rock) then
            return false
        elseif center and (hrp.Position - center).Magnitude <= 6 then
            return false
        end
    end

    -- Si no cae en las condiciones anteriores, llama a la función original para validación normal
    return originalIsValidTarget(player)
end
-- Extensión para hacer invisible Workspace.Arena.Plate y quitar hitbox (sin destruir)
spawn(function()
    while true do
        local plate = Workspace:FindFirstChild("Arena") and Workspace.Arena:FindFirstChild("Plate")
        if plate then
            if plate:IsA("BasePart") then
                plate.Transparency = 1
                plate.CanCollide = false
            elseif plate:IsA("Model") then
                for _, part in pairs(plate:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 1
                        part.CanCollide = false
                    end
                end
            end
        end
        task.wait(1)
    end
end)
-- Extensión: menú extra con botón Anti Bus (con mensajes solo en eventos)
local function createExtraPackGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ExtraPackGUI"
    screenGui.Parent = game:GetService("CoreGui")
    screenGui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0, 250, 0, 120)
    mainFrame.Position = UDim2.new(0.5, -125, 0.5, -60)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false

    -- Barra superior (drag & close)
    local topBar = Instance.new("Frame", mainFrame)
    topBar.Size = UDim2.new(1, 0, 0, 25)
    topBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

    local titleLabel = Instance.new("TextLabel", topBar)
    titleLabel.Size = UDim2.new(1, -30, 1, 0)
    titleLabel.Position = UDim2.new(0, 5, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Extra Pack"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local closeButton = Instance.new("TextButton", topBar)
    closeButton.Size = UDim2.new(0, 25, 1, 0)
    closeButton.Position = UDim2.new(1, -25, 0, 0)
    closeButton.Text = "X"
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.TextColor3 = Color3.new(1,1,1)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold

    closeButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)

    -- Botón Anti Bus
    local antiBusEnabled = false
    local antiBusButton = Instance.new("TextButton", mainFrame)
    antiBusButton.Size = UDim2.new(0.9, 0, 0, 40)
    antiBusButton.Position = UDim2.new(0.05, 0, 0, 35)
    antiBusButton.Text = "Anti Bus: OFF"
    antiBusButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0) -- rojo
    antiBusButton.TextColor3 = Color3.new(1,1,1)
    antiBusButton.TextScaled = true
    antiBusButton.Font = Enum.Font.SourceSansBold

    antiBusButton.MouseButton1Click:Connect(function()
        antiBusEnabled = not antiBusEnabled
        if antiBusEnabled then
            antiBusButton.Text = "Anti Bus: ON"
            antiBusButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0) -- verde
            statusLabel.Text = "[DEBUG] Anti Bus Activated"
        else
            antiBusButton.Text = "Anti Bus: OFF"
            antiBusButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0) -- rojo
            statusLabel.Text = "[DEBUG] Anti Bus Deactivated"
        end
    end)

    -- Loop para checar BusModel cuando está activado (solo mensajes en eventos)
    spawn(function()
        local lastBusExisted = false
        while true do
            if antiBusEnabled then
                local bus = Workspace:FindFirstChild("BusModel")
                if bus then
                    if not lastBusExisted then
                        -- Acaba de aparecer bus, eliminarlo
                        bus:Destroy()
                        statusLabel.Text = "[DEBUG] BusModel eliminado (Anti Bus)"
                        lastBusExisted = false -- porque ya no existe tras destruirlo
                    end
                else
                    if lastBusExisted then
                        -- Bus desapareció
                        statusLabel.Text = "[DEBUG] BusModel desapareció"
                    end
                    lastBusExisted = false
                end
            else
                lastBusExisted = false
            end
            task.wait(0.1)
        end
    end)

-- GUI adaptable a PC y móvil/tablet
local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled
local CoreGui = game:GetService("CoreGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ExtraPackGUI"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Name = "MainFrame"
mainFrame.Size = isMobile and UDim2.new(0, 200, 0, 250) or UDim2.new(0, 250, 0, 120)
mainFrame.Position = isMobile and UDim2.new(0, 10, 0, 100) or UDim2.new(0.5, -125, 0.5, -60)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false

-- Barra superior (draggable)
local topBar = Instance.new("Frame", mainFrame)
topBar.Size = UDim2.new(1, 0, 0, 25)
topBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local titleLabel = Instance.new("TextLabel", topBar)
titleLabel.Size = UDim2.new(1, -30, 1, 0)
titleLabel.Position = UDim2.new(0, 5, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Extra Pack"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local closeButton = Instance.new("TextButton", topBar)
closeButton.Size = UDim2.new(0, 25, 1, 0)
closeButton.Position = UDim2.new(1, -25, 0, 0)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.TextColor3 = Color3.new(1,1,1)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.SourceSansBold
closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- Draggable (mouse + touch)
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos = false

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            dragInput = input
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
end

makeDraggable(mainFrame)

-- ✅ BOTÓN DE EJEMPLO dentro del Extra Pack
local exampleButton = Instance.new("TextButton", mainFrame)
exampleButton.Size = UDim2.new(0.9, 0, 0, 40)
exampleButton.Position = UDim2.new(0.05, 0, 0, 35)
exampleButton.Text = "Botón de Ejemplo"
exampleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
exampleButton.TextColor3 = Color3.new(1, 1, 1)
exampleButton.TextScaled = true
exampleButton.Font = Enum.Font.SourceSansBold

exampleButton.MouseButton1Click:Connect(function()
    print("[EXTRA PACK] Botón presionado")
end)

-- 🔘 BOTÓN ABRIDOR (parte inferior izquierda de pantalla)
local openButton = Instance.new("TextButton", screenGui)
openButton.Size = UDim2.new(0, 150, 0, 40)
openButton.Position = UDim2.new(0, 10, 1, -50)
openButton.AnchorPoint = Vector2.new(0, 1)
openButton.Text = "Abrir Extra Pack"
openButton.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
openButton.TextColor3 = Color3.new(1,1,1)
openButton.TextScaled = true
openButton.Font = Enum.Font.SourceSansBold

openButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- 🔤 También puedes abrir con tecla B (solo en PC)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.B then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Botón para abrir/ocultar el Extra Pack en el GUI principal
local openPackButton = Instance.new("TextButton", gui)
openPackButton.Size = UDim2.new(0, 150, 0, 40)
openPackButton.Position = UDim2.new(0, 10, 1, -50)
openPackButton.AnchorPoint = Vector2.new(0, 1)
openPackButton.Text = "Abrir Extra Pack"
openPackButton.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
openPackButton.TextColor3 = Color3.new(1,1,1)
openPackButton.TextScaled = true
openPackButton.Font = Enum.Font.SourceSansBold

openPackButton.MouseButton1Click:Connect(function()
    extraPackFrame.Visible = not extraPackFrame.Visible
end)

-- Abrir/ocultar con tecla B
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.B then
        extraPackFrame.Visible = not extraPackFrame.Visible
    end
end)
-- Extensión para agregar botón "Saltar Auto" al Extra Pack

-- Asumo que extraPackFrame y statusLabel ya existen (del código previo)

do
    local autoJumpEnabled = false

    local autoJumpButton = Instance.new("TextButton", extraPackFrame)
    autoJumpButton.Size = UDim2.new(0.9, 0, 0, 40)
    autoJumpButton.Position = UDim2.new(0.05, 0, 0, 80) -- debajo del botón Anti Bus (que estaba en 35)
    autoJumpButton.Text = "Saltar Auto: OFF"
    autoJumpButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0) -- rojo
    autoJumpButton.TextColor3 = Color3.new(1,1,1)
    autoJumpButton.TextScaled = true
    autoJumpButton.Font = Enum.Font.SourceSansBold

    autoJumpButton.MouseButton1Click:Connect(function()
        autoJumpEnabled = not autoJumpEnabled
        if autoJumpEnabled then
            autoJumpButton.Text = "Saltar Auto: ON"
            autoJumpButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0) -- verde
            statusLabel.Text = "[DEBUG] Auto jump activated"
        else
            autoJumpButton.Text = "Saltar Auto: OFF"
            autoJumpButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0) -- rojo
            statusLabel.Text = "[DEBUG] Auto jump deactivated"
        end
    end)

    spawn(function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        while true do
            if autoJumpEnabled then
                local char = LocalPlayer.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    humanoid.Jump = true
                end
                local waitTime = math.random(5, 20)
                task.wait(waitTime)
            else
                task.wait(0.1)
            end
        end
    end)
end
--- Extensión para agregar botón "Anti Brazil" al Extra Pack

do
    local antiBrazilEnabled = false

    local antiBrazilButton = Instance.new("TextButton", extraPackFrame)
    antiBrazilButton.Size = UDim2.new(0.9, 0, 0, 40)
    antiBrazilButton.Position = UDim2.new(0.05, 0, 0, 125) -- debajo del auto jump (que estaba en 80)
    antiBrazilButton.Text = "Anti Brazil: OFF"
    antiBrazilButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0) -- rojo
    antiBrazilButton.TextColor3 = Color3.new(1,1,1)
    antiBrazilButton.TextScaled = true
    antiBrazilButton.Font = Enum.Font.SourceSansBold

    antiBrazilButton.MouseButton1Click:Connect(function()
        antiBrazilEnabled = not antiBrazilEnabled
        if antiBrazilEnabled then
            antiBrazilButton.Text = "Anti Brazil: ON"
            antiBrazilButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0) -- verde
            statusLabel.Text = "[DEBUG] Anti Brazil Activated"
        else
            antiBrazilButton.Text = "Anti Brazil: OFF"
            antiBrazilButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0) -- rojo
            statusLabel.Text = "[DEBUG] Anti Brazil Deactivated"
        end
    end)

    spawn(function()
        local Workspace = game:GetService("Workspace")
        while true do
            if antiBrazilEnabled then
                local lobby = Workspace:FindFirstChild("Lobby")
                local brazil = lobby and lobby:FindFirstChild("brazil")
                if brazil then
                    local portal = brazil:FindFirstChild("portal")
                    if portal then portal:Destroy() end
                    local part = brazil:FindFirstChild("Part")
                    if part then part:Destroy() end
                end
            end
            task.wait(1)
        end
    end)
end
do
    local button = Instance.new("TextButton", extraPackFrame)
    button.Size = UDim2.new(0.9, 0, 0, 40)
    button.Position = UDim2.new(0.05, 0, 0, 170) -- Debajo de Anti Brazil
    button.Text = "auto conseguir todos los guantes de emblemas (usar solo en lobby)"
    button.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextScaled = true
    button.Font = Enum.Font.SourceSansBold

    button.MouseButton1Click:Connect(function()
        button.Text = "Running..."
        button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        button.Active = false
        button.Selectable = false

        -- Ejecutar el script remoto
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/IncognitoScripts/SlapBattles/refs/heads/main/InstantGloves"))()
        end)
        if not success then
            statusLabel.Text = "[ERROR] Failed to run badge gloves script: "..tostring(err)
        else
            statusLabel.Text = "[DEBUG] Badge gloves script executed"
        end

        task.wait(1.5)
        -- Volver a original
        button.Text = "auto conseguir todos los guantes de emblemas (usar solo en lobby)"
        button.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        button.Active = true
        button.Selectable = true
    end)
end
do
    local ragdollESPEnabled = false
    local ignoredAirPlayers = {}
    local ignoredGroundPlayers = {}

    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local LocalPlayer = Players.LocalPlayer

    local billboards = {}

    local function isOnFloor(hrp)
        local rayOrigin = hrp.Position
        local rayDirection = Vector3.new(0, -4, 0)
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {hrp.Parent}
        params.FilterType = Enum.RaycastFilterType.Blacklist
        local result = Workspace:Raycast(rayOrigin, rayDirection, params)
        return result ~= nil
    end

    -- Crear botón
    local ragdollButton = Instance.new("TextButton", extraPackFrame)
    ragdollButton.Size = UDim2.new(0.9, 0, 0, 40)
    ragdollButton.Position = UDim2.new(0.05, 0, 0, 215)
    ragdollButton.Text = "Ragdoll ESP: OFF"
    ragdollButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    ragdollButton.TextColor3 = Color3.new(1, 1, 1)
    ragdollButton.TextScaled = true
    ragdollButton.Font = Enum.Font.SourceSansBold

    ragdollButton.MouseButton1Click:Connect(function()
        ragdollESPEnabled = not ragdollESPEnabled
        ragdollButton.Text = ragdollESPEnabled and "Ragdoll ESP: ON" or "Ragdoll ESP: OFF"
        ragdollButton.BackgroundColor3 = ragdollESPEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        statusLabel.Text = "[DEBUG] Ragdoll ESP " .. (ragdollESPEnabled and "Activated" or "Deactivated")

        -- Quitar ESP de todos
        if not ragdollESPEnabled then
            for _, bb in pairs(billboards) do
                if bb and bb.Parent then bb:Destroy() end
            end
            billboards = {}
            ignoredGroundPlayers = {}
            ignoredAirPlayers = {}
        end
    end)

    -- Crea o actualiza el ESP de un jugador
    local function updatePlayerESP(player)
        if not ragdollESPEnabled or player == LocalPlayer then return end

        local char = player.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end

        local ragdolled = humanoid.PlatformStand

        local bb = billboards[player]
        if not bb then
            bb = Instance.new("BillboardGui")
            bb.Name = "RagdollStatusGui"
            bb.Adornee = hrp
            bb.Size = UDim2.new(0, 150, 0, 50)
            bb.AlwaysOnTop = true
            bb.StudsOffset = Vector3.new(0, 3, 0)

            local label = Instance.new("TextLabel", bb)
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 0.5
            label.BackgroundColor3 = Color3.new(0, 0, 0)
            label.TextColor3 = Color3.new(1, 1, 1)
            label.TextScaled = true
            label.Font = Enum.Font.SourceSansBold
            label.Name = "StatusLabel"

            billboards[player] = bb
            bb.Parent = hrp
        else
            bb.Adornee = hrp
        end

        local label = bb:FindFirstChild("StatusLabel")
        if not label then return end

        if ragdolled then
            if isOnFloor(hrp) then
                label.Text = "Ragdolled\nOn Floor"
                label.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
                ignoredGroundPlayers[player] = true
            else
                label.Text = "Ragdolled\nIn Air"
                label.BackgroundColor3 = Color3.fromRGB(200, 150, 80)
                if not ignoredAirPlayers[player] then
                    ignoredAirPlayers[player] = true
                    task.delay(1, function()
                        ignoredAirPlayers[player] = nil
                    end)
                end
            end
        else
            label.Text = "No Ragdolled"
            label.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            ignoredGroundPlayers[player] = nil
        end
    end

    -- Loop cada 1 segundo para actualizar todos los jugadores
    spawn(function()
        while true do
            if ragdollESPEnabled then
                for _, player in ipairs(Players:GetPlayers()) do
                    updatePlayerESP(player)
                end
            end
            task.wait(1)
        end
    end)

    -- Hook: cuando un jugador reaparece
    for _, player in ipairs(Players:GetPlayers()) do
        player.CharacterAdded:Connect(function()
            task.wait(1) -- Espera a que Humanoid y HRP existan
            updatePlayerESP(player)
        end)
    end

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            task.wait(1)
            updatePlayerESP(player)
        end)
    end)

    -- Hook para autofarm
    local oldIsValidTarget = isValidTarget
    function isValidTarget(player)
        if ignoredGroundPlayers[player] or ignoredAirPlayers[player] then
            return false
        end
        return oldIsValidTarget(player)
    end
end
do
    local Workspace = game:GetService("Workspace")

    -- DROP/UNION/TYCOON CLEANER
    local dropperOn = false
    local dropperButton = Instance.new("TextButton", extraPackFrame)
    dropperButton.Size = UDim2.new(0.9, 0, 0, 40)
    dropperButton.Position = UDim2.new(0.05, 0, 0, 260)
    dropperButton.Text = "Dropper: OFF"
    dropperButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    dropperButton.TextColor3 = Color3.new(1, 1, 1)
    dropperButton.TextScaled = true
    dropperButton.Font = Enum.Font.SourceSansBold

    dropperButton.MouseButton1Click:Connect(function()
        dropperOn = not dropperOn
        dropperButton.Text = dropperOn and "Dropper: ON" or "Dropper: OFF"
        dropperButton.BackgroundColor3 = dropperOn and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        statusLabel.Text = "[DEBUG] Dropper Cleaner " .. (dropperOn and "Activated" or "Deactivated")
    end)

    spawn(function()
        while true do
            if dropperOn then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    local name = obj.Name:lower()
                    if (name:find("dropper") or name:find("union")) and obj:IsA("BasePart") then
                        obj:Destroy()
                        statusLabel.Text = "[DEBUG] Deleted: " .. obj.Name
                    end
                end
                local dyingTycoon = Workspace:FindFirstChild("DyingTycoon")
                if dyingTycoon and dyingTycoon:FindFirstChild("Info") then
                    dyingTycoon.Info:Destroy()
                    statusLabel.Text = "[DEBUG] Deleted: DyingTycoon.Info"
                end
            end
            task.wait(0.5)
        end
    end)

    -- ANTI ICE
    local antiIceOn = false
    local antiIceButton = Instance.new("TextButton", extraPackFrame)
    antiIceButton.Size = UDim2.new(0.9, 0, 0, 40)
    antiIceButton.Position = UDim2.new(0.05, 0, 0, 305)
    antiIceButton.Text = "Anti Ice: OFF"
    antiIceButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    antiIceButton.TextColor3 = Color3.new(1, 1, 1)
    antiIceButton.TextScaled = true
    antiIceButton.Font = Enum.Font.SourceSansBold

    antiIceButton.MouseButton1Click:Connect(function()
        antiIceOn = not antiIceOn
        antiIceButton.Text = antiIceOn and "Anti Ice: ON" or "Anti Ice: OFF"
        antiIceButton.BackgroundColor3 = antiIceOn and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        statusLabel.Text = "[DEBUG] Anti Ice " .. (antiIceOn and "Activated" or "Deactivated")
    end)

    spawn(function()
        while true do
            if antiIceOn then
                pcall(function()
                    local ice = Workspace.IceBin.is_ice
                    if ice then
                        ice:Destroy()
                        statusLabel.Text = "[DEBUG] Deleted: IceBin.is_ice"
                    end
                end)
            end
            task.wait(1)
        end
    end)

    -- ANTI ROCK
    local antiRockOn = false
    local antiRockButton = Instance.new("TextButton", extraPackFrame)
    antiRockButton.Size = UDim2.new(0.9, 0, 0, 40)
    antiRockButton.Position = UDim2.new(0.05, 0, 0, 350)
    antiRockButton.Text = "Anti Rock: OFF"
    antiRockButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    antiRockButton.TextColor3 = Color3.new(1, 1, 1)
    antiRockButton.TextScaled = true
    antiRockButton.Font = Enum.Font.SourceSansBold

    antiRockButton.MouseButton1Click:Connect(function()
        antiRockOn = not antiRockOn
        antiRockButton.Text = antiRockOn and "Anti Rock: ON" or "Anti Rock: OFF"
        antiRockButton.BackgroundColor3 = antiRockOn and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        statusLabel.Text = "[DEBUG] Anti Rock " .. (antiRockOn and "Activated" or "Deactivated")
    end)

    spawn(function()
        while true do
            if antiRockOn then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and obj.Name:lower():find("rock") then
                        obj:Destroy()
                        statusLabel.Text = "[DEBUG] Deleted: " .. obj.Name
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end
-- EXTENSIÓN: Compactar GUI y moverlo arriba a la derecha
task.delay(0.2, function()
	local gui = game:GetService("CoreGui"):FindFirstChild("ExtraPackGUI")
	if not gui then return end

	local frame = gui:FindFirstChild("MainFrame")
	if not frame then return end

	-- Redimensionar y mover el GUI
	frame.Size = UDim2.new(0, 180, 0, 150)
	frame.Position = UDim2.new(1, -190, 0, 10)

	-- Ajustar botones dentro
	for _, child in ipairs(frame:GetChildren()) do
		if child:IsA("TextButton") and child.Name ~= "X" then
			child.Size = UDim2.new(0.9, 0, 0, 30)
		end
	end
end)
