--// Prevent double execution
if _G.NoclipScriptLoaded then
	warn("[Script Already loaded.")
	return
end
_G.NoclipScriptLoaded = true

--// Load external script
pcall(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/e453h45/Scripty/refs/heads/main/fly.lua"))()
end)

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--// Vars
local Clip = true
local Noclipping = nil
local floatName = "FloatName" -- Change this to match the name of your float part if needed

--// Command system
local cmdlist = {}

local function addcmd(cmd, aliases, func)
	cmdlist[cmd:lower()] = func
	for _, alias in ipairs(aliases) do
		cmdlist[alias:lower()] = func
	end
end

local function execCmd(text)
	local args = {}
	for word in text:gmatch("%S+") do
		table.insert(args, word)
	end
	local command = args[1] and args[1]:lower() or ""
	table.remove(args, 1)
	if cmdlist[command] then
		cmdlist[command](args, LocalPlayer)
	end
end

local function notify(title, text)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = 3
		})
	end)
end

--// Noclip Command
addcmd("noclip", {}, function(args, speaker)
	Clip = false
	wait(0.1)
	local function NoclipLoop()
		if not Clip and speaker.Character then
			for _, child in pairs(speaker.Character:GetDescendants()) do
				if child:IsA("BasePart") and child.CanCollide and child.Name ~= floatName then
					child.CanCollide = false
				end
			end
		end
	end
	Noclipping = RunService.Stepped:Connect(NoclipLoop)
	if not (args[1] and args[1]:lower() == "nonotify") then
		notify("Noclip", "Noclip Enabled")
	end
end)

--// Clip Command
addcmd("clip", {"unnoclip"}, function(args, speaker)
	if Noclipping then
		Noclipping:Disconnect()
	end
	Clip = true
	if not (args[1] and args[1]:lower() == "nonotify") then
		notify("Noclip", "Noclip Disabled")
	end
end)

--// Toggle Command
addcmd("togglenoclip", {}, function(args, speaker)
	if Clip then
		execCmd("noclip")
	else
		execCmd("clip")
	end
end)

--// Chat Handler
LocalPlayer.Chatted:Connect(function(msg)
	if msg:sub(1, 1) == ";" then
		local args = {}
		for word in msg:sub(2):gmatch("%S+") do
			table.insert(args, word)
		end
		local command = args[1] and args[1]:lower() or ""
		table.remove(args, 1)
		if cmdlist[command] then
			cmdlist[command](args, LocalPlayer)
		end
	end
end)
