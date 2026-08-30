--========================================================--
--         VD • AUTO GENERATOR v4 (WITH UI)               --
--========================================================--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--========================================================--
-- REMOTES & REFERENCES
--========================================================--

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GeneratorRemotes = Remotes:WaitForChild("Generator")
local SkillCheckResultEvent = GeneratorRemotes:WaitForChild("SkillCheckResultEvent")

--========================================================--
-- SETTINGS & STATE
--========================================================--

local Enabled = false
local Mode = "SUCCESS" -- Pilihan: SUCCESS, NEUTRAL, INSTANT

local TriggerDelay = 0.035
local LastTrigger = 0
local Busy = false

--========================================================--
-- REMOVE OLD UI
--========================================================--

pcall(function()
	local old = PlayerGui:FindFirstChild("VD_AutoGenerator")
	if old then
		old:Destroy()
	end
end)

--========================================================--
-- UI SETUP (MENU UTAMA)
--========================================================--

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VD_AutoGenerator"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 210, 0, 155)
Main.Position = UDim2.new(0.5, -105, 0.25, 0)
Main.BackgroundColor3 = Color3.fromRGB(22, 22, 27)
Main.BorderSizePixel = 0
Main.Active = true
Main.Visible = true
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 1.5
Stroke.Color = Color3.fromRGB(80, 80, 90)
Stroke.Parent = Main

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -10, 0, 30)
Title.Position = UDim2.new(0, 5, 0, 3)
Title.BackgroundTransparency = 1
Title.Text = "AUTO GENERATOR v4"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

-- Toggle Button
local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(1, -20, 0, 34)
Toggle.Position = UDim2.new(0, 10, 0, 38)
Toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
Toggle.BorderSizePixel = 0
Toggle.Text = "AUTO GENERATOR : OFF"
Toggle.TextColor3 = Color3.fromRGB(255, 90, 90)
Toggle.TextSize = 13
Toggle.Font = Enum.Font.GothamBold
Toggle.Parent = Main

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 7)
ToggleCorner.Parent = Toggle

-- Mode Button
local ModeButton = Instance.new("TextButton")
ModeButton.Size = UDim2.new(1, -20, 0, 34)
ModeButton.Position = UDim2.new(0, 10, 0, 78)
ModeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
ModeButton.BorderSizePixel = 0
ModeButton.Text = "MODE : SUCCESS"
ModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeButton.TextSize = 13
ModeButton.Font = Enum.Font.GothamBold
ModeButton.Parent = Main

local ModeCorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0, 7)
ModeCorner.Parent = ModeButton

-- Status Label
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 25)
Status.Position = UDim2.new(0, 10, 0, 120)
Status.BackgroundTransparency = 1
Status.Text = "Status : OFF"
Status.TextColor3 = Color3.fromRGB(170, 170, 170)
Status.TextSize = 11
Status.Font = Enum.Font.Gotham
Status.Parent = Main

--========================================================--
-- DRAG GUI LOGIC (BISA DIGESER)
--========================================================--

local Dragging = false
local DragStart, StartPosition

Title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		Dragging = true
		DragStart = input.Position
		StartPosition = Main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				Dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not Dragging then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		local Delta = input.Position - DragStart
		Main.Position = UDim2.new(
			StartPosition.X.Scale, StartPosition.X.Offset + Delta.X,
			StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y
		)
	end
end)

--========================================================--
-- REFERENCES & AUTOMATION LOGIC
--========================================================--

local SkillCheckGui = PlayerGui:WaitForChild("SkillCheckPromptGui")
local Check = SkillCheckGui:WaitForChild("Check")
local Line = Check:WaitForChild("Line")
local Goal = Check:WaitForChild("Goal")

local function GetElements()
	pcall(function()
		SkillCheckGui = PlayerGui:FindFirstChild("SkillCheckPromptGui")
		if SkillCheckGui then
			Check = SkillCheckGui:FindFirstChild("Check")
			if Check then
				Line = Check:FindFirstChild("Line")
				Goal = Check:FindFirstChild("Goal")
			end
		end
	end)
end

RunService.RenderStepped:Connect(function()
	if not Enabled then return end
	if not Check or not Line or not Goal then
		GetElements()
		return
	end

	if not Check.Visible then return end
	if Busy then return end

	local Now = os.clock()
	if Now - LastTrigger < TriggerDelay then return end

	local LineRot = tonumber(Line.Rotation) or 0
	local GoalRot = tonumber(Goal.Rotation) or 0

	local SuccessMin = 102 + GoalRot
	local SuccessMax = 116 + GoalRot
	local NeutralMin = 116 + GoalRot
	local NeutralMax = 159 + GoalRot

	if Mode == "INSTANT" then
		Busy = true
		LastTrigger = Now

		Line.Rotation = GoalRot + 109

		pcall(function()
			SkillCheckResultEvent:FireServer("success", 1, 0, 0)
		end)

		task.delay(0.1, function()
			Busy = false
		end)

	elseif Mode == "SUCCESS" then
		if LineRot >= SuccessMin and LineRot <= SuccessMax then
			Busy = true
			LastTrigger = Now

			pcall(function()
				SkillCheckResultEvent:FireServer("success", 1, 0, 0)
			end)

			task.delay(0.08, function()
				Busy = false
			end)
		end

	elseif Mode == "NEUTRAL" then
		if LineRot > NeutralMin and LineRot <= NeutralMax then
			Busy = true
			LastTrigger = Now

			pcall(function()
				SkillCheckResultEvent:FireServer("neutral", 0, 0, 0)
			end)

			task.delay(0.08, function()
				Busy = false
			end)
		end
	end
end)

--========================================================--
-- UI BUTTON & HOTKEY HANDLERS
--========================================================--

local function UpdateUI()
	if Enabled then
		Toggle.Text = "AUTO GENERATOR : ON"
		Toggle.TextColor3 = Color3.fromRGB(90, 255, 120)
		Status.Text = "Status : " .. Mode
		Status.TextColor3 = Color3.fromRGB(100, 255, 130)
	else
		Toggle.Text = "AUTO GENERATOR : OFF"
		Toggle.TextColor3 = Color3.fromRGB(255, 90, 90)
		Status.Text = "Status : OFF"
		Status.TextColor3 = Color3.fromRGB(170, 170, 170)
	end
	ModeButton.Text = "MODE : " .. Mode
end

local function ToggleBot()
	Enabled = not Enabled
	Busy = false
	UpdateUI()
end

Toggle.MouseButton1Click:Connect(ToggleBot)

-- Hotkey: Tekan tombol INSERT di keyboard untuk ON/OFF cepat
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
		ToggleBot()
	end
end)

local Modes = {"SUCCESS", "NEUTRAL", "INSTANT"}
local ModeIndex = 1

ModeButton.MouseButton1Click:Connect(function()
	ModeIndex += 1
	if ModeIndex > #Modes then
		ModeIndex = 1
	end
	Mode = Modes[ModeIndex]
	Busy = false
	UpdateUI()
end)

-- Initial Load
UpdateUI()
print("VD • Auto Generator v4 with UI Loaded!")
