local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local window = Rayfield:CreateWindow({
    Name = "idk",
    LoadingTitle = "Loader",
    LoadingSubtitle = "By yeahafk",
})

local tab = window:CreateTab("TK", 1234567890)

-- Frameworks y waits
local v_u_1 = require(game.ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Library"))
while not v_u_1.Loaded do
    game:GetService("RunService").Heartbeat:Wait()
end

-- DAMAGE ALL MOBS
local mobDoDamage = workspace:WaitForChild("__THINGS"):WaitForChild("__REMOTES"):WaitForChild("mobdodamage")
local monstersFolder = workspace:WaitForChild("__THINGS"):WaitForChild("Monsters")
local damageEnabled, damageConnection = false, nil

tab:CreateToggle({
    Name = "matar a todos los mobs insta (daño infinito, no pueden saber eres tu",
    CurrentValue = false,
    Flag = "DamageToggle",
    Callback = function(on)
        damageEnabled = on
        if damageEnabled then
            damageConnection = game:GetService("RunService").Heartbeat:Connect(function()
                for _, mob in ipairs(monstersFolder:GetChildren()) do
                    if mob and mob.Parent == monstersFolder then
                        local args = {
                            {
                                {
                                    {
                                        mob,
                                        math.huge
                                    }
                                }
                            }
                        }
                        mobDoDamage:FireServer(unpack(args))
                    end
                end
            end)
        else
            if damageConnection then
                damageConnection:Disconnect()
                damageConnection = nil
            end
        end
    end,
})

-- AUTO REDEEM DROP
local collectionService = v_u_1.Services.CollectionService
local network = v_u_1.Network
local autoRedeemEnabled, autoRedeemConnection = false, nil

tab:CreateToggle({
    Name = "recojer todas las monedas automaticamente",
    CurrentValue = false,
    Flag = "AutoRedeemToggle",
    Callback = function(state)
        autoRedeemEnabled = state
        if autoRedeemEnabled then
            autoRedeemConnection = game:GetService("RunService").RenderStepped:Connect(function()
                local drops = collectionService:GetTagged("MobDrop")
                local allUIDs = {}
                for _, drop in ipairs(drops) do
                    if drop:FindFirstChild("UID") then
                        table.insert(allUIDs, drop.UID.Value)
                    end
                end
                if #allUIDs > 0 then
                    network.Fire("RedeemDrop", allUIDs)
                end
            end)
        else
            if autoRedeemConnection then
                autoRedeemConnection:Disconnect()
                autoRedeemConnection = nil
            end
        end
    end,
})

-- OP SHOP ABUSE
local shopAbuseEnabled, shopAbuseConnection = false, nil
local shopCFrame = CFrame.new(-64.1500397, -9.50001335, 14.4800148, 1, 0, 0, 0, 1, 0, 0, 0, 1)

local function ShopAbuse()
    local shop = game.Workspace:WaitForChild("__MAP"):WaitForChild("SHOP")
    local debris = game.Workspace:WaitForChild("__DEBRIS")
    local particles = game.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Particles")
    if game.Workspace.__THINGS:FindFirstChild("Aspernator") then
        game.Workspace.__THINGS.Aspernator:Destroy()
    elseif game.Workspace.__THINGS:FindFirstChild("BuildIntoGames") then
        game.Workspace.__THINGS.BuildIntoGames:Destroy()
    end
    local shopObj = game.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Other"):WaitForChild("Aspernator"):Clone()
    shop:SetPrimaryPartCFrame(shopCFrame + Vector3.new(0, 200, 0))
    shopObj:SetPrimaryPartCFrame(shop.CharacterCFrame.Value)
    shopObj.Parent = game.Workspace.__THINGS
    for _ = 1, 10 do
        local part = Instance.new("Part")
        part.CanCollide = false
        part.Size = Vector3.new()
        part.CFrame = shopCFrame
        part.Velocity = Vector3.new(math.random(-150, 150), 80, math.random(-150, 150))
        part.Transparency = 1
        part.Parent = debris
        particles:WaitForChild("Dust-Particles"):Clone().Parent = part
        game.Debris:AddItem(part, 3)
    end
end

tab:CreateToggle({
    Name = "espamear efectos de la tienda (elimina la tienda)",
    CurrentValue = false,
    Flag = "OPShopAbuseToggle",
    Callback = function(state)
        shopAbuseEnabled = state
        if shopAbuseEnabled then
            shopAbuseConnection = game:GetService("RunService").RenderStepped:Connect(function()
                ShopAbuse()
            end)
        else
            if shopAbuseConnection then
                shopAbuseConnection:Disconnect()
                shopAbuseConnection = nil
            end
        end
    end,
})
