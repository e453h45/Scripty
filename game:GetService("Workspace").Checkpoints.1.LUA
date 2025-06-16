local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGui"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 280)
frame.Position = UDim2.new(0.5, -160, 0.5, -140)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Text = "Checkpoint Teleporter"
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Text = "X"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 2)
closeButton.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.Parent = frame
closeButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

local minimizeButton = Instance.new("TextButton")
minimizeButton.Text = "-"
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -70, 0, 2)
minimizeButton.BackgroundColor3 = Color3.fromRGB(120, 120, 0)
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 16
minimizeButton.Parent = frame
minimizeButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

local amountLabel = Instance.new("TextLabel")
amountLabel.Text = "Teleport Amount:"
amountLabel.Position = UDim2.new(0, 10, 0, 45)
amountLabel.Size = UDim2.new(0, 150, 0, 25)
amountLabel.BackgroundTransparency = 1
amountLabel.TextColor3 = Color3.new(1, 1, 1)
amountLabel.Font = Enum.Font.Gotham
amountLabel.TextSize = 14
amountLabel.Parent = frame

local amountBox = Instance.new("TextBox")
amountBox.Text = "100"
amountBox.Position = UDim2.new(0, 170, 0, 45)
amountBox.Size = UDim2.new(0, 140, 0, 25)
amountBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
amountBox.TextColor3 = Color3.new(1, 1, 1)
amountBox.Font = Enum.Font.Gotham
amountBox.TextSize = 14
amountBox.ClearTextOnFocus = false
amountBox.Parent = frame

local delayLabel = Instance.new("TextLabel")
delayLabel.Text = "Delay (seconds):"
delayLabel.Position = UDim2.new(0, 10, 0, 80)
delayLabel.Size = UDim2.new(0, 150, 0, 25)
delayLabel.BackgroundTransparency = 1
delayLabel.TextColor3 = Color3.new(1, 1, 1)
delayLabel.Font = Enum.Font.Gotham
delayLabel.TextSize = 14
delayLabel.Parent = frame

local delayBox = Instance.new("TextBox")
delayBox.Text = "0.5"
delayBox.Position = UDim2.new(0, 170, 0, 80)
delayBox.Size = UDim2.new(0, 140, 0, 25)
delayBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
delayBox.TextColor3 = Color3.new(1, 1, 1)
delayBox.Font = Enum.Font.Gotham
delayBox.TextSize = 14
delayBox.ClearTextOnFocus = false
delayBox.Parent = frame

local startButton = Instance.new("TextButton")
startButton.Text = "Start Teleporting"
startButton.Position = UDim2.new(0, 10, 0, 120)
startButton.Size = UDim2.new(1, -20, 0, 40)
startButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
startButton.TextColor3 = Color3.new(1, 1, 1)
startButton.Font = Enum.Font.GothamBold
startButton.TextSize = 16
startButton.Parent = frame

local stopButton = Instance.new("TextButton")
stopButton.Text = "Stop"
stopButton.Position = UDim2.new(0, 10, 0, 170)
stopButton.Size = UDim2.new(1, -20, 0, 40)
stopButton.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
stopButton.TextColor3 = Color3.new(1, 1, 1)
stopButton.Font = Enum.Font.GothamBold
stopButton.TextSize = 16
stopButton.Parent = frame

-- Variables
local isTeleporting = false

-- Get nearest checkpoint
local function getNearestCheckpoint()
	local checkpoints = workspace:FindFirstChild("Checkpoints")
	if not checkpoints then return nil end

	local nearest
	local minDist = math.huge
	local hrp = character:WaitForChild("HumanoidRootPart")

	for _, checkpoint in pairs(checkpoints:GetChildren()) do
		if checkpoint:IsA("BasePart") then
			local dist = (checkpoint.Position - hrp.Position).Magnitude
			if dist < minDist then
				minDist = dist
				nearest = checkpoint
			end
		end
	end
	return nearest
end

-- Start teleport
startButton.MouseButton1Click:Connect(function()
	local count = tonumber(amountBox.Text)
	local delayTime = tonumber(delayBox.Text)
	if not count or delayTime == nil then
		warn("Enter valid numbers.")
		return
	end

	local checkpoints = workspace:FindFirstChild("Checkpoints")
	if not checkpoints then
		warn("Checkpoints folder not found.")
		return
	end

	local nearest = getNearestCheckpoint()
	if not nearest then
		warn("No nearest checkpoint found.")
		return
	end

	local startIndex = tonumber(nearest.Name)
	if not startIndex then
		warn("Checkpoint name must be a number.")
		return
	end

	isTeleporting = true

	local function doTeleport(i)
		local cp = checkpoints:FindFirstChild(tostring(i))
		if cp and cp:IsA("BasePart") then
			character = player.Character or player.CharacterAdded:Wait()
			if character:FindFirstChild("HumanoidRootPart") then
				character:MoveTo(cp.Position + Vector3.new(0, 5, 0))
			end
		end
	end

	if delayTime == 0 then
		-- Frame-based teleporting (every render frame)
		local currentIndex = startIndex
		local connection
		connection = RunService.Heartbeat:Connect(function()
			if not isTeleporting or currentIndex >= startIndex + count then
				connection:Disconnect()
				isTeleporting = false
				return
			end
			doTeleport(currentIndex)
			currentIndex += 1
		end)
	else
		-- Normal timed teleporting
		task.spawn(function()
			for i = startIndex, startIndex + count - 1 do
				if not isTeleporting then break end
				doTeleport(i)
				task.wait(delayTime)
			end
			isTeleporting = false
		end)
	end
end)

-- Stop button logic
stopButton.MouseButton1Click:Connect(function()
	isTeleporting = false
end)
