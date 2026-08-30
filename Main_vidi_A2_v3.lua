--========================================================--
--         TPS_VD_Auto_Generator.lua (FIXED)             --
--========================================================--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--========================================================--
-- SETTINGS & STATES
--========================================================--

local Enabled = false
local Mode = "SUCCESS" -- SUCCESS, NEUTRAL, INSTANT
local TriggerDelay = 0.05
local LastTrigger = 0
local Busy = false

local CurrentGenerator = nil
local CurrentGeneratorPoint = nil

--========================================================--
-- REMOVE OLD UI (MENCEGAH DUPLIKAT)
--========================================================--

pcall(function()
	local old = PlayerGui:FindFirstChild("TPS_VD_AutoGenerator")
	if old then
		old:Destroy()
	end
end)

--========================================================--
-- UI SETUP
--========================================================--

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TPS_VD_AutoGenerator"
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
Title.Text = "TPS VD Auto Generator"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
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
-- DRAG GUI LOGIC
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
-- REFERENCES & EVENT CAPTURE
--========================================================--

local SkillCheckPromptGui = nil
local Check = nil
local Line = nil
local Goal = nil
local ActionButton = nil
local SkillCheckResultEvent = nil

local function RefreshReferences()
	pcall(function()
		SkillCheckPromptGui = PlayerGui:WaitForChild("SkillCheckPromptGui", 1)
		if SkillCheckPromptGui then
			Check = SkillCheckPromptGui:WaitForChild("Check", 1)
			if Check then
				Line = Check:WaitForChild("Line", 1)
				Goal = Check:WaitForChild("Goal", 1)
			end
		end

		local SurvivorMob = PlayerGui:WaitForChild("Survivor-mob", 1)
		if SurvivorMob then
			local Controls = SurvivorMob:WaitForChild("Controls", 1)
			if Controls then
				ActionButton = Controls:WaitForChild("action", 1)
			end
		end

		SkillCheckResultEvent = ReplicatedStorage:WaitForChild("Remotes", 1)
			:WaitForChild("Generator", 1)
			:WaitForChild("SkillCheckResultEvent", 1)
	end)
end

RefreshReferences()

pcall(function()
	local GeneratorEvent = ReplicatedStorage.Remotes.Generator:WaitForChild("SkillCheckEvent")
	GeneratorEvent.OnClientEvent:Connect(function(gen, genPoint)
		CurrentGenerator = gen
		CurrentGeneratorPoint = genPoint
		Busy = false -- Reset status sibuk saat skill check baru mulai
	end)
end)

task.spawn(function()
	while ScreenGui.Parent do
		if not Check or not Line or not Goal or not ActionButton then
			RefreshReferences()
		end
		task.wait(1)
	end
end)

--========================================================--
-- EXECUTE ACTION
--========================================================--

local function ExecuteAction(resultType, scoreValue)
	if Busy then return end
	local Now = os.clock()
	if Now - LastTrigger < TriggerDelay then return end
	
	Busy = true
	LastTrigger = Now

	pcall(function()
		if ActionButton and ActionButton:IsA("GuiButton") then
			ActionButton:Activate()
		end
	end)

	pcall(function()
		if SkillCheckResultEvent then
			SkillCheckResultEvent:FireServer(
				resultType,
				scoreValue,
				CurrentGenerator,
				CurrentGeneratorPoint
			)
		end
	end)

	task.delay(0.15, function()
		Busy = false
	end)
end

--========================================================--
-- RUNSERVICE SCANNER
--========================================================--

local LastVisibleState = false

RunService.RenderStepped:Connect(function()
	if not Enabled then 
		LastVisibleState = false
		return 
	end
	
	if not Check or not Line or not Goal then return end
	
	local IsVisible = Check.Visible

	if IsVisible and not LastVisibleState then
		-- Begitu skill check muncul di layar
		Busy = false
	end
	LastVisibleState = IsVisible

	if not IsVisible then return end
	if Busy then return end

	local LineRot = tonumber(Line.Rotation) or 0
	local GoalRot = tonumber(Goal.Rotation) or 0

	local SuccessMin = GoalRot + 102
	local SuccessMax = GoalRot + 116
	local NeutralMin = GoalRot + 116
	local NeutralMax = GoalRot + 159

	if Mode == "INSTANT" then
		Line.Rotation = GoalRot + 109
		ExecuteAction("success", 1)

	elseif Mode == "SUCCESS" then
		if LineRot >= SuccessMin and LineRot <= SuccessMax then
			ExecuteAction("success", 1)
		end

	elseif Mode == "NEUTRAL" then
		if LineRot > NeutralMin and LineRot <= NeutralMax then
			ExecuteAction("neutral", 0)
		end
	end
end)

--========================================================--
-- UI HANDLERS
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

Toggle.MouseButton1Click:Connect(function()
	Enabled = not Enabled
	Busy = false
	UpdateUI()
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

LocalPlayer.CharacterAdded:Connect(function()
	Busy = false
	task.wait(1)
	RefreshReferences()
end)

UpdateUI()
print("TPS_VD_Auto_Generator Fixed Loaded!")
