-- Rayfield GUI loader
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Utilidad universal",
    LoadingTitle = "Cargando...",
    LoadingSubtitle = "by Comet Assistant",
})

local MainTab = Window:CreateTab("Funciones")

-- Auto-ClickDetector toggle
local clickToggle = false
local clickDetectors = {}

local function isGamepassRelated(obj)
    local keywords = {"Gamepass", "GamePass"}
    while obj.Parent do
        for _, word in ipairs(keywords) do
            if string.lower(obj.Parent.Name) == string.lower(word) then
                return true
            end
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

MainTab:CreateToggle({
    Name = "Clickear todos los ClickDetector",
    CurrentValue = false,
    Flag = "ClickearTodo",
    Callback = function(Value)
        clickToggle = Value
        if clickToggle then
            clickDetectors = getAllValidClickDetectors()
        end
    end
})

-- Gamepass block toggle
local blockToggle = false
local oldHooked = false

MainTab:CreateToggle({
    Name = "Bloquear todos los prompts de gamepasses",
    CurrentValue = false,
    Flag = "BlockGamepassPrompt",
    Callback = function(Value)
        blockToggle = Value
        if blockToggle and not oldHooked then
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer

            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            local oldNamecall = mt.__namecall
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if method == "PromptGamePassPurchase" then
                    return
                end
                return oldNamecall(self, ...)
            end)
            setreadonly(mt, true)

            LocalPlayer.PromptGamePassPurchase = function() end
            oldHooked = true
        end
    end
})

game:GetService("RunService").Heartbeat:Connect(function()
    if clickToggle then
        for _, cd in ipairs(clickDetectors) do
            fireclickdetector(cd)
        end
    end
end)

Rayfield:LoadConfiguration()
