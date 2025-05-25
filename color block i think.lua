local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")

local addRewardEvent = replicatedStorage:WaitForChild("Remotes"):WaitForChild("AddRewardEvent")
local spinWheelPrizeEvent = replicatedStorage:WaitForChild("Remotes"):WaitForChild("SpinWheelPrizeEvent")

-- Create the ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Create the draggable frame (menu container)
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 250, 0, 200)
menuFrame.Position = UDim2.new(0.5, -125, 0.5, -100)
menuFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
menuFrame.BorderSizePixel = 2
menuFrame.Parent = screenGui

-- Enable dragging functionality
local dragging
local dragInput
local dragStart
local startPos

menuFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = menuFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

menuFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        menuFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Create the close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0, 5)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeButton.Parent = menuFrame

closeButton.MouseButton1Click:Connect(function()
    menuFrame.Visible = false
end)

-- Function to create reward buttons inside the menu
local function createButton(position, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 40)
    button.Position = position
    button.Text = text
    button.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    button.Parent = menuFrame

    local canClick = true
    button.MouseButton1Click:Connect(function()
        if canClick then
            canClick = false
            callback()
            wait(1) -- Cooldown period
            canClick = true
        end
    end)
end

-- Add reward buttons
createButton(UDim2.new(0, 25, 0, 40), "Get inf Money", function()
    addRewardEvent:FireServer("Cash", 99999999999999999999999999999999999999999999999999999999999999999999999999999)
end)

createButton(UDim2.new(0, 25, 0, 85), "Get 1000 Nukes", function()
    for i = 1, 1000 do
        spinWheelPrizeEvent:FireServer(7)
    end
end)

createButton(UDim2.new(0, 25, 0, 130), "Get 3000 Bombs", function()
    for i = 1, 1000 do
        spinWheelPrizeEvent:FireServer(5)
    end
end)
