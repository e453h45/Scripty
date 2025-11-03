-- Rayfield GUI loader
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Utilidad universal",
    LoadingTitle = "Cargando...",
    LoadingSubtitle = "by Comet Assistant",
})

local MainTab = Window:CreateTab("Funciones")

-- TouchTransmitter global toggle
local touchToggle = false
local touchParts = {}
local clickToggle = false
local clickDetectors = {}
local deleteGPtoggle = false
local deleteAdvertToggle = false

-- Obtener todas las partes con TouchTransmitter
local function getAllTouchParts()
    local arr = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v:FindFirstChildOfClass("TouchTransmitter") then
            table.insert(arr, v)
        end
    end
    return arr
end

-- Obtener todos los ClickDetector válidos
local function isGamepassRelated(obj)
    while obj.Parent do
        if obj.Parent.Name:lower():find("gamepass") then
            return true
        end
        obj = obj.Parent
    end
    return false
end

local function getAllValidClickDetectors()
    local arr = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ClickDetector") and not isGamepassRelated(obj) then
            table.insert(arr, obj)
        end
    end
    return arr
end

-- Toggle TouchTransmitter
MainTab:CreateToggle({
    Name = "Disparar TODOS los TouchTransmitter",
    CurrentValue = false,
    Flag = "TouchEverything",
    Callback = function(Value)
        touchToggle = Value
        if touchToggle then
            touchParts = getAllTouchParts()
        else
            touchParts = {}
        end
    end
})

-- Toggle ClickDetector
MainTab:CreateToggle({
    Name = "Clickear todos los ClickDetector",
    CurrentValue = false,
    Flag = "ClickearTodo",
    Callback = function(Value)
        clickToggle = Value
        if clickToggle then
            clickDetectors = getAllValidClickDetectors()
        else
            clickDetectors = {}
        end
    end
})

-- Toggle eliminar GamePass
MainTab:CreateToggle({
    Name = "Eliminar todo lo relacionado a gamepass",
    CurrentValue = false,
    Flag = "DeleteGPs",
    Callback = function(Value)
        deleteGPtoggle = Value
    end
})

-- Toggle eliminar anuncios
MainTab:CreateToggle({
    Name = "Eliminar anuncios comunes del workspace",
    CurrentValue = false,
    Flag = "DeleteAds",
    Callback = function(Value)
        deleteAdvertToggle = Value
    end
})

-- Función para eliminar objetos "gamepass" (match parcial)
local function deleteAllGamepass()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name:lower():find("gamepass") then
            if not v:IsDescendantOf(game.Players) then
                pcall(function()
                    v:Destroy()
                end)
            end
        end
    end
end

-- Palabras clave para anunciar
local adKeywords = {"ad", "advert", "billboard", "promo", "promotion", "gui"}

local function isAdvert(obj)
    local name = obj.Name:lower()
    for _, word in ipairs(adKeywords) do
        if name:find(word) then
            return true
        end
    end
    return false
end

local function deleteAllAds()
    for _, v in ipairs(workspace:GetDescendants()) do
        if isAdvert(v) and not v:IsDescendantOf(game.Players) then
            pcall(function()
                v:Destroy()
            end)
        end
    end
end

game:GetService("RunService").Heartbeat:Connect(function()
    -- Elimina cada frame instancia falsa de GamePassService
    pcall(function()
        local gps = game:FindFirstChild("GamePassService")
        if gps then
            gps:Destroy()
        end
    end)
    -- Eliminar objetos con "gamepass" si toggle activado
    if deleteGPtoggle then
        deleteAllGamepass()
    end
    -- Eliminar anuncios comunes si toggle activado
    if deleteAdvertToggle then
        deleteAllAds()
    end
    -- Fire a todos los TouchTransmitter si toggle activado
    if touchToggle then
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, part in ipairs(touchParts) do
                if part and part.Parent then
                    pcall(function()
                        firetouchinterest(character.HumanoidRootPart, part, 0)
                        firetouchinterest(character.HumanoidRootPart, part, 1)
                    end)
                end
            end
        end
    end
    -- Fire todos los ClickDetector si toggle activado
    if clickToggle then
        for _, cd in ipairs(clickDetectors) do
            if cd and cd.Parent then
                pcall(function()
                    fireclickdetector(cd)
                end)
            end
        end
    end
end)

Rayfield:LoadConfiguration()
