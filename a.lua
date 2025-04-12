-- Create the Screen GUI
local function createGui()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "EnhancedWalkControlGui"
    ScreenGui.ResetOnSpawn = false -- Ensures GUI persists after respawn
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Create the Frame for controls
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 300, 0, 200)
    Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
    Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Frame.BackgroundTransparency = 0.2
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui

    -- Add Rounded Corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 20)
    UICorner.Parent = Frame

    -- Make the Frame Draggable
    local dragging = false
    local dragInput, dragStart, startPos

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Add a Title Label
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 300, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = "Walk Control"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Parent = Frame

    -- Create a TextBox to input speed
    local SpeedTextBox = Instance.new("TextBox")
    SpeedTextBox.Size = UDim2.new(0, 200, 0, 40)
    SpeedTextBox.Position = UDim2.new(0, 50, 0, 50)
    SpeedTextBox.PlaceholderText = "Enter Walk Speed"
    SpeedTextBox.Font = Enum.Font.Gotham
    SpeedTextBox.TextSize = 16
    SpeedTextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
    SpeedTextBox.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    SpeedTextBox.Parent = Frame

    -- Add rounded corners to the TextBox
    local SpeedUICorner = Instance.new("UICorner")
    SpeedUICorner.CornerRadius = UDim.new(0, 10)
    SpeedUICorner.Parent = SpeedTextBox

    -- Create a Button to apply the speed
    local ApplyButton = Instance.new("TextButton")
    ApplyButton.Size = UDim2.new(0, 200, 0, 40)
    ApplyButton.Position = UDim2.new(0, 50, 0, 100)
    ApplyButton.Text = "Apply Walk Speed"
    ApplyButton.Font = Enum.Font.GothamBold
    ApplyButton.TextSize = 16
    ApplyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ApplyButton.BackgroundColor3 = Color3.fromRGB(100, 180, 100)
    ApplyButton.Parent = Frame

    -- Add rounded corners to the Button
    local ApplyUICorner = Instance.new("UICorner")
    ApplyUICorner.CornerRadius = UDim.new(0, 10)
    ApplyUICorner.Parent = ApplyButton

    -- Create a Toggle for anti walk lock
    local AntiWalkLockButton = Instance.new("TextButton")
    AntiWalkLockButton.Size = UDim2.new(0, 200, 0, 40)
    AntiWalkLockButton.Position = UDim2.new(0, 50, 0, 150)
    AntiWalkLockButton.Text = "Toggle Anti Walk Lock"
    AntiWalkLockButton.Font = Enum.Font.GothamBold
    AntiWalkLockButton.TextSize = 16
    AntiWalkLockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    AntiWalkLockButton.BackgroundColor3 = Color3.fromRGB(180, 100, 100)
    AntiWalkLockButton.Parent = Frame

    -- Add rounded corners to the Toggle Button
    local ToggleUICorner = Instance.new("UICorner")
    ToggleUICorner.CornerRadius = UDim.new(0, 10)
    ToggleUICorner.Parent = AntiWalkLockButton

    return ScreenGui, SpeedTextBox, ApplyButton, AntiWalkLockButton
end

-- Setup the GUI
local ScreenGui, SpeedTextBox, ApplyButton, AntiWalkLockButton = createGui()

-- Variables to store state
local player = game.Players.LocalPlayer
local currentSpeed = 16 -- Default speed
local antiWalkLockEnabled = false

local function setupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")

    -- Restore walk speed after respawn
    humanoid.WalkSpeed = currentSpeed

    -- Apply speed when the button is clicked
    ApplyButton.MouseButton1Click:Connect(function()
        local speed = tonumber(SpeedTextBox.Text)
        if speed then
            currentSpeed = speed -- Update the current speed
            humanoid.WalkSpeed = currentSpeed
        end
    end)

    -- Toggle Anti Walk Lock
    AntiWalkLockButton.MouseButton1Click:Connect(function()
        antiWalkLockEnabled = not antiWalkLockEnabled
        AntiWalkLockButton.Text = antiWalkLockEnabled and "Anti Walk Lock: ON" or "Anti Walk Lock: OFF"

        while antiWalkLockEnabled do
            humanoid.WalkSpeed = (currentSpeed > 0) and currentSpeed or 16
            task.wait(0.1)
        end
    end)
end

-- Attach functionality to the character
setupCharacter(player.Character or player.CharacterAdded:Wait())

-- Ensure functionality persists after respawn
player.CharacterAdded:Connect(function(character)
    setupCharacter(character)
end)
