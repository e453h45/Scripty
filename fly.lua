-- Prevent multiple executions
if _G.FlyScriptLoaded then
    print("already loaded!")
    return
end
_G.FlyScriptLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local IYMouse
local flyKeyDown, flyKeyUp

local FLYING = false
local QEfly = true
local iyflyspeed = 1
local vehicleflyspeed = 1

-- Helper functions
local function getRoot(character)
	return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
end

local function isNumber(str)
	return tonumber(str) ~= nil
end

-- Fly function for PC
function sFLY(vfly)
	repeat task.wait() until Players.LocalPlayer and Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character) and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	repeat task.wait() until IYMouse
	if flyKeyDown then flyKeyDown:Disconnect() end
	if flyKeyUp then flyKeyUp:Disconnect() end

	local T = getRoot(Players.LocalPlayer.Character)
	local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local SPEED = 0

	local function FLY()
		FLYING = true
		local BG = Instance.new('BodyGyro')
		local BV = Instance.new('BodyVelocity')
		BG.P = 9e4
		BG.Parent = T
		BV.Parent = T
		BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		BG.cframe = T.CFrame
		BV.velocity = Vector3.new(0, 0, 0)
		BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
		task.spawn(function()
			repeat task.wait()
				if not vfly and Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
					Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
				end
				if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
					SPEED = 50
				elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
					SPEED = 0
				end
				if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
					BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
					lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
				elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
					BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
				else
					BV.velocity = Vector3.new(0, 0, 0)
				end
				BG.cframe = workspace.CurrentCamera.CoordinateFrame
			until not FLYING
			CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			SPEED = 0
			BG:Destroy()
			BV:Destroy()
			if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
				Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
			end
		end)
	end

	flyKeyDown = IYMouse.KeyDown:Connect(function(KEY)
		KEY = KEY:lower()
		if KEY == 'w' then
			CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
		elseif KEY == 's' then
			CONTROL.B = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif KEY == 'a' then
			CONTROL.L = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif KEY == 'd' then 
			CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
		elseif QEfly and KEY == 'e' then
			CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed)*2
		elseif QEfly and KEY == 'q' then
			CONTROL.E = -(vfly and vehicleflyspeed or iyflyspeed)*2
		end
		pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Track end)
	end)

	flyKeyUp = IYMouse.KeyUp:Connect(function(KEY)
		KEY = KEY:lower()
		if KEY == 'w' then CONTROL.F = 0
		elseif KEY == 's' then CONTROL.B = 0
		elseif KEY == 'a' then CONTROL.L = 0
		elseif KEY == 'd' then CONTROL.R = 0
		elseif KEY == 'e' then CONTROL.Q = 0
		elseif KEY == 'q' then CONTROL.E = 0
		end
	end)

	FLY()
end

function NOFLY()
	FLYING = false
	if flyKeyDown then flyKeyDown:Disconnect() end
	if flyKeyUp then flyKeyUp:Disconnect() end
	if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
		Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
	end
	pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

-- Command handler
local function addcmd(cmd, aliases, func)
	-- This is a simple command handler stub, replace with your own if needed
	local cmdlist = {}
	cmdlist[cmd] = func
	for _, alias in ipairs(aliases) do
		cmdlist[alias] = func
	end
	Players.LocalPlayer.Chatted:Connect(function(msg)
		if msg:sub(1,1) == ";" then
			local args = {}
			for word in msg:sub(2):gmatch("%S+") do
				table.insert(args, word)
			end
			local command = args[1] and args[1]:lower() or ""
			table.remove(args, 1)
			if cmdlist[command] then
				func(args, Players.LocalPlayer)
			end
		end
	end)
end

-- Fly command
addcmd('fly', {}, function(args, speaker)
	if not IYMouse then
		IYMouse = Players.LocalPlayer:GetMouse()
	end
	NOFLY()
	task.wait(0.1)
	if args[1] and isNumber(args[1]) then
		iyflyspeed = tonumber(args[1])
	else
		iyflyspeed = 1
	end
	sFLY()
end)

-- Unfly command
addcmd('unfly', {}, function(args, speaker)
	NOFLY()
end)

-- Fly speed command
addcmd('flyspeed', {'flysp'}, function(args, speaker)
	local speed = args[1] or "1"
	if isNumber(speed) then
		iyflyspeed = tonumber(speed)
	end
end)

-- Function to show notification GUI for flygui
local function showFlyGuiNotification()
	-- Remove old if exists
	local existingGui = game.CoreGui:FindFirstChild("FlyGuiNotification")
	if existingGui then existingGui:Destroy() end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FlyGuiNotification"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = game:GetService("CoreGui")

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 500, 0, 120)
    frame.Position = UDim2.new(0.6, -200, 0, 0)  -- At top edge, centered horizontally
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, -20, 1, -20)
	textLabel.Position = UDim2.new(0, 10, 0, 10)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.TextWrapped = true
	textLabel.Text = "Loaded Fly GUI V3.\nIt can be detected on some games.\nFor less detection, use ;fly instead."
	textLabel.Parent = frame

	task.delay(10, function()
		if screenGui then
			screenGui:Destroy()
		end
	end)
end

-- Flygui command: loads remote fly gui and shows notification
addcmd('flygui', {}, function(args, speaker)
	loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
	showFlyGuiNotification()
end)
